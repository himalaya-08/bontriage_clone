import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/DatePicker.dart';
import 'package:provider/provider.dart';

import '../util/MonthYearCupertinoDatePicker.dart';

class TonixTimeSection extends StatefulWidget {
  @override
  _TonixTimeSectionState createState() => _TonixTimeSectionState();

  final Function(String, String) addHeadacheDateTimeDetailsData;

  final String currentTag;
  final String updatedDateValue;
  final bool isHeadacheEnded;
  final CurrentUserHeadacheModel currentUserHeadacheModel;

  const TonixTimeSection(
      {Key? key,
        required this.currentTag,
        required this.updatedDateValue,
        required this.addHeadacheDateTimeDetailsData,
        required this.isHeadacheEnded,
        required this.currentUserHeadacheModel})
      : super(key: key);
}

class _TonixTimeSectionState extends State<TonixTimeSection>
    with SingleTickerProviderStateMixin {
  DateTime? _dateTime;
  AnimationController? _animationController;

  bool _isFromRecordScreen = false;

  @override
  void initState() {
    super.initState();

    DateTime dateTime = DateTime.parse(widget.currentUserHeadacheModel.selectedDate!).toLocal();

    DateTime startTime = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        0,
        0,
        0);

    _isFromRecordScreen = widget.currentUserHeadacheModel.isFromRecordScreen ?? false;

    Future.delayed(Duration(milliseconds: 500), () {
      widget.addHeadacheDateTimeDetailsData(
          Constant.onSetTag,
          Utils.getDateTimeInUtcFormat(startTime, true, context));
    });

    _animationController = AnimationController(
      duration: Duration(milliseconds: 350),
      reverseDuration: Duration(milliseconds: 350),
      vsync: this,
    );

    _dateTime = DateTime.now();

    var endDateTimeInfo = Provider.of<TonixEndDateTimeInfo>(context, listen: false);

    DateTime selectedEndDate = endDateTimeInfo.getSelectedEndDate();
    DateTime selectedEndTime = endDateTimeInfo.getSelectedEndTime();
    DateTime selectedEndDateAndTime =
    endDateTimeInfo.getSelectedEndDateAndTime();

    selectedEndDateAndTime = DateTime(
        selectedEndDateAndTime.year,
        selectedEndDateAndTime.month,
        selectedEndDateAndTime.day,
        selectedEndDateAndTime.hour,
        selectedEndDateAndTime.minute,
        0,
        0,
        0);

    if (widget.currentUserHeadacheModel != null) {
      try {
        var startDateTimeInfo =
        Provider.of<TonixStartDateTimeInfo>(context, listen: false);

        DateTime selectedStartDate = startDateTimeInfo.getSelectedStartDate();
        DateTime selectedStartTime = startDateTimeInfo.getSelectedStartTime();

        selectedStartDate =
            DateTime.parse(widget.currentUserHeadacheModel.selectedDate!).toLocal();
        selectedStartDate = DateTime(
            selectedStartDate.year,
            selectedStartDate.month,
            selectedStartDate.day,
            selectedStartDate.hour,
            selectedStartDate.minute,
            0,
            0,
            0);

        startDateTimeInfo.updateSelectedStartDate(selectedStartDate);
        startDateTimeInfo.updateSelectedStartTime(selectedStartDate);
        if (!widget.currentUserHeadacheModel.isOnGoing!) {
          selectedEndDate = DateTime.tryParse(
              widget.currentUserHeadacheModel.selectedEndDate!)!.toLocal();
          selectedEndDate = DateTime(
              selectedEndDate.year,
              selectedEndDate.month,
              selectedEndDate.day,
              selectedEndDate.hour,
              selectedEndDate.minute,
              0,
              0,
              0);
          selectedEndTime = selectedEndDate;
          selectedEndDateAndTime = selectedEndDate;
        }

        selectedStartTime = selectedStartDate;

        startDateTimeInfo.updateSelectedStartDate(selectedStartDate);
        startDateTimeInfo.updateSelectedStartTime(selectedStartTime);
      } catch (e) {
        e.toString();
      }
    }

    print(widget.isHeadacheEnded);

    if (widget.isHeadacheEnded != null && widget.isHeadacheEnded) {
      var endTimeExpandedInfo =
      Provider.of<TonixEndTimeExpandedInfo>(context, listen: false);
      endTimeExpandedInfo.updateEndTimeExpanded(true);
      if (selectedEndDate == null) {
        selectedEndDate = DateTime.now();
        selectedEndTime = selectedEndDate;
        selectedEndDateAndTime = selectedEndDate;

        selectedEndDateAndTime = DateTime(
            selectedEndDateAndTime.year,
            selectedEndDateAndTime.month,
            selectedEndDateAndTime.day,
            selectedEndDateAndTime.hour,
            selectedEndDateAndTime.minute,
            0,
            0,
            0);

        Future.delayed(Duration(milliseconds: 500), () {
          widget.addHeadacheDateTimeDetailsData(
              Constant.endTimeTag, Utils.getDateTimeInUtcFormat(selectedEndDateAndTime, true, context));
        });
      } else {
        selectedEndDate = DateTime(
            selectedEndDate.year,
            selectedEndDate.month,
            selectedEndDate.day,
            selectedEndDate.hour,
            selectedEndDate.minute,
            0,
            0,
            0);

        Future.delayed(Duration(milliseconds: 500), () {
          widget.addHeadacheDateTimeDetailsData(
              Constant.endTimeTag, Utils.getDateTimeInUtcFormat(selectedEndDate, true, context));
        });
      }
      Future.delayed(Duration(milliseconds: 500), () {
        widget.addHeadacheDateTimeDetailsData(Constant.onGoingTag, "No");
      });
      _animationController!.forward();
    } else {
      Future.delayed(Duration(milliseconds: 500), () {
        widget.addHeadacheDateTimeDetailsData(Constant.onGoingTag, "Yes");
      });
    }

    endDateTimeInfo.updateSelectedEndDate(selectedEndDate);
    endDateTimeInfo.updateSelectedEndTime(selectedEndTime);
    endDateTimeInfo.updateSelectedEndDateAndTime(selectedEndDateAndTime);
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  void _onStartDateSelected(DateTime dateTime) {
    DateTime currentDateTime = DateTime.now();
    if (currentDateTime.isAfter(dateTime) ||
        currentDateTime.isAtSameMomentAs(dateTime)) {
      var startDateTimeInfo =
      Provider.of<TonixStartDateTimeInfo>(context, listen: false);

      DateTime selectedStartDate = startDateTimeInfo.getSelectedStartDate();
      DateTime selectedStartTime = startDateTimeInfo.getSelectedStartTime();

      if (selectedStartTime == null) {
        selectedStartDate = dateTime;
      } else {
        selectedStartDate = DateTime(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            selectedStartTime.hour,
            selectedStartTime.minute,
            0,
            0,
            0);
      }
      widget.addHeadacheDateTimeDetailsData(
          Constant.onSetTag, Utils.getDateTimeInUtcFormat(selectedStartDate, true, context));

      startDateTimeInfo.updateStartDateTimeInfo(
          selectedStartDate, selectedStartTime);
    }
  }

  void _onEndDateSelected(DateTime dateTime) {
    var startDateTimeInfo =
    Provider.of<TonixStartDateTimeInfo>(context, listen: false);
    var endDateTimeInfo = Provider.of<TonixEndDateTimeInfo>(context, listen: false);

    DateTime selectedStartDate = startDateTimeInfo.getSelectedStartDate();

    DateTime selectedEndDate = endDateTimeInfo.getSelectedEndDate();
    DateTime selectedEndTime = endDateTimeInfo.getSelectedEndTime();
    DateTime selectedEndDateAndTime =
    endDateTimeInfo.getSelectedEndDateAndTime();

    dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day,
        selectedEndDateAndTime.hour, selectedEndDateAndTime.minute, 0, 0, 0);
    if (dateTime.isAfter(selectedStartDate) ||
        dateTime.isAtSameMomentAs(selectedStartDate)) {
      if (selectedEndTime == null) {
        /*Duration duration = selectedStartDate.difference(dateTime);
          if(duration.inSeconds.abs() <= (72*60*60))
            selectedEndDate = dateTime;*/
        selectedEndDate = dateTime;
      } else {
        /*DateTime selectedEndDate = DateTime(
              dateTime.year,
              dateTime.month,
              dateTime.day,
              selectedEndTime.hour,
              selectedEndTime.minute,
              0, 0);

          Duration duration = selectedStartDate.difference(selectedEndDate);

          if(duration.inSeconds.abs() <= (72*60*60))
            selectedEndDate = DateTime(
              dateTime.year,
              dateTime.month,
              dateTime.day,
              selectedEndTime.hour,
              selectedEndTime.minute,
              0, 0);*/
        selectedEndDate = DateTime(dateTime.year, dateTime.month, dateTime.day,
            selectedEndTime.hour, selectedEndTime.minute, 0, 0, 0);
      }

      selectedEndTime = selectedEndDate;
      selectedEndDateAndTime = selectedEndDate;

      widget.addHeadacheDateTimeDetailsData(
          Constant.endTimeTag, Utils.getDateTimeInUtcFormat(selectedEndDate, true, context));

      endDateTimeInfo.updateEndDateTimeInfo(
          selectedEndDate, selectedEndTime, selectedEndDateAndTime);
    } else {
      Future.delayed(Duration(milliseconds: 500), () {
        Utils.showValidationErrorDialog(context, 'End Date cannot be less than start date.', 'Alert!');
      });
    }
  }

  void _onStartTimeSelected(DateTime dateTime) {
    var startDateTimeInfo =
    Provider.of<TonixStartDateTimeInfo>(context, listen: false);
    var endDateTimeInfo = Provider.of<TonixEndDateTimeInfo>(context, listen: false);

    DateTime selectedStartDate = startDateTimeInfo.getSelectedStartDate();
    DateTime selectedStartTime = startDateTimeInfo.getSelectedStartTime();

    DateTime selectedEndDate = endDateTimeInfo.getSelectedEndDate();
    DateTime selectedEndTime = endDateTimeInfo.getSelectedEndTime();
    DateTime selectedEndDateAndTime =
    endDateTimeInfo.getSelectedEndDateAndTime();

    DateTime currentDateTime = DateTime.now();
    dateTime = DateTime(selectedStartDate.year, selectedStartDate.month,
        selectedStartDate.day, dateTime.hour, dateTime.minute, 0, 0, 0);
    if (currentDateTime.isAfter(dateTime) ||
        currentDateTime.isAtSameMomentAs(dateTime)) {
      if (selectedStartDate == null) {
        selectedStartTime = dateTime;
      } else {
        selectedStartTime = DateTime(
            selectedStartDate.year,
            selectedStartDate.month,
            selectedStartDate.day,
            dateTime.hour,
            dateTime.minute,
            0,
            0,
            0);
      }
      selectedStartDate = selectedStartTime;

      if (selectedEndDateAndTime != null &&
          selectedEndDateAndTime.isBefore(selectedStartTime)) {
        selectedEndDate = selectedStartTime;
        selectedEndTime = selectedEndDate;
        selectedEndDateAndTime = selectedEndDate;

        Future.delayed(Duration(milliseconds: 500), () {
          widget.addHeadacheDateTimeDetailsData(
              Constant.endTimeTag, Utils.getDateTimeInUtcFormat(selectedEndDateAndTime, true, context));
        });
      }
      widget.addHeadacheDateTimeDetailsData(
          Constant.onSetTag, Utils.getDateTimeInUtcFormat(selectedStartTime, true, context));
      startDateTimeInfo.updateStartDateTimeInfo(
          selectedStartDate, selectedStartTime);
      endDateTimeInfo.updateEndDateTimeInfo(
          selectedEndDate, selectedEndTime, selectedEndDateAndTime);
    } else {
      Future.delayed(Duration(milliseconds: 500), () {
        Utils.showValidationErrorDialog(context, 'Start time cannot be greater than end time.', 'Alert!');
      });
    }
  }

  void _onEndTimeSelected(DateTime dateTime) {
    var startDateTimeInfo =
    Provider.of<TonixStartDateTimeInfo>(context, listen: false);
    var endDateTimeInfo = Provider.of<TonixEndDateTimeInfo>(context, listen: false);

    DateTime _selectedStartDate = startDateTimeInfo.getSelectedStartDate();

    DateTime selectedEndDate = endDateTimeInfo.getSelectedEndDate();
    DateTime selectedEndTime = endDateTimeInfo.getSelectedEndTime();
    DateTime selectedEndDateAndTime =
    endDateTimeInfo.getSelectedEndDateAndTime();

    DateTime currentDateTime = DateTime.now();
    dateTime = DateTime(
        selectedEndDateAndTime.year,
        selectedEndDateAndTime.month,
        selectedEndDateAndTime.day,
        dateTime.hour,
        dateTime.minute,
        0,
        0,
        0);
    if ((dateTime.isAfter(_selectedStartDate) ||
        dateTime.isAtSameMomentAs(_selectedStartDate)) &&
        (dateTime.isBefore(currentDateTime) ||
            dateTime.isAtSameMomentAs(currentDateTime))) {
      if (selectedEndDate == null) {
        /*Duration duration = _selectedStartDate.difference(dateTime);
          if(duration.inSeconds.abs() <= (72*60*60))
            selectedEndTime = dateTime;*/
        selectedEndTime = dateTime;
      } else {
        /*DateTime startEndTime = DateTime(
              selectedEndDate.year,
              selectedEndDate.month,
              selectedEndDate.day,
              dateTime.hour,
              dateTime.minute,
              0, 0);

          Duration duration = _selectedStartDate.difference(startEndTime);

          if(duration.inSeconds.abs() <= (72*60*60))
            selectedEndTime = DateTime(
              selectedEndDate.year,
              selectedEndDate.month,
              selectedEndDate.day,
              dateTime.hour,
              dateTime.minute,
              0, 0);*/
        selectedEndTime = DateTime(selectedEndDate.year, selectedEndDate.month,
            selectedEndDate.day, dateTime.hour, dateTime.minute, 0, 0, 0);
      }

      selectedEndDate = selectedEndTime;
      selectedEndDateAndTime = selectedEndTime;
      widget.addHeadacheDateTimeDetailsData(
          Constant.endTimeTag, Utils.getDateTimeInUtcFormat(selectedEndTime, true, context));

      endDateTimeInfo.updateEndDateTimeInfo(
          selectedEndDate, selectedEndTime, selectedEndDateAndTime);
    } else {
      if (!(dateTime.isBefore(currentDateTime) ||
          dateTime.isAtSameMomentAs(currentDateTime))) {
        Future.delayed(Duration(milliseconds: 500), () {
          Utils.showValidationErrorDialog(
              context, 'End time cannot be greater than the current time.', 'Alert!');
        });
      } else {
        Future.delayed(Duration(milliseconds: 500), () {
          Utils.showValidationErrorDialog(context, 'End time cannot be less than the start time.', 'Alert!');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CustomTextWidget(
              text: Constant.start,
              style: TextStyle(
                  fontSize: 14,
                  color: Constant.locationServiceGreen,
                  fontFamily: Constant.jostRegular),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    color: Constant.backgroundTransparentColor,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          /*_openDatePickerBottomSheet(
                              CupertinoDatePickerMode.date, 0);*/
                        },
                        child: Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Consumer<TonixStartDateTimeInfo>(
                            builder: (context, data, child) {
                              return CustomTextWidget(
                                text: (data.getSelectedStartDate() == null)
                                    ? _getDateTime(DateTime.now(), 0)
                                    : _getDateTime(
                                    data.getSelectedStartDate(), 0),
                                style: TextStyle(
                                    color: Constant.splashColor,
                                    fontFamily: Constant.jostRegular,
                                    fontSize: 14),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              CustomTextWidget(
                text: Constant.at,
                style: TextStyle(
                    fontSize: 14,
                    color: Constant.locationServiceGreen,
                    fontFamily: Constant.jostRegular),
              ),
              SizedBox(
                width: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    color: Constant.backgroundTransparentColor,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _openDatePickerBottomSheet(
                              CupertinoDatePickerMode.time, MonthYearCupertinoDatePickerMode.date, 1);
                        },
                        child: Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Consumer<TonixStartDateTimeInfo>(
                            builder: (context, data, child) {
                              return CustomTextWidget(
                                text: (data.getSelectedStartTime() == null)
                                    ? Utils.getTimeInAmPmFormat(
                                    DateTime.now().hour,
                                    DateTime.now().minute)
                                    : _getDateTime(
                                    data.getSelectedStartTime(), 1),
                                style: TextStyle(
                                    color: Constant.splashColor,
                                    fontFamily: Constant.jostRegular,
                                    fontSize: 14),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CustomTextWidget(
              text: Constant.end,
              style: TextStyle(
                  fontSize: 14,
                  color: Constant.locationServiceGreen,
                  fontFamily: Constant.jostRegular),
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _animationController!,
          child: FadeTransition(
            opacity: _animationController!,
            child: Padding(
              padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        color: Constant.backgroundTransparentColor,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _openDatePickerBottomSheet(
                                  CupertinoDatePickerMode.date, MonthYearCupertinoDatePickerMode.date, 2);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Consumer<TonixEndDateTimeInfo>(
                                builder: (context, data, child) {
                                  return CustomTextWidget(
                                    text: (data.getSelectedEndDate() == null)
                                        ? '${Utils.getShortMonthName(_dateTime!.month)} ${_dateTime!.day}, ${_dateTime!.year}'
                                        : _getDateTime(
                                        data.getSelectedEndDate(), 0),
                                    style: TextStyle(
                                        color: Constant.splashColor,
                                        fontFamily: Constant.jostRegular,
                                        fontSize: 14),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CustomTextWidget(
                    text: Constant.at,
                    style: TextStyle(
                        fontSize: 14,
                        color: Constant.locationServiceGreen,
                        fontFamily: Constant.jostRegular),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        color: Constant.backgroundTransparentColor,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _openDatePickerBottomSheet(
                                  CupertinoDatePickerMode.time, MonthYearCupertinoDatePickerMode.date, 3);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Consumer<TonixEndDateTimeInfo>(
                                builder: (context, data, child) {
                                  return CustomTextWidget(
                                    text: (data.getSelectedEndTime() == null)
                                        ? Utils.getTimeInAmPmFormat(
                                        _dateTime!.hour, _dateTime!.minute)
                                        : _getDateTime(
                                        data.getSelectedEndTime(), 1),
                                    style: TextStyle(
                                        color: Constant.splashColor,
                                        fontFamily: Constant.jostRegular,
                                        fontSize: 14),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      var endDateTimeInfo =
                      Provider.of<TonixEndDateTimeInfo>(context, listen: false);
                      DateTime selectedEndDate;

                      if(_isFromRecordScreen) {
                        selectedEndDate = DateTime.now().subtract(Duration(days: 1));
                      } else {
                        selectedEndDate = DateTime.now();
                      }

                      selectedEndDate = DateTime(
                          selectedEndDate.year,
                          selectedEndDate.month,
                          selectedEndDate.day,
                          selectedEndDate.hour,
                          selectedEndDate.minute,
                          0,
                          0,
                          0);
                      DateTime selectedEndTime = selectedEndDate;
                      DateTime selectedEndDateAndTime = selectedEndDate;

                      selectedEndDateAndTime = selectedEndDate;
                      widget.addHeadacheDateTimeDetailsData(Constant.endTimeTag,
                          Utils.getDateTimeInUtcFormat(selectedEndDate, true, context));

                      endDateTimeInfo.updateEndDateTimeInfo(selectedEndDate,
                          selectedEndTime, selectedEndDateAndTime);
                    },
                    child: CustomTextWidget(
                      text: Constant.reset,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: Constant.jostRegular,
                          fontWeight: FontWeight.w500,
                          color: Constant.addCustomNotificationTextColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Visibility(
          visible:
          !(widget.currentUserHeadacheModel.isFromRecordScreen ?? false),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                var endTimeExpandedInfo =
                Provider.of<TonixEndTimeExpandedInfo>(context, listen: false);
                var endDateTimeInfo =
                Provider.of<TonixEndDateTimeInfo>(context, listen: false);

                bool _isEndTimeExpanded =
                endTimeExpandedInfo.isEndTimeExpanded();

                DateTime selectedEndDate = endDateTimeInfo.getSelectedEndDate();
                DateTime selectedEndTime = endDateTimeInfo.getSelectedEndTime();
                DateTime selectedEndDateAndTime =
                endDateTimeInfo.getSelectedEndDateAndTime();

                _isEndTimeExpanded = !_isEndTimeExpanded;

                endTimeExpandedInfo
                    .updateEndTimeExpandedInfo(_isEndTimeExpanded);

                if (_isEndTimeExpanded) {
                  _dateTime = DateTime.now();
                  _animationController!.forward();
                } else {
                  _animationController!.reverse();
                }

                if (_isEndTimeExpanded) {
                  widget.addHeadacheDateTimeDetailsData(Constant.onGoingTag, "No");
                  if (selectedEndDateAndTime == null) {
                    selectedEndDate = DateTime.now();
                    selectedEndDate = DateTime(
                        selectedEndDate.year,
                        selectedEndDate.month,
                        selectedEndDate.day,
                        selectedEndDate.hour,
                        selectedEndDate.minute,
                        0,
                        0,
                        0);
                    selectedEndTime = selectedEndDate;
                    selectedEndDateAndTime = selectedEndDate;
                    widget.addHeadacheDateTimeDetailsData(Constant.endTimeTag,
                        Utils.getDateTimeInUtcFormat(selectedEndDateAndTime, true, context));
                  } else
                    widget.addHeadacheDateTimeDetailsData(Constant.endTimeTag,
                        Utils.getDateTimeInUtcFormat(selectedEndDateAndTime, true, context));
                  widget.currentUserHeadacheModel
                    ..isOnGoing = false
                    ..selectedEndDate =
                    Utils.getDateTimeInUtcFormat(selectedEndDate, true, context);

                  endDateTimeInfo.updateEndDateTimeInfo(
                      selectedEndDate, selectedEndTime, selectedEndDateAndTime);

                  //this condition is put because we don't want to update headache data in db when user comes from record screen
                  /*if(!(widget.currentUserHeadacheModel.isFromRecordScreen ?? false))
                      SignUpOnBoardProviders.db.updateUserCurrentHeadacheData(widget.currentUserHeadacheModel);*/
                } else {
                  widget.currentUserHeadacheModel.isOnGoing = true;

                  /*if(!(widget.currentUserHeadacheModel.isFromRecordScreen ?? false))
                      SignUpOnBoardProviders.db.updateUserCurrentHeadacheData(widget.currentUserHeadacheModel);*/

                  widget.addHeadacheDateTimeDetailsData(Constant.onGoingTag, "Yes");
                  widget.addHeadacheDateTimeDetailsData(Constant.endTimeTag, "");
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Consumer<TonixEndTimeExpandedInfo>(
                  builder: (context, data, child) {
                    return CustomTextWidget(
                      text: (data.isEndTimeExpanded())
                          ? Constant.tapHereIfInProgress
                          : Constant.tapHereToEnd,
                      style: TextStyle(
                          fontSize: 14,
                          color: Constant.addCustomNotificationTextColor,
                          fontFamily: Constant.jostRegular),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Function? _getDateTimeCallbackFunction(int whichPickerClicked) {
    switch (whichPickerClicked) {
      case 0:
        return _onStartDateSelected;
      case 1:
        return _onStartTimeSelected;
      case 2:
        return _onEndDateSelected;
      case 3:
        return _onEndTimeSelected;
      default:
        return null;
    }
  }

  ///@param dateTime: DateTime instance
  ///@param type: 0 for date, 1 for time
  String _getDateTime(DateTime dateTime, int type) {
    String dateTimeString = '';
    switch (type) {
      case 0:
        dateTimeString =
        '${Utils.getShortMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}';
        return dateTimeString;
      case 1:
        dateTimeString =
            Utils.getTimeInAmPmFormat(dateTime.hour, dateTime.minute);
        return dateTimeString;
      default:
        return dateTimeString;
    }
  }

  /// @param cupertinoDatePickerMode: for time and date mode selection
  /// @param whichPickerClicked: 0 for startDate, 1 for startTime, 2 for endDate, 3 for endTime
  void _openDatePickerBottomSheet(
      CupertinoDatePickerMode cupertinoDatePickerMode, MonthYearCupertinoDatePickerMode monthYearCupertinoDatePickerMode, int whichPickerClicked) {
    DateTime dateTime;

    var startDateTimeInfo =
    Provider.of<TonixStartDateTimeInfo>(context, listen: false);
    var endDateTimeInfo = Provider.of<TonixEndDateTimeInfo>(context, listen: false);

    switch (whichPickerClicked) {
      case 1:
        dateTime = startDateTimeInfo.getSelectedStartDate() ?? DateTime.now();
        break;
      case 2:
      case 3:
        dateTime =
            endDateTimeInfo.getSelectedEndDateAndTime() ?? DateTime.now();
        break;
      default:
        dateTime = DateTime.now();
    }

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (context) => DatePicker(
          cupertinoDatePickerMode: monthYearCupertinoDatePickerMode,
          initialDateTime: dateTime,
          onDateTimeSelected:
          _getDateTimeCallbackFunction(whichPickerClicked),
          isFromYesterdayLog: widget.currentUserHeadacheModel.isFromRecordScreen ?? false,
        ));
  }
}

class TonixStartDateTimeInfo with ChangeNotifier {
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedStartTime = DateTime.now();

  DateTime getSelectedStartDate() => _selectedStartDate;

  DateTime getSelectedStartTime() => _selectedStartTime;

  updateSelectedStartDate(DateTime selectedStartDate) {
    _selectedStartDate = selectedStartDate;
  }

  updateSelectedStartTime(DateTime selectedStartTime) {
    _selectedStartTime = selectedStartTime;
  }

  updateStartDateTimeInfo(
      DateTime selectedStartDate, DateTime selectedStartTime) {
    _selectedStartDate = selectedStartDate;
    _selectedStartTime = selectedStartTime;
    notifyListeners();
  }
}

class TonixEndDateTimeInfo with ChangeNotifier {
  DateTime _selectedEndDate = DateTime.now();
  DateTime _selectedEndTime = DateTime.now();
  DateTime _selectedEndDateAndTime = DateTime.now();

  DateTime getSelectedEndDate() => _selectedEndDate;

  DateTime getSelectedEndTime() => _selectedEndTime;

  DateTime getSelectedEndDateAndTime() => _selectedEndDateAndTime;

  updateSelectedEndDate(DateTime selectedEndDate) {
    _selectedEndDate = selectedEndDate;
  }

  updateSelectedEndTime(DateTime selectedEndTime) {
    _selectedEndTime = selectedEndTime;
  }

  updateSelectedEndDateAndTime(DateTime selectedEndDateAndTime) {
    _selectedEndDateAndTime = selectedEndDateAndTime;
  }

  updateEndDateTimeInfo(DateTime selectedEndDate, DateTime selectedEndTime,
      DateTime selectedEndDateAndTime) {
    _selectedEndDate = selectedEndDate;
    _selectedEndTime = selectedEndTime;
    _selectedEndDateAndTime = selectedEndDateAndTime;

    notifyListeners();
  }
}

class TonixEndTimeExpandedInfo with ChangeNotifier {
  bool _isEndTimeExpanded = false;

  bool isEndTimeExpanded() => _isEndTimeExpanded;

  updateEndTimeExpanded(bool isEndTimeExpanded) {
    _isEndTimeExpanded = isEndTimeExpanded;
  }

  updateEndTimeExpandedInfo(bool isEndTimeExpanded) {
    _isEndTimeExpanded = isEndTimeExpanded;
    notifyListeners();
  }
}
