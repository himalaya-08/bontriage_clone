import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/models/CompassTutorialModel.dart';
import 'package:mobile/models/LocalQuestionnaire.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserProgressDataModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/RadarChart.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ChatBubble.dart';
import 'CustomScrollBar.dart';

class SignUpFirstStepCompassResult extends StatefulWidget {
  @override
  _SignUpFirstStepCompassResultState createState() =>
      _SignUpFirstStepCompassResultState();
}

class _SignUpFirstStepCompassResultState
    extends State<SignUpFirstStepCompassResult> with TickerProviderStateMixin, WidgetsBindingObserver {
  bool darkMode = false;
  double numberOfFeatures = 4;
  double sliderValue = 1;
  int _buttonPressedValue = 0;
  late List<String> _bubbleTextViewList;
  bool isBackButtonHide = false;
  late AnimationController _animationController;
  bool isEndOfOnBoard = false;
  bool isVolumeOn = false;
  late ScrollController _scrollController;
  bool _isButtonClicked = false;
  bool _isVolumeClicked = false;

  late int userFrequencyValue;
  late int userDurationValue;
  late int userIntensityValue;
  late int userDisabilityValue;

  late List<List<int>> userCompassAxesData;

  String userScoreData = '0';

  late List<int> ticks;
  late CompassTutorialModel _compassTutorialModel;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    _compassTutorialModel = CompassTutorialModel();
    _compassTutorialModel.isFromOnBoard = true;

    _compassTutorialModel.currentDateTime = DateTime.now();

    userCompassAxesData = [
      [0, 0, 0, 0]
    ];
    _bubbleTextViewList = [
      Constant.welcomePersonalizedHeadacheFirstTextView,
      Constant.welcomePersonalizedHeadacheSecondTextView,
      Constant.welcomePersonalizedHeadacheThirdTextView,
      Constant.welcomePersonalizedHeadacheFourthTextView,
      Constant.welcomePersonalizedHeadacheFifthTextView
    ];

    _animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    _animationController.forward();
    if (!isEndOfOnBoard && isVolumeOn)
      TextToSpeechRecognition.speechToText(
          _bubbleTextViewList[_buttonPressedValue]);

    // Save user progress database
    saveUserProgressInDataBase();
    setVolumeIcon();

    getCompassAxesFromDatabase();

    _scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.detached || state == AppLifecycleState.inactive){
      TextToSpeechRecognition.stopSpeech();
    }else if(state == AppLifecycleState.resumed){
      TextToSpeechRecognition.speechToText(_bubbleTextViewList[_buttonPressedValue]);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SignUpFirstStepCompassResult oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  ///Method to toggle volume on or off
  void _toggleVolume() async {
    setState(() {
      _isVolumeClicked = true;
      isVolumeOn = !isVolumeOn;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constant.chatBubbleVolumeState, isVolumeOn);
    TextToSpeechRecognition.speechToText(
        Constant.welcomePersonalizedHeadacheFirstTextView);

    Future.delayed(Duration(milliseconds: 500), () {
      _isVolumeClicked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ticks = [2, 4, 6, 8, 10];
    if (!isEndOfOnBoard && isVolumeOn)
      TextToSpeechRecognition.speechToText(
          _bubbleTextViewList[_buttonPressedValue]);
    var features = [
      "A",
      "B",
      "C",
      "D",
    ];

    if(!_isVolumeClicked) {
      if (!_animationController.isAnimating) {
        _animationController.reset();
        _animationController.forward();
      }

      try {
        _scrollController.animateTo(1,
            duration: Duration(milliseconds: 150), curve: Curves.easeIn);
        Future.delayed(Duration(milliseconds: 150), () {
          _scrollController.jumpTo(0);
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Container(
          decoration: Constant.backgroundBoxDecoration,
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Utils.navigateToExitScreen(context);
                        },
                        child: Image(
                          image: AssetImage(Constant.closeIcon),
                          width: 26,
                          height: 26,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image(
                              image: AssetImage(Constant.userAvatar),
                              width: 60.0,
                              height: 60.0,
                            ),
                            GestureDetector(
                              onTap: _toggleVolume,
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                child: AnimatedCrossFade(
                                  duration: Duration(milliseconds: 250),
                                  firstChild: Image(
                                    alignment: Alignment.topLeft,
                                    image: AssetImage(Constant.volumeOn),
                                    width: 20,
                                    height: 20,
                                  ),
                                  secondChild: Image(
                                    alignment: Alignment.topLeft,
                                    image: AssetImage(Constant.volumeOff),
                                    width: 20,
                                    height: 20,
                                  ),
                                  crossFadeState: isVolumeOn
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 17, top: 25),
                            child: ChatBubble(
                              painter:
                                  ChatBubblePainter(Constant.chatBubbleGreen),
                              child: AnimatedSize(
                                duration: Duration(milliseconds: 300),
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: FadeTransition(
                                    opacity: _animationController,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: Constant.chatBubbleMaxHeight,
                                      ),
                                      child: Theme(
                                        data: ThemeData(
                                            highlightColor: Colors.black),
                                        child: CustomScrollBar(
                                          isAlwaysShown: true,
                                          controller: _scrollController,
                                          child: SingleChildScrollView(
                                            controller: _scrollController,
                                            physics: BouncingScrollPhysics(),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: CustomTextWidget(
                                                text: _bubbleTextViewList[
                                                    _buttonPressedValue],
                                                style: TextStyle(
                                                    height: 1.3,
                                                    fontSize: 15,
                                                    color: Constant
                                                        .bubbleChatTextView,
                                                    fontFamily:
                                                        Constant.jostRegular),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RotatedBox(
                            quarterTurns: 3,
                            child: GestureDetector(
                              onTap: () {
                                Utils.showCompassTutorialDialog(context, 3, compassTutorialModel: _compassTutorialModel);
                              },
                              child: CustomTextWidget(
                                text: "Frequency",
                                style: TextStyle(
                                    color: Color(0xffafd794),
                                    fontSize: 14,
                                    fontFamily: Constant.jostMedium),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Utils.showCompassTutorialDialog(context, 1, compassTutorialModel: _compassTutorialModel);
                                },
                                child: CustomTextWidget(
                                  text: "Intensity",
                                  style: TextStyle(
                                      color: Color(0xffafd794),
                                      fontSize: 14,
                                      fontFamily: Constant.jostMedium),
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  child: Center(
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          child: darkMode
                                              ? RadarChart.dark(
                                                  ticks: ticks,
                                                  features: features,
                                                  data: userCompassAxesData,
                                                  reverseAxis: false,
                                                  compassValue: 0,
                                                )
                                              : RadarChart.light(
                                                  ticks: ticks,
                                                  features: features,
                                                  data: userCompassAxesData,
                                                  reverseAxis: false,
                                                  compassValue: 0,
                                                ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: 38,
                                            height: 38,
                                            child: Center(
                                              child: CustomTextWidget(
                                                text: userScoreData,
                                                style: TextStyle(
                                                    color: Color(0xff0E1712),
                                                    fontSize: 14,
                                                    fontFamily:
                                                        Constant.jostMedium),
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xffB8FFFF),
                                              border: Border.all(
                                                  color: Color(0xffB8FFFF),
                                                  width: 1.2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Utils.showCompassTutorialDialog(context, 2, compassTutorialModel: _compassTutorialModel);
                                },
                                child: CustomTextWidget(
                                  text: "Disability",
                                  style: TextStyle(
                                      color: Color(0xffafd794),
                                      fontSize: 14,
                                      fontFamily: Constant.jostMedium),
                                ),
                              ),
                            ],
                          ),
                          RotatedBox(
                            quarterTurns: 1,
                            child: GestureDetector(
                              onTap: () {
                                Utils.showCompassTutorialDialog(context, 4, compassTutorialModel: _compassTutorialModel);
                              },
                              child: CustomTextWidget(
                                text: "Duration",
                                style: TextStyle(
                                    color: Color(0xffafd794),
                                    fontSize: 14,
                                    fontFamily: Constant.jostMedium),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          left: (isBackButtonHide)
                              ? 0
                              : (MediaQuery.of(context).size.width - 190),
                          duration: Duration(milliseconds: 250),
                          child: AnimatedOpacity(
                            opacity: (isBackButtonHide) ? 1.0 : 0.0,
                            duration: Duration(milliseconds: 250),
                            child: BouncingWidget(
                              duration: Duration(milliseconds: 100),
                              scaleFactor: 1.5,
                              onPressed: _onBackPressed,
                              child: Container(
                                width: 130,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Color(0xffafd794),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: CustomTextWidget(
                                    text: Constant.back,
                                    style: TextStyle(
                                      color: Constant.bubbleChatTextView,
                                      fontSize: 14,
                                      fontFamily: Constant.jostMedium,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: BouncingWidget(
                            duration: Duration(milliseconds: 100),
                            scaleFactor: 1.5,
                            onPressed: () {
                              if (!_isButtonClicked) {
                                _isButtonClicked = true;
                                TextToSpeechRecognition.stopSpeech();
                                setState(() {
                                  if (_buttonPressedValue >= 0 &&
                                      _buttonPressedValue < 4) {
                                    _buttonPressedValue++;
                                    isBackButtonHide = true;
                                  } else {
                                    moveToNextScreen();
                                  }
                                });
                                Future.delayed(Duration(milliseconds: 350), () {
                                  _isButtonClicked = false;
                                });
                              }
                            },
                            child: Container(
                              width: 130,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Color(0xffafd794),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: CustomTextWidget(
                                  text: Constant.next,
                                  style: TextStyle(
                                    color: Constant.bubbleChatTextView,
                                    fontSize: 14,
                                    fontFamily: Constant.jostMedium,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void saveUserProgressInDataBase() async {
    UserProgressDataModel userProgressDataModel = UserProgressDataModel();
    int? userProgressDataCount = await SignUpOnBoardProviders.db
        .checkUserProgressDataAvailable(
            SignUpOnBoardProviders.TABLE_USER_PROGRESS);
    userProgressDataModel.userId = Constant.userID;
    userProgressDataModel.step = Constant.firstCompassEventStep;
    userProgressDataModel.userScreenPosition = 0;
    userProgressDataModel.questionTag = "";

    if (userProgressDataCount == 0) {
      SignUpOnBoardProviders.db.insertUserProgress(userProgressDataModel);
    } else {
      SignUpOnBoardProviders.db.updateUserProgress(userProgressDataModel);
    }
  }

  void moveToNextScreen() async {
    isEndOfOnBoard = true;
    TextToSpeechRecognition.speechToText("");
    Navigator.pushReplacementNamed(
        context, Constant.onBoardCreateAccountScreenRouter);
  }

  void setVolumeIcon() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? isVolume = sharedPreferences.getBool(Constant.chatBubbleVolumeState);
    setState(() {
      if (isVolume == null || isVolume) {
        isVolumeOn = true;
      } else {
        isVolumeOn = false;
      }
    });
  }

  Future<bool> _onBackPressed() async {
    TextToSpeechRecognition.stopSpeech();
    if (!_isButtonClicked) {
      _isButtonClicked = true;
      if (_buttonPressedValue == 0) {
        Future.delayed(Duration(milliseconds: 350), () {
          _isButtonClicked = false;
        });
        Utils.navigateToExitScreen(context);
        return false;
      } else {
        setState(() {
          if (_buttonPressedValue <= 4 && _buttonPressedValue > 1) {
            _buttonPressedValue--;
          } else {
            isBackButtonHide = false;
            _buttonPressedValue = 0;
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

  void getCompassAxesFromDatabase() async {
    int baseMaxValue = 10;

    var userFrequencyNormalisedValue;
    var userDurationNormalisedValue;
    var userDisabilityNormalisedValue;

    List<LocalQuestionnaire> localQuestionnaireData =
        await SignUpOnBoardProviders.db
            .getQuestionnaire(Constant.firstEventStep);
    print(localQuestionnaireData);
    SignUpOnBoardSelectedAnswersModel answerListData =
        SignUpOnBoardSelectedAnswersModel.fromJson(
            json.decode(localQuestionnaireData[0].selectedAnswers!));
    List<SelectedAnswers> selectedAnswerListData =
        answerListData.selectedAnswers!;
    var userFrequency = selectedAnswerListData.firstWhereOrNull(
        (frequencyElement) =>
            frequencyElement.questionTag == Constant.headacheFreeTag);

    if (userFrequency != null) {
      ///freq = 2
      userFrequencyValue = int.tryParse(userFrequency.answer!)!;
      if (userFrequencyValue == 0) {
        _compassTutorialModel.currentMonthFrequency = 31 - userFrequencyValue;
        userFrequencyNormalisedValue = (31 - userFrequencyValue) ~/ (31 / baseMaxValue);
        userFrequencyValue = 31 - userFrequencyValue;
      } else {
        _compassTutorialModel.currentMonthFrequency = (31 - userFrequencyValue);
        userFrequencyNormalisedValue = (31 - userFrequencyValue) ~/ (31 / baseMaxValue);
        ///userNormalizedFreq = 9
        userFrequencyValue = (31 - userFrequencyValue);
      }
    }
    var userDuration = selectedAnswerListData.firstWhereOrNull(
        (intensityElement) =>
            intensityElement.questionTag == Constant.headacheTypicalTag);
    if (userDuration != null) {
      int? userMaxDurationValue;
      ///duration = 3
      userDurationValue = int.tryParse(userDuration.answer!)!;
      _compassTutorialModel.currentMonthDuration = userDurationValue;
      if (userDurationValue <= 1) {
        userMaxDurationValue = 1;
      } else if (userDurationValue > 1 && userDurationValue <= 24) {
        userMaxDurationValue = 24;
      } else if (userDurationValue > 24 && userDurationValue <= 72) {
        userMaxDurationValue = 72;
      }
      userDurationNormalisedValue =
          userDurationValue ~/ (userMaxDurationValue! / baseMaxValue);
      ///userNormalisedDuration = 1.25 = 1
    }
    var userIntensity = selectedAnswerListData.firstWhereOrNull(
        (intensityElement) =>
            intensityElement.questionTag == Constant.headacheTypicalBadPainTag);
    if (userIntensity != null) {
      ///intensity = 1
      userIntensityValue = int.tryParse(userIntensity.answer!)!;
      _compassTutorialModel.currentMonthIntensity = userIntensityValue;
      //userFrequencyValue = userFrequencyValue ~/ (90 / baseMaxValue);
    }
    var userDisability = selectedAnswerListData.firstWhereOrNull(
        (intensityElement) =>
            intensityElement.questionTag == Constant.headacheDisabledTag);
    if (userDisability != null) {
      ///disability = 0
      userDisabilityValue = int.tryParse(userDisability.answer!)!;
      _compassTutorialModel.currentMonthDisability = userDisabilityValue;
      userDisabilityNormalisedValue = userDisabilityValue ~/ (4 / baseMaxValue);
    }

    print(
        'Frequency???${userFrequency!.answer}Duration???${userDuration!.answer}Intensity???${userIntensity!.answer}Disability???${userDisability!.answer}');
    setState(() {
      // Intensity,Duration,Disability,Frequency
      /*  1. 16  last 3 month  1
      2. 32 hour last 3 month
      3. 7 intensity
      4 . 2 disability*/
      userCompassAxesData = [
        [
          userIntensityValue,
          userDurationNormalisedValue,
          userDisabilityNormalisedValue,
          userFrequencyNormalisedValue,
        ]
      ];
      print('First Step Compass Axes $userCompassAxesData');
      setCompassDataScore(userIntensityValue, userDisabilityValue,
          userFrequencyValue, userDurationValue);
    });
  }

  void setCompassDataScore(int userIntensityValue, int userDisabilityValue,
      int userFrequencyValue, int userDurationValue) {
    int? userMaxDurationValue;
    var intensityScore = userIntensityValue / 10 * 100.0;  ///10
    var disabilityScore = userDisabilityValue.toInt() / 4 * 100.0; ///0
    var frequencyScore = userFrequencyValue.toInt() / 31 * 100.0; ///93.54
    if (userDurationValue <= 1) {
      userMaxDurationValue = 1;

    } else if (userDurationValue > 1 && userDurationValue <= 24) {
      userMaxDurationValue = 24;
    } else if (userDurationValue > 24 && userDurationValue <= 72) {
      userMaxDurationValue = 72;
    }
    var durationScore =
        userDurationValue.toInt() / userMaxDurationValue! * 100.0; ///12.5
    print('intensityScore???$intensityScore???disabilityScore???$disabilityScore???frequencyScore???$frequencyScore???durationScore???$durationScore');
    var userTotalScore =
        (intensityScore + disabilityScore + frequencyScore + durationScore) / 4;
    print('userTotalScore???$userTotalScore');
    userScoreData = userTotalScore.round().toString();///29
    print('First Step User ScoreData$userScoreData');
  }

}
