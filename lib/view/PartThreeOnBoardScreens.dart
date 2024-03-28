import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:mobile/blocs/SignUpOnBoardThirdStepBloc.dart';
import 'package:mobile/models/LocalQuestionnaire.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardFirstStepQuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserProgressDataModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/sign_up_on_board_screen.dart';
import 'package:provider/provider.dart';

import 'NetworkErrorScreen.dart';
import 'SignUpBottomSheet.dart';
import 'on_board_bottom_buttons.dart';
import 'on_board_chat_bubble.dart';

class PartThreeOnBoardScreens extends StatefulWidget {
  @override
  _PartThreeOnBoardScreensState createState() =>
      _PartThreeOnBoardScreensState();
}

class _PartThreeOnBoardScreensState extends State<PartThreeOnBoardScreens> {
  PageController _pageController = PageController(
    initialPage: 0,
  );

  int _currentPageIndex = 0;
  double _progressPercent = 0;
  bool _isAlreadyDataFiltered = false;
  bool _isButtonClicked = false;

  List<SignUpOnBoardFirstStepQuestionsModel> _pageViewWidgetList = [];

  late SignUpOnBoardThirdStepBloc _signUpOnBoardThirdStepBloc;
  late SignUpOnBoardSelectedAnswersModel _signUpOnBoardSelectedAnswersModel;

  int currentScreenPosition = 0;
  List<Questions> _currentQuestionLists = [];

  var _filterQuestionsListData;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    _signUpOnBoardThirdStepBloc = SignUpOnBoardThirdStepBloc();

    _signUpOnBoardSelectedAnswersModel = SignUpOnBoardSelectedAnswersModel();
    _signUpOnBoardSelectedAnswersModel.eventType = Constant.thirdEventStep;
    _signUpOnBoardSelectedAnswersModel.selectedAnswers = [];

