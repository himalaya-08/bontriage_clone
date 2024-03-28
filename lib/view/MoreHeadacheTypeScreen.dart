import 'dart:io';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/ResponseModel.dart';
import 'package:mobile/util/TabNavigatorRoutes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

import '../AppConfig.dart';
import '../blocs/MoreHeadacheTypeBloc.dart';
import '../models/CurrentUserHeadacheModel.dart';
import '../providers/SignUpOnBoardProviders.dart';
import '../util/Utils.dart';
import '../util/constant.dart';
import 'AddHeadacheOnGoingScreen.dart';
import 'CustomTextWidget.dart';
import 'MoreSection.dart';

import 'dart:core';

class MoreHeadacheTypeScreen extends StatefulWidget {
  final Future<dynamic> Function(BuildContext, String, dynamic) onPush;
  final Function(String)? openActionSheetCallback;
  final Function(Stream, Function) showApiLoaderCallback;
  final Future<dynamic> Function(String, dynamic) navigateToOtherScreenCallback;

  const MoreHeadacheTypeScreen(
      {Key? key,
      required this.onPush,
      this.openActionSheetCallback,
      required this.showApiLoaderCallback,
      required this.navigateToOtherScreenCallback})
      : super(key: key);

  @override
  State<MoreHeadacheTypeScreen> createState() => _MoreHeadacheTypeScreenState();
}

class _MoreHeadacheTypeScreenState extends State<MoreHeadacheTypeScreen> {
  MoreHeadacheTypeBloc _bloc = MoreHeadacheTypeBloc();
  CurrentUserHeadacheModel? currentUserHeadacheModel;

  int _whichItemSelected = -1;

  List<HeadacheTypeData> _headacheList = [];

