import 'package:flutter/material.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/MoreSection.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../providers/SignUpOnBoardProviders.dart';

class MoreSupportScreen extends StatefulWidget {
  final Function(BuildContext, String, dynamic) onPush;
  final Future<dynamic> Function(String, dynamic) navigateToOtherScreenCallback;

  const MoreSupportScreen({Key? key, required this.onPush, required this.navigateToOtherScreenCallback})
      : super(key: key);
  @override
  _MoreSupportScreenState createState() => _MoreSupportScreenState();
}

class _MoreSupportScreenState extends State<MoreSupportScreen> {
  String _subjectId = Constant.blankString;
  String _versionName = Constant.blankString;
  String _siteCode = Constant.blankString;
  String _siteName = Constant.blankString;
  String _siteCoordinatorName = Constant.blankString;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      setState(() {
        _subjectId = userProfileInfoData.subjectId ?? Constant.blankString;
        _siteCode = userProfileInfoData.siteCode ?? Constant.blankString;
        _siteName = userProfileInfoData.siteName ?? Constant.blankString;
        _siteCoordinatorName = userProfileInfoData.siteCoordinatorName ?? Constant.blankString;
        _versionName = packageInfo.version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appConfig = AppConfig.of(context);
    return Container(
        decoration: Constant.backgroundBoxDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Constant.moreBackgroundColor,
                        ),
                        child: Row(
                          children: [
                            Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(Constant.leftArrow),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CustomTextWidget(
                              text: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.more : 'Settings',
                              style: TextStyle(
                                color: Constant.locationServiceGreen,
                                fontSize: 16,
                                fontFamily: Constant.jostRegular,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Constant.moreBackgroundColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                            child: MoreSection(
                              currentTag: Constant.faq,
                              text: Constant.faq,
                              moreStatus: '',
                              isShowDivider: true,
                              navigateToOtherScreenCallback: _navigateToOtherScreen,
                            ),
                          ),
                          Visibility(
                            visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                            child: MoreSection(
                              currentTag: Constant.replayTutorial,
                              text: Constant.replayTutorial,
                              moreStatus: '',
                              isShowDivider: true,
                              navigateToOtherScreenCallback: _navigateToOtherScreen,
                            ),
                          ),
                          Visibility(
                            visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                            child: MoreSection(
                              currentTag: Constant.goToBontriageAssessment,
                              text: Constant.goToBontriageAssessment,
                              moreStatus: '',
                              isShowDivider: true,
                              navigateToOtherScreenCallback: _navigateToOtherScreen,
                            ),
                          ),
                          Visibility(
                            visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                            child: MoreSection(
                              currentTag: Constant.termsAndConditions,
                              text: Constant.termsAndConditions,
                              moreStatus: '',
                              isShowDivider: true,
                              navigateToOtherScreenCallback: _navigateToOtherScreen,
                            ),
                          ),
                          Visibility(
                            visible: appConfig?.buildFlavor == Constant.tonixBuildFlavor,
                            child: MoreSection(
                              currentTag: Constant.siteCode,
                              text: Constant.siteCode,
                              moreStatus: _siteCode,
                              isShowDivider: true,
                              navigateToOtherScreenCallback: _navigateToOtherScreen,
                            ),
                          ),
                          Visibility(
                            visible: appConfig?.buildFlavor == Constant.tonixBuildFlavor,
                            child: MoreSection(
                              currentTag: Constant.siteName,
                              text: Constant.siteName,
                              moreStatus: _siteName,
                              isShowDivider: true,
                              navigateToOtherScreenCallback: _navigateToOtherScreen,
                            ),
                          ),
                          Visibility(
                            visible: appConfig?.buildFlavor == Constant.tonixBuildFlavor,
                            child: MoreSection(
                              currentTag: Constant.coordinatorName,
                              text: Constant.coordinatorName,
                              moreStatus: _siteCoordinatorName,
                              isShowDivider: true,
                              navigateToOtherScreenCallback: _navigateToOtherScreen,
                            ),
                          ),
                          Visibility(
                            visible: appConfig?.buildFlavor == Constant.tonixBuildFlavor,
                            child: MoreSection(
                              currentTag: Constant.contactInfo,
                              text: Constant.contactInfo,
                              moreStatus: '+1(987) 654-3210',
                              isShowDivider: true,
                            ),
                          ),
                          MoreSection(
                            currentTag: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.contactTheMigraineMentorTeam : Constant.contactEmail,
                            text: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.contactTheMigraineMentorTeam : Constant.contactEmail,
                            moreStatus: Constant.blankString,
                            isShowDivider: false,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30,),
                    Visibility(
                      visible: appConfig?.buildFlavor == Constant.tonixBuildFlavor,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text('Subject ID:  $_subjectId',
                            style: TextStyle(
                              color: Constant.locationServiceGreen,
                              fontFamily: Constant.jostRegular,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: appConfig?.buildFlavor == Constant.tonixBuildFlavor,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            'v$_versionName',
                            style: TextStyle(
                              color: Constant.locationServiceGreen,
                              fontFamily: Constant.jostRegular,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }

  void _navigateToOtherScreen(String routeName, dynamic arguments) {
    if (routeName == Constant.replayTutorial) {
      widget.navigateToOtherScreenCallback(routeName, null);
    } else
      widget.onPush(
        context, routeName, arguments);
  }
}
