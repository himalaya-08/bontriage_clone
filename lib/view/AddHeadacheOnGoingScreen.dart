import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:health/health.dart';
import 'package:mobile/blocs/AddHeadacheLogBloc.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserAddHeadacheLogModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/AddANoteWidget.dart';
import 'package:mobile/view/AddHeadacheSection.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'DiscardChangesBottomSheet.dart';
import 'NetworkErrorScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddHeadacheOnGoingScreen extends StatefulWidget {
  final CurrentUserHeadacheModel? currentUserHeadacheModel;

  const AddHeadacheOnGoingScreen({Key? key, this.currentUserHeadacheModel})
      : super(key: key);

  @override
  _AddHeadacheOnGoingScreenState createState() =>
      _AddHeadacheOnGoingScreenState();
}

class _AddHeadacheOnGoingScreenState extends State<AddHeadacheOnGoingScreen>
    with SingleTickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  AddHeadacheLogBloc _addHeadacheLogBloc = AddHeadacheLogBloc();
  String headacheType = '';
  SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel =
  SignUpOnBoardSelectedAnswersModel();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<Questions> _addHeadacheUserListData = <Questions>[];

  List<SelectedAnswers> selectedAnswers = [];

  bool _isUserHeadacheEnded = false;

  bool _isDataPopulated = false;
  bool _isFromRecordScreen = false;
  CurrentUserHeadacheModel _currentUserHeadacheModel = CurrentUserHeadacheModel();
  bool _isButtonClicked = false;
  bool _isEditing = false;

  bool _healthAuthorization = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    _dateTime = DateTime.now();

    signUpOnBoardSelectedAnswersModel.selectedAnswers = [];

    _currentUserHeadacheModel = widget.currentUserHeadacheModel!;

    if (widget.currentUserHeadacheModel != null) {
      if (widget.currentUserHeadacheModel!.headacheId != null) {
        _isEditing = true;
      }
    }

    _isFromRecordScreen = widget.currentUserHeadacheModel!.isFromRecordScreen ?? false;

    Utils.setAnalyticsCurrentScreen(Constant.addHeadacheScreen, context);

    try {
      if(_isFromRecordScreen)
       _dateTime = DateTime.parse(widget.currentUserHeadacheModel!.selectedDate!);
    } catch(e) {
      debugPrint(e.toString());
    }

    signUpOnBoardSelectedAnswersModel.eventType = "Headache";
    signUpOnBoardSelectedAnswersModel.selectedAnswers = [];

    _addHeadacheLogBloc = AddHeadacheLogBloc();
    _addHeadacheLogBloc.currentUserHeadacheModel = widget.currentUserHeadacheModel;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      requestService();
      Utils.showApiLoaderDialog(context);
    });

  }

  @override
  void dispose() {
    _addHeadacheLogBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(signUpOnBoardSelectedAnswersModel.selectedAnswers!.length > 0)
          _showDiscardChangesBottomSheet();
        else {
          if(_isFromRecordScreen)
            Navigator.pop(context, _addHeadacheLogBloc.isHeadacheLogged);
          else
            Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
        }
        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        body: Container(
          decoration: Constant.backgroundBoxDecoration,
          child: ConstrainedBox(
            constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                decoration: BoxDecoration(
                  color: Constant.backgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextWidget(
                            text: '${Utils.getMonthName(_dateTime.month)} ${_dateTime.day}',
                            style: TextStyle(
                                fontSize: 16,
                                color: Constant.chatBubbleGreen,
                                fontFamily: Constant.jostMedium),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              if(signUpOnBoardSelectedAnswersModel.selectedAnswers!.length > 0)
                                _showDiscardChangesBottomSheet();
                              else {
                                if(_isFromRecordScreen)
                                  Navigator.pop(context, _addHeadacheLogBloc.isHeadacheLogged);
                                else
                                  Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 5, top: 5),
                              child: Image(
                                image: AssetImage(Constant.closeIcon),
                                width: 22,
                                height: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        height: 30,
                        thickness: 1,
                        color: Constant.chatBubbleGreen,
                      ),
                    ),
                    StreamBuilder<dynamic>(
                      stream: _addHeadacheLogBloc.addHeadacheLogDataStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if(!_isDataPopulated) {
                            Utils.closeApiLoaderDialog(context);
                            Future.delayed(Duration(seconds: 2), () {
                              //_fetchHealthData();
                            });
                          }
                          return Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: RawScrollbar(
                                    thickness: 2,
                                    radius: Radius.circular(2),
                                    thumbColor: Constant.locationServiceGreen,
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                      child: Container(
                                        child: Column(
                                          children: _getAddHeadacheSection(snapshot.data),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15,),
                                AddANoteWidget(
                                  selectedAnswerList: signUpOnBoardSelectedAnswersModel.selectedAnswers!,
                                  scaffoldKey: scaffoldKey,
                                  noteTag: 'headache.note',
                                ),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: NetworkErrorScreen(
                                    errorMessage: snapshot.error.toString(),
                                    tapToRetryFunction: () {
                                      Utils.showApiLoaderDialog(context);
                                      requestService();
                                    },
                                  ),
                                ),
                                const SizedBox(height: 15,),
                                AddANoteWidget(
                                  selectedAnswerList: signUpOnBoardSelectedAnswersModel.selectedAnswers!,
                                  scaffoldKey: scaffoldKey,
                                  noteTag: 'headache.note',
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(),
                                ),
                                const SizedBox(height: 15,),
                                AddANoteWidget(
                                  scaffoldKey: scaffoldKey,
                                  selectedAnswerList: selectedAnswers,
                                  noteTag: 'logday.note',
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BouncingWidget(
                          onPressed: () {
                            if (!_isButtonClicked) {
                              _isButtonClicked = true;
                              saveDataInLocalDataBaseOrServer();
                            }
                          },
                          child: Container(
                            width: 110,
                            padding:
                            EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Constant.chatBubbleGreen,
                              borderRadius:
                              BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: CustomTextWidget(
                                text: Constant.save,
                                style: TextStyle(
                                    color:
                                    Constant.bubbleChatTextView,
                                    fontSize: 15,
                                    fontFamily: Constant.jostMedium),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BouncingWidget(
                          onPressed: () {
                            if(signUpOnBoardSelectedAnswersModel.selectedAnswers!.length > 0)
                              _showDiscardChangesBottomSheet();
                            else {
                              if(_isFromRecordScreen)
                                Navigator.pop(context, _addHeadacheLogBloc.isHeadacheLogged);
                              else
                                Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
                            }
                          },
                          child: Container(
                            width: 110,
                            padding:
                            EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.3,
                                  color: Constant.chatBubbleGreen),
                              borderRadius:
                              BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: CustomTextWidget(
                                text: Constant.cancel,
                                style: TextStyle(
                                    color: Constant.chatBubbleGreen,
                                    fontSize: 15,
                                    fontFamily:
                                    Constant.jostMedium),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// This method will be use for add widget from the help of ADDHeadacheSection class.
  List<Widget> _getAddHeadacheSection(List<Questions> addHeadacheListData) {
    List<Widget> listOfWidgets = [];
    _addHeadacheUserListData = addHeadacheListData;
    selectedAnswers.forEach((element) {
      Questions? questionsTag = _addHeadacheUserListData
          .firstWhereOrNull((element1) => element1.tag == element.questionTag);
      if(questionsTag != null) {
        switch (questionsTag.questionType) {
          case Constant.singleTypeTag:
            Values? answerValuesData = questionsTag.values
                !.firstWhereOrNull((element1) => element1.text == element.answer);
            answerValuesData!.isSelected = true;
            break;
          case Constant.numberTypeTag:
          /*if(element.answer == null) {
            SelectedAnswers numberTypeSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers.firstWhere((element1) => element1.questionTag == element.questionTag, orElse: () => null);
            if(numberTypeSelectedAnswer == null)
              signUpOnBoardSelectedAnswersModel.selectedAnswers.add(SelectedAnswers(questionTag: element.questionTag, answer: '0'));
            else
              numberTypeSelectedAnswer.answer = '0';
          }*/
            questionsTag.currentValue = element.answer;
            break;
          case Constant.dateTimeTypeTag:
            questionsTag.updatedAt = element.answer;
            break;
        }
      }
    });

    _addHeadacheUserListData.forEach((element) {
      listOfWidgets.add(AddHeadacheSection(
        headerText: element.text!,
        subText: element.helpText!,
        contentType: element.tag!,
        min: element.min!.toDouble(),
        max: element.max!.toDouble(),
        valuesList: element.values!,
        updateAtValue: null,
        selectedCurrentValue: element.currentValue ?? Constant.blankString,
        selectedAnswers: signUpOnBoardSelectedAnswersModel.selectedAnswers!,
        addHeadacheDetailsData: addSelectedHeadacheDetailsData,
        moveWelcomeOnBoardTwoScreen: moveOnWelcomeBoardSecondStepScreens,
        isHeadacheEnded: !widget.currentUserHeadacheModel!.isOnGoing!,
        removeHeadacheTypeData: (tag, headacheType) {
          if (signUpOnBoardSelectedAnswersModel.selectedAnswers!.length > 0) {
            signUpOnBoardSelectedAnswersModel.selectedAnswers!.removeWhere((element) => element.questionTag == tag);
          }
        },
        currentUserHeadacheModel: _currentUserHeadacheModel,
        uiHints: element.uiHints!,
        userMedicationHistoryList: [

        ],
      ));
    });

    _isDataPopulated = true;
    return listOfWidgets;
  }

  /// This method will be use for to insert and update his answer in the local model.So we will save his answer on the basis of current Tag
  void addSelectedHeadacheDetailsData(String currentTag, String selectedValue) {
    SelectedAnswers? selectedAnswers;
    if (signUpOnBoardSelectedAnswersModel.selectedAnswers!.length > 0) {
      selectedAnswers = signUpOnBoardSelectedAnswersModel.selectedAnswers
          !.firstWhereOrNull((model) => model.questionTag == currentTag);
    }
    if (selectedAnswers != null) {
      selectedAnswers.answer = selectedValue;
    } else {
      signUpOnBoardSelectedAnswersModel.selectedAnswers
          !.add(SelectedAnswers(questionTag: currentTag, answer: selectedValue));
      debugPrint(signUpOnBoardSelectedAnswersModel.selectedAnswers.toString());
    }

    if (currentTag == "ongoing") {
      if (selectedValue == "Yes") {
        _isUserHeadacheEnded = false;
      } else {
        _isUserHeadacheEnded = true;
      }
    }
  }

  /// This method will be use for if user click Headache Plus Icon and he want to add another headache name of Add headache Screen.
  /// So we will move to the user  2nd Step of welcome OnBoard Screen in which he will add all information related to his headache.
  moveOnWelcomeBoardSecondStepScreens() async {
   /* final pushToScreenResult = await Navigator.pushNamed(
        context, Constant.partTwoOnBoardScreenRouter,
        arguments: PartTwoOnBoardArgumentModel(argumentName: Constant.clinicalImpressionEventType));*/
    /*final pushToScreenResult =
    await Navigator.pushNamed(context, Constant.addNewHeadacheIntroScreen);*/
    final pushToScreenResult = await Navigator.pushNamed(context, Constant.addNewHeadacheIntroScreen, arguments: Constant.addHeadacheOnGoingScreenRouter);

    //final pushToScreenResult = Navigator.pushNamed(context, Constant.headacheQuestionnaireDisclaimerScreenRouter);

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userHeadacheName = sharedPreferences.getString(Constant.userHeadacheName);
    bool? isMigraine = sharedPreferences.getBool("isMigraine");
    sharedPreferences.remove("userHeadacheName");
    sharedPreferences.remove("isMigraine");

    if (userHeadacheName != null) {
      if (_addHeadacheUserListData != null) {
        Questions? questions = _addHeadacheUserListData.firstWhereOrNull(
                (element) => element.tag == "headacheType");
        if (questions != null) {
          questions.values!.removeLast();
          Values? values = questions.values!.firstWhereOrNull(
                  (element) => element.isSelected);
          if (values != null) {
            values.isSelected = false;
          }
          questions.values
              !.add(Values(text: userHeadacheName, isSelected: true, isMigraine: isMigraine));
          questions.values!.add(Values(text: Constant.plusText, isSelected: false, isMigraine: false));
        }

        addSelectedHeadacheDetailsData("headacheType", userHeadacheName);

        var headacheTypeInfo = Provider.of<HeadacheTypeInfo>(context, listen: false);
        headacheTypeInfo.updateHeadacheTypeInfo();
      }
    }
    debugPrint(pushToScreenResult.toString());
  }

  void saveDataInLocalDataBaseOrServer() async {
    SelectedAnswers? headacheTypeSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull((element) => element.questionTag == Constant.headacheTypeTag);
    SelectedAnswers? onSetSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull((element) => element.questionTag == Constant.onSetTag);
    SelectedAnswers? endTimeSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull((element) => element.questionTag == Constant.endTimeTag);

    bool isTimeValidationSatisfied = true;
    String errorMessage = '';
    String? errorTitle;
    bool isShowErrorIcon = false;
    if(_isUserHeadacheEnded) {
      if(onSetSelectedAnswer != null && endTimeSelectedAnswer != null) {
        DateTime onSetDateTime = DateTime.tryParse(onSetSelectedAnswer.answer!)!;
        DateTime endDateTime = DateTime.tryParse(endTimeSelectedAnswer.answer!)!;

        debugPrint('Onset???$onSetDateTime\nEndtime???$endDateTime');

        if (onSetDateTime.isAtSameMomentAs(endDateTime)) {
          isShowErrorIcon = true;
          errorTitle = 'Invalid time';
          errorMessage = 'Start and end times cannot be the same.';
          isTimeValidationSatisfied = false;
        }
        else if(onSetDateTime.isAfter(endDateTime)) {
          isShowErrorIcon = true;
          errorTitle = 'Invalid start time';
          errorMessage = 'Start time cannot be greater than the current time.';
          isTimeValidationSatisfied = false;
        } else {
          isTimeValidationSatisfied = true;
        }
      }
    }

    if(headacheTypeSelectedAnswer != null) {
      if(isTimeValidationSatisfied) {
        _addHeadacheLogBloc.initAddHeadacheNetworkStreamController();
        Utils.showApiLoaderDialog(
            context,
            networkStream: _addHeadacheLogBloc.sendAddHeadacheLogDataStream,
            tapToRetryFunction: () {
              _addHeadacheLogBloc.initAddHeadacheNetworkStreamController();
              _addHeadacheLogBloc.enterSomeDummyData();
              _callSendAddHeadacheLogApi();
            }
        );
        _callSendAddHeadacheLogApi();
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString(Constant.loggedHeadacheName, headacheTypeSelectedAnswer.answer ?? Constant.blankString);
      } else {
        Utils.showValidationErrorDialog(context, errorMessage, errorTitle ?? 'Alert!', isShowErrorIcon);
        _isButtonClicked = false;
      }
    } else {
      //show headacheType selection error
      debugPrint('headache type error');
      /*Utils.showValidationErrorDialog(context, 'Please select a headache type.', 'Alert!');*/
      Utils.showSnackBar(context, 'Please select a headache type.');
      _isButtonClicked = false;
    }
  }

  void _callSendAddHeadacheLogApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await _addHeadacheLogBloc
        .sendAddHeadacheDetailsData(signUpOnBoardSelectedAnswersModel, context);
    if (response == Constant.success) {
      if (_isUserHeadacheEnded) {
        //_addHeadacheDataToHealthKit();
      }
      prefs.setString(Constant.updateCalendarTriggerData, 'true');
      prefs.setString(Constant.updateCalendarIntensityData, 'true');
      prefs.setString(Constant.updateOverTimeCompassData, 'true');
      prefs.setString(Constant.updateCompareCompassData, 'true');
      prefs.setString(Constant.updateTrendsData, 'true');
      prefs.setString(Constant.updateMeScreenData, 'true');
      Navigator.pop(context);
      if(!_isFromRecordScreen) {
        if(_isUserHeadacheEnded) {
          debugPrint('Headache Ended');
          await SignUpOnBoardProviders.db.deleteUserCurrentHeadacheData();
        } else {
          var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

          CurrentUserHeadacheModel? currentUserHeadacheModel = await SignUpOnBoardProviders.db
              .getUserCurrentHeadacheData(userProfileInfoData.userId!);

          currentUserHeadacheModel?.isFromServer = true;

          await SignUpOnBoardProviders.db.deleteUserCurrentHeadacheData();

          await SignUpOnBoardProviders.db
              .insertUserCurrentHeadacheData(currentUserHeadacheModel ?? CurrentUserHeadacheModel());
        }

        if (_isEditing) {
          Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
        } else {
          Navigator.pushNamed(context, Constant.addHeadacheSuccessScreenRouter);
        }
      } else {
        if(_isFromRecordScreen)
          Navigator.pop(context, _addHeadacheLogBloc.isHeadacheLogged);
        else
          Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
      }
    }
    _isButtonClicked = false;
  }

  void saveAndUpdateDataInLocalDatabase(UserAddHeadacheLogModel userAddHeadacheLogModel) async {
    try {
      int? userProgressDataCount = await SignUpOnBoardProviders.db
          .checkUserProgressDataAvailable(
          SignUpOnBoardProviders.TABLE_ADD_HEADACHE);
      if (userProgressDataCount == 0) {
        SignUpOnBoardProviders.db
            .insertAddHeadacheDetails(userAddHeadacheLogModel);
      } else {
        SignUpOnBoardProviders.db
            .updateAddHeadacheDetails(userAddHeadacheLogModel);
      }
    } catch (e) {
      e.toString();
    }
  }

  void requestService() async {
    List<Map>? userHeadacheDataList;
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    if (userProfileInfoData != null)
      userHeadacheDataList = await _addHeadacheLogBloc.fetchDataFromLocalDatabase(userProfileInfoData.userId!);
    else
      userHeadacheDataList = await _addHeadacheLogBloc.fetchDataFromLocalDatabase("4214");
    if (userHeadacheDataList!.length > 0) {
      userHeadacheDataList.forEach((element) {
        List<dynamic> map = jsonDecode(element['selectedAnswers']);
        map.forEach((element) {
          selectedAnswers.add(SelectedAnswers(questionTag: element['questionTag'], answer: element['answer']));
        });
      });
      signUpOnBoardSelectedAnswersModel.selectedAnswers = selectedAnswers;
    }

    if(_isFromRecordScreen) {
      if(_currentUserHeadacheModel.headacheId != null) {
        await _addHeadacheLogBloc.fetchCalendarHeadacheLogDayData(widget.currentUserHeadacheModel!, context);
        signUpOnBoardSelectedAnswersModel.selectedAnswers = _addHeadacheLogBloc.selectedAnswersList;

        SelectedAnswers? startTimeSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers?.firstWhereOrNull((element) => element.questionTag == Constant.onSetTag);
        SelectedAnswers? endTimeSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers?.firstWhereOrNull((element) => element.questionTag == Constant.endTimeTag);
        SelectedAnswers? onGoingSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers?.firstWhereOrNull((element) => element.questionTag == Constant.onGoingTag);

        if(startTimeSelectedAnswer != null) {
          _currentUserHeadacheModel.selectedDate = startTimeSelectedAnswer.answer;
        }

        if(endTimeSelectedAnswer != null) {
          _currentUserHeadacheModel.selectedEndDate = endTimeSelectedAnswer.answer;
        }

        if(onGoingSelectedAnswer != null) {
          _currentUserHeadacheModel.isOnGoing = onGoingSelectedAnswer.answer!.toLowerCase() != 'no';
        }

        debugPrint(_currentUserHeadacheModel.toString());
      } else {
        //put condition for the headache id to fetch the current on going headache data
        _addHeadacheLogBloc.fetchAddHeadacheLogData(context);
      }
    } else {
      if(_currentUserHeadacheModel.headacheId != null) {
        await _addHeadacheLogBloc.fetchCalendarHeadacheLogDayData(widget.currentUserHeadacheModel!, context);
        signUpOnBoardSelectedAnswersModel.selectedAnswers = _addHeadacheLogBloc.selectedAnswersList;
      } else {
        //put condition for the headache id to fetch the current on going headache data
        _addHeadacheLogBloc.fetchAddHeadacheLogData(context);
      }
    }
  }

  void _showDiscardChangesBottomSheet() async {
    var resultOfDiscardChangesBottomSheet = await showCupertinoModalPopup(
        context: context,
        builder: (context) => DiscardChangesBottomSheet());
    if (resultOfDiscardChangesBottomSheet == Constant.discardChanges) {
      if(!_isFromRecordScreen) {
        if (!widget.currentUserHeadacheModel!.isFromServer!) {
          await SignUpOnBoardProviders.db.deleteUserCurrentHeadacheData();
        }
      }
      //SignUpOnBoardProviders.db.deleteAllUserLogDayData();
      if(_isFromRecordScreen)
        Navigator.pop(context, _addHeadacheLogBloc.isHeadacheLogged);
      else
        Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
    } else if (resultOfDiscardChangesBottomSheet == Constant.saveAndExit) {
      if (!_isButtonClicked) {
        _isButtonClicked = true;
        saveDataInLocalDataBaseOrServer();
      }
    }
  }

/*  Future<void> _fetchHealthData() async {
    if (Platform.isIOS) {
      List<HealthDataType> types;
      types = [
        HealthDataType.HEADACHE_NOT_PRESENT,
        HealthDataType.HEADACHE_MILD,
        HealthDataType.HEADACHE_MODERATE,
        HealthDataType.HEADACHE_SEVERE,
        HealthDataType.HEADACHE_UNSPECIFIED,
      ];

      List<HealthDataAccess> permissions = [];

      types.forEach((element) {
        if (element == HealthDataType.HEADACHE_NOT_PRESENT || element == HealthDataType.HEADACHE_MILD || element == HealthDataType.HEADACHE_MODERATE || element == HealthDataType.HEADACHE_SEVERE || element == HealthDataType.HEADACHE_UNSPECIFIED)
          permissions.add(HealthDataAccess.WRITE);
        else
          permissions.add(HealthDataAccess.READ);
      });

      bool requested = await healthFactory.requestAuthorization(types, permissions: permissions);

      if (requested) {
        _healthAuthorization = requested;
      } else {
        debugPrint('Authorization not granted - error in authorization');
      }
    }
  }

  Future<void> _addHeadacheDataToHealthKit() async {
    if (Platform.isIOS) {
      if (_healthAuthorization) {
        SelectedAnswers? startTimeSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers?.firstWhereOrNull((element) => element.questionTag == Constant.onSetTag);
        SelectedAnswers? endTimeSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers?.firstWhereOrNull((element) => element.questionTag == Constant.endTimeTag);

        SelectedAnswers? intensitySelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers?.firstWhereOrNull((element) => element.questionTag == Constant.intensity);
        double? intensityValue = double.parse(intensitySelectedAnswer?.answer ?? '1.0');

        HealthDataType headacheHealthDataType = HealthDataType.HEADACHE_MILD;
        if (intensityValue >= 4 && intensityValue <= 7) {
          headacheHealthDataType = HealthDataType.HEADACHE_MODERATE;
        } else if (intensityValue >= 8 && intensityValue <= 10) {
          headacheHealthDataType = HealthDataType.HEADACHE_SEVERE;
        }

        DateTime? startDateTime = DateTime.tryParse(startTimeSelectedAnswer?.answer ?? '');
        DateTime? endDateTime = DateTime.tryParse(endTimeSelectedAnswer?.answer ?? '');

        if (startDateTime != null && endDateTime != null) {
          startDateTime = DateTime(
              startDateTime.year, startDateTime.month, startDateTime.day,
              startDateTime.hour, startDateTime.minute);
          endDateTime = DateTime(
              endDateTime.year, endDateTime.month, endDateTime.day,
              endDateTime.hour, endDateTime.minute);


          double minutes = endDateTime.difference(startDateTime).inMinutes.toDouble();

          bool isAdded = await healthFactory.writeHealthData(minutes, headacheHealthDataType, startDateTime, endDateTime);

          debugPrint('isAdded????$isAdded');
        }
      }
    }
  }*/
}

class HeadacheTypeInfo with ChangeNotifier {
  updateHeadacheTypeInfo() {
    notifyListeners();
  }
}
