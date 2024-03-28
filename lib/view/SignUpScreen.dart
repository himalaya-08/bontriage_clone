import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile/blocs/TonixSignUpBloc.dart';
import 'package:mobile/models/HomeScreenArgumentModel.dart';
import 'package:mobile/models/SiteNameModelResponse.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:provider/provider.dart';

import '../blocs/SiteNameBloc.dart';
import 'BirthYearPicker.dart';
import 'CustomTextFormFieldWidget.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  late TextEditingController _subjectIdEditingController;
  late TextEditingController _birthYearEditingController;
  late TextEditingController _siteNameEditingController;
  late TextEditingController _passwordEditingController;
  late TextEditingController _confirmPassEditingController;

  late TonixSignUpBloc _bloc;
  late SiteNameBloc _siteNameBloc;
  var siteNameModelList;

  late FocusNode _subjectIdFocusNode;

  @override
  void initState() {
    super.initState();


    _subjectIdFocusNode = FocusNode();

    _bloc = TonixSignUpBloc();
    _siteNameBloc = SiteNameBloc();
    _subjectIdEditingController = TextEditingController();
    _birthYearEditingController = TextEditingController();
    _siteNameEditingController = TextEditingController();
    _passwordEditingController = TextEditingController();
    _confirmPassEditingController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Utils.showApiLoaderDialog(context, networkStream: _siteNameBloc.siteNameStream, tapToRetryFunction: () {
        _siteNameBloc.siteNameSink.add(Constant.loading);
        getSiteNameDate(); /// This method will be call when Register screen will be open.
      });
      getSiteNameDate();
    });
    _listenToSignUpStream();
  }

  @override
  void dispose() {
    _bloc.dispose();
    _siteNameBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: Container(
            decoration: Constant.backgroundBoxDecoration,
            child: SingleChildScrollView(
              physics: Utils.getScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                child: SafeArea(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    child: StreamBuilder<dynamic>(
                      stream: _siteNameBloc.siteNameStream,
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
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
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image(
                                    image: AssetImage(Constant.tonixSplash),
                                    width: 148,
                                    height: 148,
                                  ),

                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                margin: EdgeInsets.only(top: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 35,
                                      child: CustomTextFormFieldWidget(
                                        readOnly: true,
                                        onTap: () {
                                          _openSiteNameBottomSheet();
                                        },
                                        controller: _siteNameEditingController,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: Constant.jostMedium),
                                        cursorColor: Constant.bubbleChatTextView,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 20),
                                          hintStyle: TextStyle(
                                              fontSize: 15, color: Colors.black),
                                          filled: true,
                                          fillColor: Constant.locationServiceGreen,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(30),),
                                            borderSide: BorderSide(
                                              color:
                                              Constant.editTextBoarderColor,
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color:
                                                  Constant.editTextBoarderColor,
                                                  width: 1)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 20),
                                      child: CustomTextWidget(
                                        text: Constant.siteName,
                                        style: TextStyle(
                                            fontFamily: Constant.jostRegular,
                                            fontSize: 13,
                                            color: Constant.chatBubbleGreen),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Container(
                                      height: 35,
                                      child: CustomTextFormFieldWidget(
                                        controller: _subjectIdEditingController,
                                        keyboardType: TextInputType.numberWithOptions(signed: true),
                                        maxLength: 7,
                                        focusNode: _subjectIdFocusNode,
                                        onChanged: (text) {
                                          debugPrint('controller????${_subjectIdEditingController.text}');
                                        },
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: Constant.jostMedium),
                                        cursorColor: Constant.bubbleChatTextView,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          counterText: Constant.blankString,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 20),
                                          hintStyle: TextStyle(
                                              fontSize: 15, color: Colors.black),
                                          filled: true,
                                          fillColor: Constant.locationServiceGreen,
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color:
                                                  Constant.editTextBoarderColor,
                                                  width: 1)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color:
                                                  Constant.editTextBoarderColor,
                                                  width: 1)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 20),
                                      child: CustomTextWidget(
                                        text: Constant.subjectId,
                                        style: TextStyle(
                                            fontFamily: Constant.jostRegular,
                                            fontSize: 13,
                                            color: Constant.chatBubbleGreen),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Container(
                                      height: 35,
                                      child: CustomTextFormFieldWidget(
                                        readOnly: true,
                                        onTap: () {
                                          _openDatePickerBottomSheet();
                                        },
                                        controller: _birthYearEditingController,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: Constant.jostMedium),
                                        cursorColor: Constant.bubbleChatTextView,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 20),
                                          hintStyle: TextStyle(
                                              fontSize: 15, color: Colors.black),
                                          filled: true,
                                          fillColor: Constant.locationServiceGreen,
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color:
                                                  Constant.editTextBoarderColor,
                                                  width: 1)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color:
                                                  Constant.editTextBoarderColor,
                                                  width: 1)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 20),
                                      child: CustomTextWidget(
                                        text: Constant.yearBirth,
                                        style: TextStyle(
                                            fontFamily: Constant.jostRegular,
                                            fontSize: 13,
                                            color: Constant.chatBubbleGreen),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 35,
                                          child: Consumer<SignupPasswordHiddenInfo>(
                                            builder: (context, data, child) {
                                              return CustomTextFormFieldWidget(
                                                controller: _passwordEditingController,
                                                obscureText: data.isHidden(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontFamily:
                                                    Constant.jostMedium),
                                                cursorColor:
                                                Constant.bubbleChatTextView,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 20),
                                                  hintStyle: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black),
                                                  filled: true,
                                                  fillColor:
                                                  Constant.locationServiceGreen,
                                                  suffixIcon: IconButton(
                                                    onPressed: () {
                                                      _togglePasswordVisibility(1);
                                                    },
                                                    icon: Image.asset(data
                                                        .isHidden()
                                                        ? Constant.hidePassword
                                                        : Constant.showPassword),
                                                  ),
                                                  suffixIconConstraints:
                                                  BoxConstraints(
                                                    minHeight: 30,
                                                    maxHeight: 35,
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(30)),
                                                    borderSide: BorderSide(
                                                        color: Constant
                                                            .editTextBoarderColor,
                                                        width: 1),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(30)),
                                                    borderSide: BorderSide(
                                                        color: Constant
                                                            .editTextBoarderColor,
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
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: CustomTextWidget(
                                            text: Constant.password,
                                            style: TextStyle(
                                                fontFamily: Constant.jostRegular,
                                                fontSize: 13,
                                                color: Constant.chatBubbleGreen),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                          height: 35,
                                          child: Consumer<
                                              SignupConfirmPasswordHiddenInfo>(
                                            builder: (context, data, child) {
                                              return CustomTextFormFieldWidget(
                                                obscureText: data.isHidden(),
                                                controller: _confirmPassEditingController,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontFamily:
                                                    Constant.jostMedium),
                                                cursorColor:
                                                Constant.bubbleChatTextView,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 20),
                                                  hintStyle: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black),
                                                  filled: true,
                                                  fillColor:
                                                  Constant.locationServiceGreen,
                                                  suffixIcon: IconButton(
                                                    onPressed: () {
                                                      _togglePasswordVisibility(2);
                                                    },
                                                    icon: Image.asset(data
                                                        .isHidden()
                                                        ? Constant.hidePassword
                                                        : Constant.showPassword),
                                                  ),
                                                  suffixIconConstraints:
                                                  BoxConstraints(
                                                    minHeight: 30,
                                                    maxHeight: 35,
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(30)),
                                                    borderSide: BorderSide(
                                                        color: Constant
                                                            .editTextBoarderColor,
                                                        width: 1),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(30)),
                                                    borderSide: BorderSide(
                                                        color: Constant
                                                            .editTextBoarderColor,
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
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: CustomTextWidget(
                                            text: Constant.confirmPassword,
                                            style: TextStyle(
                                                fontFamily: Constant.jostRegular,
                                                fontSize: 13,
                                                color: Constant.chatBubbleGreen),
                                          ),
                                        ),
                                        Consumer<TonixSignUpErrorInfo>(
                                          builder: (context, data, child) {
                                            return AnimatedSize(
                                              alignment: Alignment.topLeft,
                                              duration: Duration(milliseconds: 300),
                                              child: Visibility(
                                                visible: data.isShowAlert(),
                                                child: Container(
                                                  margin: EdgeInsets.only(left: 20, right: 10, top: 20),
                                                  child: Row(
                                                    children: [
                                                      Image(
                                                        image: AssetImage(Constant.warningPink),
                                                        width: 22,
                                                        height: 22,
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: CustomTextWidget(
                                                          text: data.getErrorMessage(),
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Constant.pinkTriggerColor,
                                                              fontFamily: Constant.jostRegular),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(height: 30,),
                                        Center(
                                          child: BouncingWidget(
                                            onPressed: () {
                                              FocusScope.of(context).requestFocus(FocusNode());
                                              _onSubmitButtonClicked();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 40),
                                              decoration: BoxDecoration(
                                                color: Constant.chatBubbleGreen,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: CustomTextWidget(
                                                text: Constant.submit,
                                                style: TextStyle(
                                                  color: Constant.bubbleChatTextView,
                                                  fontSize: 14,
                                                  fontFamily: Constant.jostMedium,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        onWillPop: _onBackPressed);
  }

  Future<bool> _onBackPressed() async {
    return true;
  }

  //Method to toggle password visibility
  void _togglePasswordVisibility(int i) {
    if (i == 1) {
      var passwordHiddenInfo =
      Provider.of<SignupPasswordHiddenInfo>(context, listen: false);
      passwordHiddenInfo.updateIsHidden(!passwordHiddenInfo.isHidden());
    } else {
      var passwordHiddenInfo =
      Provider.of<SignupConfirmPasswordHiddenInfo>(context, listen: false);
      passwordHiddenInfo.updateIsHidden(!passwordHiddenInfo.isHidden());
    }
  }

  /// @param cupertinoDatePickerMode: for time and date mode selection
  Future<String> _openDatePickerBottomSheet() async {
    var resultFromActionSheet = await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (context) => BirthYearPicker(
          selectedBirthValue: _birthYearEditingController.text,
          isSiteName: false,
        ));
    if (resultFromActionSheet != null)
      _birthYearEditingController.text = resultFromActionSheet;
    return resultFromActionSheet;
  }

  /// @param cupertinoDatePickerMode: for site Name Selection
  Future<String> _openSiteNameBottomSheet() async {
    var resultFromActionSheet = await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (context) => BirthYearPicker(
          selectedBirthValue: _siteNameEditingController.text,
          isSiteName: true,
          siteNameList: _siteNameBloc.siteNameModelList,
        ));
    if (resultFromActionSheet != null) {
      _siteNameEditingController.text = resultFromActionSheet;

      SiteNameModel siteNameModel = _siteNameBloc.siteNameModelList.firstWhere((element) => element.siteName == resultFromActionSheet);

      if(siteNameModel != null) {
        if (_subjectIdEditingController.text.length >= 3) {
          String firstThreeChars = (_subjectIdEditingController.text.length == 3) ? _subjectIdEditingController.text.substring(0) : _subjectIdEditingController.text.substring(0, 3);

          if (firstThreeChars != siteNameModel.siteCode) {

            _subjectIdEditingController.text = _subjectIdEditingController.text.replaceRange(0, 3, siteNameModel.siteCode!);
          }
        } else
          _subjectIdEditingController.text = '${siteNameModel.siteCode}-';


        if(_subjectIdEditingController.text.length == 4)
          FocusScope.of(context).requestFocus(_subjectIdFocusNode);
      }
    }
    return resultFromActionSheet;
  }

  void _onSubmitButtonClicked() {
    String subjectId = _subjectIdEditingController.text.trim();
    String yearOfBirth = _birthYearEditingController.text.trim();
    String siteName = _siteNameEditingController.text.trim();
    String password = _passwordEditingController.text.trim();
    String confirmPassword = _confirmPassEditingController.text.trim();

    var signUpErrorInfo = Provider.of<TonixSignUpErrorInfo>(context, listen: false);

    String? errorMessage;

    if (siteName.isEmpty) {
      errorMessage = 'Please select your site name.';
    } else if(subjectId.isEmpty) {
      errorMessage = 'Please enter your subject ID.';
    } else if (!Utils.validateSubjectId(subjectId)) {
      errorMessage = "Please enter a valid subject ID.";
    } else if (yearOfBirth.isEmpty) {
      errorMessage = 'Please select your year of birth.';
    }  else if (password.isEmpty) {
      errorMessage = 'Please enter a password.';
    } else if (!Utils.validatePassword(password)) {
      errorMessage = Constant.signUpAlertMessage;
    } else if (confirmPassword.isEmpty) {
      errorMessage = 'Please confirm your password.';
    }  else if (password != confirmPassword) {
      errorMessage = 'Password and confirm password should be the same.';
    } else {

      String firstThreeCharsOfSubjectId = Constant.blankString;

      if (subjectId.isNotEmpty) {
        firstThreeCharsOfSubjectId = (_subjectIdEditingController.text.length == 3) ? _subjectIdEditingController.text.substring(0) : _subjectIdEditingController.text.substring(0, 3);
      }

      SiteNameModel? siteNameModelSelected = _siteNameBloc.siteNameModelList.firstWhereOrNull((element) => element.siteName == siteName);

      if (siteNameModelSelected != null) {
        if (firstThreeCharsOfSubjectId == siteNameModelSelected.siteCode) {
          Utils.showApiLoaderDialog(context, networkStream: _bloc.signUpStream, tapToRetryFunction: () {
            _bloc.enterSomeDummyData();
            _bloc.checkUserExistServiceCall(subjectId, yearOfBirth, password, signUpErrorInfo, context, siteName: siteName, siteNameModelList: _siteNameBloc.siteNameModelList);
          });
          _bloc.checkUserExistServiceCall(subjectId, yearOfBirth, password, signUpErrorInfo, context, siteName: siteName, siteNameModelList: _siteNameBloc.siteNameModelList);
        } else {
          errorMessage = "Error! Selected site name does not match site code. Please try again.";
        }
      }
    }

    if(errorMessage != null)
      signUpErrorInfo.updateSignUpErrorInfo(true, errorMessage);
    else
      signUpErrorInfo.updateSignUpErrorInfo(false, Constant.blankString);
  }

  void _listenToSignUpStream() {
    _bloc.signUpStream.listen((signUpEvent) {
      if (signUpEvent != null && signUpEvent == Constant.success) {
        Future.delayed(Duration(milliseconds: 350), () {
          Navigator.popUntil(context, ModalRoute.withName(Constant.loginScreenRouter));
          Utils.navigateToHomeScreen(context, false, homeScreenArgumentModel: HomeScreenArgumentModel(isFromOnBoard: true));
        });
      } else if (signUpEvent != null && signUpEvent == 'User Already Exits!')
        Navigator.pop(context);
    });
  }

  /// This method will be use for get data of all sites Names.
  void getSiteNameDate() async {
    await _siteNameBloc.getSiteNameServiceCall(context);
  }
}

class SignupPasswordHiddenInfo with ChangeNotifier {
  bool _isHidden = true;

  bool isHidden() => _isHidden;

  updateIsHidden(bool isHidden) {
    _isHidden = isHidden;

    notifyListeners();
  }
}

class SignupConfirmPasswordHiddenInfo with ChangeNotifier {
  bool _isHidden = true;

  bool isHidden() => _isHidden;

  updateIsHidden(bool isHidden) {
    _isHidden = isHidden;

    notifyListeners();
  }
}

class TonixSignUpErrorInfo with ChangeNotifier {
  bool _isShowAlert = false;
  String _errorMessage = Constant.blankString;

  bool isShowAlert ()=> _isShowAlert;
  String getErrorMessage ()=> _errorMessage;

  updateSignUpErrorInfo(bool isShowAlert, String errorMessage) {
    _isShowAlert = isShowAlert;
    _errorMessage = errorMessage;

    notifyListeners();
  }
}
