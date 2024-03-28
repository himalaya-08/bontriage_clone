import 'dart:convert';
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobile/blocs/MoreHeadacheTypeBloc.dart';
import 'package:mobile/blocs/SignUpOnBoardSecondStepBloc.dart';
import 'package:mobile/models/LocalQuestionnaire.dart';
import 'package:mobile/models/OnBoardSelectOptionModel.dart';
import 'package:mobile/models/PartTwoOnBoardArgumentModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardFirstStepQuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserProgressDataModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/NetworkErrorScreen.dart';
import 'package:mobile/view/OnBoardMultiSelectOption.dart';
import 'package:mobile/view/on_board_bottom_buttons.dart';
import 'package:mobile/view/on_board_chat_bubble.dart';
import 'package:mobile/view/on_board_select_options.dart';
import 'package:mobile/view/sign_up_age_screen.dart';
import 'package:mobile/view/sign_up_name_screen.dart';
import 'package:mobile/view/sign_up_on_board_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/PostClinicalImpressionArgumentModel.dart';

class PartTwoOnBoardScreens extends StatefulWidget {
  final PartTwoOnBoardArgumentModel? partTwoOnBoardArgumentModel;

  const PartTwoOnBoardScreens({this.partTwoOnBoardArgumentModel});

  @override
  _PartTwoOnBoardScreensState createState() => _PartTwoOnBoardScreensState();
}

class _PartTwoOnBoardScreensState extends State<PartTwoOnBoardScreens> {
  PageController _pageController = PageController(
    initialPage: 0,
  );

  String _argumentName = Constant.clinicalImpressionShort1;

  int _currentPageIndex = 0;
  double _progressPercent = 0;

  List<SignUpOnBoardFirstStepQuestionsModel>? _pageViewWidgetList;
  bool isEndOfOnBoard = false;
  bool isAlreadyDataFiltered = false;
  SignUpOnBoardSecondStepBloc? _signUpOnBoardSecondStepBloc;

  bool _isButtonClicked = false;
  SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel =
      SignUpOnBoardSelectedAnswersModel();

  int currentScreenPosition = 0;

  List<Questions> currentQuestionListData = [];
  List<int> _backQuestionIndexList = [];

