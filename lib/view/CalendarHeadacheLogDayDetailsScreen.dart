import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/blocs/CalendarHeadacheLogDayDetailsBloc.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/UserHeadacheLogDayDetailsModel.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/RecordCalendarHeadacheSection.dart';
import 'package:mobile/view/RecordDayPage.dart';

class CalendarHeadacheLogDayDetailsScreen extends StatefulWidget {
  final DateTime? dateTime;

  const CalendarHeadacheLogDayDetailsScreen({Key? key, this.dateTime})
      : super(key: key);

  @override
  _CalendarHeadacheLogDayDetailsScreenState createState() =>
      _CalendarHeadacheLogDayDetailsScreenState();
}

class _CalendarHeadacheLogDayDetailsScreenState
    extends State<CalendarHeadacheLogDayDetailsScreen> {
  DateTime? _dateTime;
  bool isPageChanged = false;
  bool isDataUpdated = false;
  CalendarHeadacheLogDayDetailsBloc calendarHeadacheLogDayDetailsBloc = CalendarHeadacheLogDayDetailsBloc();
  UserHeadacheLogDayDetailsModel userHeadacheLogDayDetailsModel =
      UserHeadacheLogDayDetailsModel();
  int? _headacheIdSelected;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    _dateTime = widget.dateTime;
    calendarHeadacheLogDayDetailsBloc = CalendarHeadacheLogDayDetailsBloc();
    print("SelectedDate??????$_dateTime");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      callAPIService();
    });
  }

  @override
  @override
  void dispose() {
    calendarHeadacheLogDayDetailsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, isDataUpdated);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: Constant.backgroundBoxDecoration,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: SafeArea(
                child: Container(
                  margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Constant.backgroundColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomTextWidget(
                                text: '${Utils.getMonthName(_dateTime!.month)} ${_dateTime!.day}',
                                style: TextStyle(
                                  color: Constant.chatBubbleGreen,
                                  fontSize: 20,
                                  fontFamily: Constant.jostRegular,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Navigator.pop(context, isDataUpdated);
                              },
                              child: Image(
                                image: AssetImage(Constant.closeIcon),
                                width: 22,
                                height: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      StreamBuilder<dynamic>(
                          stream: calendarHeadacheLogDayDetailsBloc
                              .calendarLogDayDetailsDataStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data is UserHeadacheLogDayDetailsModel) {
                              userHeadacheLogDayDetailsModel = snapshot.data;
                              return Column(
                                children: [
                                  RecordCalendarHeadacheSection(
                                    dateTime: _dateTime!,
                                    userHeadacheLogDayDetailsModel: userHeadacheLogDayDetailsModel,
                                    onHeadacheTypeSelectedCallback: (headacheIdSelected) {
                                      _headacheIdSelected = headacheIdSelected;
                                    },
                                    openHeadacheLogDayScreenCallback: _openHeadacheLogDayScreen,
                                    onGoingHeadacheId: calendarHeadacheLogDayDetailsBloc.onGoingHeadacheId,
                                  ),
                                  RecordDayPage(
                                    hasData: userHeadacheLogDayDetailsModel.headacheLogDayListData != null &&
                                    userHeadacheLogDayDetailsModel.headacheLogDayListData?.isNotEmpty == true,
                                    dateTime: _dateTime!,
                                    userHeadacheLogDayDetailsModel:
                                    userHeadacheLogDayDetailsModel,
                                    openHeadacheLogDayScreenCallback: _openHeadacheLogDayScreen,
                                    onGoingHeadacheId: calendarHeadacheLogDayDetailsBloc.onGoingHeadacheId,
                                  ),

                                ],
                              );
                            } else {
                              return Container(
                                height: 100,
                              );
                            }
                          })
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void callAPIService() {
    calendarHeadacheLogDayDetailsBloc.initNetworkStreamController();
    Utils.showApiLoaderDialog(context,
        networkStream: calendarHeadacheLogDayDetailsBloc.networkDataStream,
        tapToRetryFunction: () {
      calendarHeadacheLogDayDetailsBloc.enterSomeDummyDataToStream();
      _requestService();
    });
    _requestService();
  }

  void _requestService() {
    String selectedDate = '${_dateTime!.year}-${_dateTime!.month}-${_dateTime!.day}T00:00:00Z';
    calendarHeadacheLogDayDetailsBloc.fetchMedicationHistoryLogDayData(selectedDate, context);
  }

  ///Method to open headache or log day screen
  ///@param isForHeadache: to identify which screen should open (Add Headache or Log Day screen)
  ///@param arguments: arguments needed to be send to other screen
  void _openHeadacheLogDayScreen(bool isForHeadache, bool isEditing, dynamic arguments) async{
      dynamic dataReceived;
      var appConfig = AppConfig.of(context);

      if(isForHeadache) {
        if(arguments is CurrentUserHeadacheModel && arguments != null && isEditing) {
          arguments.headacheId = _headacheIdSelected;
        }
        if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
          dataReceived = await Navigator.pushNamed(context, Constant.addHeadacheOnGoingScreenRouter, arguments: arguments);
        else
          dataReceived = await Navigator.pushNamed(context, Constant.tonixAddHeadacheScreen, arguments: arguments);
      } else {
        dataReceived = await Navigator.pushNamed(context, Constant.logDayScreenRouter,
            arguments: arguments);
      }
      
      print('RECORD DAY DATA??????$dataReceived');

      if(dataReceived != null && dataReceived is bool) {
        if(dataReceived) {
          isDataUpdated = true;
          callAPIService();
        }
      }
  }
}
