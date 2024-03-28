import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';

import 'CustomTextWidget.dart';

class DateTimePicker extends StatefulWidget {
  final CupertinoDatePickerMode cupertinoDatePickerMode;
  final Function? onDateTimeSelected;
  final DateTime? initialDateTime;
  final DateTime? miniDateTime;
  final DateTime? maxDateTime;
  final bool isFromHomeScreen;
  final bool isFromYesterdayLog;

  const DateTimePicker(
      {Key? key,
        required this.cupertinoDatePickerMode,
        required this.onDateTimeSelected,
        this.initialDateTime,
        this.miniDateTime,
        this.maxDateTime,
        this.isFromHomeScreen = false,
        this.isFromYesterdayLog = true,
        })
      : super(key: key);

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  DateTime _dateTime = DateTime.now();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();

    if (widget.initialDateTime == null) {
      _dateTime = DateTime.now();
    } else {
      _dateTime = widget.initialDateTime!;
    }
    _selectedDateTime = _dateTime;
  }

  @override
  Widget build(BuildContext context) {
    var appConfig = AppConfig.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 10),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: Constant.backgroundTransparentColor),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _bottomSheetTopButtons(
                            () => Navigator.of(context).pop(), Constant.cancel),
                    _bottomSheetTopButtons(() {
                      if (!widget.isFromHomeScreen)
                        widget.onDateTimeSelected!(_selectedDateTime);
                      Navigator.pop(context, _selectedDateTime);
                    }, Constant.done)
                  ],
                ),
                Expanded(
                  child: Container(
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                              fontSize: 18,
                              color: Constant.locationServiceGreen,
                              fontFamily: Constant.jostRegular),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        initialDateTime: _dateTime,
                        backgroundColor: Colors.transparent,
                        mode: widget.cupertinoDatePickerMode,
                        use24hFormat: false,
                        minimumYear: (widget.miniDateTime != null)
                            ? widget.miniDateTime?.year ?? DateTime.now().year - 100
                            : 2015,
                        minimumDate: widget.miniDateTime,
                        maximumDate: (widget.maxDateTime != null) ? widget.maxDateTime
                            :(appConfig?.buildFlavor ==
                            Constant.migraineMentorBuildFlavor)
                            ? ((widget.cupertinoDatePickerMode !=
                            CupertinoDatePickerMode.time)
                            ? DateTime.now()
                            : null)
                            : ((!widget.isFromYesterdayLog)
                            ? (widget.cupertinoDatePickerMode !=
                            CupertinoDatePickerMode.time)
                            ? DateTime.now()
                            : null
                            : Utils.getDateTimeOf12AM(DateTime.now())
                            .subtract(Duration(minutes: 1))),
                        maximumYear: (widget.maxDateTime != null) ? widget.maxDateTime!.year : DateTime.now().year,
                        onDateTimeChanged: (dateTime) {
                          _selectedDateTime = dateTime;
                        },
                      ),
                    ),
                  ),
                ),],
            ),
          ),
        ],
      ),
    );
  }

  //widget that returns the top button in the cupertino bottom sheet
  Widget _bottomSheetTopButtons(void Function() onTap, String buttonText) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15,
        right: 15,
        left: 15,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: CustomTextWidget(
          text: buttonText,
          style: TextStyle(
              fontSize: 14,
              fontFamily: Constant.jostMedium,
              fontWeight: FontWeight.w500,
              color: Constant.locationServiceGreen),
        ),
      ),
    );
  }
}