  Future<bool> _onBackPressed() async {
    if (!_isButtonClicked) {
      _isButtonClicked = true;
      if (_currentPageIndex == 0) {
        if (!widget.partTwoOnBoardArgumentModel!.isFromSignUp) {
          if (!widget.partTwoOnBoardArgumentModel!.isFromMoreScreen) {
            // TextToSpeechRecognition.stopSpeech();
            if (widget.partTwoOnBoardArgumentModel!.isFromHeadacheTypeScreen) {
              if (widget.partTwoOnBoardArgumentModel!.fromScreenRouter ==
                  Constant.addHeadacheOnGoingScreenRouter) {
                TextToSpeechRecognition.stopSpeech();
                Navigator.popUntil(
                    context,
                    ModalRoute.withName(
                        Constant.addHeadacheOnGoingScreenRouter));
              } else {
                TextToSpeechRecognition.stopSpeech();
                Navigator.popUntil(
                    context, ModalRoute.withName(Constant.homeRouter));
              }
              return false;
            } else {
              TextToSpeechRecognition.stopSpeech();
              Navigator.popUntil(context,
                  ModalRoute.withName(Constant.addHeadacheOnGoingScreenRouter));
              return false;
            }
          }
          var userHeadacheName = signUpOnBoardSelectedAnswersModel
              .selectedAnswers!
              .firstWhereOrNull(
                  (model) => model.questionTag == "nameClinicalImpression");

          if (userHeadacheName != null) {
            TextToSpeechRecognition.stopSpeech();
            Navigator.pop(context, userHeadacheName.answer);
          } else {
            TextToSpeechRecognition.stopSpeech();
            Navigator.pop(context);
          }

          Future.delayed(Duration(milliseconds: 350), () {
            _isButtonClicked = false;
          });
          return false;
        }
        Future.delayed(Duration(milliseconds: 350), () {
          _isButtonClicked = false;
        });
        if (widget.partTwoOnBoardArgumentModel!.isFromSignUp)
          Utils.navigateToExitScreen(context);
        else if (!widget.partTwoOnBoardArgumentModel!.isFromSignUp &&
            !widget.partTwoOnBoardArgumentModel!.isFromMoreScreen &&
            !widget.partTwoOnBoardArgumentModel!.isFromHeadacheTypeScreen)
          Navigator.popUntil(context,
              ModalRoute.withName(Constant.addHeadacheOnGoingScreenRouter));
        else if (widget.partTwoOnBoardArgumentModel!.isFromHeadacheTypeScreen)
          Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
        else {
          TextToSpeechRecognition.stopSpeech();
          Navigator.pop(context);
        }
        return false;
      } else {
        setState(() {
          double stepOneProgress = 1 / _pageViewWidgetList!.length;

          if (_currentPageIndex != 0) {
            _currentPageIndex = _backQuestionIndexList.last;
            _backQuestionIndexList.removeLast();
            _progressPercent = (_currentPageIndex + 1) * stepOneProgress;
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
    _signUpOnBoardSecondStepBloc!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _signUpOnBoardSecondStepBloc = SignUpOnBoardSecondStepBloc();
    signUpOnBoardSelectedAnswersModel.eventType = Constant.secondEventStep;
    signUpOnBoardSelectedAnswersModel.selectedAnswers = [];

    if (widget.partTwoOnBoardArgumentModel != null) {
      //_argumentName = widget.partTwoOnBoardArgumentModel.argumentName ?? Constant.clinicalImpressionShort1;
      _argumentName = Constant.clinicalImpressionEventType;
    }

    _pageViewWidgetList = [];

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Utils.showApiLoaderDialog(context);
      getCurrentUserPosition();
    });

    Utils.setAnalyticsCurrentScreen(Constant.partTwoOnBoardAssessmentScreen, context);
  }

  Future<void> updateHeadacheDataChecker() async {
    MoreHeadacheTypeBloc bloc = MoreHeadacheTypeBloc();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? isUpdateHeadacheData =
        sharedPreferences.getBool(Constant.updateMoreHeadacheData);
    if (isUpdateHeadacheData != null) {
      if (isUpdateHeadacheData) {
        bloc.initNetworkStreamController();
        /*widget.showApiLoaderCallback(_bloc.networkStream, () {
          _bloc.enterDummyDataToNetworkStream();
          _bloc.getAllHeadacheTypeService(context);
        });*/
        bloc.getAllHeadacheTypeService(context);
        //await sharedPreferences.setBool(Constant.updateMoreHeadacheData, false);
      }
    }
  }

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Constant.backgroundColor,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: StreamBuilder<dynamic>(
                stream: _signUpOnBoardSecondStepBloc!
                    .signUpOnBoardSecondStepDataStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (!isAlreadyDataFiltered && !_isButtonClicked) {
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
                            isEndOfOnBoard: isEndOfOnBoard,
                            chatBubbleText:
                                _pageViewWidgetList![_currentPageIndex]
                                    .questions!,
                            closeButtonFunction: () {
                              if (widget
                                  .partTwoOnBoardArgumentModel!.isFromSignUp)
                                Utils.navigateToExitScreen(context);
                              else if (!widget.partTwoOnBoardArgumentModel!
                                      .isFromSignUp &&
                                  !widget.partTwoOnBoardArgumentModel!
                                      .isFromMoreScreen &&
                                  !widget.partTwoOnBoardArgumentModel!
                                      .isFromHeadacheTypeScreen)
                                Navigator.popUntil(
                                    context,
                                    ModalRoute.withName(Constant
                                        .addHeadacheOnGoingScreenRouter));
                              else if (widget.partTwoOnBoardArgumentModel!
                                  .isFromHeadacheTypeScreen) {
                                if (widget.partTwoOnBoardArgumentModel!
                                        .fromScreenRouter ==
                                    Constant.addHeadacheOnGoingScreenRouter) {
                                  Navigator.popUntil(
                                      context,
                                      ModalRoute.withName(Constant
                                          .addHeadacheOnGoingScreenRouter));
                                } else {
                                  Navigator.popUntil(context,
                                      ModalRoute.withName(Constant.homeRouter));
                                }
                              } else {
                                TextToSpeechRecognition.stopSpeech();
                                Navigator.pop(context);
                              }
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _pageViewWidgetList!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return _pageViewWidgetList![index]
                                    .questionsWidget;
                              },
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Consumer<SignupOnboardErrorInfo>(
                            builder: (context, data, child) {
                              return OnBoardBottomButtons(
                                isFromSignUp: widget.partTwoOnBoardArgumentModel
                                        ?.isFromSignUp ??
                                    true,
                                progressPercent: _progressPercent,
                                backButtonFunction: () {
                                  data.updateErrorString();
                                  _onBackPressed();
                                },
                                currentIndex: _currentPageIndex,
                                nextButtonFunction: () {
                                  _nextButtonFunction(data, snapshot);
                                },
                                onBoardPart: 2,
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
                })),
      ),
    );
  }

  /// This method will be use for to set the UI content from the respective Question Tag.
  addFilteredQuestionListData(List<Questions> questionListData) {
    if (questionListData != null) {
      //This code is to two remove the infoClinicalImpression tag from clinical_impression event
      questionListData
          .removeWhere((element) => element.tag == 'infoClinicalImpression');

      if (widget.partTwoOnBoardArgumentModel!.isFromMoreScreen)
        questionListData
            .removeWhere((element) => element.tag == 'nameClinicalImpression');

      currentQuestionListData = questionListData;
      debugPrint(jsonEncode(currentQuestionListData));
      questionListData.forEach((element) {
        //element.helpText = '${Constant.questionTagMap[element.tag]}\n${element.helpText}';
        switch (element.questionType) {
          case Constant.QuestionNumberType:
            _pageViewWidgetList!.add(SignUpOnBoardFirstStepQuestionsModel(
                questions: element.helpText,
                questionsWidget: SignUpAgeScreen(
                  sliderValue: element.min!.toDouble(),
                  sliderMinValue: element.min!.toDouble(),
                  sliderMaxValue:
                      (element.max!.toDouble() < element.min!.toDouble())
                          ? element.min!.toDouble() + 1
                          : element.max!.toDouble(),
                  minText: element.min.toString(),
                  maxText: element.max.toString(),
                  labelText: "",
                  currentTag: element.tag!,
                  selectedAnswerListData:
                      signUpOnBoardSelectedAnswersModel.selectedAnswers,
                  selectedAnswerCallBack: (currentTag, selectedUserAnswer) {
                    //print(currentTag + selectedUserAnswer);
                    selectedAnswerListData(currentTag, selectedUserAnswer);
                  },
                  uiHints: element.uiHints!,
                )));
            break;

          case Constant.QuestionTextType:
            _pageViewWidgetList!.add(SignUpOnBoardFirstStepQuestionsModel(
                questions: element.helpText,
                questionsWidget: SignUpNameScreen(
                  tag: element.tag!,
                  helpText: element.helpText!,
                  selectedAnswerListData:
                      signUpOnBoardSelectedAnswersModel.selectedAnswers!,
                  selectedAnswerCallBack: (currentTag, selectedUserAnswer) {
                    print(currentTag + selectedUserAnswer);
                    selectedAnswerListData(
                        currentTag, selectedUserAnswer.trim());
                  },
                )));
            break;

          case Constant.QuestionSingleType:
            List<OnBoardSelectOptionModel> valuesListData = [];
            element.values!.forEach((element) {
              valuesListData.add(OnBoardSelectOptionModel(
                  optionId: element.valueNumber, optionText: element.text));
            });
            _pageViewWidgetList!.add(SignUpOnBoardFirstStepQuestionsModel(
                questions: element.helpText,
                questionsWidget: OnBoardSelectOptions(
                    selectOptionList: valuesListData,
                    questionTag: element.tag!,
                    selectedAnswerListData:
                        signUpOnBoardSelectedAnswersModel.selectedAnswers!,
                    selectedAnswerCallBack: (currentTag, selectedUserAnswer) {
                      selectedAnswerListData(currentTag, selectedUserAnswer);
                    })));
            break;
          case Constant.QuestionMultiType:
            List<OnBoardSelectOptionModel> valuesListData = [];
            element.values!.forEach((element) {
              valuesListData.add(OnBoardSelectOptionModel(
                  optionId: element.valueNumber, optionText: element.text));
            });
            _pageViewWidgetList!.add(SignUpOnBoardFirstStepQuestionsModel(
                questions: element.helpText,
                questionsWidget: OnBoardMultiSelectOptions(
                    selectOptionList: element.values!,
                    questionTag: element.tag!,
                    selectedAnswerListData:
                        signUpOnBoardSelectedAnswersModel.selectedAnswers!,
                    selectedAnswerCallBack: (currentTag, selectedUserAnswer) {
                      selectedAnswerListData(currentTag, selectedUserAnswer);
                    })));
            break;
        }
        isAlreadyDataFiltered = true;
      });
      debugPrint(questionListData.toString());
      // We have to change this condition
      _currentPageIndex = currentScreenPosition;
      _progressPercent =
          (_currentPageIndex + 1) * (1 / _pageViewWidgetList!.length);
      _pageController = PageController(initialPage: _currentPageIndex);
    }
  }

  /// This method will be use for to get current position of the user. When he last time quit the application or click the close
  /// icon. We will fetch last position from Local database.
  void getCurrentUserPosition() async {
    if (widget.partTwoOnBoardArgumentModel!.isFromSignUp) {
      UserProgressDataModel? userProgressModel =
          await SignUpOnBoardProviders.db.getUserProgress();
      if (userProgressModel != null &&
          userProgressModel.step == Constant.secondEventStep) {
        currentScreenPosition = userProgressModel.userScreenPosition!;
        if (userProgressModel.backQuestionIndexList != null &&
            userProgressModel.backQuestionIndexList!.length > 0)
          _backQuestionIndexList
              .addAll(userProgressModel.backQuestionIndexList!);
        print(_backQuestionIndexList);
        print(userProgressModel);
      }

      getCurrentQuestionTag(currentScreenPosition);
    } else {
      List<SelectedAnswers> selectedAnswerList =
          widget.partTwoOnBoardArgumentModel!.selectedAnswersList ?? [];
      signUpOnBoardSelectedAnswersModel.selectedAnswers =
          selectedAnswerList ?? [];
    }

    requestService();
  }

  /// In this method we will hit the API of Second step of questions list.So if we have empty table into the database.
  /// then we hit the API and save the all questions data in to the database. if not then we will fetch the all data from the local
  /// database of respective table.
  void requestService() async {
    List<LocalQuestionnaire> localQuestionnaireData =
        await SignUpOnBoardProviders.db
            .getQuestionnaire(Constant.secondEventStep);

    if (localQuestionnaireData != null &&
        localQuestionnaireData.length > 0 &&
        widget.partTwoOnBoardArgumentModel!.isFromSignUp) {
      await _signUpOnBoardSecondStepBloc!
          .fetchAllHeadacheListData(_argumentName, false, context);
      signUpOnBoardSelectedAnswersModel = await _signUpOnBoardSecondStepBloc!
          .fetchDataFromLocalDatabase(localQuestionnaireData);
    } else {
      //_signUpOnBoardSecondStepBloc.fetchSignUpOnBoardSecondStepData(_argumentName);
      _signUpOnBoardSecondStepBloc!
          .fetchAllHeadacheListData(_argumentName, true, context);
    }
  }

  /// This method will be use for to get current tag from respective API and if the current table from database is empty then insert the
  /// data on respective position of the questions list.and if not then update the data on respective position.
  void getCurrentQuestionTag(int currentPageIndex) async {
    var isDataBaseExists = await SignUpOnBoardProviders.db.isDatabaseExist();
    UserProgressDataModel userProgressDataModel = UserProgressDataModel();

    if (!isDataBaseExists) {
      userProgressDataModel = await _signUpOnBoardSecondStepBloc!
          .fetchAllHeadacheListData(_argumentName, true, context);
    } else {
      int? userProgressDataCount = await SignUpOnBoardProviders.db
          .checkUserProgressDataAvailable(
              SignUpOnBoardProviders.TABLE_USER_PROGRESS);
      userProgressDataModel.userId = Constant.userID;
      userProgressDataModel.step = Constant.secondEventStep;
      userProgressDataModel.userScreenPosition = currentPageIndex;
      userProgressDataModel.questionTag = (currentQuestionListData.length > 0)
          ? currentQuestionListData[currentPageIndex].tag
          : Constant.blankString;
      userProgressDataModel.backQuestionIndexList = _backQuestionIndexList;

      if (userProgressDataCount == 0) {
        SignUpOnBoardProviders.db.insertUserProgress(userProgressDataModel);
      } else {
        SignUpOnBoardProviders.db.updateUserProgress(userProgressDataModel);
      }
    }
  }

  /// This method will be use for select the answer data on the basis of current Tag. and also update the selected answer in local database.
  void selectedAnswerListData(String currentTag, String selectedUserAnswer) {
    SelectedAnswers? selectedAnswers;
    if (signUpOnBoardSelectedAnswersModel.selectedAnswers!.length > 0) {
      selectedAnswers = signUpOnBoardSelectedAnswersModel.selectedAnswers!
          .firstWhereOrNull((model) => model.questionTag == currentTag);
    }
    if (selectedAnswers != null) {
      selectedAnswers.answer = selectedUserAnswer;
    } else {
      signUpOnBoardSelectedAnswersModel.selectedAnswers!.add(
          SelectedAnswers(questionTag: currentTag, answer: selectedUserAnswer));
      print(signUpOnBoardSelectedAnswersModel.selectedAnswers);
    }

    if (widget.partTwoOnBoardArgumentModel!.isFromSignUp)
      updateSelectedAnswerDataOnLocalDatabase();
  }

  /// This method will be use for update the answer in to the database on the basis of event type.
  updateSelectedAnswerDataOnLocalDatabase() {
    var answerStringData =
        Utils.getStringFromJson(signUpOnBoardSelectedAnswersModel);
    LocalQuestionnaire localQuestionnaire = LocalQuestionnaire();
    localQuestionnaire.selectedAnswers = answerStringData;
    SignUpOnBoardProviders.db.updateSelectedAnswers(
        signUpOnBoardSelectedAnswersModel, Constant.secondEventStep);
  }

  Future<void> moveUserToNextScreen() async {
    isEndOfOnBoard = true;
    TextToSpeechRecognition.speechToText("");

    Utils.showApiLoaderDialog(context,
        networkStream: _signUpOnBoardSecondStepBloc!.sendSecondStepDataStream,
        tapToRetryFunction: () {
      _signUpOnBoardSecondStepBloc!.enterSomeDummyDataToStreamController();
      _callSendSecondStepDataApi();
    });

    _callSendSecondStepDataApi();
  }

  void _callSendSecondStepDataApi() async {
    List<SelectedAnswers> selectedAnswersList = [];
    _backQuestionIndexList.forEach((questionIndex) {
      String questionTag = currentQuestionListData[questionIndex].tag!;
      SelectedAnswers? selectedAnswer = signUpOnBoardSelectedAnswersModel
          .selectedAnswers!
          .firstWhereOrNull((element) => element.questionTag == questionTag);
      if (selectedAnswer != null) selectedAnswersList.add(selectedAnswer);
    });

    if (widget.partTwoOnBoardArgumentModel!.isFromMoreScreen) {
      var userProfileInfoModel =
      await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
      var userHeadacheName = signUpOnBoardSelectedAnswersModel
          .selectedAnswers!
          .firstWhereOrNull(
              (model) => model.questionTag == "nameClinicalImpression");
      Utils.sendAnalyticsEvent(Constant.reCompleteAssessmentCompleted, {
        'isCompleted': Constant.trueString,
        'user_id': userProfileInfoModel.userId,
        'headache_name': userHeadacheName
      }, context);
      SelectedAnswers? nameClinicalImpressionAnswer =
          signUpOnBoardSelectedAnswersModel.selectedAnswers?.firstWhereOrNull(
              (element) => element.questionTag == 'nameClinicalImpression');

      if (nameClinicalImpressionAnswer != null)
        selectedAnswersList.add(nameClinicalImpressionAnswer);
    }

    signUpOnBoardSelectedAnswersModel.selectedAnswers = selectedAnswersList;

    var response = await _signUpOnBoardSecondStepBloc!.sendSignUpSecondStepData(
        signUpOnBoardSelectedAnswersModel,
        widget.partTwoOnBoardArgumentModel!.eventId,
        widget.partTwoOnBoardArgumentModel!.isFromMoreScreen ?? false,
        context);
    if (response is String && response != null) {
      if (response == Constant.success) {
        var userProfileInfoModel =
            await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

        Utils.sendAnalyticsEvent(Constant.part2AssessmentCompleted, {
          'isCompleted': Constant.trueString,
          'user_id': userProfileInfoModel.userId
        }, context);
        await SignUpOnBoardProviders.db
            .deleteOnBoardQuestionnaireProgress(Constant.secondEventStep);
        Navigator.pop(context);
        if (!widget.partTwoOnBoardArgumentModel!.isFromSignUp) {
          if (widget.partTwoOnBoardArgumentModel!.isFromMoreScreen) {
            //Navigator.popUntil(context, ModalRoute.withName(widget.partTwoOnBoardArgumentModel?.fromScreenRouter ?? ''));
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            await sharedPreferences.setBool(
                Constant.updateMoreHeadacheData, true);
            Navigator.pop(context, _signUpOnBoardSecondStepBloc!.eventId);
          } else if (widget
              .partTwoOnBoardArgumentModel!.isFromHeadacheTypeScreen) {
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            await sharedPreferences.setBool(
                Constant.updateMoreHeadacheData, true);
            await sharedPreferences.setString(
                Constant.updateOverTimeCompassData, Constant.trueString);
            await sharedPreferences.setString(
                Constant.updateCompareCompassData, Constant.trueString);
            await sharedPreferences.setString(
                Constant.updateTrendsData, Constant.trueString);

            if (widget.partTwoOnBoardArgumentModel?.fromScreenRouter ==
                Constant.addHeadacheOnGoingScreenRouter) {
              var userHeadacheName = signUpOnBoardSelectedAnswersModel
                  .selectedAnswers!
                  .firstWhereOrNull(
                      (model) => model.questionTag == "nameClinicalImpression");

              if (userHeadacheName != null) {
                await sharedPreferences.setString(
                    Constant.userHeadacheName, userHeadacheName.answer ?? '');
              }

              Navigator.popUntil(context,
                  ModalRoute.withName(Constant.addHeadacheOnGoingScreenRouter));
            } else {
              var userHeadacheName = signUpOnBoardSelectedAnswersModel
                  .selectedAnswers!
                  .firstWhereOrNull(
                      (model) => model.questionTag == "nameClinicalImpression");

              if (userHeadacheName != null) {
                await sharedPreferences.setString(
                    Constant.userHeadacheName, userHeadacheName.answer ?? '');
              }
              Navigator.popUntil(
                  context, ModalRoute.withName(Constant.homeRouter));
            }
          } else if (!widget.partTwoOnBoardArgumentModel!.isFromMoreScreen) {
            //add headache name to shared pref
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            var userHeadacheName = signUpOnBoardSelectedAnswersModel
                .selectedAnswers
                ?.firstWhereOrNull(
                    (model) => model.questionTag == "nameClinicalImpression");

            sharedPreferences.setString(
                "userHeadacheName", userHeadacheName?.answer ?? '');
          } else {
            var userHeadacheName =
                signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhere(
                    (model) => model.questionTag == "nameClinicalImpression");
            Navigator.pop(context, userHeadacheName.answer);
          }
        } else {
          SelectedAnswers? nameClinicalImpressionSelectedAnswer =
              signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhere(
                  (element) => element.questionTag == "nameClinicalImpression");
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString(Constant.userHeadacheName,
              nameClinicalImpressionSelectedAnswer.answer!);
          Navigator.pushReplacementNamed(context,
              Constant.signUpOnBoardSecondStepPersonalizedHeadacheResultRouter);
        }
      } else {
        Navigator.pop(context);
        Utils.showValidationErrorDialog(context, response);
      }
    }
  }

  Future<void> _openPostClinicalImpressionScreen() async {
    final result = await Navigator.pushNamed(
        context, Constant.postClinicalImpressionScreenRouter,
        arguments: PostClinicalImpressionArgumentModel(
            signUpOnBoardSelectedAnswersModel:
                signUpOnBoardSelectedAnswersModel));

    if (result != null) {
      if (result is String && result == Constant.next) {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        bool isMigraine = sharedPreferences.getBool("isMigraine") ?? false;

        _pageViewWidgetList?.last.questions =
            "Please provide a name for this headache type (${isMigraine ? 'Migraine' : 'Headache'}).";
        _pageViewWidgetList?.last.questionsWidget = SignUpNameScreen(
          tag: 'nameClinicalImpression',
          helpText: _pageViewWidgetList?.last.questions,
          selectedAnswerListData:
              signUpOnBoardSelectedAnswersModel.selectedAnswers,
          selectedAnswerCallBack: (currentTag, selectedUserAnswer) {
            //print(currentTag + selectedUserAnswer);
            selectedAnswerListData(currentTag, selectedUserAnswer.trim());
          },
        );

        Future.delayed(Duration(milliseconds: 350), () {
          double stepOneProgress = 1 / _pageViewWidgetList!.length;
          setState(() {
            _backQuestionIndexList.add(_currentPageIndex);
            _currentPageIndex = Utils.fetchQuestionTag(
                currentPageIndex: _currentPageIndex,
                currentQuestionListData: currentQuestionListData,
                signUpOnBoardSelectedAnswersModel:
                    signUpOnBoardSelectedAnswersModel);

            debugPrint('QuestionTAG?????' +
                currentQuestionListData[_currentPageIndex].tag!);

            if (_currentPageIndex != _pageViewWidgetList!.length - 1)
              _progressPercent = (_currentPageIndex + 1) * stepOneProgress;
            else {
              _progressPercent = 1;
            }

            _pageController.animateToPage(_currentPageIndex,
                duration: Duration(milliseconds: 1), curve: Curves.easeIn);
          });

          Future.delayed(Duration(milliseconds: 350), () {
            _isButtonClicked = false;
          });
        });

        debugPrint(result.toString());
      } else {
        Future.delayed(Duration(milliseconds: 350), () {
          _isButtonClicked = false;
        });
      }
    } else {
      Future.delayed(Duration(milliseconds: 350), () {
        _isButtonClicked = false;
      });
    }
  }

  void _nextButtonFunction(
      SignupOnboardErrorInfo data, AsyncSnapshot<dynamic> snapshot) {
    if (!_isButtonClicked) {
      _isButtonClicked = true;
      if (Utils.validationForOnBoard(
          signUpOnBoardSelectedAnswersModel.selectedAnswers!,
          currentQuestionListData[_currentPageIndex])) {
        data.updateErrorString();
        double stepOneProgress = 1 / _pageViewWidgetList!.length;
        if (_progressPercent == 1) {
          int? backQuestionIndex = _backQuestionIndexList
              .firstWhereOrNull((element) => element == _currentPageIndex);
          if (backQuestionIndex == null)
            _backQuestionIndexList.add(_currentPageIndex);
          updateHeadacheDataChecker();
          moveUserToNextScreen();
        } else {
          if (!widget.partTwoOnBoardArgumentModel!.isFromSignUp &&
              !widget.partTwoOnBoardArgumentModel!.isFromMoreScreen) {
            if (_currentPageIndex == _pageViewWidgetList!.length - 2) {
              _openPostClinicalImpressionScreen();
              return;
            }
          }
          setState(() {
            _backQuestionIndexList.add(_currentPageIndex);
            _currentPageIndex = Utils.fetchQuestionTag(
                currentPageIndex: _currentPageIndex,
                currentQuestionListData: currentQuestionListData,
                signUpOnBoardSelectedAnswersModel:
                    signUpOnBoardSelectedAnswersModel);

            print('QuestionTAG?????' +
                currentQuestionListData[_currentPageIndex].tag!);

            if (_currentPageIndex != _pageViewWidgetList!.length - 1)
              _progressPercent = (_currentPageIndex + 1) * stepOneProgress;
            else {
              _progressPercent = 1;
            }

            _pageController.animateToPage(_currentPageIndex,
                duration: Duration(milliseconds: 1), curve: Curves.easeIn);
          });
        }
        if (widget.partTwoOnBoardArgumentModel!.isFromSignUp)
          getCurrentQuestionTag(_currentPageIndex);
      } else {
        if (snapshot.data[_currentPageIndex].questionType ==
                Constant.QuestionSingleType ||
            snapshot.data[_currentPageIndex].questionType ==
                Constant.QuestionMultiType) {
          data.setErrorString = 'Please select atleast one value!';
        } else {
          data.setErrorString = 'Please enter a value!';
        }
      }
      Future.delayed(Duration(milliseconds: 350), () {
        _isButtonClicked = false;
      });
    }
  }
}
