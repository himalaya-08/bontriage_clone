import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/util/MonthYearCupertinoDatePicker.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CalendarIntensityScreen.dart';
import 'package:mobile/view/slide_dots.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CalendarTriggersScreen.dart';
import 'CustomTextWidget.dart';

class CalendarScreen extends StatefulWidget {
  final Function(Stream, Function)? showApiLoaderCallback;
  final Future<dynamic> Function(String, dynamic)? navigateToOtherScreenCallback;
  final Future<DateTime> Function(MonthYearCupertinoDatePickerMode, Function, DateTime)?
      openDatePickerCallback;

  const CalendarScreen(
      {Key? key,
       this.showApiLoaderCallback,
       this.navigateToOtherScreenCallback,
       this.openDatePickerCallback})
      : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  PageController? _pageController;
  List<Widget>? pageViewWidgetList;

  //int currentIndex = 0;

  StreamController<dynamic>? _refreshCalendarDataStreamController;

  StreamSink<dynamic> get refreshCalendarDataSink =>
      _refreshCalendarDataStreamController!.sink;

  Stream<dynamic> get refreshCalendarDataStream =>
      _refreshCalendarDataStreamController!.stream;

  StreamController<dynamic>? _initPageViewStreamController;

  StreamSink<dynamic> get initPageViewSink =>
      _initPageViewStreamController!.sink;

  Stream<dynamic> get initPageViewStream =>
      _initPageViewStreamController!.stream;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    pageViewWidgetList = [Container()];
    _refreshCalendarDataStreamController =
        StreamController<dynamic>.broadcast();
    _initPageViewStreamController = StreamController<dynamic>();
  }

  @override
  void didUpdateWidget(CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    getCurrentPositionOfTabBar();
    debugPrint('In did update widget calendar screen');
  }

  @override
  void dispose() {
    _refreshCalendarDataStreamController?.close();
    _initPageViewStreamController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    var calendarInfo =
                        Provider.of<CalendarInfo>(context, listen: false);
                    int currentIndex = calendarInfo.getCurrentIndex();
                    if (currentIndex == 1) {
                      currentIndex = currentIndex - 1;
                      _pageController!.animateToPage(currentIndex,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                      calendarInfo.updateCalendarInfo(currentIndex);
                    }
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Constant.backgroundColor.withOpacity(0.85),
                    child: Image(
                      image: AssetImage(Constant.calenderBackArrow),
                      width: 15,
                      height: 15,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                ),
                Consumer<CalendarInfo>(
                  builder: (context, data, child) {
                    int currentIndex = data.getCurrentIndex();
                    return CustomTextWidget(
                      text: currentIndex != 0 ? 'Triggers' : 'Intensity',
                      style: TextStyle(
                          color: Constant.locationServiceGreen,
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          fontFamily: Constant.jostMedium),
                    );
                  },
                ),
                SizedBox(
                  width: 60,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    var calendarInfo =
                        Provider.of<CalendarInfo>(context, listen: false);
                    int currentIndex = calendarInfo.getCurrentIndex();
                    if (currentIndex == 0) {
                      currentIndex = currentIndex + 1;
                      _pageController!.animateToPage(currentIndex,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                      calendarInfo.updateCalendarInfo(currentIndex);
                    }
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Constant.backgroundColor.withOpacity(0.85),
                    child: Image(
                      image: AssetImage(Constant.calenderNextArrow),
                      width: 15,
                      height: 15,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Consumer<CalendarInfo>(
              builder: (context, data, child) {
                int currentIndex = data.getCurrentIndex();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideDots(isActive: currentIndex == 0),
                    SlideDots(isActive: currentIndex == 1),
                  ],
                );
              },
            ),
            Expanded(
              child: StreamBuilder<dynamic>(
                stream: initPageViewStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return PageView.builder(
                      itemBuilder: (context, index) {
                        return pageViewWidgetList![index];
                      },
                      controller: _pageController,
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (index) {
                        var calendarInfo =
                            Provider.of<CalendarInfo>(context, listen: false);
                        calendarInfo.updateCalendarInfo(index);
                      },
                      reverse: false,
                      itemCount: pageViewWidgetList!.length,
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getCurrentPositionOfTabBar() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? currentPositionOfTabBar =
        sharedPreferences.getInt(Constant.currentIndexOfTabBar);
    int? recordTabBarPosition = 0;

    try {
      recordTabBarPosition =
          sharedPreferences.getInt(Constant.recordTabNavigatorState);
    } catch (e) {
      debugPrint(e.toString());
    }

    debugPrint('currentPositionOfTabBar?????$currentPositionOfTabBar????????recordTabBarPosition????$recordTabBarPosition');
    if (currentPositionOfTabBar == 1 && recordTabBarPosition == 0) {
      if (pageViewWidgetList!.length == 1) {
        pageViewWidgetList = [
          CalendarIntensityScreen(
            showApiLoaderCallback: widget.showApiLoaderCallback,
            navigateToOtherScreenCallback: widget.navigateToOtherScreenCallback,
            refreshCalendarDataStream: refreshCalendarDataStream,
            refreshCalendarDataSink: refreshCalendarDataSink,
            openDatePickerCallback: widget.openDatePickerCallback,
          ),
          CalendarTriggersScreen(
            showApiLoaderCallback: widget.showApiLoaderCallback,
            navigateToOtherScreenCallback: widget.navigateToOtherScreenCallback,
            refreshCalendarDataStream: refreshCalendarDataStream,
            refreshCalendarDataSink: refreshCalendarDataSink,
            openDatePickerCallback: widget.openDatePickerCallback,
          ),
        ];
      }
      else {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();

        String isSeeMoreClicked =
            sharedPreferences.getString(Constant.isSeeMoreClicked) ??
                Constant.blankString;
        String isTrendsClicked =
            sharedPreferences.getString(Constant.isViewTrendsClicked) ??
                Constant.blankString;
        String updateCalendarTriggerData =
            sharedPreferences.getString(Constant.updateCalendarTriggerData) ??
                Constant.blankString;
        String updateCalendarIntensityData =
            sharedPreferences.getString(Constant.updateCalendarIntensityData) ??
                Constant.blankString;

        if (isSeeMoreClicked.isEmpty &&
            isTrendsClicked.isEmpty &&
            (updateCalendarIntensityData == Constant.trueString ||
                updateCalendarTriggerData == Constant.trueString)) {
          refreshCalendarDataSink.add(true);
        } else if (isSeeMoreClicked == Constant.trueString && (updateCalendarIntensityData == Constant.trueString ||
            updateCalendarTriggerData == Constant.trueString)) {
          refreshCalendarDataSink.add(true);
        }
      }
      initPageViewSink.add('data');
    }
  }
}

class CalendarInfo with ChangeNotifier {
  int _currentIndex = 0;

  int getCurrentIndex() => _currentIndex;

  updateCalendarInfo(int currentIndex) {
    _currentIndex = currentIndex;
    notifyListeners();
  }
}