    _pageViewWidgetList = [];

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Utils.showApiLoaderDialog(context);
      _getCurrentUserPosition();
    });

    Utils.setAnalyticsCurrentScreen(Constant.partThreeOnBoardAssessmentScreen, context);
  }

  /// This method will be use for to get current position of the user. When he last time quit the application or click the close
  /// icon. We will fetch last position from Local database.
  void _getCurrentUserPosition() async {
    UserProgressDataModel? userProgressModel =
        await SignUpOnBoardProviders.db.getUserProgress();
    if (userProgressModel != null &&
        userProgressModel.step == Constant.thirdEventStep) {
      currentScreenPosition = userProgressModel.userScreenPosition!;
      print(userProgressModel);
    }
    _getCurrentQuestionTag(currentScreenPosition);

    requestService();
  }

  /// In this method we will hit the API of Second step of questions list.So if we have empty table into the database.
  /// then we hit the API and save the all questions data in to the database. if not then we will fetch the all data from the local
  /// database of respective table.
  void requestService() async {
    List<LocalQuestionnaire> localQuestionnaireData =
        await SignUpOnBoardProviders.db
            .getQuestionnaire(Constant.thirdEventStep);

    List<SelectedAnswers> selectedAnswerList = await _signUpOnBoardThirdStepBloc.fetchMyProfileData(context);

    if (localQuestionnaireData != null && localQuestionnaireData.length > 0) {
      _signUpOnBoardSelectedAnswersModel = await _signUpOnBoardThirdStepBloc.fetchDataFromLocalDatabase(localQuestionnaireData);

      debugPrint(_signUpOnBoardSelectedAnswersModel.toString());

      if (selectedAnswerList.isNotEmpty) {
        await SignUpOnBoardProviders.db
            .deleteOnBoardQuestionnaireProgress(Constant.thirdEventStep);
        getSignUpOnBoardSelectedAnswersModel(_signUpOnBoardSelectedAnswersModel, selectedAnswerList);
        localQuestionnaireData[0].selectedAnswers = jsonEncode(_signUpOnBoardSelectedAnswersModel.toJson());
      }
    } else {
      _signUpOnBoardThirdStepBloc.fetchSignUpOnBoardThirdStepData(Constant.clinicalImpressionShort3, context);

      if (selectedAnswerList.isNotEmpty) {
        _signUpOnBoardSelectedAnswersModel.selectedAnswers = selectedAnswerList;
      }
    }
  }

  void getSignUpOnBoardSelectedAnswersModel(SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel, List<SelectedAnswers> profileSelectedAnswers){
    for(SelectedAnswers selectedAnswer in signUpOnBoardSelectedAnswersModel.selectedAnswers ?? []){
      if(selectedAnswer.questionTag == Constant.headacheTriggerTag){
        selectedAnswer.answer = profileSelectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.headacheTriggerTag)?.answer;
      }
      else if(selectedAnswer.questionTag == Constant.headacheMedicationsTag){
        selectedAnswer.answer = profileSelectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.headacheMedicationsTag)?.answer;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            stream: _signUpOnBoardThirdStepBloc.signUpOnBoardThirdStepDataStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                debugPrint(snapshot.hasData.toString());
                if (!_isAlreadyDataFiltered) {
                  _filterQuestionsListData = snapshot.data;
                  Utils.closeApiLoaderDialog(context);
                  _addPageViewWidgets(snapshot.data);
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
                      Consumer<SignupOnboardErrorInfo>(
                        builder: (context, data, child){
                          return OnBoardBottomButtons(
                            progressPercent: _progressPercent,
                            currentIndex: _currentPageIndex,
                            backButtonFunction: () {
                              data.updateErrorString();
                              _onBackPressed();
                            },
                            nextButtonFunction: () {
                              _nextButtonPressed(data);
                            },
                            onBoardPart: 3,
                          );
                        },
                      )
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
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  /// This method is used to add widgets into Page View
  void _addPageViewWidgets(List<Questions> questionsList) {
    _currentQuestionLists = questionsList;
    questionsList.forEach((element) {
      if (element.questionType == Constant.QuestionMultiType) {
        _pageViewWidgetList.add(SignUpOnBoardFirstStepQuestionsModel(
          questions: element.helpText,
          questionsWidget: SignUpBottomSheet(
            isFromOnboard: true,
            question: element,
            selectAnswerCallback: _selectedAnswerListData,
            selectAnswerListData:
                _signUpOnBoardSelectedAnswersModel.selectedAnswers!,
          ),
        ));
      }
    });

    _isAlreadyDataFiltered = true;

    _currentPageIndex = currentScreenPosition;
    _progressPercent =
        (_currentPageIndex + 1) * (1 / _pageViewWidgetList.length);
    _pageController = PageController(initialPage: currentScreenPosition);
  }

  /// This method will be use for to get current tag from respective API and if the current table from database is empty then insert the
  /// data on respective position of the questions list.and if not then update the data on respective position.
  void _getCurrentQuestionTag(int currentPageIndex) async {
    var isDataBaseExists = await SignUpOnBoardProviders.db.isDatabaseExist();
    UserProgressDataModel userProgressDataModel = UserProgressDataModel();

    if (!isDataBaseExists) {
      userProgressDataModel = await _signUpOnBoardThirdStepBloc
          .fetchSignUpOnBoardThirdStepData(Constant.clinicalImpressionShort3, context);
    } else {
      int? userProgressDataCount = await SignUpOnBoardProviders.db
          .checkUserProgressDataAvailable(
              SignUpOnBoardProviders.TABLE_USER_PROGRESS);
      userProgressDataModel.userId = Constant.userID;
      userProgressDataModel.step = Constant.thirdEventStep;
      userProgressDataModel.userScreenPosition = currentPageIndex;
      userProgressDataModel.questionTag = (_currentQuestionLists.length > 0)
          ? _currentQuestionLists[currentPageIndex].tag
          : '';

      if (userProgressDataCount == 0) {
        SignUpOnBoardProviders.db.insertUserProgress(userProgressDataModel);
      } else {
        SignUpOnBoardProviders.db.updateUserProgress(userProgressDataModel);
      }
    }
  }

  /// This method will be use for select the answer data on the basis of current Tag. and also update the selected answer in local database.
  Future<dynamic> _selectedAnswerListData(
      Questions question, List<String> valuesSelectedList) async{
    SelectedAnswers? selectedAnswers;
    if (_signUpOnBoardSelectedAnswersModel.selectedAnswers!.length > 0) {
      selectedAnswers = _signUpOnBoardSelectedAnswersModel.selectedAnswers
          !.firstWhereOrNull((model) => model.questionTag == question.tag);
    }
    if (selectedAnswers != null) {
      selectedAnswers.answer = jsonEncode(valuesSelectedList);
    } else {
      _signUpOnBoardSelectedAnswersModel.selectedAnswers!.add(SelectedAnswers(
          questionTag: question.tag, answer: jsonEncode(valuesSelectedList)));
      print(_signUpOnBoardSelectedAnswersModel.selectedAnswers);
    }
    _updateSelectedAnswerDataOnLocalDatabase();
  }

  /// This method will be use for update the answer in to the database on the basis of event type.
  void _updateSelectedAnswerDataOnLocalDatabase() {
    var answerStringData =
        Utils.getStringFromJson(_signUpOnBoardSelectedAnswersModel);
    LocalQuestionnaire localQuestionnaire = LocalQuestionnaire();
    localQuestionnaire.selectedAnswers = answerStringData;
    SignUpOnBoardProviders.db.updateSelectedAnswers(
        _signUpOnBoardSelectedAnswersModel, Constant.thirdEventStep);
  }

  void sendUserDataAndMoveInToNextScreen() async {
    TextToSpeechRecognition.speechToText("");
    Utils.showApiLoaderDialog(
      context,
      networkStream: _signUpOnBoardThirdStepBloc.sendThirdStepDataStream,
      tapToRetryFunction: () {
        _signUpOnBoardThirdStepBloc.enterSomeDummyDataToStreamController();
        _callSendThirdStepDataApi();
      }
    );
    _callSendThirdStepDataApi();
  }

  void _callSendThirdStepDataApi() async {
    var response = await _signUpOnBoardThirdStepBloc
        .sendSignUpThirdStepData(_signUpOnBoardSelectedAnswersModel, context);
    if (response is String) {
      if (response == Constant.success) {
        var userProfileInfoModel = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

        Utils.sendAnalyticsEvent(Constant.part3AssessmentCompleted, {
          'isCompleted': Constant.trueString,
          'user_id': userProfileInfoModel.userId
        }, context);

        await SignUpOnBoardProviders.db
            .deleteOnBoardQuestionnaireProgress(Constant.thirdEventStep);

        Navigator.pop(context);
        TextToSpeechRecognition.speechToText("");
        Navigator.pushReplacementNamed(
            context, Constant.postPartThreeOnBoardRouter);
      }
    }
  }

  Future<bool> _onBackPressed() async {
    if(!_isButtonClicked) {
      _isButtonClicked = true;
      if (_currentPageIndex == 0) {
        Future.delayed(Duration(milliseconds: 350), () {
          _isButtonClicked = false;
        });
        Utils.navigateToExitScreen(context);
        return false;
      } else {
        setState(() {
          double stepOneProgress = 1 / _pageViewWidgetList.length;

          if (_currentPageIndex != 0) {
            _progressPercent -= stepOneProgress;
            _currentPageIndex--;
            _pageController.animateToPage(_currentPageIndex,
                duration: Duration(milliseconds: 1),
                curve: Curves.easeIn);
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

  void _nextButtonPressed(SignupOnboardErrorInfo data) {
    setState(() {});
    if(!_isButtonClicked) {
      _isButtonClicked = true;
      Future.delayed(Duration(milliseconds: 350), () {
        _isButtonClicked = false;
      });
      if (Utils.validationForOnBoard(
          _signUpOnBoardSelectedAnswersModel.selectedAnswers!,
          _currentQuestionLists[_currentPageIndex])) {
        data.updateErrorString();
        double stepOneProgress =
            1 / _pageViewWidgetList.length;

        if (_progressPercent == 1) {
          sendUserDataAndMoveInToNextScreen();
        } else {
          setState(() {
            _currentPageIndex++;

            if (_currentPageIndex !=
                _pageViewWidgetList.length - 1)
              _progressPercent += stepOneProgress;
            else {
              _progressPercent = 1;
            }

            _pageController.animateToPage(_currentPageIndex,
                duration: Duration(milliseconds: 1),
                curve: Curves.easeInOutCubic);

            _getCurrentQuestionTag(_currentPageIndex);
          });
        }
      }
      else {
        if(_filterQuestionsListData[_currentPageIndex].questionType == Constant.QuestionSingleType || _filterQuestionsListData[_currentPageIndex].questionType == Constant.QuestionMultiType){
          data.setErrorString = 'Please select atleast one value!';
        }
        else{
          data.setErrorString = 'Please enter a value!';
        }
      }
    }
  }
}
