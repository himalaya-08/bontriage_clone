import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/blocs/LoginScreenBloc.dart';
import 'package:mobile/models/ForgotPasswordModel.dart';
import 'package:mobile/repository/social_signin_repository.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/ChangePasswordScreen.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/OtpValidationScreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'BirthYearPicker.dart';

class LoginScreen extends StatefulWidget {
  final LoginScreenArgumentModel? loginScreenArgumentModel;

  const LoginScreen({Key? key, this.loginScreenArgumentModel}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  String? emailValue;
  String? passwordValue;
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  LoginScreenBloc _loginScreenBloc = LoginScreenBloc();
  AnimationController? _sizeAnimationController;

  AnimationController? _passwordSizeAnimationController;

  late SocialSigninRepository _socialSigninRepository;

  //Method to toggle password visibility
  void _togglePasswordVisibility() {
    var passwordHiddenInfo = Provider.of<PasswordHiddenInfo>(context, listen: false);
    passwordHiddenInfo.updateIsHidden(!passwordHiddenInfo.isHidden());
  }

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    emailTextEditingController = TextEditingController();
    passwordTextEditingController = TextEditingController();
    _loginScreenBloc = LoginScreenBloc();
    _socialSigninRepository = SocialSigninRepository();

    _sizeAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
        reverseDuration: Duration(milliseconds: 300));

