import 'dart:io';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:provider/provider.dart';

class MoreAgeScreen extends StatefulWidget {
  final List<SelectedAnswers>? selectedAnswerList;
  final Future<dynamic> Function(String, dynamic) openActionSheetCallback;
  final Function(
      List<String> listData,
      String initialData,
      int initialIndex,
      bool month,
      Function(String, int) selectedAgeCallback,
      bool disableFurtherOptions) openBirthDateBottomSheet;

  const MoreAgeScreen(
      {Key? key,
      required this.selectedAnswerList,
      required this.openActionSheetCallback,
      required this.openBirthDateBottomSheet})
      : super(key: key);

  @override
  _MoreAgeScreenState createState() => _MoreAgeScreenState();
}

class _MoreAgeScreenState extends State<MoreAgeScreen>
    with SingleTickerProviderStateMixin {
  String _selectedMonth = '';
  String _selectedYear = '';

  int _selectedMonthIndex = 0;
  int _selectedYearIndex = 0;

  late AgeValue _selectedAge;
  late AgeValue _initialAge;

  SelectedAnswers? _selectedAnswers;

  @override
  void initState() {
    super.initState();
    if (widget.selectedAnswerList != null) {
      _selectedAnswers = widget.selectedAnswerList?.firstWhereOrNull(
          (element) => element.questionTag == Constant.profileAgeTag);

      var moreAgeInfo = Provider.of<MoreAgeInfo>(context, listen: false);

      if (_selectedAnswers != null) {
        AgeValue? ageValue;
        try {
          String? ans = _selectedAnswers!.answer!.trim();

          String year = ans.substring(0, 4);
          String month = ans.substring(4, 6);
          ageValue = AgeValue(year, month);
        } catch (e) {
          e.toString();
        }

        if (ageValue != null) {
          _initialAge = ageValue;
          _selectedAge = AgeValue(ageValue.year!, ageValue.month!);
          _selectedMonth = Constant.monthMapper[int.tryParse(_selectedAge.month!)]!;
          _selectedMonthIndex = int.tryParse(_selectedAge.month!)! - 1;
          _selectedYear = _selectedAge.year!;
          _selectedYearIndex = 99 - (DateTime.now().subtract(Duration(days: 365 * 3)).year - int.tryParse(_selectedYear)!);
        }
      } else {
        _initialAge = AgeValue('${DateTime.january}',
            (DateTime.now().year - 3).toString());
        _selectedAge = AgeValue('${DateTime.january}',
            (DateTime.now().year - 3).toString());
        _selectedMonth = Constant.monthMapper[int.parse(_selectedAge.month!)]!;
        _selectedYear = _selectedAge.year!;
        _selectedMonthIndex = int.tryParse(_selectedAge.month!)! - 1;
        _selectedYearIndex = 99 - (DateTime.now().subtract(Duration(days: 365 * 3)).year - int.tryParse(_selectedYear)!);
        _selectedAnswers = SelectedAnswers(
            questionTag: Constant.profileAgeTag,
            answer: '${_selectedAge.year}${_selectedAge.month}01');
        widget.selectedAnswerList?.add(_selectedAnswers!);
      }
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        moreAgeInfo.updateCurrentAgeValue(_selectedAge);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          _openSaveAndExitActionSheet();
          return false;
        },
        child: Container(
          decoration: Constant.backgroundBoxDecoration,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _openSaveAndExitActionSheet();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Constant.moreBackgroundColor,
                  ),
                  child: Row(
                    children: [
                      Image(
                        width: 20,
                        height: 20,
                        image: AssetImage(Constant.leftArrow),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      CustomTextWidget(
                        text: Constant.generalProfileSettings,
                        style: TextStyle(
                            color: Constant.locationServiceGreen,
                            fontSize: 16,
                            fontFamily: Constant.jostMedium),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 100,
                          child: Center(
                            child: CustomTextWidget(
                              text: 'Month',
                              style: TextStyle(
                                  color: Constant.locationServiceGreen,
                                  fontFamily: Constant.jostRegular,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Platform.isAndroid ? 16 : 19),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                      color: Constant.locationServiceGreen),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      widget.openBirthDateBottomSheet(
                                          _listDataGenerator(true),
                                          Constant.monthMapper[
                                              DateTime.now().month]!,
                                          _selectedMonthIndex,
                                          true,
                                          (selectedItem, selectedItemIndex) {
                                        setState(() {
                                          _selectedMonth = selectedItem;
                                          _selectedMonthIndex =
                                              selectedItemIndex;
                                        });
                                        _selectedAge.month = (_selectedMonthIndex + 1).toString();
                                        _selectedAge.year = _selectedYear;
                                      }, (_selectedYear == (DateTime.now().year-3).toString()) ? true:false);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Center(
                                        child: CustomTextWidget(
                                          text: _selectedMonth,
                                          style: TextStyle(
                                              color:
                                                  Constant.locationServiceGreen,
                                              fontFamily: Constant.jostRegular,
                                              fontSize:
                                                  Platform.isAndroid ? 14 : 15),
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
                          child: Center(
                            child: CustomTextWidget(
                              text: 'Year',
                              style: TextStyle(
                                  color: Constant.locationServiceGreen,
                                  fontFamily: Constant.jostRegular,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Platform.isAndroid ? 16 : 19),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                        color: Constant.locationServiceGreen),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        widget.openBirthDateBottomSheet(
                                            _listDataGenerator(false),
                                            DateTime.now().year.toString(),
                                            _selectedYearIndex,
                                            false,
                                            (selectedItem, selectedItemIndex) {
                                          setState(() {
                                            _selectedYear = selectedItem;
                                            _selectedYearIndex =
                                                selectedItemIndex;
                                            if(_selectedYear == (DateTime.now().year-3).toString()){
                                              if(int.tryParse(_selectedAge.month ?? '1')! > DateTime.now().month){
                                                _selectedMonth = Constant.monthMapper[DateTime.now().month]!;
                                              }
                                            }
                                          });
                                          if(_selectedYear == (DateTime.now().year-3).toString()){
                                            if(int.tryParse(_selectedAge.month ?? '1')! > DateTime.now().month){
                                              _selectedAge.month = DateTime.now().month.toString();
                                            }
                                          }
                                          else{
                                            _selectedAge.month = (_selectedMonthIndex + 1).toString();
                                          }
                                          _selectedAge.year = _selectedYear;
                                        }, false);
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: Center(
                                          child: CustomTextWidget(
                                            text: _selectedYear,
                                            style: TextStyle(
                                                color: Constant
                                                    .locationServiceGreen,
                                                fontFamily:
                                                    Constant.jostRegular,
                                                fontSize: Platform.isAndroid
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
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //generates the month and year lists
  List<String> _listDataGenerator(bool month) {
    if (month) {
      int monthCount = 12;
      return List<String>.generate(12, (index) {
        monthCount--;
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

  Future<void> _openSaveAndExitActionSheet() async {
    if (_selectedAge != null) {
      if ((_initialAge.year != _selectedAge.year) || (_initialAge.month != _selectedAge.month)) {
        var result = await widget.openActionSheetCallback(
            Constant.saveAndExitActionSheet, null);
        if (result != null) {
          if (result == Constant.saveAndExit) {
            if(_selectedAge.year == (DateTime.now().year-3).toString()){
              if(int.tryParse(_selectedAge.month ?? '1')! > DateTime.now().month){
                _selectedAge.month = DateTime.now().month.toString();
              }
            }
            String birthMonth = _selectedAge.month!;
            if (birthMonth.length < 2) {
              birthMonth = '0${_selectedAge.month}';
            }
            _selectedAnswers!.answer = '${_selectedAge.year}${birthMonth}01';
          }
          Navigator.pop(context, result == Constant.saveAndExit);
        }
      } else {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }
}

class MoreAgeInfo with ChangeNotifier {
  AgeValue _currentAgeValue = AgeValue('${DateTime.january}',
      (DateTime.now().year - 3).toString());

  AgeValue getCurrentAgeValue() => _currentAgeValue;

  updateCurrentAgeValue(AgeValue currentAgeValue) {
    _currentAgeValue = currentAgeValue;
    //notifyListeners();
  }
}

class AgeValue {
  String? month;
  String? year;

  AgeValue(String year, String month) {
    this.month = month;
    this.year = year;
  }
}
