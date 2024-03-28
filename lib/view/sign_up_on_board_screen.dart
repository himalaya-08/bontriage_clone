import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:mobile/blocs/WelcomeOnBoardProfileBloc.dart';
import 'package:mobile/models/LocalQuestionnaire.dart';
import 'package:mobile/models/OnBoardSelectOptionModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardFirstStepQuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserProgressDataModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/NetworkErrorScreen.dart';
import 'package:mobile/view/PartOneOnBoardBottomView.dart';
import 'package:mobile/view/on_board_chat_bubble.dart';
import 'package:mobile/view/on_board_select_options.dart';
import 'package:mobile/view/sign_up_age_screen.dart';
import 'package:mobile/view/sign_up_location_services.dart';
import 'package:provider/provider.dart';

import 'SignUpAgeInputScreen.dart';
import 'sign_up_name_screen.dart';

class SignUpOnBoardScreen extends StatefulWidget {
  @override
  _SignUpOnBoardScreenState createState() => _SignUpOnBoardScreenState();
}

class _SignUpOnBoardScreenState extends State<SignUpOnBoardScreen> {
  bool isVolumeOn = true;
  bool isEndOfOnBoard = false;
  double _progressPercent = 0;
  int _currentPageIndex = 0;
  late WelcomeOnBoardProfileBloc welcomeOnBoardProfileBloc;

  PageController _pageController = PageController(
    initialPage: 0,
  );

  late List<SignUpOnBoardFirstStepQuestionsModel> _pageViewWidgetList;

  List<Questions> currentQuestionListData = [];

  SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel =
      SignUpOnBoardSelectedAnswersModel();

  int currentScreenPosition = 0;

