import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:mobile/models/MoreHeadacheScreenArgumentModel.dart';
import 'package:mobile/models/MoreMedicationArgumentModel.dart';
import 'package:mobile/models/MoreTriggerArgumentModel.dart';
import 'package:mobile/models/ResponseModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/TabNavigatorRoutes.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/SignUpOnBoardProviders.dart';

class MoreSection extends StatefulWidget {
  final String text;
  final String moreStatus;
  final bool isShowDivider;
  final String? currentTag;
  final Function(String, dynamic)? navigateToOtherScreenCallback;
  final List<SelectedAnswers>? selectedAnswerList;
  final HeadacheTypeData? headacheTypeData;
  final MoreTriggersArgumentModel? moreTriggersArgumentModel;
  final MoreMedicationArgumentModel? moreMedicationArgumentModel;
  final Function? viewReportClickedCallback;
  final bool isFromMyProfile;
  final List<HealthDataType> healthDataTypeList;

  const MoreSection(
      {Key? key,
      required this.text,
      required this.moreStatus,
      required this.isShowDivider,
      required this.currentTag,
      this.navigateToOtherScreenCallback,
      this.selectedAnswerList,
      this.headacheTypeData,
      this.moreTriggersArgumentModel,
      this.moreMedicationArgumentModel,
      this.viewReportClickedCallback,
      this.isFromMyProfile = false,
      this.healthDataTypeList = const <HealthDataType>[],
      })
      : super(key: key);

  @override
  _MoreSectionState createState() => _MoreSectionState();
}

