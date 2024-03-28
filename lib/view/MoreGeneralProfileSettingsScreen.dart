import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:mobile/blocs/MoreGeneralProfileSettingsBloc.dart';
import 'package:mobile/util/TabNavigatorRoutes.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';

import '../models/MoreGeneralProfileSettingsArgumentModel.dart';
import '../providers/SignUpOnBoardProviders.dart';
import 'CustomTextWidget.dart';
import 'MoreSection.dart';

class MoreGeneralProfileSettingsScreen extends StatefulWidget {
  final MoreGeneralProfileSettingsArgumentModel
      moreGeneralProfileSettingsArgumentModel;
  final Future<dynamic> Function(String, dynamic) openActionSheetCallback;
  final Future<dynamic> Function(BuildContext, String, dynamic) onPush;
  final Function(Stream, Function) showApiLoaderCallback;

  const MoreGeneralProfileSettingsScreen(
      {Key? key,
      required this.moreGeneralProfileSettingsArgumentModel,
      required this.openActionSheetCallback,
      required this.onPush,
      required this.showApiLoaderCallback})
      : super(key: key);

  @override
  State<MoreGeneralProfileSettingsScreen> createState() =>
      _MoreGeneralProfileSettingsScreenState();
}

class _MoreGeneralProfileSettingsScreenState
    extends State<MoreGeneralProfileSettingsScreen> {
  List<SelectedAnswers> _selectedAnswersList = [];
  MoreGeneralProfileSettingsBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _selectedAnswersList = widget.moreGeneralProfileSettingsArgumentModel.selectedAnswerList!;

    _bloc = MoreGeneralProfileSettingsBloc(
        widget.moreGeneralProfileSettingsArgumentModel.profileId!);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _bloc!.updateUserProfileModel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (canPop) {
        if (!canPop)
          Navigator.pop(context, widget.moreGeneralProfileSettingsArgumentModel);
      },
      child: Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.of(context).pop(
                            widget.moreGeneralProfileSettingsArgumentModel);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
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
                              text: Constant.myProfile,
                              style: TextStyle(
                                  color: Constant.locationServiceGreen,
                                  fontSize: 16,
                                  fontFamily: Constant.jostRegular),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Constant.moreBackgroundColor,
                          ),
                          child: StreamBuilder(
                            stream: _bloc!.generalProfileStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                SelectedAnswers? firstNameSelectedAnswer = _selectedAnswersList.firstWhereOrNull(
                                        (element) => element.questionTag == Constant.profileFirstNameTag);
                                SelectedAnswers? ageSelectedAnswer = _selectedAnswersList.firstWhereOrNull(
                                        (element) => element.questionTag == Constant.profileAgeTag);
                                SelectedAnswers? sexSelectedAnswer = _selectedAnswersList.firstWhereOrNull(
                                        (element) => element.questionTag == Constant.profileSexTag);
                                SelectedAnswers? genderSelectedAnswer = _selectedAnswersList.firstWhereOrNull(
                                        (element) => element.questionTag == Constant.profileGenderTag);
                                SelectedAnswers? menstruationSelectedAnswer = _selectedAnswersList.firstWhereOrNull((element) => element.questionTag == Constant.profileMenstruationTag);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MoreSection(
                                      currentTag: Constant.profileFirstNameTag,
                                      text: Constant.name,
                                      moreStatus:
                                          firstNameSelectedAnswer?.answer ?? '',
                                      isShowDivider: true,
                                      navigateToOtherScreenCallback:
                                          _navigateToOtherScreen,
                                      selectedAnswerList: _selectedAnswersList,
                                    ),
                                    MoreSection(
                                      currentTag: Constant.profileAgeTag,
                                      text: Constant.age,
                                      moreStatus: Utils.calculateAge(
                                              ageSelectedAnswer!.answer!) ??
                                          '',
                                      isShowDivider: true,
                                      navigateToOtherScreenCallback:
                                          _navigateToOtherScreen,
                                      selectedAnswerList: _selectedAnswersList,
                                    ),
                                    MoreSection(
                                      currentTag: Constant.profileGenderTag,
                                      text: Constant.gender,
                                      moreStatus:
                                          genderSelectedAnswer?.answer ?? '',
                                      isShowDivider: true,
                                      navigateToOtherScreenCallback:
                                          _navigateToOtherScreen,
                                      selectedAnswerList: _selectedAnswersList,
                                    ),
                                    MoreSection(
                                      currentTag: Constant.profileSexTag,
                                      text: Constant.sex,
                                      moreStatus:
                                          sexSelectedAnswer?.answer ?? '',
                                      isShowDivider: true,
                                      navigateToOtherScreenCallback:
                                          _navigateToOtherScreen,
                                      selectedAnswerList: _selectedAnswersList,
                                    ),
                                    (genderSelectedAnswer?.answer == 'Woman' && sexSelectedAnswer?.answer == 'Female') ?
                                    MoreSection(
                                      currentTag: Constant.profileMenstruationTag,
                                      text: Constant.menstruation,
                                      moreStatus:
                                      menstruationSelectedAnswer?.answer ?? 'N/A',
                                      isShowDivider: true,
                                      navigateToOtherScreenCallback:
                                      _navigateToOtherScreen,
                                      selectedAnswerList: _selectedAnswersList,
                                    ) : const SizedBox(),

                                    MoreSection(
                                      currentTag: Constant.profileEmailTag,
                                      text: Constant.email,
                                      moreStatus:
                                          _bloc!.userProfileInfoModel.email ??
                                              '',
                                      isShowDivider: false,
                                      navigateToOtherScreenCallback:
                                          _navigateToOtherScreen,
                                      selectedAnswerList: _selectedAnswersList,
                                    ),
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToOtherScreen(String routeName, dynamic arguments) async {
    if (routeName == TabNavigatorRoutes.moreEmailScreenRoute) {
      var userProfileInfoModel =
          await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
      arguments = userProfileInfoModel.email;
    }
    var result = await widget.onPush(context, routeName, arguments);
    if (result != null) {
      if (result is bool && result) {
        if (routeName == TabNavigatorRoutes.moreEmailScreenRoute) {
          _bloc!.updateUserProfileModel();
        } else {
          _bloc!.initNetworkStreamController();
          widget.showApiLoaderCallback(_bloc!.networkStream, () {
            _bloc!.enterSomeDummyData();
            _bloc!.editMyProfileServiceCall(context, _selectedAnswersList);
          });
          _bloc!.editMyProfileServiceCall(context, _selectedAnswersList);
        }
      }
    }
  }

  @override
  void dispose() {
    _bloc!.dispose();
    super.dispose();
  }
}
