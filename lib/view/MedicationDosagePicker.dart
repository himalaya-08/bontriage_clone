import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class MedicationDosagePicker extends StatefulWidget {

  final String? selectedDosageValue;

  const MedicationDosagePicker({Key? key, required this.selectedDosageValue}) : super(key: key);

  @override
  _MedicationDosagePickerState createState() => _MedicationDosagePickerState();
}

class _MedicationDosagePickerState extends State<MedicationDosagePicker> {
  List<Widget> _widgetList = [];
  List<int> _valuesList = [];
  int _currentIndex = 0;
  FixedExtentScrollController _fixedExtentScrollController = FixedExtentScrollController();

  @override
  void initState() {
    super.initState();

    _fixedExtentScrollController = FixedExtentScrollController();

    for(int i = 50; i <= 1000; i = i + 50) {
      _valuesList.add(i);
      _widgetList.add(Center(
        child: CustomTextWidget(
          text: '$i mg',
          style: TextStyle(
              fontSize: 18,
              fontFamily: Constant.jostRegular,
              fontWeight: FontWeight.w500,
              color: Constant.locationServiceGreen
          ),
        ),
      ));
    }

    int? value = 0;

    if(widget.selectedDosageValue != null) {
      if(widget.selectedDosageValue != null){
        value = int.tryParse(widget.selectedDosageValue!.replaceAll(' mg', Constant.blankString));
      }
      int index = _valuesList.indexOf(value!);

      if(index != -1)
        _currentIndex = index;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fixedExtentScrollController.jumpToItem(_currentIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                color: Constant.backgroundTransparentColor
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, right: 15),
                    child: GestureDetector(
                      onTap: () {
                        int dosageValue = 50 + _currentIndex * 50;
                        Navigator.pop(context, '$dosageValue mg');
                      },
                      child: CustomTextWidget(
                        text: 'Done',
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: Constant.jostMedium,
                            fontWeight: FontWeight.w500,
                            color: Constant.locationServiceGreen
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(fontSize: 18, color: Constant.locationServiceGreen, fontFamily: Constant.jostRegular),
                        ),
                      ),
                      child: CupertinoPicker(
                        scrollController: _fixedExtentScrollController,
                        itemExtent: 40,
                        children: _widgetList,
                        onSelectedItemChanged: (value) {
                          _currentIndex = value;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
