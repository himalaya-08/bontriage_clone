import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:mobile/blocs/SignUpOnBoardFirstStepBloc.dart';
import 'package:mobile/models/LocalQuestionnaire.dart';
import 'package:mobile/models/OnBoardSelectOptionModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardFirstStepQuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserProgressDataModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/view/sign_up_name_screen.dart';
import '../util/constant.dart';
import 'NetworkErrorScreen.dart';
import 'on_board_bottom_buttons.dart';
import 'on_board_chat_bubble.dart';
import 'on_board_select_options.dart';
import 'sign_up_age_screen.dart';

class PartOneOnBoardScreenTwo extends StatefulWidget {
  @override
  _PartOneOnBoardScreenStateTwo createState() =>
      _PartOneOnBoardScreenStateTwo();
}

class _PartOneOnBoardScreenStateTwo extends State<PartOneOnBoardScreenTwo> {
  SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel =
      SignUpOnBoardSelectedAnswersModel();

  int currentScreenPosition = 0;
  SignUpBoardFirstStepBloc? signUpBoardFirstStepBloc;
  List<Questions>? currentQuestionListData;

  PageController _pageController = PageController(
    initialPage: 0,
  );

  int _currentPageIndex = 0;
  double _progressPercent = 0.66;

  List<SignUpOnBoardFirstStepQuestionsModel> _pageViewWidgetList = [];
  bool isEndOfOnBoard = false;
  bool _isButtonClicked = false;

  bool isAlreadyDataFiltered = false;