  bool _isButtonClicked = false;
  bool _isAlreadyDataFiltered = false;
  MediaQueryData? mediaQueryData;
  List<int> _backQuestionIndexList = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    currentQuestionListData.add(Questions());
    welcomeOnBoardProfileBloc = WelcomeOnBoardProfileBloc();
    signUpOnBoardSelectedAnswersModel.eventType = Constant.zeroEventStep;
    signUpOnBoardSelectedAnswersModel.selectedAnswers = [];
    _pageViewWidgetList = [
      SignUpOnBoardFirstStepQuestionsModel(
          questions: Constant.firstBasics, questionsWidget: Container())
    ];

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Utils.showApiLoaderDialog(context);
      getCurrentUserPosition();
    });

    Utils.setAnalyticsCurrentScreen(Constant.partOneOnBoardAssessmentScreen, context);
  }

  @override
  void didUpdateWidget(SignUpOnBoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _pageController.dispose();
    welcomeOnBoardProfileBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //mediaQueryData = MediaQuery.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: _onBackPressed,
      child: Scaffold(
        backgroundColor: Constant.backgroundColor,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: StreamBuilder<dynamic>(
                stream: welcomeOnBoardProfileBloc.albumDataStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (!_isAlreadyDataFiltered) {
                      Utils.closeApiLoaderDialog(context);
                      addFilteredQuestionListData(snapshot.data);
                    }
                    return ChangeNotifierProvider(
                      create: (_) => SignupOnboardErrorInfo(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OnBoardChatBubble(
                            chatBubbleText:
                                _pageViewWidgetList[_currentPageIndex].questions!,
                            isEndOfOnBoard: isEndOfOnBoard,
                            closeButtonFunction: () {
                              Utils.navigateToExitScreen(context);
                            },
                          ),
                          SizedBox(height: 40),
                          Expanded(
                              child: PageView.builder(
                            controller: _pageController,
                            itemCount: _pageViewWidgetList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _pageViewWidgetList[index].questionsWidget;
                            },
                            physics: NeverScrollableScrollPhysics(),
                          )),
                          SizedBox(
                            height: 20,
                          ),
                          Consumer<SignupOnboardErrorInfo>(
                            builder: (context, data, child){
                              return PartOneOnBoardBottomView(
                                currentPageIndex: _currentPageIndex,
                                progressPercent: _progressPercent,
                                backButtonFunction: () {
                                  data.updateErrorString();
                                  _onBackPressed(false);
                                },
                                nextButtonFunction: () {
                                  if (!_isButtonClicked) {
                                    _isButtonClicked = true;
                                    if (Utils.validationForOnBoard(
                                        signUpOnBoardSelectedAnswersModel
                                            .selectedAnswers!,
                                        currentQuestionListData[_currentPageIndex])) {
                                      data.updateErrorString();
                                      setState(() {
                                        if (_progressPercent == 0.66) {
                                          /*     welcomeOnBoardProfileBloc
                                                  .sendSignUpFirstStepData(
                                                      signUpOnBoardSelectedAnswersModel);*/
                                          int? backQuestionIndex = _backQuestionIndexList.firstWhereOrNull((element) => element == _currentPageIndex);
                                          if(backQuestionIndex == null)
                                            _backQuestionIndexList.add(_currentPageIndex);
                                          moveToNextScreen();
                                        } else {
                                          //_currentPageIndex++;
                                          _backQuestionIndexList.add(_currentPageIndex);
                                          _currentPageIndex = Utils.fetchQuestionTag(currentPageIndex: _currentPageIndex, currentQuestionListData: currentQuestionListData, signUpOnBoardSelectedAnswersModel: signUpOnBoardSelectedAnswersModel);

                                          if (_currentPageIndex !=
                                              _pageViewWidgetList.length - 1)
                                            _progressPercent += 0.094;
                                          else {
                                            _progressPercent = 0.66;
                                          }

                                          _pageController.animateToPage(
                                              _currentPageIndex,
                                              duration: Duration(milliseconds: 1),
                                              curve: Curves.easeIn);

                                          getCurrentQuestionTag(_currentPageIndex);
                                        }
                                      });
                                    }
                                    else{
                                      if(snapshot.data[_currentPageIndex-1].questionType == Constant.QuestionSingleType || snapshot.data[_currentPageIndex-1].questionType == Constant.QuestionMultiType){
                                        data.setErrorString = 'Please select atleast one value!';
                                      }
                                      else{
                                        data.setErrorString = 'Please enter a value!';
                                      }
                                    }
                                    Future.delayed(Duration(milliseconds: 350), () {
                                      _isButtonClicked = false;
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
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
                  } else {
                    /*return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ApiLoaderScreen(),
                      ],
                    );*/
                    return Container();
                  }
                })),
      ),
    );
  }

  addFilteredQuestionListData(List<Questions>? questionListData) {
    if (questionListData != null) {
      currentQuestionListData.addAll(questionListData);
      questionListData.forEach((element) {
        switch (element.questionType) {
          case Constant.QuestionNumberType:
            //if the current element tag is profileAgeTag then the cupertino scrollview is shown, if not then a slider is shown
            //to enable user to input their age in the signup onboard age screen
            if(element.tag == Constant.profileAgeTag){
              //year & month input
              _pageViewWidgetList.add(SignUpOnBoardFirstStepQuestionsModel(
                  questions: element.helpText,
                  questionsWidget: SignUpAgeInputScreen(
                    minYearValue: element.min!.toDouble(),
                    maxYearValue: element.max!.toDouble(),
                    currentTag: element.tag!,
                    selectedAnswerListData:
                    signUpOnBoardSelectedAnswersModel.selectedAnswers!,
                    selectedAnswerCallBack: (currentTag, selectedUserAnswer) {
                      print(currentTag + selectedUserAnswer);
                      selectedAnswerListData(currentTag, selectedUserAnswer);
                    },
                    uiHints: element.uiHints!,
                  )));
            }
            else{
              //slider
              _pageViewWidgetList.add(SignUpOnBoardFirstStepQuestionsModel(
                  questions: element.helpText,
                  questionsWidget: SignUpAgeScreen(
                    sliderValue: element.min!.toDouble(),
                    sliderMinValue: element.min!.toDouble(),
                    sliderMaxValue: element.max!.toDouble(),
                    minText: element.min.toString(),
                    maxText: element.max.toString(),
                    labelText: Constant.blankString,
                    currentTag: element.tag!,
                    selectedAnswerListData:
                    signUpOnBoardSelectedAnswersModel.selectedAnswers,
                    selectedAnswerCallBack: (currentTag, selectedUserAnswer) {
                      print(currentTag + selectedUserAnswer);
                      selectedAnswerListData(currentTag, selectedUserAnswer);
                    },
                    uiHints: element.uiHints!,
                  )));
            }


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
                 // errorString: _errorString
                )
            ));
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
          case Constant.QuestionLocationType:
            _pageViewWidgetList.add(SignUpOnBoardFirstStepQuestionsModel(
                questions: element.helpText,
                questionsWidget: SignUpLocationServices(
                  question: element,
                  selectedAnswerListData:
                      signUpOnBoardSelectedAnswersModel.selectedAnswers!,
                  selectedAnswerCallBack: selectedAnswerListData,
                  removeSelectedAnswerCallback: _removeDataFromSelectedAnswer,
                )));
            break;
        }
        _isAlreadyDataFiltered = true;
      });

      _currentPageIndex = currentScreenPosition;
      _progressPercent = (_currentPageIndex + 1) * 0.094;
      _pageController = PageController(initialPage: currentScreenPosition);
      /*_pageController.animateToPage(currentScreenPosition,
          duration: Duration(milliseconds: 1), curve: Curves.easeIn);*/

      print(questionListData);
    }
  }

  void requestService() async {
    List<LocalQuestionnaire> localQuestionnaireData =
        await SignUpOnBoardProviders.db
            .getQuestionnaire(Constant.zeroEventStep);
    if (localQuestionnaireData.length > 0) {
      signUpOnBoardSelectedAnswersModel = await welcomeOnBoardProfileBloc
          .fetchDataFromLocalDatabase(localQuestionnaireData);
    } else {
      welcomeOnBoardProfileBloc.fetchSignUpFirstStepData(context);
    }
  }

  void getCurrentUserPosition() async {
    UserProgressDataModel? userProgressModel =
        await SignUpOnBoardProviders.db.getUserProgress();

    if (userProgressModel != null && userProgressModel.step == Constant.zeroEventStep) {
      currentScreenPosition = userProgressModel.userScreenPosition!;
      if(userProgressModel.backQuestionIndexList != null && userProgressModel.backQuestionIndexList!.length > 0)
        _backQuestionIndexList.addAll(userProgressModel.backQuestionIndexList!);
      debugPrint(_backQuestionIndexList.toString());
      debugPrint(userProgressModel.toString());
    }
    getCurrentQuestionTag(currentScreenPosition);
    requestService();
  }

  void getCurrentQuestionTag(int currentPageIndex) async {
    var isDataBaseExists = await SignUpOnBoardProviders.db.isDatabaseExist();
    UserProgressDataModel userProgressDataModel = UserProgressDataModel();

    if (!isDataBaseExists) {
      userProgressDataModel =
          await welcomeOnBoardProfileBloc.fetchSignUpFirstStepData(context);
    } else {
      int? userProgressDataCount = await SignUpOnBoardProviders.db
          .checkUserProgressDataAvailable(
              SignUpOnBoardProviders.TABLE_USER_PROGRESS);
      userProgressDataModel.userId = Constant.userID;
      userProgressDataModel.step = Constant.zeroEventStep;
      userProgressDataModel.userScreenPosition = currentPageIndex;
      userProgressDataModel.questionTag = '';
      userProgressDataModel.backQuestionIndexList = _backQuestionIndexList;

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

  void _removeDataFromSelectedAnswer(String questionTag) {
    signUpOnBoardSelectedAnswersModel.selectedAnswers
        !.removeWhere((element) => element.questionTag == questionTag);
    updateSelectedAnswerDataOnLocalDatabase();
  }

  updateSelectedAnswerDataOnLocalDatabase() {
    var answerStringData =
        Utils.getStringFromJson(signUpOnBoardSelectedAnswersModel);
    LocalQuestionnaire localQuestionnaire = LocalQuestionnaire();
    localQuestionnaire.selectedAnswers = answerStringData;
    SignUpOnBoardProviders.db.updateSelectedAnswers(
        signUpOnBoardSelectedAnswersModel, Constant.zeroEventStep);
  }

  void moveToNextScreen() async {
    isEndOfOnBoard = true;
    TextToSpeechRecognition.speechToText("");
    List<SelectedAnswers> selectedAnswersList = [];
    _backQuestionIndexList.forEach((questionIndex) {
      String questionTag = currentQuestionListData[questionIndex].tag ?? '';
      SelectedAnswers? selectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull((element) => element.questionTag == questionTag);
      if(selectedAnswer != null)
        selectedAnswersList.add(selectedAnswer);
    });

    SelectedAnswers? locationSelectedAnswer = signUpOnBoardSelectedAnswersModel
        .selectedAnswers?.firstWhereOrNull((element) =>
    element.questionTag == 'profile.location');

    if(locationSelectedAnswer != null) {
      SelectedAnswers? locationAnswer = selectedAnswersList.firstWhereOrNull((element) => element.questionTag == 'profile.location');

      if (locationAnswer == null)
        selectedAnswersList.add(locationSelectedAnswer);
    }

    signUpOnBoardSelectedAnswersModel.selectedAnswers = selectedAnswersList;

    Utils.sendAnalyticsEvent(Constant.part1AssessmentCompleted, {
      'isCompleted': Constant.trueString,
    }, context);

    Navigator.pushReplacementNamed(
        context, Constant.onBoardHeadacheInfoScreenRouter);
  }

  void _onBackPressed(bool didPop) async {
    if (didPop)
      return;
    TextToSpeechRecognition.stopSpeech();
    if (!_isButtonClicked) {
      _isButtonClicked = true;
      if (_currentPageIndex == 0) {
        Future.delayed(Duration(milliseconds: 350), () {
          _isButtonClicked = false;
        });
        Utils.navigateToExitScreen(context);
      } else {
        setState(() {
          if (_currentPageIndex != 0) {
            _currentPageIndex = _backQuestionIndexList.last;
            _backQuestionIndexList.removeLast();
            _progressPercent = _currentPageIndex * 0.094;
            _pageController.animateToPage(_currentPageIndex,
                duration: Duration(milliseconds: 1), curve: Curves.easeIn);
          } else {
            _progressPercent = 0;
          }
        });
        Future.delayed(Duration(milliseconds: 350), () {
          _isButtonClicked = false;
        });
      }
    }
  }
}

class SignupOnboardErrorInfo extends ChangeNotifier{
  String _errorString = Constant.blankString;

  String get getErrorString => _errorString;

  set setErrorString(String err){
    _errorString = err;
    notifyListeners();
  }

  void updateErrorString() => _errorString = Constant.blankString;
}
