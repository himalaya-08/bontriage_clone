import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/util/MonthYearCupertinoDatePicker.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CompareCompassScreen.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/OverTimeCompassScreen.dart';
import 'package:mobile/view/slide_dots.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompassScreen extends StatefulWidget {
  final Function(Stream, Function)? showApiLoaderCallback;
  final Future<dynamic> Function(String, dynamic)? navigateToOtherScreenCallback;
  final Future<dynamic> Function(String, dynamic)? openActionSheetCallback;
  final Future<DateTime> Function(MonthYearCupertinoDatePickerMode, Function, DateTime)?
      openDatePickerCallback;

  const CompassScreen(
      {Key? key,
       this.showApiLoaderCallback,
       this.navigateToOtherScreenCallback,
       this.openActionSheetCallback,
       this.openDatePickerCallback})
      : super(key: key);

  @override
  _CompassScreenState createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  PageController _pageController = PageController();
  List<Widget> pageViewWidgetList = [];

  //int currentIndex = 0;

  StreamController<dynamic> _initPageViewStreamController = StreamController();

  StreamSink<dynamic> get initPageViewSink =>
      _initPageViewStreamController.sink;

  Stream<dynamic> get initPageViewStream =>
      _initPageViewStreamController.stream;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    pageViewWidgetList = [Container()];
    _initPageViewStreamController = StreamController<dynamic>();
  }

  @override
  void didUpdateWidget(CompassScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    getCurrentPositionOfTabBar();
  }

  @override
  void dispose() {
    _initPageViewStreamController.close();
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
                    var compassInfo =
                        Provider.of<CompassInfo>(context, listen: false);
                    int currentIndex = compassInfo.getCurrentIndex();

                    if (currentIndex == 1) {
                      currentIndex = currentIndex - 1;
                      _pageController.animateToPage(currentIndex,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                      compassInfo.updateCompassInfo(currentIndex);
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
                Consumer<CompassInfo>(
                  builder: (context, data, child) {
                    int currentIndex = data.getCurrentIndex();
                    return CustomTextWidget(
                      text: currentIndex == 0 ? 'Over Time' : 'Compare',
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
                    var compassInfo =
                        Provider.of<CompassInfo>(context, listen: false);
                    int currentIndex = compassInfo.getCurrentIndex();

                    if (currentIndex == 0) {
                      currentIndex = currentIndex + 1;
                      _pageController.animateToPage(currentIndex,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                      compassInfo.updateCompassInfo(currentIndex);
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
            Consumer<CompassInfo>(
              builder: (context, data, child) {
                int currentIndex = data.getCurrentIndex();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideDots(isActive: currentIndex == 0),
                    SlideDots(isActive: currentIndex == 1)
                  ],
                );
              },
            ),
            Expanded(
              child: StreamBuilder<dynamic>(
                stream: initPageViewStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ChangeNotifierProvider(
                      create: (context) => CompassScreenUpdateInfo(),
                      child: PageView.builder(
                        itemBuilder: (context, index) {
                          return pageViewWidgetList[index];
                        },
                        controller: _pageController,
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (index) {
                          var compassInfo =
                              Provider.of<CompassInfo>(context, listen: false);
                          compassInfo.updateCompassInfo(index);
                        },
                        reverse: false,
                        itemCount: pageViewWidgetList.length,
                      ),
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
      print(e);
    }
    print(currentPositionOfTabBar);
    if (currentPositionOfTabBar == 1 && recordTabBarPosition == 1) {
      pageViewWidgetList = [
        OverTimeCompassScreen(
          openActionSheetCallback: widget.openActionSheetCallback!,
          showApiLoaderCallback: widget.showApiLoaderCallback!,
          navigateToOtherScreenCallback: widget.navigateToOtherScreenCallback!,
          openDatePickerCallback: widget.openDatePickerCallback!,
        ),
        CompareCompassScreen(
          openActionSheetCallback: widget.openActionSheetCallback!,
          showApiLoaderCallback: widget.showApiLoaderCallback!,
          navigateToOtherScreenCallback: widget.navigateToOtherScreenCallback!,
          openDatePickerCallback: widget.openDatePickerCallback!,
        ),
      ];
      initPageViewSink.add('Data');
    }
  }
}

class CompassInfo with ChangeNotifier {
  int _currentIndex = 0;

  int getCurrentIndex() => _currentIndex;

  updateCompassInfo(int currentIndex) {
    _currentIndex = currentIndex;
    notifyListeners();
  }
}

class CompassScreenUpdateInfo with ChangeNotifier {
  bool _updateCompareScreen = false;
  bool _updateOverTimeScreen = false;
  
  bool get getUpdateCompareScreenInfo => _updateCompareScreen;
  bool get getUpdateOverTimeScreenInfo => _updateOverTimeScreen;
  
  updateCompareScreenInfo(bool value){
    _updateCompareScreen = value;
    if(value) notifyListeners();
  }
  
  updateOverTimeScreenInfo(bool value){
    _updateOverTimeScreen = value;
    if(value) notifyListeners();
  }

  @override
  // ignore: must_call_super
  void dispose() {}
}
