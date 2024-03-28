import 'package:flutter/material.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/blocs/MoreGeneralProfileSettingsBloc.dart';
import 'package:mobile/blocs/MoreMyProfileBloc.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/providers/UpdateUserEmailProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/OtpValidationScreen.dart';
import 'package:provider/provider.dart';

class MoreEmailScreen extends StatefulWidget {
  final String email;
  final Future<dynamic> Function(String, dynamic) openActionSheetCallback;
  final Future<dynamic> Function(String, dynamic) navigateToOtherScreenCallback;

  final Function(Stream, Function) showApiLoaderCallback;

  const MoreEmailScreen(
      {Key? key,
      required this.email,
      required this.openActionSheetCallback,
      required this.navigateToOtherScreenCallback,
      required this.showApiLoaderCallback})
      : super(key: key);

  @override
  _MoreEmailScreenState createState() => _MoreEmailScreenState();
}

class _MoreEmailScreenState extends State<MoreEmailScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController _textEditingController = TextEditingController();
  String? _initialEmailValue;

  //MoreMyProfileBloc _moreMyProfileBloc;
  //MoreGeneralProfileSettingsBloc _bloc;

  var _responseData = Constant.blankString;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      /*_moreMyProfileBloc.initNetworkStreamController();
      widget.showApiLoaderCallback(_moreMyProfileBloc.networkStream, () {
        _moreMyProfileBloc.enterSomeDummyData();
        _moreMyProfileBloc.fetchMyProfileData(context);
      });
      _moreMyProfileBloc.fetchMyProfileData(context);*/
      //_bloc = MoreGeneralProfileSettingsBloc(_moreMyProfileBloc.profileId);
      /*_initialEmailValue =
          _bloc.userProfileInfoModel.email ?? Constant.blankString;*/
    });

    _initialEmailValue = widget.email;

    if (_initialEmailValue != null) {
      _textEditingController.text = _initialEmailValue!;
    } else {
      _initialEmailValue = Constant.blankString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Constant.backgroundBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: SafeArea(
              child: ChangeNotifierProvider<UpdateUserEmailProvider>(
                create: (context) => UpdateUserEmailProvider(),
                child: Consumer<UpdateUserEmailProvider>(
                  builder: (context, updateUserEmailProvider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Constant.moreBackgroundColor,
                            ),
                            child: Row(
                              children: [
                                Image(
                                  width: 20,
                                  height: 20,
                                  image: AssetImage(Constant.leftArrow),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                CustomTextWidget(
                                  text: Constant.generalProfileSettings,
                                  style: TextStyle(
                                      color: Constant.locationServiceGreen,
                                      fontSize: 16,
                                      fontFamily: Constant.jostMedium),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: CustomTextFormFieldWidget(
                            controller: _textEditingController,
                            onChanged: (value) {
                              setState(() {});
                            },
                            style: TextStyle(
                                color: Constant.locationServiceGreen,
                                fontSize: 15,
                                fontFamily: Constant.jostMedium),
                            cursorColor: Constant.locationServiceGreen,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: Constant.tapToTypeYourEmail,
                              hintStyle: TextStyle(
                                  color: Constant.locationServiceGreen
                                      .withOpacity(0.5),
                                  fontSize: 15,
                                  fontFamily: Constant.jostMedium),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Constant.locationServiceGreen)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Constant.locationServiceGreen)),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 0),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: CustomTextWidget(
                            text: Constant.tapToTypeYourEmail,
                            style: TextStyle(
                                color: Constant.locationServiceGreen,
                                fontSize: 14,
                                fontFamily: Constant.jostMedium),
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            if (updateUserEmailProvider.errorMessage == null &&
                                _errorMessage == null) {
                              _errorMessage = null;
                              return const SizedBox(height: 50);
                            } else if (updateUserEmailProvider.errorMessage !=
                                    null ||
                                _errorMessage != null) {
                              if (_errorMessage == null) {
                                _errorMessage =
                                    updateUserEmailProvider.errorMessage;
                              }
                              debugPrint('error: $_errorMessage');
                              return Column(
                                children: [
                                  const SizedBox(height: 25),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 20, right: 10, top: 10),
                                    child: Row(
                                      children: [
                                        Image(
                                          image:
                                              AssetImage(Constant.warningPink),
                                          width: 17,
                                          height: 17,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: CustomTextWidget(
                                            text: _errorMessage!,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color:
                                                    Constant.pinkTriggerColor,
                                                fontFamily:
                                                    Constant.jostRegular),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                ],
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: TextButton(
                            onPressed: (_initialEmailValue!.toLowerCase() ==
                                    _textEditingController.text.toLowerCase())
                                ? null
                                : () async {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    String userEmail = _textEditingController
                                        .value.text
                                        .toLowerCase();
                                    /*userEmail != null
                                        ? userEmail.trim()
                                        : Constant.blankString;*/

                                    var appConfig = AppConfig.of(context);

                                    if (userEmail != null &&
                                        userEmail != Constant.blankString &&
                                        (appConfig?.buildFlavor ==
                                                Constant
                                                    .migraineMentorBuildFlavor
                                            ? Utils.validateEmail(userEmail)
                                            : true)) {
                                      var result = await widget
                                          .navigateToOtherScreenCallback(
                                              Constant
                                                  .otpValidationScreenRouter,
                                              OTPValidationArgumentModel(
                                                  email: userEmail,
                                                  isFromMore: true,
                                                  isFromSignUp: false,
                                                  isForgotPasswordFromSignUp:
                                                      false));
                                      if (result != null &&
                                          result == Constant.success) {
                                        var updateEmailProvider = Provider.of<
                                                UpdateUserEmailProvider>(
                                            context,
                                            listen: false);

                                        _errorMessage = null;
                                        var userProfileInfoData =
                                            await SignUpOnBoardProviders.db
                                                .getLoggedInUserAllInformation();
                                        updateEmailProvider
                                            .initNetworkStreamController();
                                        widget.showApiLoaderCallback(
                                            updateEmailProvider.networkStream!,
                                            () async {
                                          updateEmailProvider
                                              .enterSomeDummyData();
                                          _responseData =
                                              await updateEmailProvider
                                                  .changeUserEmail(
                                                      _textEditingController
                                                          .text,
                                                      userProfileInfoData
                                                          .userId!,
                                                      RequestMethod.POST,
                                                      context);
                                          if (updateEmailProvider
                                                  .errorMessage ==
                                              null) {
                                            updateEmailProvider.dispose();
                                            Navigator.pop(context, true);
                                          } else {
                                            updateEmailProvider.dispose();
                                          }
                                        });
                                        _responseData =
                                            await updateEmailProvider
                                                .changeUserEmail(
                                                    _textEditingController.text,
                                                    userProfileInfoData.userId!,
                                                    RequestMethod.POST,
                                                    context);
                                        if (updateEmailProvider.errorMessage ==
                                            null) {
                                          Navigator.pop(context, true);
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        _errorMessage = Constant
                                            .signUpEmilFieldAlertMessage;
                                      });
                                    }
                                  },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 40),
                              decoration: BoxDecoration(
                                color: (_initialEmailValue!.toLowerCase() !=
                                        _textEditingController.text
                                            .toLowerCase())
                                    ? Constant.chatBubbleGreen
                                    : Constant.greyColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CustomTextWidget(
                                text: Constant.save,
                                style: TextStyle(
                                  color: Constant.bubbleChatTextView,
                                  fontSize: 14,
                                  fontFamily: Constant.jostMedium,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
