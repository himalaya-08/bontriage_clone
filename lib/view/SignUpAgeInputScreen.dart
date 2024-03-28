import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CupertinoSingleList.dart';
import 'package:mobile/view/CustomTextWidget.dart';

//TODO: remove the unused parameters
class SignUpAgeInputScreen extends StatefulWidget {
  final double? minYearValue;
  final double? maxYearValue;
  final double horizontalPadding;
  final bool isAnimate;
  final String? currentTag;
  final Function(String, String)? selectedAnswerCallBack;
  final List<SelectedAnswers>? selectedAnswerListData;
  final Function(String, String)? onValueChangeCallback;
  final String? uiHints;

  SignUpAgeInputScreen(
      {Key? key,
      this.horizontalPadding = 0,
      this.isAnimate = true,
      this.currentTag,
      this.selectedAnswerListData,
      this.selectedAnswerCallBack,
      this.onValueChangeCallback,
      this.uiHints,
      this.minYearValue,
      this.maxYearValue})
      : super(key: key);

  @override
  _SignUpAgeInputScreenState createState() => _SignUpAgeInputScreenState();
}

class _SignUpAgeInputScreenState extends State<SignUpAgeInputScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  String? _selectedMonth = Constant.monthMapper[DateTime.now().month];
  String? _selectedYear = DateTime.now().year.toString();

  SelectedAnswers? _selectedAnswers;

  int? _selectedMonthIndex;
  int? _selectedYearIndex;

  AgeValue? _selectedAge;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        duration: Duration(milliseconds: widget.isAnimate ? 800 : 0),
        vsync: this);

    _animationController!.forward();

    if (widget.selectedAnswerListData != null) {
      _selectedAnswers = widget.selectedAnswerListData!
          .firstWhereOrNull((model) => model.questionTag == widget.currentTag);
      if (_selectedAnswers != null) {
        AgeValue? ageValue;
        try {
          String ans = _selectedAnswers!.answer!.trim();

          String year = ans.substring(0, 4);
          String month = ans.substring(4, 6);
          debugPrint('---------------------------------> $ans');
          ageValue = AgeValue(month, year);
        } catch (e) {
          e.toString();
        }

        if (ageValue != null) {
          _selectedAge = ageValue;
          _selectedMonth =
              Constant.monthMapper[int.parse(_selectedAge!.month!)];
          _selectedYear = _selectedAge?.year;
          _selectedMonthIndex = int.tryParse(_selectedAge!.month!)! - 1;
          _selectedYearIndex = 99 -
              (DateTime.now().subtract(Duration(days: 365 * 3)).year -
                  int.tryParse(_selectedYear!)!);
        } else {
          _selectedAge = AgeValue(
              '${DateTime.january}', (DateTime.now().year - 3).toString());
          _selectedMonth =
              Constant.monthMapper[int.tryParse(_selectedAge!.month!)];
          _selectedYear = _selectedAge!.year;
          _selectedMonthIndex = int.tryParse(_selectedAge!.month!)! - 1;
          _selectedYearIndex = 99 -
              (DateTime.now().subtract(Duration(days: 365 * 3)).year -
                  int.tryParse(_selectedYear!)!);
        }
      } else {
        _selectedAge = AgeValue('${DateTime.january}',
            (DateTime.now().subtract(Duration(days: 365 * 3)).year).toString());
        _selectedMonth = Constant.monthMapper[int.parse(_selectedAge!.month!)];
        _selectedYear = _selectedAge!.year;
        _selectedMonthIndex = int.tryParse(_selectedAge!.month!)! - 1;
        _selectedYearIndex = 99 -
            (DateTime.now().subtract(Duration(days: 365 * 3)).year -
                int.tryParse(_selectedYear!)!);
      }
    }
    if (widget.selectedAnswerCallBack != null && widget.isAnimate) {
      String selectedDate =
          '${_selectedAge?.year}${(_selectedAge?.month.toString().length == 2) ? _selectedAge?.month : "0${_selectedAge?.month}"}01';
      widget.selectedAnswerCallBack!(widget.currentTag!, selectedDate);
    }
  }

  @override
  void didUpdateWidget(SignUpAgeInputScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_animationController!.isAnimating) {
      _animationController?.reset();
      _animationController?.forward();
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController!,
      child: Container(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: (widget.horizontalPadding == null)
                    ? 15
                    : widget.horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: (widget.horizontalPadding == null) ? 0 : 15,
                ),
                Container(
                  child: Center(
                    child: Wrap(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 88,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: CustomTextWidget(
                                      text: 'Month',
                                      style: TextStyle(
                                          color: Constant.chatBubbleGreen,
                                          fontFamily: Constant.jostRegular,
                                          fontSize:
                                              Platform.isAndroid ? 14 : 17),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Container(
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          border: Border.all(
                                              color: Constant.chatBubbleGreen),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              _openPickerBottomSheet(
                                                  _listDataGenerator(true),
                                                  DateTime.now()
                                                      .month
                                                      .toString(),
                                                  _selectedMonthIndex!,
                                                  true, (selectedItem,
                                                      selectedItemIndex) {
                                                if (selectedItem.length < 3) {
                                                  selectedItem = Constant
                                                          .monthMapper[
                                                      selectedItemIndex + 1]!;
                                                }
                                                setState(() {
                                                  _selectedMonth = selectedItem;
                                                  _selectedMonthIndex =
                                                      selectedItemIndex;
                                                });
                                                if (widget
                                                        .selectedAnswerCallBack !=
                                                    null) {
                                                  int monthNumber =
                                                      _selectedMonthIndex! + 1;
                                                  if (monthNumber
                                                          .toString()
                                                          .length <
                                                      2) {
                                                    String birthMonth =
                                                        '0$monthNumber';
                                                    _selectedAge!.month =
                                                        birthMonth;
                                                  } else {
                                                    _selectedAge!.month =
                                                        monthNumber.toString();
                                                  }
                                                  _selectedAge!.year =
                                                      _selectedYear;
                                                  String selectedDate =
                                                      '${_selectedAge?.year}${_selectedAge?.month}01';
                                                  widget.selectedAnswerCallBack!(
                                                      widget.currentTag!,
                                                      selectedDate);
                                                }
                                              },
                                                  (_selectedYear ==
                                                          (DateTime.now().year -
                                                                  3)
                                                              .toString())
                                                      ? true
                                                      : false);
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              child: Center(
                                                child: CustomTextWidget(
                                                  text:
                                                      _selectedMonth ?? 'MONTH',
                                                  style: TextStyle(
                                                      color: Constant
                                                          .chatBubbleGreen,
                                                      fontFamily:
                                                          Constant.jostRegular,
                                                      fontSize:
                                                          Platform.isAndroid
                                                              ? 14
                                                              : 15),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  width: 100,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: CustomTextWidget(
                                      text: 'Year',
                                      style: TextStyle(
                                          color: Constant.chatBubbleGreen,
                                          fontFamily: Constant.jostRegular,
                                          fontSize:
                                              Platform.isAndroid ? 14 : 17),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Container(
                                          width: 88,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            border: Border.all(
                                                color:
                                                    Constant.chatBubbleGreen),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                _openPickerBottomSheet(
                                                    _listDataGenerator(false),
                                                    DateTime.now()
                                                        .month
                                                        .toString(),
                                                    _selectedYearIndex!,
                                                    true, (selectedItem,
                                                        selectedItemIndex) {
                                                  setState(() {
                                                    _selectedYear =
                                                        selectedItem;
                                                    _selectedYearIndex =
                                                        selectedItemIndex;
                                                    if (_selectedYear ==
                                                        (DateTime.now().year -
                                                                3)
                                                            .toString()) {
                                                      if (_selectedMonthIndex! + 1 >
                                                          DateTime.now()
                                                              .month) {
                                                        _selectedMonth =
                                                            Constant.monthMapper[
                                                                DateTime.now()
                                                                    .month]!;
                                                      }
                                                    }
                                                  });
                                                  if (widget
                                                          .selectedAnswerCallBack !=
                                                      null) {
                                                    int monthNumber =
                                                        _selectedMonthIndex! +
                                                            1;
                                                    if (monthNumber
                                                            .toString()
                                                            .length <
                                                        2) {
                                                      String birthMonth =
                                                          '0$monthNumber';
                                                      _selectedAge?.month =
                                                          birthMonth;
                                                    } else {
                                                      _selectedAge?.month =
                                                          monthNumber
                                                              .toString();
                                                    }
                                                    _selectedAge?.year =
                                                        _selectedYear;
                                                    String selectedDate =
                                                        '${_selectedAge?.year}${_selectedAge?.month}01';
                                                    widget.selectedAnswerCallBack!(
                                                        widget.currentTag ?? '',
                                                        selectedDate);
                                                  }
                                                }, false);
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5),
                                                child: Center(
                                                  child: CustomTextWidget(
                                                    text:
                                                        _selectedYear ?? 'Year',
                                                    style: TextStyle(
                                                        color: Constant
                                                            .chatBubbleGreen,
                                                        fontFamily: Constant
                                                            .jostRegular,
                                                        fontSize:
                                                            Platform.isAndroid
                                                                ? 14
                                                                : 15),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPickerBottomSheet(
      List<String> listData,
      String initialData,
      int initialDataIndex,
      bool month,
      Function(String, int) selectedAgeCallback,
      bool disableFurtherOptions) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (context) => SizedBox(
              child: CupertinoSingleList(
                  listData: listData,
                  initialData: initialData,
                  initialIndex: initialDataIndex,
                  onItemSelected: selectedAgeCallback,
              disableFurtherOptions: disableFurtherOptions,),
            ));
  }

  //generates the month and year lists
  List<String> _listDataGenerator(bool month) {
    if (month) {
      int monthCount = 12;
      return List<String>.generate(12, (index) {
        monthCount--;
        debugPrint(Constant.monthMapper[(DateTime.december - monthCount)]);
        return Constant.monthMapper[(DateTime.december - monthCount)]!;
      });
    } else {
      int yearCount = 100;
      int maxYear = DateTime.now().year - 3;
      return List<String>.generate(100, (index) {
        yearCount--;
        return (maxYear - yearCount).toString();
      });
    }
  }

//current month checker
}

class AgeValue {
  String? month;
  String? year;

  AgeValue(String month, String year) {
    this.month = month;
    this.year = year;
  }
}
