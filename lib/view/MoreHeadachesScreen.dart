import 'dart:io';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile/blocs/MoreHeadachesBloc.dart';
import 'package:mobile/models/MoreHeadacheScreenArgumentModel.dart';
import 'package:mobile/models/PDFScreenArgumentModel.dart';
import 'package:mobile/models/PartTwoOnBoardArgumentModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserGenerateReportDataModel.dart';
import 'package:mobile/util/TabNavigatorRoutes.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/MoreSection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CustomTextWidget.dart';

class MoreHeadachesScreen extends StatefulWidget {
  final Function(BuildContext, String, dynamic) onPush;
  final Future<dynamic> Function(String, dynamic) openActionSheetCallback;
  final MoreHeadacheScreenArgumentModel moreHeadacheScreenArgumentModel;
  final Function(Stream, Function) showApiLoaderCallback;
  final Future<dynamic> Function(String, dynamic) navigateToOtherScreenCallback;

  const MoreHeadachesScreen(
      {Key? key,
      required this.onPush,
      required this.openActionSheetCallback,
      required this.moreHeadacheScreenArgumentModel,
      required this.showApiLoaderCallback,
      required this.navigateToOtherScreenCallback})
      : super(key: key);

  @override
  _MoreHeadachesScreenState createState() => _MoreHeadachesScreenState();
}

class _MoreHeadachesScreenState extends State<MoreHeadachesScreen> {
  MoreHeadacheBloc _bloc = MoreHeadacheBloc();
  int? _totalDaysInCurrentMonth;
  DateTime startDateTime = DateTime.now();
  TextStyle _textStyle = TextStyle(
    color: Constant.locationServiceGreen,
    fontSize: 14,
    fontFamily: Constant.jostMedium,
  );

