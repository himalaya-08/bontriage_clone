import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobile/util/constant.dart';
import 'package:provider/provider.dart';
import 'CustomTextWidget.dart';
import 'slide_dots.dart';
import 'WelcomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  PageController _pageController = PageController(initialPage: 0);

  List<Widget> _pageViewWidgets = [
    WelcomePage(
      headerText: Constant.welcomeToMigraineMentor,
      imagePath: Constant.logoShadow,
      subText: Constant.developedByATeam,
    ),
    WelcomePage(
      headerText: Constant.trackRightData,
      imagePath: Constant.chartShadow,
      subText: Constant.mostHeadacheTracking,
    ),
    WelcomePage(
      headerText: Constant.conquerYourHeadaches,
      imagePath: Constant.notifsGreenShadow,
      subText: Constant.withRegularUse,
    ),
  ];

  Widget _getThreeDotsWidget(int currentPageIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SlideDots(isActive: currentPageIndex == 0),
        SlideDots(isActive: currentPageIndex == 1),
        SlideDots(isActive: currentPageIndex == 2),
      ],
    );
  }

  String _getButtonText(int currentPageIndex) {
    if (currentPageIndex == 2)
      return Constant.getGoing;
    else
      return Constant.next;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Container(
          decoration: Constant.backgroundBoxDecoration,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: _pageViewWidgets.length,
                    controller: _pageController,
                    onPageChanged: (currentPage) {
                      var welcomePageInfoData = Provider.of<WelcomePageInfo>(context, listen: false);
                      welcomePageInfoData.updateCurrentPageIndex(currentPage);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return _pageViewWidgets[index];
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Consumer<WelcomePageInfo>(
                        builder: (context, data, child) {
                          return _getThreeDotsWidget(data.getCurrentPageIndex());
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      BouncingWidget(
                        onPressed: () {
                          var welcomePageInfoData = Provider.of<WelcomePageInfo>(context, listen: false);
                          int currentPageIndex = welcomePageInfoData.getCurrentPageIndex();
                          if (currentPageIndex != 2) {
                            _pageController.animateToPage(currentPageIndex + 1,
                                duration: Duration(milliseconds: 250),
                                curve: Curves.easeIn);
                          } else {
                            saveTutorialsState();
                            Navigator.pushReplacementNamed(
                                context, Constant.welcomeStartAssessmentScreenRouter);
                          }
                        },
                        child: Container(
                          width: 140,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color(0xffafd794),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Consumer<WelcomePageInfo>(
                              builder: (context, data, child) {
                                return CustomTextWidget(
                                  text: _getButtonText(data.getCurrentPageIndex()),
                                  style: TextStyle(
                                      color: Constant.bubbleChatTextView,
                                      fontSize: 14,
                                      fontFamily: Constant.jostMedium),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void saveTutorialsState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constant.tutorialsState, true);
  }

  Future<bool> _onBackPressed() async{
    var welcomePageInfoData = Provider.of<WelcomePageInfo>(context, listen: false);
    int currentPageIndex = welcomePageInfoData.getCurrentPageIndex();
    if(currentPageIndex == 0) {
      return true;
    } else {
      _pageController.animateToPage(currentPageIndex - 1, duration: Duration(milliseconds: 250), curve: Curves.easeIn);
      return false;
    }
  }
}

class WelcomePageInfo with ChangeNotifier {
  int _currentPageIndex = 0;

  int getCurrentPageIndex() => _currentPageIndex;

  updateCurrentPageIndex(int currentIndex) {
    _currentPageIndex = currentIndex;
    notifyListeners();
  }
}