    _passwordSizeAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 300),
    );

    _passwordSizeAnimationController!.forward();

    _sizeAnimationController!.forward();

    _emailFocusNode.requestFocus();

    _listenToForgotPasswordStream();
  }

  @override
  void dispose() {
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    _sizeAnimationController!.dispose();
    _loginScreenBloc.dispose();
    _passwordSizeAnimationController!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appConfig = AppConfig.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: Constant.backgroundBoxDecoration,
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Visibility(
                      visible: !widget.loginScreenArgumentModel!.isFromMore,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image(
                          image: AssetImage(Constant.closeIcon),
                          width: 26,
                          height: 26,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                            image: AssetImage(appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.compassGreen : Constant.tonixSplash),
                            width: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? 78 : 128,
                            height: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? 78 : 128,
                          ),
                          Visibility(
                            visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                            child: SizedBox(
                              width: 10,
                            ),
                          ),
                          Visibility(
                            visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                            child: CustomTextWidget(
                              text: Constant.migraineMentor,
                              style: TextStyle(
                                  color: Constant.chatBubbleGreen,
                                  fontSize: 24,
                                  fontFamily: Constant.jostMedium),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        margin: EdgeInsets.only(top: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? 60 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 35,
                              child: CustomTextFormFieldWidget(
                                focusNode: _emailFocusNode,
                                onEditingComplete: () {
                                  emailValue = emailTextEditingController.text.trim();
                                },
                                onFieldSubmitted: (value) {
                                  emailValue = emailTextEditingController.text.trim();
                                  _passwordFocusNode.requestFocus();
                                },
                                controller: emailTextEditingController,
                                onChanged: (value) {
                                  emailValue = emailTextEditingController.text.trim();
                                },
                                keyboardType: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? TextInputType.emailAddress : TextInputType.numberWithOptions(signed: true),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: Constant.jostMedium),
                                cursorColor: Constant.bubbleChatTextView,
                                textAlign: TextAlign.start,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 20,
                                  ),
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  filled: true,
                                  fillColor: Constant.locationServiceGreen,
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      borderSide: BorderSide(
                                          color: Constant.editTextBoarderColor,
                                          width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      borderSide: BorderSide(
                                          color: Constant.editTextBoarderColor,
                                          width: 1)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: CustomTextWidget(
                                text: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.email : Constant.subjectId,
                                style: TextStyle(
                                  fontFamily: Constant.jostRegular,
                                  fontSize: 13,
                                  color: Constant.chatBubbleGreen,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            SizeTransition(
                              sizeFactor: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? _sizeAnimationController! : _passwordSizeAnimationController!,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 35,
                                    child: Consumer2<PasswordHiddenInfo, ForgotPasswordClickedInfo>(
                                      builder: (context, data, data1, child) {
                                        return CustomTextFormFieldWidget(
                                          obscureText: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? data.isHidden() : (!data1.isForgotPasswordClicked() ? data.isHidden() : false),
                                          focusNode: _passwordFocusNode,
                                          onEditingComplete: () {
                                            passwordValue = passwordTextEditingController.text;
                                          },
                                          onFieldSubmitted: (String value) {
                                            passwordValue = passwordTextEditingController.text;
                                            FocusScope.of(context).requestFocus(FocusNode());
                                            _clickedLoginButton(null);
                                          },
                                          controller: passwordTextEditingController,
                                          onChanged: (String value) {
                                            passwordValue = passwordTextEditingController.text;
                                          },
                                          onTap: () {
                                            if(appConfig?.buildFlavor == Constant.tonixBuildFlavor)
                                              if(data1.isForgotPasswordClicked())
                                                _showBirthYearActionSheet();
                                          },
                                          readOnly: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? false : data1.isForgotPasswordClicked(),
                                          style: TextStyle(
                                              fontSize: 15, fontFamily: Constant.jostMedium),
                                          cursorColor: Constant.bubbleChatTextView,
                                          textAlign: TextAlign.start,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 20),
                                            hintStyle:
                                            TextStyle(fontSize: 15, color: Colors.black),
                                            filled: true,
                                            fillColor: Constant.locationServiceGreen,
                                            suffixIcon:  data1.isForgotPasswordClicked() ? null : IconButton(
                                              onPressed: _togglePasswordVisibility,
                                              icon: Image.asset(data.isHidden()
                                                  ? Constant.hidePassword
                                                  : Constant.showPassword),
                                            ),
                                            suffixIconConstraints: BoxConstraints(
                                              minHeight: 30,
                                              maxHeight: 35,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.all(Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color: Constant.editTextBoarderColor,
                                                  width: 1),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.all(Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color: Constant.editTextBoarderColor,
                                                  width: 1),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Consumer<ForgotPasswordClickedInfo>(
                                    builder: (context, data, child) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: CustomTextWidget(
                                          text: data.isForgotPasswordClicked() ? (appConfig?.buildFlavor == Constant.tonixBuildFlavor ? Constant.yearBirth : Constant.password) : Constant.password,
                                          style: TextStyle(
                                            fontFamily: Constant.jostRegular,
                                            fontSize: 13,
                                            color: Constant.chatBubbleGreen,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Consumer<LoginErrorInfo>(
                              builder: (context, data, child) {
                                return Visibility(
                                  visible: data.isShowAlert(),
                                  child: Container(
                                    margin: EdgeInsets.only(left: 20, right: 10, top: 10),
                                    child: Row(
                                      children: [
                                        Image(
                                          image: AssetImage(Constant.warningPink),
                                          width: 17,
                                          height: 17,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: CustomTextWidget(
                                            text: data.getErrorMessage(),
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Constant.pinkTriggerColor,
                                                fontFamily: Constant.jostRegular),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizeTransition(
                              sizeFactor: _sizeAnimationController!,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      _forgotPasswordClicked();
                                    },
                                    child: CustomTextWidget(
                                      text: Constant.forgotPassword,
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          decorationColor: Constant.chatBubbleGreen,
                                          fontFamily: Constant.jostMedium,
                                          fontSize: 13,
                                          color: Constant.chatBubbleGreen),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<ForgotPasswordClickedInfo>(
                        builder: (context, data, child) {
                          return Column(
                            children: [
                              TextButton(
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(FocusNode());

                                  if(!data.isForgotPasswordClicked())
                                    _clickedLoginButton(null);
                                  else
                                    _clickedNextButton();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 40),
                                  decoration: BoxDecoration(
                                    color: Constant.chatBubbleGreen,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: CustomTextWidget(
                                    text: !data.isForgotPasswordClicked() ? Constant.login : Constant.next,
                                    style: TextStyle(
                                        color: Constant.bubbleChatTextView,
                                        fontSize: 14,
                                        fontFamily: Constant.jostMedium,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              AnimatedCrossFade(
                                  crossFadeState: !data.isForgotPasswordClicked()
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  duration: Duration(milliseconds: 300),
                                  firstChild: GestureDetector(
                                    onTap: () {
                                      if(widget.loginScreenArgumentModel!.isFromMore) {
                                        if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
                                          Navigator.pushReplacementNamed(context,
                                              Constant
                                                  .welcomeStartAssessmentScreenRouter);
                                        else
                                          Navigator.pushNamed(context, Constant.signUpScreenRouter);
                                      }
                                      else
                                        Navigator.pop(context);
                                    },
                                    child: CustomTextWidget(
                                      text: Constant.register,
                                      style: TextStyle(
                                          color: Constant.chatBubbleGreen,
                                          fontSize: 14,
                                          fontFamily: Constant.jostMedium,
                                          decoration: TextDecoration.underline,
                                        decorationColor: Constant.chatBubbleGreen,
                                      ),
                                    ),
                                  ),
                                  secondChild: GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).requestFocus(FocusNode());

                                      var forgotPasswordClickedInfoData = Provider.of<ForgotPasswordClickedInfo>(context, listen: false);
                                      forgotPasswordClickedInfoData.updateForgotPasswordClicked(false);

                                      var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
                                      loginErrorInfoData.updateLoginErrorInfo(false, Constant.blankString);

                                      emailTextEditingController.text = Constant.blankString;
                                      passwordTextEditingController.text = Constant.blankString;
                                      _sizeAnimationController!.forward();
                                    },
                                    child: CustomTextWidget(
                                      text: "Switch to login",
                                      style: TextStyle(
                                          color: Constant.chatBubbleGreen,
                                          fontSize: 14,
                                          fontFamily: Constant.jostMedium,
                                          decoration: TextDecoration.underline,
                                        decorationColor: Constant.chatBubbleGreen,
                                      ),
                                    ),
                                  )
                              ),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      _facebookSignIn();
                                    },
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.facebook_rounded, color: Color(0XFF1877F2), size: 35,),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      _googleSignIn();
                                    },
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Constant.chatBubbleGreen),
                                        color: Colors.white
                                      ),
                                      child: Image.asset(Constant.googleIcon, fit: BoxFit.fill,),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      _xSignIn();
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Color(0XFF000000),
                                      backgroundImage: ExactAssetImage(Constant.xIcon),
                                      radius: 20,
                                    ),
                                  )
                                ],
                              )
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// This method will be use for to Check Validation of Email and Password value. If condition is true then we will hit the API.
  /// or not then show alert to user into the screen.
  void _clickedLoginButton(String? source) {
    emailValue = emailValue != null ? emailValue!.trim().toLowerCase() : Constant.blankString;

    var appConfig = AppConfig.of(context);

    if (emailValue != null &&
        //passwordValue != null &&
        emailValue != Constant.blankString &&
        //passwordValue != Constant.blankString &&
        (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? Utils.validateEmail(emailValue!) : true)) {
      var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
      loginErrorInfoData.updateLoginErrorInfo(false, Constant.blankString);

      Utils.showApiLoaderDialog(context,
          networkStream: _loginScreenBloc.loginDataStream,
          tapToRetryFunction: () {
        _loginScreenBloc.enterSomeDummyDataToStream();
        _loginService(source);
      });
      _loginService(source);
    } else {
      var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
      loginErrorInfoData.updateLoginErrorInfo(true, appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.loginAlertMessage : Constant.tonixLoginAlertMessage);
      /// TO:Do Show Error message
    }
  }

  /// This method will be use for to get response of Login API. If response is successful then navigate the screen into Home Screen.
  /// or not then show alert to the user into the screen.
  void _loginService(String? source) async {
    FirebaseMessaging _fcm = FirebaseMessaging.instance;
    var deviceToken = await _fcm.getToken();
    //debugPrint('DeviceToken????$deviceToken');
    //Clipboard.setData(ClipboardData(text: deviceToken));
    var appConfig = AppConfig.of(context);

    var response = await _loginScreenBloc.getLoginOfUser(
        emailValue!, passwordValue ?? Constant.blankString, source, deviceToken!, context);
    if (response is String) {
      if (response == Constant.success) {
        var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
        loginErrorInfoData.updateLoginErrorInfo(false, Constant.blankString);
        if(!widget.loginScreenArgumentModel!.isFromMore) {
          if(widget.loginScreenArgumentModel!.isFromSignUp!) {
            Navigator.popUntil(context, ModalRoute.withName(Constant.onBoardingScreenSignUpRouter));
          } else {
            Navigator.popUntil(context, ModalRoute.withName(Constant.welcomeStartAssessmentScreenRouter));
          }
        } else {
          Navigator.pop(context);
        }

        Utils.navigateToHomeScreen(context, false);
      } else if (response == Constant.userNotFound) {
        _loginScreenBloc.init();
        Navigator.pop(context);

        var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
        loginErrorInfoData.updateLoginErrorInfo(true, appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.loginAlertMessage : Constant.tonixLoginAlertMessage);
      }
    }
  }

  ///Method that handles the user login via Google
  Future<void> _googleSignIn() async{
    var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
    // google login:
    try{
      await GoogleSignIn().signOut();
      GoogleSignInAccount? googleUser = await _socialSigninRepository.signInWithGoogle();
      if (googleUser != null && googleUser.email.isNotEmpty) {
          emailValue = googleUser.email.trim();
        _clickedLoginButton(Constant.googleSocialSource);
      }
    }
    catch(err){
      emailValue = null;
      passwordValue = null;
      loginErrorInfoData.updateLoginErrorInfo(true, Constant.somethingWentWrong);
    }
  }

  ///Method that handles the user login via facebook
  Future<void> _facebookSignIn() async{
    var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
    // Facebook login:
    try{
      FacebookAuth.instance.logOut();
      String? userEmail = await _socialSigninRepository.signInWithFacebook();
      if (userEmail != null && userEmail.isNotEmpty) {
        emailValue = userEmail.trim();
        _clickedLoginButton(Constant.facebookSocialSource);
      }
    }
    catch(err){
      emailValue = null;
      passwordValue = null;
      loginErrorInfoData.updateLoginErrorInfo(true, Constant.somethingWentWrong);
    }
  }

  ///Method that handles the user login via X
  Future<void> _xSignIn() async{
    var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
    // X login:
    try{
      String? userEmail = await _socialSigninRepository.signInWithX();
      if (userEmail != null && userEmail.isNotEmpty) {
          emailValue = userEmail.trim();
        _clickedLoginButton(Constant.twitterSocialSource);
      }
    }
    catch(err){
      emailValue = null;
      passwordValue = null;
      loginErrorInfoData.updateLoginErrorInfo(true, Constant.somethingWentWrong);
    }
  }

  void _forgotPasswordClicked() async {
    FocusScope.of(context).requestFocus(FocusNode());

    var forgotPasswordClickedInfoData = Provider.of<ForgotPasswordClickedInfo>(context, listen: false);
    forgotPasswordClickedInfoData.updateForgotPasswordClicked(true);

    var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
    loginErrorInfoData.updateLoginErrorInfo(false, Constant.blankString);

    emailTextEditingController.text = Constant.blankString;
    passwordTextEditingController.text = Constant.blankString;

    _sizeAnimationController!.reverse();
  }

  void _listenToForgotPasswordStream() {
    _loginScreenBloc.forgotPasswordStream.listen((event) {
      var appConfig = AppConfig.of(context);
      if (event != null && event is ForgotPasswordModel) {
        if (event.status == 1) {
          if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
            Future.delayed(Duration(milliseconds: 350), () {
              Navigator.pushNamed(context, Constant.otpValidationScreenRouter,
                  arguments: OTPValidationArgumentModel(
                      email: emailTextEditingController.text.trim(),
                      isForgotPasswordFromSignUp: widget
                          .loginScreenArgumentModel!.isFromSignUp ?? false,
                      isFromMore: widget.loginScreenArgumentModel!.isFromMore));
            });
          } else {
            Future.delayed(Duration(milliseconds: 350), () {
              Navigator.pushNamed(context, Constant.changePasswordScreenRouter, arguments: ChangePasswordArgumentModel(emailValue: emailValue,  isFromMoreLogin: true));
              var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
              loginErrorInfoData.updateLoginErrorInfo(false, Constant.blankString);
            });
          }
        } else {
          if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
            var loginErrorInfoData = Provider.of<LoginErrorInfo>(
                context, listen: false);
            loginErrorInfoData.updateLoginErrorInfo(true,
                event.messageText == Constant.userNotFound
                    ? 'The email address you have entered is not registered.'
                    : event.messageText!);
          } else {
            var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
            loginErrorInfoData.updateLoginErrorInfo(true, event.messageText!);
          }
        }
      }
    });
  }

  void _clickedNextButton() {
    String email = emailTextEditingController.text.trim();
    String birthYear = passwordTextEditingController.text.trim();

    var appConfig = AppConfig.of(context);

    if(email != null && email.isEmpty) {
      var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
      loginErrorInfoData.updateLoginErrorInfo(true, appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? 'Please enter your email address.' : 'Please enter your subject ID.');
    } else if(appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? !Utils.validateEmail(email) : false) {
      var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
      loginErrorInfoData.updateLoginErrorInfo(true, 'Please enter a valid email address.');
    } else if (appConfig?.buildFlavor == Constant.tonixBuildFlavor ? birthYear.isEmpty : false) {
      var loginErrorInfoData = Provider.of<LoginErrorInfo>(context, listen: false);
      loginErrorInfoData.updateLoginErrorInfo(true, 'Please select your year of birth.');
    } else {
      _loginScreenBloc.initNetworkStreamController();
      Utils.showApiLoaderDialog(context,
          networkStream: _loginScreenBloc.networkStream,
          tapToRetryFunction: () {
        _loginScreenBloc.enterDummyDataToNetworkStream();
        _loginScreenBloc.callForgotPasswordApi(email, birthYear, context);
      });
      _loginScreenBloc.callForgotPasswordApi(email, birthYear, context);
    }
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _showBirthYearActionSheet() async {
    var resultFromActionSheet = await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (context) => BirthYearPicker(
          selectedBirthValue: passwordTextEditingController.text,
        ));
    if (resultFromActionSheet != null)
      passwordTextEditingController.text = resultFromActionSheet;
  }
}


class PasswordHiddenInfo with ChangeNotifier {
  bool _isHidden = true;

  bool isHidden() => _isHidden;

  updateIsHidden(bool isHidden) {
    _isHidden = isHidden;

    notifyListeners();
  }
}

class ForgotPasswordClickedInfo with ChangeNotifier {
  bool _isForgotPasswordClicked = false;

  bool isForgotPasswordClicked() => _isForgotPasswordClicked;

  updateForgotPasswordClicked(bool isForgotPasswordClicked) {
    _isForgotPasswordClicked = isForgotPasswordClicked;
    notifyListeners();
  }
}

class LoginErrorInfo with ChangeNotifier {
  bool _isShowAlert = false;
  String _errorMessage = Constant.blankString;

  bool isShowAlert() => _isShowAlert;
  String getErrorMessage() => _errorMessage;

  updateLoginErrorInfo(bool isShowAlert, String errorMessage) {
    _isShowAlert = isShowAlert;
    _errorMessage = errorMessage;

    notifyListeners();
  }
}

class LoginScreenArgumentModel {
  bool? isFromSignUp;
  bool isFromMore;

  LoginScreenArgumentModel({this.isFromMore = false, this.isFromSignUp});
}