  @override
  void initState() {
    super.initState();

    _bloc = MoreHeadacheTypeBloc();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setBool(Constant.updateMoreHeadacheData, false);

      _bloc.initNetworkStreamController();
      debugPrint('show api loader 22');
      widget.showApiLoaderCallback(_bloc.networkStream, () {
        _bloc.enterDummyDataToNetworkStream();
        _bloc.getAllHeadacheTypeService(context);
      });
      _bloc.getAllHeadacheTypeService(context);
    });
  }

  @override
  void didUpdateWidget(covariant MoreHeadacheTypeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateHeadacheDataChecker();
  }

  Future<void> _updateHeadacheDataChecker() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? isUpdateHeadacheData =
        sharedPreferences.getBool(Constant.updateMoreHeadacheData);
    if (isUpdateHeadacheData != null) {
      if (isUpdateHeadacheData) {
        debugPrint('updateData: more headache type screen');
        _bloc.initNetworkStreamController();
        debugPrint('show api loader 19');
        widget.showApiLoaderCallback(_bloc.networkStream, () {
          _bloc.enterDummyDataToNetworkStream();
          _bloc.getAllHeadacheTypeService(context);
        });
        _bloc.getAllHeadacheTypeService(context);
        await sharedPreferences.setBool(Constant.updateMoreHeadacheData, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: Constant.backgroundBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: RawScrollbar(
            thickness: 2,
            thumbColor: Constant.locationServiceGreen,
            thumbVisibility: true,
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
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
                              text: Constant.more,
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
                    StreamBuilder<dynamic>(
                      stream: _bloc.headacheTypeStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = snapshot.data;
                          if (data is List<HeadacheTypeData>) {
                            _headacheList = data;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _getHeadacheTypeWidget(),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
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

  Widget _getHeadacheTypeWidget() {
    List<Widget> headacheTypeWidgetList = [];

    _headacheList.asMap().forEach((index, value) {
      headacheTypeWidgetList.add(
        MoreSection(
          currentTag: Constant.headacheType,
          text: (value.isMigraine!)
              ? '${value.text} (Migraine)'
              : '${value.text} (Headache)',
          moreStatus: '',
          isShowDivider: index != _headacheList.length - 1,
          navigateToOtherScreenCallback:
              (String routeName, dynamic arguments) async {
            _whichItemSelected = index;
            _navigateToOtherScreen(routeName, arguments);
          },
          headacheTypeData: value,
        ),
      );
    });

    return _headacheList.length == 0
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomTextWidget(
                  text:
                      'We noticed you didn\'t log any headache yet. So please add any headache to see your Headache data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.3,
                    fontSize: 14,
                    fontFamily: Constant.jostRegular,
                    color: Constant.locationServiceGreen,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BouncingWidget(
                    onPressed: () async {
                      await widget.navigateToOtherScreenCallback(Constant.addNewHeadacheIntroScreen, TabNavigatorRoutes.moreHeadacheTypesScreenRoute);

                      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                      bool value = sharedPreferences.getBool(Constant.updateMoreHeadacheData) ?? false;

                      if (value) {
                        _bloc.initNetworkStreamController();
                        debugPrint('show api loader 20');
                        widget.showApiLoaderCallback(_bloc.networkStream, () {
                          _bloc.enterDummyDataToNetworkStream();
                          _bloc.getAllHeadacheTypeService(context);
                        });
                        _bloc.getAllHeadacheTypeService(context);

                        sharedPreferences.setBool(Constant.updateMoreHeadacheData, false);
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: Constant.chatBubbleGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: CustomTextWidget(
                          text: '+ Add a headache type',
                          style: TextStyle(
                              color: Constant.bubbleChatTextView,
                              fontSize: 15,
                              fontFamily: Constant.jostMedium),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                text:
                    'Click on a Headache Type to View or Modify/Delete Headache Assessment/Report',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Constant.locationServiceGreen,
                    fontSize: 14,
                    fontFamily: Constant.jostMedium),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Constant.moreBackgroundColor,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        await widget.navigateToOtherScreenCallback(Constant.addNewHeadacheIntroScreen, Constant.homeRouter);


                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                        bool value = sharedPreferences.getBool(Constant.updateMoreHeadacheData) ?? false;

                        if (value) {
                          _bloc.initNetworkStreamController();
                          debugPrint('show api loader 21');
                          widget.showApiLoaderCallback(_bloc.networkStream, () {
                            _bloc.enterDummyDataToNetworkStream();
                            _bloc.getAllHeadacheTypeService(context);
                          });
                          _bloc.getAllHeadacheTypeService(context);

                          sharedPreferences.setBool(Constant.updateMoreHeadacheData, false);
                        }
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CustomTextWidget(
                          text: '+ Add a headache type',
                          style: TextStyle(
                            fontSize: Platform.isAndroid ? 16 : 17,
                            color: Constant.addCustomNotificationTextColor,
                            fontFamily: Constant.jostRegular,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      color: Constant.locationServiceGreen,
                      thickness: 1,
                      height: 30,
                    ),
                    Column(
                      children: headacheTypeWidgetList,
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  void _navigateToOtherScreen(String routeName, dynamic arguments) async {
    var result = await widget.onPush(context, routeName, arguments);

    if (result != null) {
      if (result is String && result == 'Event Deleted') {
        _headacheList.removeAt(_whichItemSelected);
        _bloc.headacheTypeSink.add(_headacheList);
      }
    }

    _updateHeadacheDataChecker();
  }

  Future<void> _getUserCurrentHeadacheData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    int? currentPositionOfTabBar =
        sharedPreferences.getInt(Constant.currentIndexOfTabBar);
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    if (currentPositionOfTabBar == 1 && userProfileInfoData != null) {
      currentUserHeadacheModel = await SignUpOnBoardProviders.db
          .getUserCurrentHeadacheData(userProfileInfoData.userId!);
    }
  }

  void _navigateToAddHeadacheScreen() async {
    DateTime currentDateTime = DateTime.now();
    DateTime endHeadacheDateTime = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        currentDateTime.hour,
        currentDateTime.minute,
        0,
        0,
        0);

    currentUserHeadacheModel?.selectedEndDate =
        Utils.getDateTimeInUtcFormat(endHeadacheDateTime, true, context);

    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    currentUserHeadacheModel = await SignUpOnBoardProviders.db
        .getUserCurrentHeadacheData(userProfileInfoData.userId!);

    currentUserHeadacheModel?.isOnGoing = false;
    currentUserHeadacheModel?.selectedEndDate =
        Utils.getDateTimeInUtcFormat(endHeadacheDateTime, true, context);

    var appConfig = AppConfig.of(context);

    if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
      await widget.navigateToOtherScreenCallback(
          Constant.addHeadacheOnGoingScreenRouter, currentUserHeadacheModel);
    else
      await widget.navigateToOtherScreenCallback(
          Constant.tonixAddHeadacheScreen, currentUserHeadacheModel);

    Utils.setAnalyticsCurrentScreen(Constant.compassScreen, context);
    _getUserCurrentHeadacheData();
  }

  void _navigateUserToHeadacheLogScreen() async {
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    CurrentUserHeadacheModel? currentUserHeadacheModel;

    if (userProfileInfoData != null)
      currentUserHeadacheModel = await SignUpOnBoardProviders.db
          .getUserCurrentHeadacheData(userProfileInfoData.userId!);

    if (currentUserHeadacheModel == null) {
      await widget.navigateToOtherScreenCallback(
          Constant.headacheStartedScreenRouter, null);
    } else {
      if (currentUserHeadacheModel.isOnGoing ?? true) {
        await widget.navigateToOtherScreenCallback(
            Constant.currentHeadacheProgressScreenRouter, null);
      } else {
        var appConfig = AppConfig.of(context);

        if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
          await widget.navigateToOtherScreenCallback(
              Constant.addHeadacheOnGoingScreenRouter,
              currentUserHeadacheModel);
        else
          await widget.navigateToOtherScreenCallback(
              Constant.tonixAddHeadacheScreen, currentUserHeadacheModel);
      }
    }

    Utils.setAnalyticsCurrentScreen(Constant.compassScreen, context);
    _getUserCurrentHeadacheData();
  }
}
