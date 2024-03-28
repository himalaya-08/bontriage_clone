import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';

import 'CustomTextWidget.dart';

class LogDaySuccessScreen extends StatefulWidget {
  @override
  _LogDaySuccessScreenState createState() => _LogDaySuccessScreenState();
}

class _LogDaySuccessScreenState extends State<LogDaySuccessScreen> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    Utils.setAnalyticsCurrentScreen(Constant.logDaySuccessScreen, context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: Constant.backgroundBoxDecoration,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height
              ),
              child: SafeArea(
                child: Container(
                  margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
                  decoration: BoxDecoration(
                    color: Constant.backgroundColor,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
                            onTap: (){
                              //Navigator.pop(context);
                              Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 5),
                              child: Image(
                                image: AssetImage(Constant.closeIcon),
                                width: 22,
                                height: 22,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 80,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Align(
                            alignment: Alignment.center,
                            child: CustomTextWidget(
                              text: Constant.dayLogged,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Constant.chatBubbleGreen,
                                  fontFamily: Constant.jostMedium
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Align(
                            alignment: Alignment.center,
                            child: CustomTextWidget(
                              text: Constant.loggedDaysInARow,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Constant.chatBubbleGreen,
                                  fontFamily: Constant.jostMedium
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 80,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          child: BouncingWidget(
                            onPressed: () {
                              //Navigator.pushNamed(context, Constant.addHeadacheOnGoingScreenRouter);
                            },
                            child: Visibility(
                              visible: false,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1.3, color: Constant.chatBubbleGreen),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: CustomTextWidget(
                                    text: Constant.viewTrends,
                                    style: TextStyle(
                                        color: Constant.chatBubbleGreen,
                                        fontSize: 15,
                                        fontFamily: Constant.jostMedium),
                                  ),
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
}
