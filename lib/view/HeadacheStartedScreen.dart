import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/blocs/HeadacheLogStartedBloc.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

import '../providers/SignUpOnBoardProviders.dart';
import 'HeadacheDiscardActionSheet.dart';

class HeadacheStartedScreen extends StatefulWidget {
  @override
  _HeadacheStartedScreenState createState() => _HeadacheStartedScreenState();
}

class _HeadacheStartedScreenState extends State<HeadacheStartedScreen> {
  HeadacheLogStartedBloc _headacheLogStartedBloc = HeadacheLogStartedBloc();
  CurrentUserHeadacheModel? _currentUserHeadacheModel = CurrentUserHeadacheModel();

  @override
  void initState() {
    super.initState();
    _headacheLogStartedBloc = HeadacheLogStartedBloc();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _storeHeadacheDataIntoDB();
    });

    Utils.setAnalyticsCurrentScreen(Constant.headacheLogStartedScreen, context);
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showDiscardChangesBottomSheet();
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: Constant.backgroundBoxDecoration,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: SafeArea(
                child: Container(
                  margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
                  decoration: BoxDecoration(
                    color: Constant.backgroundColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              _showDiscardChangesBottomSheet();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 10),
                              child: Image(
                                image: AssetImage(Constant.closeIcon),
                                width: 22,
                                height: 22,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 80,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Align(
                            alignment: Alignment.center,
                            child: CustomTextWidget(
                              text: Constant.headacheLogStarted,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Constant.chatBubbleGreen,
                                  fontFamily: Constant.jostMedium),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Align(
                            alignment: Alignment.center,
                            child: CustomTextWidget(
                              text: Constant.feelFreeToComeBack,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Constant.chatBubbleGreen,
                                  fontFamily: Constant.jostMedium),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 80,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          child: BouncingWidget(
                            onPressed: () {
                              Navigator.pushNamed(context,
                                  Constant.currentHeadacheProgressScreenRouter);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Constant.chatBubbleGreen,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: CustomTextWidget(
                                  text: Constant.viewCurrentLog,
                                  style: TextStyle(
                                      color: Constant.bubbleChatTextView,
                                      fontSize: 15,
                                      fontFamily: Constant.jostMedium),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          child: BouncingWidget(
                            onPressed: () {
                              var appConfig = AppConfig.of(context);

                              if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
                                Navigator.pushNamed(context, Constant.addHeadacheOnGoingScreenRouter, arguments: _currentUserHeadacheModel);
                              else
                                Navigator.pushNamed(context, Constant.tonixAddHeadacheScreen, arguments: _currentUserHeadacheModel);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1.3, color: Constant.chatBubbleGreen),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: CustomTextWidget(
                                  text: Constant.addDetails,
                                  style: TextStyle(
                                      color: Constant.chatBubbleGreen,
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _storeHeadacheDataIntoDB() async{
    _currentUserHeadacheModel = await _headacheLogStartedBloc.storeHeadacheDetailsIntoLocalDatabase(context);
  }

  Future<void> _showDiscardChangesBottomSheet() async {
    if (!_currentUserHeadacheModel!.isFromServer!) {
      var resultOfDiscardChangesBottomSheet = await showCupertinoModalPopup(
          context: context,
          builder: (context) => HeadacheDiscardActionSheet());

      if (resultOfDiscardChangesBottomSheet == Constant.keepHeadacheAndExit) {
        Navigator.pop(context);
      } else if (resultOfDiscardChangesBottomSheet == Constant.discardHeadache) {
        await SignUpOnBoardProviders.db.deleteUserCurrentHeadacheData();
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }
}
