import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';

import 'package:provider/provider.dart';
import 'package:mobile/view/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/UserProgressDataModel.dart';
import '../providers/SignUpOnBoardProviders.dart';

import 'CustomTextWidget.dart';

class WelcomeStartAssessmentScreen extends StatefulWidget {
  @override
  _WelcomeStartAssessmentScreenState createState() =>
      _WelcomeStartAssessmentScreenState();
}

class _WelcomeStartAssessmentScreenState
    extends State<WelcomeStartAssessmentScreen> {
  String _buttonText = Constant.startYourAssessment;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _checkUserAlreadyLoggedIn();
    Utils.setAnalyticsCurrentScreen(
        Constant.welcomeStartAssessmentScreen, context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UserProgressDataModel? userProgressModel =
          await SignUpOnBoardProviders.db.getUserProgress();

      if (userProgressModel != null) {
        setState(() {
          _buttonText = Constant.continueYourAssessment;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: Constant.backgroundBoxDecoration,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 15, horizontal: Constant.screenHorizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Image(
                          image: AssetImage(Constant.compassGreen),
                          width: 78,
                          height: 78,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CustomTextWidget(
                          text: '${Constant.migraineMentor}\u2122',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Constant.chatBubbleGreen,
                            fontSize: 24,
                            fontFamily: Constant.jostMedium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 100),
                    CustomTextWidget(
                      text: Constant.conquerYourHeadaches,
                      style: TextStyle(
                        color: Constant.chatBubbleGreen,
                        fontSize: 20,
                        fontFamily: Constant.jostMedium,
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomTextWidget(
                      text: Constant.personalizedUnderstanding,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Constant.locationServiceGreen,
                        height: 1.3,
                        fontSize: 15,
                        fontFamily: Constant.jostRegular,
                      ),
                    ),
                    SizedBox(height: 100),
                    BouncingWidget(
                      onPressed: () {
                        Utils.navigateToUserOnProfileBoard(context);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Constant.chatBubbleGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomTextWidget(
                          text: _buttonText,
                          style: TextStyle(
                            color: Constant.bubbleChatTextView,
                            fontSize: 16,
                            fontFamily: Constant.jostMedium,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Consumer<WelcomeStartAssessmentInfo>(
                      builder: (context, data, child) {
                        return Column(
                          children: [
                            Visibility(
                              visible: data.isAlreadyLoggedIn(),
                              child: GestureDetector(
                                onTap: () {
                                  _moveToHomeScreen();
                                },
                                child: CustomTextWidget(
                                  text: Constant.cancelAssessment,
                                  style: TextStyle(
                                    color: Constant.chatBubbleGreen,
                                    fontFamily: Constant.jostRegular,
                                    fontSize: 15,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Constant.chatBubbleGreen,
                                    decorationThickness: 1,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: !data.isAlreadyLoggedIn(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomTextWidget(
                                    text: Constant.or,
                                    style: TextStyle(
                                      wordSpacing: 1,
                                      color: Constant.chatBubbleGreen,
                                      fontFamily: Constant.jostRegular,
                                      fontSize: 15,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Constant.loginScreenRouter,
                                          arguments: LoginScreenArgumentModel(
                                              isFromSignUp: false));
                                    },
                                    child: CustomTextWidget(
                                      text: Constant.signIn,
                                      style: TextStyle(
                                          color: Constant.chatBubbleGreen,
                                          fontFamily: Constant.jostBold,
                                          wordSpacing: 1,
                                          fontSize: 15,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              Constant.chatBubbleGreen,
                                          decorationThickness: 1),
                                    ),
                                  ),
                                  CustomTextWidget(
                                    text: Constant.toAn,
                                    style: TextStyle(
                                      color: Constant.chatBubbleGreen,
                                      fontFamily: Constant.jostRegular,
                                      fontSize: 15,
                                      wordSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Visibility(
                              visible: !data.isAlreadyLoggedIn(),
                              child: CustomTextWidget(
                                text: Constant.existingAccount,
                                style: TextStyle(
                                    color: Constant.chatBubbleGreen,
                                    fontFamily: Constant.jostRegular,
                                    fontSize: 15,
                                    wordSpacing: 1),
                              ),
                            ),
                          ],
                        );
                      },
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

  void _checkUserAlreadyLoggedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var welcomeStartAssessmentInfoData =
        Provider.of<WelcomeStartAssessmentInfo>(context, listen: false);
    welcomeStartAssessmentInfoData.updateAlreadyLoggedIn(
        sharedPreferences.getBool(Constant.userAlreadyLoggedIn) ?? false);
  }

  void _moveToHomeScreen() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isProfileInComplete =
        sharedPreferences.getBool(Constant.isProfileInCompleteStatus) ?? false;
    Utils.navigateToHomeScreen(context, isProfileInComplete);
  }
}

class WelcomeStartAssessmentInfo with ChangeNotifier {
  bool _isAlreadyLoggedIn = false;

  bool isAlreadyLoggedIn() => _isAlreadyLoggedIn;

  updateAlreadyLoggedIn(bool isAlreadyLoggedIn) {
    _isAlreadyLoggedIn = isAlreadyLoggedIn;
    notifyListeners();
  }
}