  @override
  void initState() {
    super.initState();
    _bloc = MoreHeadacheBloc();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.showApiLoaderCallback(_bloc.networkStream, () {
        _bloc.enterDummyDataToNetworkStream();
        _bloc.getClinicalImpressionData(
            widget.moreHeadacheScreenArgumentModel.headacheTypeData!.text ?? '',
            context);
      });
      _bloc.getClinicalImpressionData(
          widget.moreHeadacheScreenArgumentModel.headacheTypeData!.text ?? '',
          context);
    });

    _listenToDeleteHeadacheStream();
    _listenToViewReportStream();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
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
                        Navigator.pop(context, );
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
                            Expanded(
                              child: CustomTextWidget(
                                text: widget.moreHeadacheScreenArgumentModel
                                        .isFromMyProfile!
                                    ? Constant.myProfile
                                    : Constant.headacheTypes,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Constant.locationServiceGreen,
                                  fontSize: 16,
                                  fontFamily: Constant.jostRegular,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Constant.moreBackgroundColor,
                      ),
                      child: Column(
                        children: [
                          MoreSection(
                            currentTag: Constant.viewReport,
                            text: Constant.viewReport,
                            moreStatus: '',
                            isShowDivider: true,
                            viewReportClickedCallback: () {
                             // _checkStoragePermission().then((value) {
                               // if (value) {
                                  _openDateRangeActionSheet(
                                      Constant.dateRangeActionSheet, null);
                                //}
                              //});
                            },
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              _bloc.initNetworkStreamController();
                              widget.showApiLoaderCallback(_bloc.networkStream,
                                  () {
                                _bloc.networkSink.add(Constant.loading);
                                _getDiagnosticAnswerList();
                              });
                              _getDiagnosticAnswerList();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextWidget(
                                  text: Constant.reCompleteInitialAssessment,
                                  style: TextStyle(
                                      color:
                                          Constant.addCustomNotificationTextColor,
                                      fontSize: 16,
                                      fontFamily: Constant.jostRegular),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Image(
                                      width: 16,
                                      height: 16,
                                      image: AssetImage(Constant.rightArrow),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            thickness: 1,
                            height: 30,
                            color: Constant.locationServiceGreen,
                          ),
                          GestureDetector(
                            onTap: () {
                              _openDeleteHeadacheActionSheet();
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextWidget(
                                  text: Constant.deleteHeadacheType,
                                  style: TextStyle(
                                      color: Constant.pinkTriggerColor,
                                      fontSize: 16,
                                      fontFamily: Constant.jostRegular),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Image(
                                      width: 16,
                                      height: 16,
                                      image: AssetImage(Constant.rightArrow),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    StreamBuilder<dynamic>(
                        stream: _bloc.clinicalImpressionStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data is List<String>) {
                              return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 15),
                                  child: _getClinicalImpressionWidget(snapshot
                                      .data) /*CustomTextWidget(
                                text: _getInfoText(snapshot.data),
                                style: TextStyle(
                                    color: Constant.locationServiceGreen,
                                    fontSize: 14,
                                    fontFamily: Constant.jostMedium
                                ),
                              ),*/
                                  );
                            } else
                              return Container();
                          } else {
                            return Container();
                          }
                        }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getInfoText(List<String> clinicalImpression) {
    return 'Based on what you entered, it looks like your ${widget.moreHeadacheScreenArgumentModel.headacheTypeData!.text} could potentially be considered by doctors to be $clinicalImpression. This is not a diagnosis, but it is an accurate clinical impression, based on your answers, of how your headache best matches up to known headache types. If you haven’t already done so, you should see a qualified medical professional for a firm diagnosis';
  }

  void _openDeleteHeadacheActionSheet() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var resultOfActionSheet = await widget.openActionSheetCallback(
        Constant.deleteHeadacheTypeActionSheet, null);
    if (resultOfActionSheet == Constant.deleteHeadacheType) {
      var result = await Utils.showConfirmationDialog(
          context, 'Are you sure want to delete this headache type?');
      if (result == 'Yes') {
        _bloc.initNetworkStreamController();
        widget.showApiLoaderCallback(_bloc.networkStream, () {
          _bloc.networkSink.add(Constant.loading);
          _bloc.callDeleteHeadacheTypeService(
              widget.moreHeadacheScreenArgumentModel.headacheTypeData!
                      .valueNumber ??
                  '',
              context);
        });
        _bloc.callDeleteHeadacheTypeService(
            widget.moreHeadacheScreenArgumentModel.headacheTypeData!
                    .valueNumber ??
                '',
            context);
        sharedPreferences.setString(Constant.updateCalendarIntensityData, Constant.trueString);
        sharedPreferences.setString(Constant.updateCalendarTriggerData, Constant.trueString);

        sharedPreferences.setString(Constant.updateOverTimeCompassData, Constant.trueString);

        sharedPreferences.setString(Constant.updateCompareCompassData, Constant.trueString);
        sharedPreferences.setString(Constant.deletedHeadacheName, widget.moreHeadacheScreenArgumentModel.headacheTypeData?.text ?? Constant.blankString);

        sharedPreferences.setString(Constant.updateTrendsData, Constant.trueString);

        sharedPreferences.setString(Constant.updateMeScreenData, Constant.trueString);
      }
    }
  }

  void _listenToDeleteHeadacheStream() {
    _bloc.deleteHeadacheStream.listen((data) {
      if (data == 'Event Deleted') {
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pop(context, data);
        });
      }
    });
  }

  void _getDiagnosticAnswerList() async {
    List<SelectedAnswers> selectedAnswerList =
        await _bloc.fetchDiagnosticAnswers(
            widget.moreHeadacheScreenArgumentModel.headacheTypeData!
                    .valueNumber ??
                '',
            context);
    if (selectedAnswerList.length > 0) {
      Future.delayed(Duration(milliseconds: 500), () async {
        var eventId = await widget.navigateToOtherScreenCallback(
            Constant.partTwoOnBoardScreenRouter,
            PartTwoOnBoardArgumentModel(
              eventId: widget.moreHeadacheScreenArgumentModel.headacheTypeData!
                  .valueNumber,
              selectedAnswersList: selectedAnswerList,
              argumentName: Constant.clinicalImpressionEventType,
              isFromMoreScreen: true,
            ));

        debugPrint('ResultFromAssessment???$eventId');

        if (eventId != null && eventId is String) {
          /*SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          sharedPreferences.setString(Constant.updateCalendarIntensityData, Constant.trueString);*/
          int? id = int.tryParse(eventId);

          if (id != null)
            widget.moreHeadacheScreenArgumentModel.headacheTypeData!.valueNumber = eventId;

          _bloc.getClinicalImpressionData(
              widget.moreHeadacheScreenArgumentModel.headacheTypeData!.text ?? '',
              context);
        }
      });
    }
  }

  void _openDateRangeActionSheet(
      String actionSheetIdentifier, dynamic argument) async {
    DateTime endDateTime;

    startDateTime = DateTime.now();
    startDateTime = DateTime(startDateTime.year, startDateTime.month, 1);

    _totalDaysInCurrentMonth =
        Utils.daysInCurrentMonth(startDateTime.month, startDateTime.month);

    endDateTime = DateTime(
        startDateTime.year, startDateTime.month, _totalDaysInCurrentMonth ?? 0);

    var resultFromActionSheet = await widget.openActionSheetCallback(
        Constant.dateRangeActionSheet, startDateTime);
    /*if (resultFromActionSheet != null && resultFromActionSheet is String) {
      switch (resultFromActionSheet) {
        case Constant.last2Weeks:
          startDateTime = DateTime.now();
          endDateTime = startDateTime.subtract(Duration(days: 13));
          break;
        case Constant.last4Weeks:
          startDateTime = DateTime.now();
          endDateTime = startDateTime.subtract(Duration(days: 27));
          break;
        case Constant.last2Months:
          startDateTime = DateTime.now();
          endDateTime = startDateTime.subtract(Duration(days: 59));
          break;
        case Constant.last3Months:
          startDateTime = DateTime.now();
          endDateTime = startDateTime.subtract(Duration(days: 89));
          break;
        default:
          startDateTime = DateTime.now();
          endDateTime = startDateTime.subtract(Duration(days: 13));
      }
     _getUserReport(startDateTime, endDateTime);
    }*/
    if (resultFromActionSheet != null && resultFromActionSheet is DateTime) {
      startDateTime =
          DateTime(resultFromActionSheet.year, resultFromActionSheet.month, 1);

      _totalDaysInCurrentMonth = Utils.daysInCurrentMonth(
          resultFromActionSheet.month, resultFromActionSheet.month);

      endDateTime = DateTime(startDateTime.year, startDateTime.month,
          _totalDaysInCurrentMonth ?? 0);
      _getUserReport(endDateTime, startDateTime);
    }
  }

  void _getUserReport(DateTime startDateTime, DateTime endDateTime) {
    _bloc.initNetworkStreamController();
    widget.showApiLoaderCallback(_bloc.networkStream, () {
      _bloc.enterDummyDataToNetworkStream();
      _bloc.getUserGenerateReportData(
          '${endDateTime.year}-${endDateTime.month}-${endDateTime.day}T00:00:00Z',
          '${startDateTime.year}-${startDateTime.month}-${startDateTime.day}T00:00:00Z',
          widget.moreHeadacheScreenArgumentModel.headacheTypeData!.text ?? '',
          context);
    });
    _bloc.getUserGenerateReportData(
        '${endDateTime.year}-${endDateTime.month}-${endDateTime.day}T00:00:00Z',
        '${startDateTime.year}-${startDateTime.month}-${startDateTime.day}T00:00:00Z',
        widget.moreHeadacheScreenArgumentModel.headacheTypeData!.text ?? '',
        context);
  }

  ///Method to navigate to pdf screen
  void _navigateToPdfScreen(String base64String) {
    //widget.onPush(context, TabNavigatorRoutes.pdfScreenRoute, base64String);
    widget.navigateToOtherScreenCallback(
        TabNavigatorRoutes.pdfScreenRoute,
        PDFScreenArgumentModel(
            base64String: base64String,
            monthYear: Utils.getMonthYearText(startDateTime)));
  }

  ///Method to get permission of the storage.
  Future<bool> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      return await Constant.platform.invokeMethod('getStoragePermission');
    } else {
      return true;
    }
  }

  void _listenToViewReportStream() {
    _bloc.viewReportStream.listen((reportModel) {
      if (reportModel is UserGenerateReportDataModel) {
        Future.delayed(Duration(milliseconds: 350), () {
          _navigateToPdfScreen(reportModel.map!.base64!);
        });
      }
    });
  }

  Widget _getClinicalImpressionWidget(List<String> clinicalImpressionList) {
    List<Widget> widgetList = [];

    List<String> stringList = widget
        .moreHeadacheScreenArgumentModel.headacheTypeData!.text!
        .trim()
        .split(' ');

    String headacheTypeName =
        widget.moreHeadacheScreenArgumentModel.headacheTypeData!.text!.trim();

    String lastWordOfHeadacheType = stringList[stringList.length - 1];

    if (clinicalImpressionList.length == 1) {
      if (clinicalImpressionList[0] == Constant.defaultClinicalImpression) {
        widgetList = [
          CustomTextWidget(
            text:
                'Based on your response, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}does not appear to align with clinically known headache types. More importantly, some of your answers raise red flags that warrant further evaluation by your provider or headache specialist.',
            style: _textStyle,
          ),
          SizedBox(
            height: 10,
          ),
          CustomTextWidget(
            text: Constant.ifYouHaventAlreadyDone,
            style: _textStyle,
          ),
          SizedBox(
            height: 10,
          ),
        ];
      } else if (clinicalImpressionList[0] ==
          Constant.medicalHistoryClinicalImpression) {
        widgetList = [
          CustomTextWidget(
            text:
                'The information in your medical history regarding your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}does not match any of the recognized diagnostic criteria for headache disorders, as specified by the International Classification of Headache Disorders. This is often the result of conflicting information in your medical history, which your physician can help you sort out.',
            style: _textStyle,
          ),
          SizedBox(
            height: 10,
          ),
          CustomTextWidget(
            text: Constant.ifYouHaventAlreadyDone,
            style: _textStyle,
          ),
          SizedBox(
            height: 10,
          ),
        ];
      } else {
        widgetList = [
          CustomTextWidget(
            text:
                'Based on what you entered, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}could potentially be ${clinicalImpressionList[0].toLowerCase()}.',
            style: _textStyle,
          ),
          SizedBox(
            height: 10,
          ),
          CustomTextWidget(
            text: Constant.thisIsNotDiagnosis,
            style: _textStyle,
          ),
          SizedBox(
            height: 10,
          ),
          CustomTextWidget(
            text: Constant.ifYouHaventAlreadyDone,
            style: _textStyle,
          ),
          SizedBox(
            height: 10,
          ),
        ];
      }
    } else {
      String? defaultMessage = clinicalImpressionList.firstWhereOrNull(
          (element) => element == Constant.defaultClinicalImpression);

      if (defaultMessage == null) {
        widgetList = [
          CustomTextWidget(
            text:
                'Based on what you entered, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}could potentially be ${clinicalImpressionList.length == 2 ? 'either' : 'any of the following'}:',
            style: _textStyle,
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              children:
                  _getClinicalImpressionWidgetList(clinicalImpressionList),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          CustomTextWidget(
            text: Constant.thisIsNotDiagnosis,
            style: _textStyle,
          ),
          SizedBox(
            height: 10,
          ),
          CustomTextWidget(
            text: Constant.ifYouHaventAlreadyDone,
            style: _textStyle,
          ),
          SizedBox(
            height: 10,
          ),
        ];
      } else {
        if (clinicalImpressionList.length == 2) {
          widgetList = [
            CustomTextWidget(
              text:
                  'Based on what you entered, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}could potentially be ${clinicalImpressionList[0].toLowerCase()}; ${Constant.defaultClinicalImpressionReplacement.toLowerCase()}',
              style: _textStyle,
            ),
            SizedBox(
              height: 10,
            ),
            CustomTextWidget(
              text: Constant.thisIsNotDiagnosis,
              style: _textStyle,
            ),
            SizedBox(
              height: 10,
            ),
            CustomTextWidget(
              text: Constant.ifYouHaventAlreadyDone,
              style: _textStyle,
            ),
            SizedBox(
              height: 10,
            ),
          ];
        } else {
          widgetList = [
            CustomTextWidget(
              text:
                  'Based on what you entered, your $headacheTypeName ${lastWordOfHeadacheType.toLowerCase() == 'headache' ? Constant.blankString : 'headache '}could potentially be ${clinicalImpressionList.length == 3 ? 'either' : 'any of the following'}:',
              style: _textStyle,
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                children:
                    _getClinicalImpressionWidgetList(clinicalImpressionList),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            CustomTextWidget(
              text: Constant.defaultClinicalImpressionReplacement,
              style: _textStyle,
            ),
            SizedBox(
              height: 10,
            ),
            CustomTextWidget(
              text: Constant.thisIsNotDiagnosis,
              style: _textStyle,
            ),
            SizedBox(
              height: 10,
            ),
            CustomTextWidget(
              text: Constant.ifYouHaventAlreadyDone,
              style: _textStyle,
            ),
            SizedBox(
              height: 10,
            ),
          ];
        }
      }
    }

    return Column(
      children: widgetList,
    );
  }

  List<Widget> _getClinicalImpressionWidgetList(
      List<String> clinicalImpressionList) {
    List<Widget> widgetList = [];
    int num = 1;

    clinicalImpressionList.forEach((element) {
      if (element != Constant.defaultClinicalImpression) {
        widgetList.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 15,
              child: CustomTextWidget(
                text: '$num.',
                style: _textStyle,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: CustomTextWidget(
                text: element.replaceAll(".", Constant.blankString),
                style: _textStyle,
              ),
            ),
          ],
        ));
        num++;
      }
    });

    return widgetList;
  }
}