class _MoreSectionState extends State<MoreSection>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  AnimationController? _animationController;
  int clickedOnWhichButton = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: Duration(milliseconds: 350),
        reverseDuration: Duration(milliseconds: 350),
        vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              if (widget.currentTag != null) {
                switch (widget.currentTag) {
                  case Constant.settings:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreSettingRoute, null);
                    break;
                  case Constant.generateReport:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreGenerateReportRoute, null);
                    break;
                  case Constant.support:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreSupportRoute, null);
                    break;
                  case Constant.myProfile:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreMyProfileScreenRoute, null);
                    break;
                  case Constant.notifications:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreNotificationScreenRoute, null);
                    break;
                  case Constant.faq:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreFaqScreenRoute, null);
                    break;
                  case Constant.headacheType:
                    {
                      Utils.sendAnalyticsEvent(Constant.headacheTypeClicked, {
                        'headache_name': widget.headacheTypeData!.text,
                        'headache_type': (widget.headacheTypeData?.isMigraine ?? true) ? 'Migraine' : 'Headache'
                      }, context);
                      widget.navigateToOtherScreenCallback!(
                          TabNavigatorRoutes.moreHeadachesScreenRoute,
                          MoreHeadacheScreenArgumentModel(
                              headacheTypeData: widget.headacheTypeData!));
                    }
                    break;
                  case Constant.locationServices:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreLocationServicesScreenRoute,
                        null);
                    break;
                  case Constant.voiceSelection:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreVoiceSelectionScreenRoute,
                        null);
                    break;
                  case Constant.profileFirstNameTag:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreNameScreenRoute,
                        widget.selectedAnswerList);
                    break;
                  case Constant.profileAgeTag:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreAgeScreenRoute,
                        widget.selectedAnswerList);
                    break;
                  case Constant.profileGenderTag:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreGenderScreenRoute,
                        widget.selectedAnswerList);
                    break;
                  case Constant.profileSexTag:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreSexScreenRoute,
                        widget.selectedAnswerList);
                    break;
                  case Constant.profileMenstruationTag:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreMenstruationScreenRoute,
                        widget.selectedAnswerList);
                    break;
                  case Constant.myTriggers:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreTriggersScreenRoute,
                        widget.moreTriggersArgumentModel);
                    break;
                  case Constant.myMedications:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreMedicationsScreenRoute,
                        widget.moreMedicationArgumentModel);
                    break;
                  case Constant.dailyLog:
                  case Constant.medication:
                  case Constant.exercise:
                    if (!isExpanded) {
                      isExpanded = true;
                      _animationController!.forward();
                    } else {
                      isExpanded = false;
                      _animationController!.reverse();
                    }
                    break;
                  case Constant.contactTheMigraineMentorTeam:
                    Uri uri =
                        Uri(scheme: 'mailto', path: 'support@bontriage.com');
                    Utils.customLaunch(uri);
                    break;
                  case Constant.contactEmail:
                    var userProfileInfoModel = await SignUpOnBoardProviders.db
                        .getLoggedInUserAllInformation();

                    final Uri params = Uri(
                      scheme: 'mailto',
                      path: 'support@tonixpharma.com',
                      query:
                          'subject=Subject ID: ${Uri.encodeComponent(userProfileInfoModel.subjectId!)} ${Uri.encodeComponent('& Trial ID: TNX-OX-CM201')}', //add subject and body here
                    );

                    Utils.customLaunch(params);

                    break;
                  case Constant.dateRange:
                    widget.navigateToOtherScreenCallback!(
                        Constant.dateRangeActionSheet, null);
                    break;
                  case Constant.viewReport:
                    widget.viewReportClickedCallback!();
                    break;
                  case Constant.profileEmailTag:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreEmailScreenRoute,
                        widget.selectedAnswerList);
                    break;
                  case Constant.changePassword:
                    widget.navigateToOtherScreenCallback!(
                        Constant.changePasswordScreenRouter, null);
                    break;
                  case Constant.inviteFriends:
                    //Utils.createDynamicLink();
                    final box = context.findRenderObject() as RenderBox;
                    Utils.sendShareAnalyticsEvent(context);
                    Share.share(Constant.shareText, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
                    break;
                  case Constant.contactInfo:
                    Uri uri = Uri(scheme: 'tel', path: '+19876543210');
                    Utils.customLaunch(uri);
                    break;
                  case Constant.replayTutorial:
                    await SignUpOnBoardProviders.db.deleteUserTutorial(1);
                    widget.navigateToOtherScreenCallback!(
                        widget.currentTag ?? '', null);
                    break;
                  case Constant.goToBontriageAssessment:
                    Uri uri = Uri.parse(Constant.deepDiveUrl);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    break;
                  case Constant.termsAndConditions:
                    Uri uri = Uri.parse(Constant.termsAndConditionUrl);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    break;
                  case Constant.generalProfileSettings:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreGeneralProfileSettingsRoute,
                        widget.selectedAnswerList);
                    break;
                  case Constant.headacheTypes:
                    widget.navigateToOtherScreenCallback!(
                        TabNavigatorRoutes.moreHeadacheTypesScreenRoute, null);
                    break;
                  case Constant.appleHealth:
                    {
                      Utils.sendAnalyticsEvent(Constant.appleHealth + '_clicked',{} , context);
                      widget.navigateToOtherScreenCallback!(
                          TabNavigatorRoutes.moreHealthScreenRoute,
                          widget.healthDataTypeList);
                      break;
                    }
                  case Constant.googleFit:
                    {
                      Utils.sendAnalyticsEvent(Constant.googleFit + '_clicked',{} , context);
                      widget.navigateToOtherScreenCallback!(
                          TabNavigatorRoutes.moreHealthScreenRoute,
                          widget.healthDataTypeList);
                      break;
                    }
                }
              }
            },
            child: _getInnerContentWidget(),
          ),
          /*SizeTransition(
            sizeFactor: _animationController,
            child: _getExpandableWidget(),
          ),*/
          Visibility(
            visible: widget.isShowDivider,
            child: Divider(
              color: Constant.locationServiceGreen,
              thickness: 1,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getInnerContentWidget() {
    if (widget.currentTag == Constant.headacheType) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              child: CustomTextWidget(
                text: widget.text,
                style: TextStyle(
                    color: Constant.locationServiceGreen,
                    fontSize: 16,
                    fontFamily: Constant.jostRegular),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Image(
            width: 16,
            height: 16,
            image: AssetImage(Constant.rightArrow),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: CustomTextWidget(
              text: widget.text,
              style: TextStyle(
                  color: Constant.locationServiceGreen,
                  fontSize: 16,
                  fontFamily: Constant.jostRegular),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    child: CustomTextWidget(
                      text: widget.moreStatus,
                      style: TextStyle(
                          color: Constant.notificationTextColor,
                          fontSize: 15,
                          fontFamily: Constant.jostMedium,
                          overflow: TextOverflow.ellipsis),
                      textAlign: TextAlign.end,
                    ),
                    alignment: Alignment.topRight,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Visibility(
                  visible: widget.currentTag != Constant.siteCode &&
                      widget.currentTag != Constant.siteName &&
                      widget.currentTag != Constant.coordinatorName &&
                      widget.currentTag != Constant.contactInfo &&
                  widget.currentTag != Constant.healthDescription,
                  child: Image(
                    width: 16,
                    height: 16,
                    image: AssetImage(Constant.rightArrow),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