  Future<bool> _onBackPressed() async{
    if(!_isButtonClicked) {
      _isButtonClicked = true;
      if (_currentPageIndex == 0) {
        Future.delayed(Duration(milliseconds: 350), () {
          _isButtonClicked = false;
        });
        return true;
      } else {
        setState(() {
          double stepOneProgress = 1 / _pageViewWidgetList.length;

          if (_currentPageIndex != 0) {
            _progressPercent -= stepOneProgress;
            _currentPageIndex--;
            _pageController.animateToPage(_currentPageIndex,
                duration: Duration(milliseconds: 1), curve: Curves.easeIn);
          }
        });
        Future.delayed(Duration(milliseconds: 350), () {
          _isButtonClicked = false;
        });
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    signUpBoardFirstStepBloc!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    signUpBoardFirstStepBloc = SignUpBoardFirstStepBloc();
    signUpOnBoardSelectedAnswersModel.eventType = Constant.firstEventStep;
    signUpOnBoardSelectedAnswersModel.selectedAnswers = [];

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Utils.showApiLoaderDialog(context);
      getCurrentUserPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Constant.backgroundColor,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: StreamBuilder<dynamic>(
          stream: signUpBoardFirstStepBloc!.albumDataStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (!isAlreadyDataFiltered) {
                Utils.closeApiLoaderDialog(context);
                addFilteredQuestionListData(snapshot.data);
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OnBoardChatBubble(
                    isEndOfOnBoard: isEndOfOnBoard,
                    chatBubbleText:
                        _pageViewWidgetList[_currentPageIndex].questions!,
                    closeButtonFunction: () {
                      Utils.navigateToExitScreen(context);
                    },
                  ),
                  Expanded(
                      child: PageView.builder(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _pageViewWidgetList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _pageViewWidgetList[index].questionsWidget;
                    },
                  )),
                  OnBoardBottomButtons(
                    progressPercent: _progressPercent,
                    backButtonFunction: () {
                      _onBackPressed();
                    },
                    currentIndex: _currentPageIndex,
                    nextButtonFunction: () {
                      if(!_isButtonClicked) {
                        _isButtonClicked = true;
                        if (Utils.validationForOnBoard(
                            signUpOnBoardSelectedAnswersModel.selectedAnswers!,
                            currentQuestionListData![_currentPageIndex])) {
                          setState(() {
                            double stepOneProgress = 1 /
                                _pageViewWidgetList.length;

                            if (_progressPercent == 1) {
                              sendToNextScreen();
                            } else {
                              _currentPageIndex++;

                              if (_currentPageIndex !=
                                  _pageViewWidgetList.length - 1)
                                _progressPercent += stepOneProgress;
                              else {
                                _progressPercent = 1;
                              }

                              _pageController.animateToPage(_currentPageIndex,
                                  duration: Duration(milliseconds: 1),
                                  curve: Curves.easeIn);
                            }
                            getCurrentQuestionTag(_currentPageIndex);
                          });
                        }
                        Future.delayed(Duration(milliseconds: 350), () {
                          _isButtonClicked = false;
                        });
                      }
                    },
                    onBoardPart: 1,
                  )
                ],
              );
            } else if (snapshot.hasError) {
              Utils.closeApiLoaderDialog(context);
              return NetworkErrorScreen(
                errorMessage: snapshot.error.toString(),
                tapToRetryFunction: () {
                  Utils.showApiLoaderDialog(context);
                  requestService();
                },
              );
            }else {
              return Container();
            }
          },
        )),
      ),
    );
  }

  void getCurrentUserPosition() async {
    UserProgressDataModel? userProgressModel =
        await SignUpOnBoardProviders.db.getUserProgress();
    if (userProgressModel != null &&
        userProgressModel.step == Constant.firstEventStep) {
      currentScreenPosition = userProgressModel.userScreenPosition!;
      print(userProgressModel);
    }
    getCurrentQuestionTag(currentScreenPosition);
    requestService();
  }

  void requestService() async {
    List<LocalQuestionnaire> localQuestionnaireData =
        await SignUpOnBoardProviders.db
            .getQuestionnaire(Constant.firstEventStep);
    if (localQuestionnaireData != null && localQuestionnaireData.length > 0) {
      signUpOnBoardSelectedAnswersModel = await signUpBoardFirstStepBloc
          !.fetchDataFromLocalDatabase(localQuestionnaireData);
    } else {
      signUpBoardFirstStepBloc!.fetchSignUpFirstStepData(context);
    }
  }

  void getCurrentQuestionTag(int currentPageIndex) async {
    var isDataBaseExists = await SignUpOnBoardProviders.db.isDatabaseExist();
    UserProgressDataModel userProgressDataModel = UserProgressDataModel();

    if (!isDataBaseExists) {
      userProgressDataModel =
          await signUpBoardFirstStepBloc!.fetchSignUpFirstStepData(context);
    } else {
      int? userProgressDataCount = await SignUpOnBoardProviders.db
          .checkUserProgressDataAvailable(
              SignUpOnBoardProviders.TABLE_USER_PROGRESS);
      userProgressDataModel.userId = Constant.userID;
      userProgressDataModel.step = Constant.firstEventStep;
      userProgressDataModel.userScreenPosition = currentPageIndex;
      userProgressDataModel.questionTag = (currentQuestionListData != null)
          ? currentQuestionListData![currentPageIndex].tag
          : '';

      if (userProgressDataCount == 0) {
        SignUpOnBoardProviders.db.insertUserProgress(userProgressDataModel);
      } else {
        SignUpOnBoardProviders.db.updateUserProgress(userProgressDataModel);
      }
    }
  }

  void selectedAnswerListData(String currentTag, String selectedUserAnswer) {
    SelectedAnswers? selectedAnswers;
    if (signUpOnBoardSelectedAnswersModel.selectedAnswers!.length > 0) {
      selectedAnswers = signUpOnBoardSelectedAnswersModel.selectedAnswers
          !.firstWhereOrNull((model) => model.questionTag == currentTag);
    }
    if (selectedAnswers != null) {
      selectedAnswers.answer = selectedUserAnswer;
    } else {
      signUpOnBoardSelectedAnswersModel.selectedAnswers!.add(
          SelectedAnswers(questionTag: currentTag, answer: selectedUserAnswer));
      print(signUpOnBoardSelectedAnswersModel.selectedAnswers);
    }
    updateSelectedAnswerDataOnLocalDatabase();
  }

  updateSelectedAnswerDataOnLocalDatabase() {
    var answerStringData =
        Utils.getStringFromJson(signUpOnBoardSelectedAnswersModel);
    LocalQuestionnaire localQuestionnaire = LocalQuestionnaire();
    localQuestionnaire.selectedAnswers = answerStringData;
    SignUpOnBoardProviders.db.updateSelectedAnswers(
        signUpOnBoardSelectedAnswersModel, Constant.firstEventStep);
  }

  addFilteredQuestionListData(List<Questions>? questionListData) {
    if (questionListData != null) {
      currentQuestionListData = questionListData;
      questionListData.forEach((element) {
        switch (element.questionType) {
          case Constant.QuestionNumberType:
            _pageViewWidgetList.add(SignUpOnBoardFirstStepQuestionsModel(
                questions: element.helpText,
                questionsWidget: SignUpAgeScreen(
                  sliderValue: element.min!.toDouble(),
                  sliderMinValue: element.min!.toDouble(),
                  sliderMaxValue: element.max!.toDouble(),
                  minText: element.min.toString(),
                  maxText: element.max.toString(),
                  labelText: "",
                  currentTag: element.tag!,
                  selectedAnswerListData:
                      signUpOnBoardSelectedAnswersModel.selectedAnswers,
                  selectedAnswerCallBack: (currentTag, selectedUserAnswer) {
                    print(currentTag + selectedUserAnswer);
                    selectedAnswerListData(currentTag, selectedUserAnswer);
                  },
                  uiHints: element.uiHints!,
                )));
            break;

          case Constant.QuestionTextType:
            _pageViewWidgetList.add(SignUpOnBoardFirstStepQuestionsModel(
                questions: element.helpText,
                questionsWidget: SignUpNameScreen(
                  tag: element.tag!,
                  helpText: element.helpText!,
                  selectedAnswerListData:
                      signUpOnBoardSelectedAnswersModel.selectedAnswers!,
                  selectedAnswerCallBack: (currentTag, selectedUserAnswer) {
                    print(currentTag + selectedUserAnswer);
                    selectedAnswerListData(currentTag, selectedUserAnswer);
                  },
                )));
            break;

          case Constant.QuestionSingleType:
            List<OnBoardSelectOptionModel> valuesListData = [];
            element.values!.forEach((element) {
              valuesListData.add(OnBoardSelectOptionModel(
                  optionId: element.valueNumber, optionText: element.text));
            });
            _pageViewWidgetList.add(SignUpOnBoardFirstStepQuestionsModel(
                questions: element.helpText,
                questionsWidget: OnBoardSelectOptions(
                  selectOptionList: valuesListData,
                  questionTag: element.tag!,
                  selectedAnswerListData:
                      signUpOnBoardSelectedAnswersModel.selectedAnswers!,
                  selectedAnswerCallBack: (currentTag, selectedUserAnswer) {
                    selectedAnswerListData(currentTag, selectedUserAnswer);
                  },
                )));
            break;
        }
        isAlreadyDataFiltered = true;
      });

      _currentPageIndex = currentScreenPosition;
      double stepOneProgress = 1 / _pageViewWidgetList.length;
      _progressPercent = (_currentPageIndex + 1) * stepOneProgress;
      _pageController = PageController(initialPage: currentScreenPosition);

      print(questionListData);
    }
  }

  void sendToNextScreen() async {
    isEndOfOnBoard = true;
    TextToSpeechRecognition.speechToText("");
    Navigator.pushReplacementNamed(
        context, Constant.signUpOnBoardPersonalizedHeadacheResultRouter);
  }
}
