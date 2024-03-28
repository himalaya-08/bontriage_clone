import 'dart:async';
import 'dart:math';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/blocs/CurrentHeadacheProgressBloc.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:provider/provider.dart';

import '../providers/SignUpOnBoardProviders.dart';
import 'HeadacheDiscardActionSheet.dart';

class CurrentHeadacheProgressScreen extends StatefulWidget {
  final CurrentUserHeadacheModel? currentUserHeadacheModel;

  const CurrentHeadacheProgressScreen({Key? key, this.currentUserHeadacheModel}) : super(key: key);

  @override
  _CurrentHeadacheProgressScreenState createState() =>
      _CurrentHeadacheProgressScreenState();
}

class _CurrentHeadacheProgressScreenState
    extends State<CurrentHeadacheProgressScreen> {
  DateTime _dateTime = DateTime.now();
  DateTime? _storedDateTime;
  Timer? _timer;
  bool _isAlreadyDataFetched = false;
  CurrentHeadacheProgressBloc _currentHeadacheProgressBloc = CurrentHeadacheProgressBloc();
  CurrentUserHeadacheModel _currentUserHeadacheModel = CurrentUserHeadacheModel();
  bool _isShowErrorMessage = false;

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    //_dateTime = DateTime.tryParse(Utils.getDateTimeInUtcFormat(DateTime.now()));

    _currentHeadacheProgressBloc = CurrentHeadacheProgressBloc();

    _currentHeadacheProgressBloc.fetchDataFromLocalDatabase(widget.currentUserHeadacheModel);

    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      var currentHeadacheTimeInfo = Provider.of<CurrentHeadacheTimerInfo>(context, listen: false);
      int totalTime = currentHeadacheTimeInfo.getTotalTime();

      totalTime++;

      if ((totalTime ~/ 60) > 23)
        currentHeadacheTimeInfo.updateCurrentTimerInfo(totalTime, true);
      else
        currentHeadacheTimeInfo.updateCurrentTimerInfo(totalTime, false);
    });

    Utils.setAnalyticsCurrentScreen(Constant.currentHeadacheProgressScreen, context);
  }

  ///This method is used to return the display time format for the headache time
  /// Short Time
  /// Medium Time
  /// Long Time
  String _getDisplayTime(int totalTime) {
    int hours = totalTime ~/ 60;
    int minute = totalTime % 60;

    if (hours < 10) {
      if (minute < 10) {
        return '$hours:0$minute h';
      } else {
        return '$hours:$minute h';
      }
    } else if (hours < 24) {
      if (minute < 10) {
        return '${hours}h 0${minute}m';
      } else {
        return '${hours}h ${minute}m';
      }
    } else {
      int days = (hours == 24) ? 1 : hours ~/ 24;
      hours = hours % 24;
      if (minute < 10) {
        if(days > 1)
          return '$days days,\n$hours:0$minute h';
        else
          return '$days day,\n$hours:0$minute h';
      } else {
        if(days > 1)
          return '$days days,\n$hours:$minute h';
        else
          return '$days day,\n$hours:$minute h';
      }
    }
  }

  double _getCurrentHeadacheProgressPercent(int totalTime) {
    double percentValue = 0;

    percentValue = ((totalTime % (24 * 60)) / (24 * 60));
    if (percentValue > 1) {
      percentValue -= 1;
    }
    return percentValue * 100;
  }

  @override
  void dispose() {
    try {
      _timer!.cancel();
    } catch(e) {
      debugPrint(e.toString());
    }
    _currentHeadacheProgressBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _dateTime = DateTime.tryParse(Utils.getDateTimeInUtcFormat(_dateTime, true, context))!;
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
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextWidget(
                              text: '${Utils.getMonthName(_dateTime.month)} ${_dateTime.day}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Constant.chatBubbleGreen,
                                  fontFamily: Constant.jostMedium),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                //Navigator.pop(context);
                                _showDiscardChangesBottomSheet();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, top: 5, bottom: 10),
                                child: Image(
                                  image: AssetImage(Constant.closeIcon),
                                  width: 22,
                                  height: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 30,
                          thickness: 1,
                          color: Constant.chatBubbleGreen,
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        StreamBuilder(
                          stream: _currentHeadacheProgressBloc.stream,
                          builder: (context, snapshot) {
                            if(snapshot.hasData) {
                              if(snapshot.data != null && snapshot.data is CurrentUserHeadacheModel && !_isAlreadyDataFetched) {
                                _resetTimeSeconds(snapshot.data);
                              }
                              return Column(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: CustomTextWidget(
                                      text: Constant.yourCurrentHeadache,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Constant.chatBubbleGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Container(
                                    width: 190,
                                    height: 190,
                                    child: Consumer<CurrentHeadacheTimerInfo>(
                                      builder: (context, data, child) {
                                        return Stack(
                                          children: [
                                            Visibility(
                                              visible: data.isShowDayBorder(),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Constant.chatBubbleGreen,
                                                      width: 3),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: ClipPath(
                                                clipper: ProgressClipper(
                                                    percent: _getCurrentHeadacheProgressPercent(data.getTotalTime())),
                                                child: Container(
                                                  width: 170,
                                                  height: 170,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Constant.chatBubbleGreen
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: <Color>[
                                                        Color(0xff0E4C47),
                                                        Color(0xff0E232F),
                                                      ]),
                                                ),
                                                child: Center(
                                                  child: CustomTextWidget(
                                                    text: _getDisplayTime(data.getTotalTime()),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily: Constant.jostMedium,
                                                        color: Constant.chatBubbleGreen),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: CustomTextWidget(
                                      text: Constant.started,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: Constant.jostMedium,
                                          color: Constant.chatBubbleGreen),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: CustomTextWidget(
                                      text: (_storedDateTime != null)
                                          ? '${Utils.getWeekDay(_storedDateTime!)}, ${Utils.getShortMonthName(_storedDateTime!.month)} ${_storedDateTime!.day} ${Constant.at} ${Utils.getTimeInAmPmFormat(_storedDateTime!.hour, _storedDateTime!.minute)}'
                                          : '${Utils.getShortMonthName(DateTime.now().month)} ${DateTime.now().day}, ${Utils.getTimeInAmPmFormat(DateTime.now().hour, DateTime.now().minute)}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: Constant.jostRegular,
                                          color: Constant.chatBubbleGreen),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Visibility(
                                    visible: _isShowErrorMessage,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          image: AssetImage(Constant.warningPink),
                                          width: 22,
                                          height: 22,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        CustomTextWidget(
                                          text: Constant.logHeadacheError,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Constant.pinkTriggerColor,
                                              fontFamily: Constant.jostRegular),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      BouncingWidget(
                                        onPressed: () {
                                          var appConfig = AppConfig.of(context);
                                          if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
                                            Navigator.pushNamed(context, Constant.addHeadacheOnGoingScreenRouter, arguments: _currentUserHeadacheModel);
                                          else
                                            Navigator.pushNamed(context, Constant.tonixAddHeadacheScreen, arguments: _currentUserHeadacheModel);
                                        },
                                        child: Container(
                                          width: 130,
                                          padding: EdgeInsets.symmetric(vertical: 7),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1.3,
                                                color: Constant.chatBubbleGreen),
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: Center(
                                            child: CustomTextWidget(
                                              text: Constant.addEditDetails,
                                              style: TextStyle(
                                                  color: Constant.chatBubbleGreen,
                                                  fontSize: 13,
                                                  fontFamily: Constant.jostMedium),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      BouncingWidget(
                                        onPressed: () {
                                          _navigateToAddHeadacheScreen();
                                        },
                                        child: Container(
                                          width: 130,
                                          padding: EdgeInsets.symmetric(vertical: 7),
                                          decoration: BoxDecoration(
                                            color: Constant.chatBubbleGreen,
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: Center(
                                            child: CustomTextWidget(
                                              text: Constant.endHeadache,
                                              style: TextStyle(
                                                  color: Constant.bubbleChatTextView,
                                                  fontSize: 13,
                                                  fontFamily: Constant.jostMedium),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              );
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
        ),
      ),
    );
  }

  void _resetTimeSeconds(dynamic currentUserHeadacheModel) {
    try {
      var appConfig = AppConfig.of(context);
      _currentUserHeadacheModel = currentUserHeadacheModel;

      DateTime dateTime;
      if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
        dateTime = DateTime.parse(currentUserHeadacheModel.selectedDate!);
      else
        dateTime = DateTime.parse(currentUserHeadacheModel.selectedDate!).toLocal();
      _storedDateTime = dateTime;

      Duration duration = _dateTime.difference(dateTime);

      var currentHeadacheTimeInfo = Provider.of<CurrentHeadacheTimerInfo>(context, listen: false);

      int totalTime = duration.inMinutes;

      if(!_currentUserHeadacheModel.isOnGoing!)  {
        _timer!.cancel();
      }

      bool isShowDayBorder = duration.inDays >= 1;

      currentHeadacheTimeInfo.updateCurrentTimerInfo(totalTime, isShowDayBorder, false);
      _isAlreadyDataFetched = true;
    } catch(e) {
      debugPrint(e.toString());
    }
  }

  void _navigateToAddHeadacheScreen() async{
    _currentUserHeadacheModel.isOnGoing = false;

    DateTime currentDateTime = DateTime.now();
    DateTime endHeadacheDateTime = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, currentDateTime.hour, currentDateTime.minute, 0, 0, 0);
    /*DateTime startHeadacheDateTime = DateTime.tryParse(_currentUserHeadacheModel.selectedDate);
    Duration duration = endHeadacheDateTime.difference(startHeadacheDateTime);*/
    /*if(duration.inSeconds.abs() <= (72*60*60)) {
      _currentUserHeadacheModel.selectedEndDate = endHeadacheDateTime.toUtc().toIso8601String();
    } else {
      _currentUserHeadacheModel.selectedEndDate = startHeadacheDateTime.add(Duration(days: 3)).toUtc().toIso8601String();
    }*/

    _currentUserHeadacheModel.selectedEndDate = Utils.getDateTimeInUtcFormat(endHeadacheDateTime, true, context);
    //await SignUpOnBoardProviders.db.updateUserCurrentHeadacheData(_currentUserHeadacheModel);

    var appConfig = AppConfig.of(context);

    if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
      Navigator.pushNamed(context, Constant.addHeadacheOnGoingScreenRouter, arguments: _currentUserHeadacheModel);
    else
      Navigator.pushNamed(context, Constant.tonixAddHeadacheScreen, arguments: _currentUserHeadacheModel);
  }

  Future<void> _showDiscardChangesBottomSheet() async {
    if (!_currentUserHeadacheModel.isFromServer!) {
      var resultOfDiscardChangesBottomSheet = await showCupertinoModalPopup(
          context: context,
          builder: (context) => HeadacheDiscardActionSheet());

      if (resultOfDiscardChangesBottomSheet == Constant.keepHeadacheAndExit) {
        Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
      } else if (resultOfDiscardChangesBottomSheet == Constant.discardHeadache) {
        await SignUpOnBoardProviders.db.deleteUserCurrentHeadacheData();
        Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
      }
    } else {
      Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
    }
  }
}

class ProgressClipper extends CustomClipper<Path> {
  final double percent;

  const ProgressClipper({this.percent = 0});

  @override
  Path getClip(Size size) {
    double sectorValue = 25;

    //for if (percent >= 50 && percent <= 62.5)
    if (percent >= 50 && percent < 62.5) {
      return Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(0, 0)
          ..lineTo(0, size.height)
          ..lineTo(size.width * 0.5, size.height)
          ..lineTo(size.width * ((62.5 - percent) / sectorValue), size.height)
          ..lineTo(size.width * 0.5, size.height * 0.5)
          ..close(),
      );
    } else if (percent >= 62.5 && percent < 87.5) {
      return Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(0, 0)
          ..lineTo(0, size.height * ((87.5 - percent) / sectorValue))
          ..lineTo(size.width * 0.5, size.height * 0.5)
          ..close(),
      );
    } else if (percent >= 87.5 && percent < 100) {
      return Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(0, 0)
          ..lineTo(size.width * ((percent - 87.5) / sectorValue), 0)
          ..lineTo(size.width * 0.5, size.height * 0.5)
          ..close(),
      );
    } else if (percent >= 0 && percent < 12.5) {
      return Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(0, 0)
          ..lineTo(0, size.height)
          ..lineTo(size.width, size.height)
          ..lineTo(size.width, 0)
          ..lineTo(size.width * (0.5 + (percent / sectorValue)), 0)
          ..lineTo(size.width * 0.5, size.height * 0.5)
          ..close(),
      );
    } else if (percent >= 12.5 && percent < 37.5) {
      return Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(0, 0)
          ..lineTo(0, size.height)
          ..lineTo(size.width, size.height)
          ..lineTo(size.width, size.height * ((percent - 12.5) / sectorValue))
          ..lineTo(size.width * 0.5, size.height * 0.5)
          ..close(),
      );
    } else if (percent >= 37.5 && percent < 50) {
      return Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(0, 0)
          ..lineTo(0, size.height)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(
              size.width * (0.5 + ((50 - percent) / sectorValue)), size.height)
          ..lineTo(size.width * 0.5, size.height * 0.5)
          ..close(),
      );
    }
    return Path();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class GradientProgressBar extends SingleChildRenderObjectWidget {
  GradientProgressBar({
    Key? key,
    required this.painter,
    required Widget child,
  }) : super(key: key, child: child);

  final CustomPainter painter;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomPaint(
      painter: painter,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderCustomPaint renderObject) {
    renderObject..painter = painter;
  }
}

class GradientProgressBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Constant.chatBubbleGreen;

    debugPrint(size.width.toString());

    var circleRect = Offset(85, 0) & Size(170, 170);
    canvas.drawArc(circleRect, -pi / 3, pi * 3, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CurrentHeadacheTimerInfo with ChangeNotifier {
  int _totalTime = 0; //in minutes
  bool _isShowDayBorder = false;

  int getTotalTime() => _totalTime;
  bool isShowDayBorder() => _isShowDayBorder;

  updateCurrentTimerInfo(int totalTime, bool isShowDayBorder, [bool shouldNotify = true]) {
    _totalTime = totalTime;
    _isShowDayBorder = isShowDayBorder;

    if(shouldNotify)
      notifyListeners();
  }
}
