import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/blocs/ChangePasswordScreenBloc.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  final ChangePasswordArgumentModel? changePasswordArgumentModel;

  const ChangePasswordScreen({Key? key, this.changePasswordArgumentModel})
      : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String? passwordValue;
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController = TextEditingController();

  String? confirmPasswordValue;
  ChangePasswordBloc _changePasswordBloc = ChangePasswordBloc();

  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  //Method to toggle password visibility
  void _togglePasswordVisibility() {
    var changePasswordVisibilityInfo =
        Provider.of<ChangePasswordVisibilityInfo>(context, listen: false);
    changePasswordVisibilityInfo
        .updateIsHidden(!changePasswordVisibilityInfo.isHidden());
  }

  //Method to toggle password visibility
  void _toggleConfirmPasswordVisibility() {
    var changeConfirmPasswordVisibilityInfo =
        Provider.of<ChangeConfirmPasswordVisibilityInfo>(context,
            listen: false);
    changeConfirmPasswordVisibilityInfo.updateIsConfirmPasswordHidden(
        !changeConfirmPasswordVisibilityInfo.isConfirmPasswordHidden());
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    _changePasswordBloc = ChangePasswordBloc();
    confirmPasswordTextEditingController = TextEditingController();
    passwordTextEditingController = TextEditingController();

    passwordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(passwordFocusNode);
    });
  }

  @override
  void dispose() {
    confirmPasswordTextEditingController.dispose();
    passwordTextEditingController.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Constant.backgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image(
                      image: AssetImage(Constant.closeIcon),
                      width: 26,
                      height: 26,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: CustomTextWidget(
                text: 'Create New Password',
                style: TextStyle(
                    color: Constant.chatBubbleGreen,
                    fontSize: 18,
                    fontFamily: Constant.jostRegular),
              ),
            ),
            SizedBox(
              height: 60,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: CustomTextWidget(
                text: 'New Password',
                style: TextStyle(
                    fontFamily: Constant.jostRegular,
                    fontSize: 13,
                    color: Constant.chatBubbleGreen),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Consumer<ChangePasswordVisibilityInfo>(
                builder: (context, data, child) {
                  return Container(
                    height: 35,
                    child: CustomTextFormFieldWidget(
                      obscureText: data.isHidden(),
                      focusNode: passwordFocusNode,
                      textInputAction: TextInputAction.next,
                      controller: passwordTextEditingController,
                      onChanged: (String value) {
                        passwordValue = passwordTextEditingController.text;
                      },
                      onFieldSubmitted: (text) {
                        FocusScope.of(context)
                            .requestFocus(confirmPasswordFocusNode);
                      },
                      style: TextStyle(
                          fontSize: 15, fontFamily: Constant.jostMedium),
                      cursorColor: Constant.bubbleChatTextView,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        hintStyle: TextStyle(fontSize: 15, color: Colors.black),
                        filled: true,
                        fillColor: Constant.locationServiceGreen,
                        suffixIcon: IconButton(
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
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(
                                color: Constant.editTextBoarderColor,
                                width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(
                                color: Constant.editTextBoarderColor,
                                width: 1)),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: CustomTextWidget(
                text: 'Confirm Password',
                style: TextStyle(
                    fontFamily: Constant.jostRegular,
                    fontSize: 13,
                    color: Constant.chatBubbleGreen),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Container(
                height: 35,
                child: Consumer<ChangeConfirmPasswordVisibilityInfo>(
                  builder: (context, data, child) {
                    return CustomTextFormFieldWidget(
                      obscureText: data.isConfirmPasswordHidden(),
                      focusNode: confirmPasswordFocusNode,
                      onFieldSubmitted: (String value) {
                        _clickedChangePasswordButton();
                      },
                      controller: confirmPasswordTextEditingController,
                      onChanged: (String value) {
                        confirmPasswordValue =
                            confirmPasswordTextEditingController.text;
                      },
                      style: TextStyle(
                          fontSize: 15, fontFamily: Constant.jostMedium),
                      cursorColor: Constant.bubbleChatTextView,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        hintStyle: TextStyle(fontSize: 15, color: Colors.black),
                        filled: true,
                        fillColor: Constant.locationServiceGreen,
                        suffixIcon: IconButton(
                          onPressed: _toggleConfirmPasswordVisibility,
                          icon: Image.asset(data.isConfirmPasswordHidden()
                              ? Constant.hidePassword
                              : Constant.showPassword),
                        ),
                        suffixIconConstraints: BoxConstraints(
                          minHeight: 30,
                          maxHeight: 35,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(
                                color: Constant.editTextBoarderColor,
                                width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(
                                color: Constant.editTextBoarderColor,
                                width: 1)),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Consumer<ChangePasswordErrorInfo>(
              builder: (context, data, child) {
                return Visibility(
                  visible: data.isShowAlert(),
                  child: Container(
                    margin: EdgeInsets.only(left: 40, right: 10),
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
            SizedBox(
              height: 80,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: BouncingWidget(
                onPressed: () {
                  _clickedChangePasswordButton();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xffafd794),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: CustomTextWidget(
                      text: 'Change Password',
                      style: TextStyle(
                          color: Constant.bubbleChatTextView,
                          fontSize: 15,
                          fontFamily: Constant.jostMedium),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clickedChangePasswordButton() {
    FocusScope.of(context).requestFocus(FocusNode());
    passwordValue = passwordTextEditingController.text.trim();
    confirmPasswordValue = confirmPasswordTextEditingController.text.trim();

    var changePasswordErrorInfo =
        Provider.of<ChangePasswordErrorInfo>(context, listen: false);

    if (passwordValue == null ||
        passwordValue!.length < 8 ||
        !Utils.validatePassword(passwordValue!)) {
      changePasswordErrorInfo.updateErrorInfo(
          true, Constant.signUpAlertMessage);
    } else if (confirmPasswordValue == null ||
        confirmPasswordValue!.length < 8 ||
        !Utils.validatePassword(confirmPasswordValue!)) {
      changePasswordErrorInfo.updateErrorInfo(
          true, Constant.signUpAlertMessage);
    } else if (passwordValue != confirmPasswordValue) {
      changePasswordErrorInfo.updateErrorInfo(
          true, Constant.passwordNotMatchMessage);
    } else {
      changePasswordErrorInfo.updateErrorInfo(false, Constant.blankString);
      Utils.showApiLoaderDialog(context,
          networkStream: _changePasswordBloc.changePasswordDataStream,
          tapToRetryFunction: () {
        _changePasswordBloc.enterSomeDummyDataToStreamController();
        changePasswordService();
      });
      changePasswordService();
    }
  }

  void changePasswordService() async {
    var responseData = await _changePasswordBloc.sendChangePasswordData(
        widget.changePasswordArgumentModel!.emailValue!,
        passwordValue!,
        widget.changePasswordArgumentModel!.isFromMoreSettings, context);
    if (responseData is String) {
      if (responseData == Constant.success) {
        var changePasswordErrorInfo =
            Provider.of<ChangePasswordErrorInfo>(context, listen: false);
        changePasswordErrorInfo.updateErrorInfo(false, Constant.blankString);
        if (!widget.changePasswordArgumentModel!.isFromMoreSettings) {
          if (!widget.changePasswordArgumentModel!.isFromSignUp) {
            debugPrint(
                'isFromMore Change????${widget.changePasswordArgumentModel!.isFromMoreLogin}');
            if (widget.changePasswordArgumentModel!.isFromMoreLogin)
              Navigator.popUntil(
                  context, ModalRoute.withName(Constant.loginScreenRouter));
            else
              Navigator.popUntil(
                  context,
                  ModalRoute.withName(
                      Constant.welcomeStartAssessmentScreenRouter));
          } else
            Navigator.popUntil(context,
                ModalRoute.withName(Constant.onBoardingScreenSignUpRouter));

          Utils.navigateToHomeScreen(context, false);
        } else {
          await Utils.clearAllDataFromDatabaseAndCache();
          Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
          Navigator.pushReplacementNamed(context, Constant.loginScreenRouter,
              arguments: LoginScreenArgumentModel(
                  isFromSignUp: false, isFromMore: true));
        }
      }
    }
  }
}

class ChangePasswordArgumentModel {
  String? emailValue;
  bool isFromSignUp;
  bool isFromMoreSettings;
  bool isFromMoreLogin;

  ChangePasswordArgumentModel({
    this.emailValue,
    this.isFromSignUp = false,
    this.isFromMoreSettings = false,
    this.isFromMoreLogin = false,
  });
}

class ChangePasswordVisibilityInfo with ChangeNotifier {
  bool _isHidden = true;

  bool isHidden() => _isHidden;

  updateIsHidden(bool isHidden) {
    _isHidden = isHidden;
    notifyListeners();
  }
}

class ChangeConfirmPasswordVisibilityInfo with ChangeNotifier {
  bool _isConfirmPasswordHidden = true;

  bool isConfirmPasswordHidden() => _isConfirmPasswordHidden;

  updateIsConfirmPasswordHidden(bool isConfirmPasswordHidden) {
    _isConfirmPasswordHidden = isConfirmPasswordHidden;
    notifyListeners();
  }
}

class ChangePasswordErrorInfo with ChangeNotifier {
  bool _isShowAlert = false;
  String _errorMessage = Constant.blankString;

  bool isShowAlert() => _isShowAlert;

  String getErrorMessage() => _errorMessage;

  updateErrorInfo(bool isShowAlert, String errorMessage) {
    _isShowAlert = isShowAlert;
    _errorMessage = errorMessage;
    notifyListeners();
  }
}
