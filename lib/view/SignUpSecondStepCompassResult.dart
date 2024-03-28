import 'dart:io';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:mobile/blocs/SignUpSecondStepCompassBloc.dart';
import 'package:mobile/models/CompassTutorialModel.dart';
import 'package:mobile/models/RecordsCompassAxesResultModel.dart';
import 'package:mobile/models/UserGenerateReportDataModel.dart';
import 'package:mobile/models/UserProgressDataModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/RadarChart.dart';
import 'package:mobile/util/TabNavigatorRoutes.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import 'package:mobile/view/CustomScrollBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/models/PDFScreenArgumentModel.dart';
import 'ChatBubble.dart';
import 'CustomTextWidget.dart';

class SignUpSecondStepCompassResult extends StatefulWidget {
  @override
  _SignUpSecondStepCompassResultState createState() =>
      _SignUpSecondStepCompassResultState();
}

class _SignUpSecondStepCompassResultState
    extends State<SignUpSecondStepCompassResult>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late SignUpSecondStepCompassBloc _bloc;
  bool darkMode = false;
  double numberOfFeatures = 4;
  double sliderValue = 1;
  int _buttonPressedValue = 0;
  late List<String> _bubbleTextViewList;
  bool isBackButtonHide = false;
  AnimationController? _animationController;
  bool isEndOfOnBoard = false;
  bool isVolumeOn = false;
  bool _isButtonClicked = false;

  String? userHeadacheName = "";
  String? _userScoreData = '0';

  static late String userHeadacheTextView;

  ScrollController _scrollController = ScrollController();

  int userFrequencyValue = 0;
  int userDurationValue = 0;
  int userIntensityValue = 0;
  int userDisabilityValue = 0;

  CompassTutorialModel? _compassTutorialModel;
  DateTime startDateTime = DateTime.now();

  var data = [
    [0, 0, 0, 0]
  ];

  bool _isPdfScreenOpened = false;

  bool _shouldSpeak = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _compassTutorialModel = CompassTutorialModel();
    _compassTutorialModel!.isFromOnBoard = true;

    WidgetsBinding.instance.addObserver(this);

    _bloc = SignUpSecondStepCompassBloc();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getUserHeadacheName();
    });
    _bubbleTextViewList = [
      Constant.welcomePersonalizedHeadacheFirstTextView,
      Constant.accurateClinicalImpression,
      Constant.moreDetailedHistory,
    ];

    _animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    _animationController!.forward();
    /*if (!isEndOfOnBoard && isVolumeOn)
      TextToSpeechRecognition.speechToText(
          bubbleChatTextView[_buttonPressedValue]);*/
    //Save User Progress
    saveUserProgressInDataBase();
    setVolumeIcon();

    _listenToViewReportStream();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      TextToSpeechRecognition.stopSpeech();
    } else if (state == AppLifecycleState.resumed) {
      debugPrint('booleanvalue???$_isPdfScreenOpened');
      if (!isEndOfOnBoard &&
          isVolumeOn &&
          !_isPdfScreenOpened &&
          _shouldSpeak) {
        debugPrint("2Speech???????${bubbleChatTextView[_buttonPressedValue]}");
        TextToSpeechRecognition.speechToText(
            bubbleChatTextView[_buttonPressedValue]);
      }
    }
  }

  @override
  void didUpdateWidget(SignUpSecondStepCompassResult oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  ///Method to toggle volume on or off
  void _toggleVolume() async {
    setState(() {
      isVolumeOn = !isVolumeOn;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constant.chatBubbleVolumeState, isVolumeOn);
    TextToSpeechRecognition.speechToText("");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController!.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('inbuild func');
    const ticks = [2, 4, 6, 8, 10];
    debugPrint('_isPdfScreenOpened????$_isPdfScreenOpened');
    var features = [
      "A",
      "B",
      "C",
      "D",
    ];

    if (!_animationController!.isAnimating) {
      _animationController!.reset();
      _animationController!.forward();
    }

    try {
      _scrollController.animateTo(1,
          duration: Duration(milliseconds: 150), curve: Curves.easeIn);
      Future.delayed(Duration(milliseconds: 150), () {
        _scrollController.jumpTo(0);
      });
    } catch (e) {}

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Container(
          decoration: Constant.backgroundBoxDecoration,
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: Constant.chatBubbleHorizontalPadding),
              child: StreamBuilder(
                  stream: _bloc.recordsCompassDataStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData ) {
                      var axesData =  snapshot.data;
                      if(axesData is RecordsCompassAxesResultModel)
                      _getCompassAxesFromDatabase(axesData);

                      _shouldSpeak = true;
                      /*userHeadacheTextView =
                      'Based on what you entered, it looks like your $userHeadacheName could potentially be considered by doctors to be ${_bloc.clinicalImpression}. We\'ll learn more about this as you log your headache and daily habits in the app';*/
                      userHeadacheTextView = _getClinicalImpressionString(
                          _bloc.clinicalImpressionList);
                      _bubbleTextViewList[0] = userHeadacheTextView;

                      bubbleChatTextView[0] = userHeadacheTextView;

                      if (!isEndOfOnBoard &&
                          isVolumeOn &&
                          !_isPdfScreenOpened &&
                          _shouldSpeak) {
                        debugPrint(
                            '1Speech???${bubbleChatTextView[_buttonPressedValue]}');
                        TextToSpeechRecognition.speechToText(
                            bubbleChatTextView[_buttonPressedValue]);
                      }

                      return Column(
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
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image(
                                      image: AssetImage(Constant.userAvatar),
                                      width: 60.0,
                                      height: 60.0,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: _toggleVolume,
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
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 17, top: 25),
                                    child: ChatBubble(
                                      painter: ChatBubblePainter(
                                          Constant.chatBubbleGreen),
                                      child: AnimatedSize(
                                        duration: Duration(milliseconds: 300),
                                        child: Container(
                                            padding: EdgeInsets.all(15),
                                            child: FadeTransition(
                                              opacity: _animationController!,
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxHeight: Constant
                                                      .chatBubbleMaxHeight,
                                                ),
                                                child: RawScrollbar(
                                                  thumbColor: Colors.black,
                                                  thickness: 1.5,
                                                  radius: Radius.circular(2),
                                                  controller: _scrollController,
                                                  thumbVisibility: true,
                                                  child: SingleChildScrollView(
                                                    controller:
                                                        _scrollController,
                                                    physics:
                                                        BouncingScrollPhysics(),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: _buttonPressedValue ==
                                                              0
                                                          ? _getClinicalImpressionWidget(
                                                              _bloc
                                                                  .clinicalImpressionList)
                                                          : CustomRichTextWidget(
                                                              text: TextSpan(
                                                                children:
                                                                    _getBubbleTextSpans(),
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                        Utils.showCompassTutorialDialog(
                                            context, 3,
                                            compassTutorialModel:
                                                _compassTutorialModel!);
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
                                          Utils.showCompassTutorialDialog(
                                              context, 1,
                                              compassTutorialModel:
                                                  _compassTutorialModel!);
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
                                          width: 185,
                                          height: 185,
                                          child: Center(
                                            child: Stack(
                                              children: <Widget>[
                                                Container(
                                                  child: RadarChart.light(
                                                    ticks: ticks,
                                                    features: features,
                                                    data: data,
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
                                                        text: _userScoreData!,
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xff0E1712),
                                                            fontSize: 14,
                                                            fontFamily: Constant
                                                                .jostMedium),
                                                      ),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xffB8FFFF),
                                                      border: Border.all(
                                                          color:
                                                              Color(0xffB8FFFF),
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
                                          Utils.showCompassTutorialDialog(
                                              context, 2,
                                              compassTutorialModel:
                                                  _compassTutorialModel!);
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
                                        Utils.showCompassTutorialDialog(
                                            context, 4,
                                            compassTutorialModel:
                                                _compassTutorialModel!);
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
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 40),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Constant.headacheCompassColor),
                                  height: 11,
                                  width: 11,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                CustomTextWidget(
                                  text: userHeadacheName!,
                                  style: TextStyle(
                                      color: Constant.locationServiceGreen,
                                      fontSize: 11,
                                      fontFamily: Constant.jostMedium),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: Stack(
                              children: [
                                AnimatedPositioned(
                                  left: (isBackButtonHide)
                                      ? 0
                                      : (MediaQuery.of(context).size.width -
                                          190),
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
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: CustomTextWidget(
                                            text: Constant.back,
                                            style: TextStyle(
                                              color:
                                                  Constant.bubbleChatTextView,
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
                                              _buttonPressedValue < 2) {
                                            _buttonPressedValue++;
                                            isBackButtonHide = true;
                                          } else {
                                            moveToNextScreen();
                                          }
                                        });
                                        Future.delayed(
                                            Duration(milliseconds: 350), () {
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
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Center(
                              child: CustomTextWidget(
                                text: Constant.or,
                                style: TextStyle(
                                    color: Constant.locationServiceGreen,
                                    fontSize: 13,
                                    fontFamily: Constant.jostMedium),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: Center(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _isPdfScreenOpened = true;

                                  TextToSpeechRecognition.stopSpeech();
                                  _getUserReport();
                                },
                                child: CustomTextWidget(
                                  text: Constant.viewDetailedReport,
                                  style: TextStyle(
                                      color: Constant.locationServiceGreen,
                                      fontSize: 13,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Constant.locationServiceGreen,
                                      fontFamily: Constant.jostMedium),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    } else
                      return Container();
                  }),
            ),
          ),
        ),
      ),
    );
  }

  String _getClinicalImpressionString(List<String> clinicalImpressionList) {
    List<String> stringList = userHeadacheName!.trim().split(' ');

    String headacheTypeName = userHeadacheName!.trim();

    String lastWordOfHeadacheType = stringList[stringList.length - 1];

    String result = '';

    if (clinicalImpressionList.length == 1) {
      if (clinicalImpressionList[0] == Constant.defaultClinicalImpression) {
        result = 'Based on your response, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}does not appear to align with clinically known headache types. More importantly, some of your answers raise red flags that warrant further evaluation by your provider or headache specialist.';
        return result;
      } else if (clinicalImpressionList[0] == Constant.medicalHistoryClinicalImpression) {
        result = 'The information in your medical history regarding your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}does not match any of the recognized diagnostic criteria for headache disorders, as specified by the International Classification of Headache Disorders. This is often the result of conflicting information in your medical history, which your physician can help you sort out.';
        return result;
      } else {
        result = 'Based on what you entered, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}could potentially be ${clinicalImpressionList[0]}';
        return result;
      }
    } else {
      String? defaultMessage = clinicalImpressionList.firstWhereOrNull((element) => element == Constant.defaultClinicalImpression);

      if (defaultMessage == null) {
        result = 'Based on what you entered, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}could potentially be ${clinicalImpressionList.length == 2 ? 'either' : 'any of the following'}:\n${_getClinicalImpressionStringList(clinicalImpressionList)}.';
        return result;
      } else {
        if (clinicalImpressionList.length == 2) {
          result = 'Based on what you entered, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}could potentially be ${clinicalImpressionList[0].toLowerCase()}; ${Constant.defaultClinicalImpressionReplacement.toLowerCase()}';
          return result;
        } else {
          result = 'Based on what you entered, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}could potentially be ${clinicalImpressionList.length == 3 ? 'either' : 'any of the following'}:\n${_getClinicalImpressionStringList(clinicalImpressionList)}.\n${Constant.defaultClinicalImpressionReplacement}';
          return result;
        }
      }
    }
  }

  String _getClinicalImpressionStringList(List<String> clinicalImpressionList) {
    int num = 1;

    String result = '';

    clinicalImpressionList.forEach((element) {
      if (element != Constant.defaultClinicalImpression) {
        result = '$result\n$num. ${element.replaceAll(".", Constant.blankString)}';
        num++;
      }
    });

    return result;
  }

  Widget _getClinicalImpressionWidget(List<String> clinicalImpressionList) {
    List<Widget> widgetList = [];

    List<String> stringList = userHeadacheName!.trim().split(' ');

    String headacheTypeName = userHeadacheName!.trim();

    String lastWordOfHeadacheType = stringList[stringList.length - 1];

    var textStyle = TextStyle(
      color: Constant.bubbleChatTextView,
      fontSize: 14,
      fontFamily: Constant.jostRegular,
    );

    if (clinicalImpressionList.length == 1) {
      if (clinicalImpressionList[0] == Constant.defaultClinicalImpression) {
        widgetList = [
          CustomTextWidget(
            text: 'Based on your response, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}does not appear to align with clinically known headache types. More importantly, some of your answers raise red flags that warrant further evaluation by your provider or headache specialist.',
            style: textStyle,
          ),
          SizedBox(height: 10,),
        ];
      } else if (clinicalImpressionList[0] == Constant.medicalHistoryClinicalImpression) {
        widgetList = [
          CustomTextWidget(
            text: 'The information in your medical history regarding your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}does not match any of the recognized diagnostic criteria for headache disorders, as specified by the International Classification of Headache Disorders. This is often the result of conflicting information in your medical history, which your physician can help you sort out.',
            style: textStyle,
          ),
          SizedBox(height: 10,),
        ];
      } else {
        widgetList = [
          CustomTextWidget(
            text: 'Based on what you entered, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}could potentially be ${clinicalImpressionList[0]}',
            style: textStyle,
          ),
          SizedBox(height: 10,),
        ];
      }
    } else {
      String? defaultMessage = clinicalImpressionList.firstWhereOrNull((element) => element == Constant.defaultClinicalImpression);

      if (defaultMessage == null) {
        widgetList = [
          CustomTextWidget(
            text: 'Based on what you entered, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}could potentially be ${clinicalImpressionList.length == 2 ? 'either' : 'any of the following'}:',
            style: textStyle,
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              children: _getClinicalImpressionWidgetList(clinicalImpressionList),
            ),
          ),
          SizedBox(height: 10,),
        ];
      } else {
        if (clinicalImpressionList.length == 2) {
          widgetList = [
            CustomTextWidget(
              text: 'Based on what you entered, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}could potentially be ${clinicalImpressionList[0].toLowerCase()}; ${Constant.defaultClinicalImpressionReplacement.toLowerCase()}',
              style: textStyle,
            ),
            SizedBox(height: 10,),
          ];
        } else {
          widgetList = [
            CustomTextWidget(
              text: 'Based on what you entered, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}could potentially be ${clinicalImpressionList.length == 3 ? 'either' : 'any of the following'}:',
              style: textStyle,
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                children: _getClinicalImpressionWidgetList(clinicalImpressionList),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            CustomTextWidget(
              text: Constant.defaultClinicalImpressionReplacement,
              style: textStyle,
            ),
            SizedBox(height: 10,),
          ];
        }
      }
    }

    return Column(
      children: widgetList,
    );
  }

  List<Widget> _getClinicalImpressionWidgetList(List<String> clinicalImpressionList) {
    List<Widget> widgetList = [];
    int num = 1;

    var textStyle = TextStyle(
      color: Constant.bubbleChatTextView,
      fontSize: 14,
      fontFamily: Constant.jostRegular,
    );

    clinicalImpressionList.forEach((element) {
      if (element != Constant.defaultClinicalImpression) {
        widgetList.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 15,
                  child: CustomTextWidget(
                    text: '$num.',
                    style: textStyle,
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: CustomTextWidget(
                    text: element.replaceAll(".", Constant.blankString),
                    style: textStyle,
                  ),
                ),
              ],
            )
        );
        num++;
      }
    });

    return widgetList;
  }

  List<TextSpan> _getBubbleTextSpans() {
    List<TextSpan> list = [];
    if (_buttonPressedValue == 0) {
      list.add(TextSpan(
          /*text: 'Based on what you entered, it looks like your ',
          style: TextStyle(
              height: 1.3,
              fontSize: 15,
              fontFamily: Constant.jostRegular,
              color: Constant.bubbleChatTextView)));
      list.add(TextSpan(
          text: userHeadacheName,
          style: TextStyle(
              height: 1.3,
              fontSize: 13,
              fontFamily: Constant.jostBold,
              color: Constant.bubbleChatTextView)));
      list.add(TextSpan(
          text: ' could potentially be considered by doctors to be ',
          style: TextStyle(
              height: 1.3,
              fontSize: 15,
              fontFamily: Constant.jostRegular,
              color: Constant.bubbleChatTextView)));
      list.add(TextSpan(
          text: '${_bloc.clinicalImpression}. ',
          style: TextStyle(
              height: 1.3,
              fontSize: 13,
              fontFamily: Constant.jostBold,
              color: Constant.bubbleChatTextView)));
      list.add(TextSpan(
          text:
              'We\'ll learn more about this as you log your headache and daily habits in the app.',
          style: TextStyle(
              height: 1.3,
              fontSize: 15,
              fontFamily: Constant.jostRegular,
              color: Constant.bubbleChatTextView))*/
              ));
    } else {
      list.add(TextSpan(
          text: _bubbleTextViewList[_buttonPressedValue],
          style: TextStyle(
              fontWeight: FontWeight.normal,
              height: 1.3,
              fontSize: 15,
              fontFamily: Constant.jostRegular,
              color: Constant.bubbleChatTextView)));
    }

    return list;
  }

  static List<String> bubbleChatTextView = [
    userHeadacheTextView,
    Constant.accurateClinicalImpression,
    Constant.moreDetailedHistory,
  ];

  void saveUserProgressInDataBase() async {
    UserProgressDataModel userProgressDataModel = UserProgressDataModel();
    int? userProgressDataCount = await SignUpOnBoardProviders.db
        .checkUserProgressDataAvailable(
            SignUpOnBoardProviders.TABLE_USER_PROGRESS);
    userProgressDataModel.userId = Constant.userID;
    userProgressDataModel.step = Constant.secondCompassEventStep;
    userProgressDataModel.userScreenPosition = 0;
    userProgressDataModel.questionTag = "";

    if (userProgressDataCount == 0) {
      SignUpOnBoardProviders.db.insertUserProgress(userProgressDataModel);
    } else {
      SignUpOnBoardProviders.db.updateUserProgress(userProgressDataModel);
    }
  }

  void moveToNextScreen() async {
    debugPrint("");
    TextToSpeechRecognition.speechToText("");
    isEndOfOnBoard = true;
    Navigator.pushReplacementNamed(
        context, Constant.partTwoOnBoardMoveOnScreenRouter);
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
          if (_buttonPressedValue <= 2 && _buttonPressedValue > 1) {
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

  void getUserHeadacheName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userHeadacheName =
        sharedPreferences.get(Constant.userHeadacheName).toString();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Utils.showApiLoaderDialog(context, networkStream: _bloc.networkDataStream,
          tapToRetryFunction: () {
        _bloc.networkDataSink.add(Constant.loading);
        _bloc.fetchFirstLoggedScoreData(userHeadacheName!, context);
      });
      _bloc.fetchFirstLoggedScoreData(userHeadacheName!, context);
    });
  }

  void _getCompassAxesFromDatabase(
      RecordsCompassAxesResultModel recordsCompassAxesResultModel) async {
    _compassTutorialModel!.currentDateTime =
        DateTime.tryParse(recordsCompassAxesResultModel.calendarEntryAt!);
    int baseMaxValue = 10;

    int userFrequencyNormalisedValue = 0;
    int userDurationNormalisedValue = 0;
    int userDisabilityNormalisedValue = 0;

    Axes? userFrequency = recordsCompassAxesResultModel.signUpAxes?.firstWhereOrNull((intensityElement) => intensityElement.name == 'Frequency');

    debugPrint(userFrequency.toString());


    if (userFrequency != null) {
      userFrequencyValue = userFrequency?.value!.toInt() ?? 0;
      if (userFrequencyValue == 0) {
        _compassTutorialModel!.currentMonthFrequency =
            (31 - userFrequencyValue!);
        userFrequencyNormalisedValue =
            (31 - userFrequencyValue!) ~/ (31 / baseMaxValue);
        userFrequencyValue = 31 - userFrequencyValue!;
      } else {
        _compassTutorialModel!.currentMonthFrequency =
            (31 - userFrequencyValue!);
        userFrequencyNormalisedValue =
            (31 - userFrequencyValue!) ~/ (31 / baseMaxValue);
        userFrequencyValue = (31 - userFrequencyValue!);
      }
    }
    Axes? userDuration = recordsCompassAxesResultModel.signUpAxes
        ?.firstWhereOrNull(
            (intensityElement) => intensityElement.name == 'Duration');
    if (userDuration != null) {
      int? userMaxDurationValue;
      userDurationValue = userDuration.value!.toInt();
      _compassTutorialModel!.currentMonthDuration = userDurationValue!;
      if (userDurationValue! <= 1) {
        userMaxDurationValue = 1;
      } else if (userDurationValue! > 1 && userDurationValue! <= 24) {
        userMaxDurationValue = 24;
      } else if (userDurationValue! > 24 && userDurationValue! <= 72) {
        userMaxDurationValue = 72;
      }
      userDurationNormalisedValue =
          userDurationValue! ~/ (userMaxDurationValue! / baseMaxValue);
    }
    Axes? userIntensity = recordsCompassAxesResultModel.signUpAxes
        ?.firstWhereOrNull(
            (intensityElement) => intensityElement.name == 'Intensity');
    if (userIntensity != null) {
      userIntensityValue = userIntensity.value!.toInt();
      _compassTutorialModel!.currentMonthIntensity = userIntensityValue!;
    }
    Axes? userDisability = recordsCompassAxesResultModel.signUpAxes
        ?.firstWhereOrNull(
            (intensityElement) => intensityElement.name == 'Disability');
    if (userDisability != null) {
      userDisabilityValue = userDisability.value!.toInt();
      _compassTutorialModel!.currentMonthDisability = userDisabilityValue!;
      userDisabilityNormalisedValue =
          userDisabilityValue! ~/ (4 / baseMaxValue);
    }
    debugPrint(
        'Frequency???${userFrequency!.value}Duration???${userDuration!.value}Intensity???${userIntensity!.value}Disability???${userDisability!.value}');
    // Intensity,Duration,Disability,Frequency
    /*  1. 16  last 3 month  1
      2. 32 hour last 3 month
      3. 7 intensity
      4 . 2 disability*/
    data = [
      [
        userIntensityValue!,
        userDurationNormalisedValue,
        userDisabilityNormalisedValue,
        userFrequencyNormalisedValue
      ]
    ];
    debugPrint('Second Step Compass Data: $data');
    setCompassDataScore(userIntensityValue!, userDisabilityValue!,
        userFrequencyValue!, userDurationValue!);
  }

  void setCompassDataScore(int userIntensityValue, int userDisabilityValue,
      int userFrequencyValue, int userDurationValue) {
    int? userMaxDurationValue;
    var intensityScore = userIntensityValue / 10 * 100.0;
    var disabilityScore = userDisabilityValue.toInt() / 4 * 100.0;
    var frequencyScore = userFrequencyValue.toInt() / 31 * 100.0;
    if (userDurationValue <= 1) {
      userMaxDurationValue = 1;
    } else if (userDurationValue > 1 && userDurationValue <= 24) {
      userMaxDurationValue = 24;
    } else if (userDurationValue > 24 && userDurationValue <= 72) {
      userMaxDurationValue = 72;
    }
    var durationScore =
        userDurationValue.toInt() / userMaxDurationValue! * 100.0;
    print(
        'intensityScore???$intensityScore???disabilityScore???$disabilityScore???frequencyScore???$frequencyScore???durationScore???$durationScore');
    var userTotalScore =
        (intensityScore + disabilityScore + frequencyScore + durationScore) / 4;
    print('userTotalScore???$userTotalScore');
    _userScoreData = userTotalScore.round().toString();
    print('First Step User ScoreData$_userScoreData');
  }

  ///Method to get permission of the storage.
  Future<bool> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      return await Constant.platform.invokeMethod('getStoragePermission');
    } else {
      return true;
    }
  }

  void _getUserReport() {
    startDateTime = DateTime.now();
    DateTime endDateTime;

    startDateTime = DateTime(startDateTime.year, startDateTime.month, 1);

    int totalDaysInCurrentMonth =
    Utils.daysInCurrentMonth(startDateTime.month, startDateTime.month);

    endDateTime = DateTime(startDateTime.year, startDateTime.month, totalDaysInCurrentMonth);

    _bloc.initNetworkStreamController();
    Utils.showApiLoaderDialog(
        context,
        networkStream: _bloc.networkDataStream,
        tapToRetryFunction: () {
          _bloc.enterDummyDataToNetworkStream();
          _bloc.getUserGenerateReportData(
              '${startDateTime.year}-${startDateTime.month}-${startDateTime.day}T00:00:00Z',
              '${endDateTime.year}-${endDateTime.month}-${endDateTime.day}T00:00:00Z',
              userHeadacheName ?? '', context);
        }
    );
    _bloc.getUserGenerateReportData(
        '${startDateTime.year}-${startDateTime.month}-${startDateTime.day}T00:00:00Z',
        '${endDateTime.year}-${endDateTime.month}-${endDateTime.day}T00:00:00Z',
        userHeadacheName ?? '', context);
  }

  ///Method to listen to view report stream
  void _listenToViewReportStream() {
    _bloc.viewReportStream.listen((reportModel) {
      if (reportModel is UserGenerateReportDataModel) {
        _navigateToPdfScreen(reportModel.map!.base64!);
      }
    });
  }

  ///Method to navigate to pdf screen
  void _navigateToPdfScreen(String base64String) {
    _isPdfScreenOpened = true;
    debugPrint("");
    TextToSpeechRecognition.speechToText("");
    Future.delayed(Duration(milliseconds: 300), () async {
      await Navigator.pushNamed(context, TabNavigatorRoutes.pdfScreenRoute, arguments: PDFScreenArgumentModel(base64String: base64String, monthYear: Utils.getMonthYearText(startDateTime)));
      Future.delayed(Duration(milliseconds: 350), () {
        _isPdfScreenOpened = false;
      });
    });
  }
}
