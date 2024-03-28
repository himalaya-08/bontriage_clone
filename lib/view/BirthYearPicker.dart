import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/SiteNameModelResponse.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class BirthYearPicker extends StatefulWidget {

  final String selectedBirthValue;
  final bool isSiteName;
  final List<SiteNameModel>? siteNameList;

  /// Site name is for SiteName BottomSheet. So, if the site name is true then the site name bottom sheet the data will be loaded on the bottom sheet.
  const BirthYearPicker({Key? key, required this.selectedBirthValue, this.isSiteName = false, this.siteNameList}) : super(key: key);

  @override
  _BirthYearPickerState createState() => _BirthYearPickerState();
}

class _BirthYearPickerState extends State<BirthYearPicker> {
  List<Widget> _widgetList = [];
  List<dynamic> _valuesList = [];
  int _currentIndex = 0;
  FixedExtentScrollController? _fixedExtentScrollController;

  @override
  void initState() {
    super.initState();

    _fixedExtentScrollController = FixedExtentScrollController();

    if(widget.isSiteName){
      for(int i = 0; i < widget.siteNameList!.length; i++) {
        _valuesList.add(widget.siteNameList![i].siteName);
        _widgetList.add(Center(
          child: CustomTextWidget(
            text: '${widget.siteNameList![i].siteName}',
            style: TextStyle(
                fontSize: 18,
                fontFamily: Constant.jostRegular,
                fontWeight: FontWeight.w500,
                color: Constant.locationServiceGreen
            ),
          ),
        ));
      }
    } else {
      for(int i = 1940; i <= DateTime.now().year; i++) {
        _valuesList.add(i);
        _widgetList.add(Center(
          child: CustomTextWidget(
            text: '$i',
            style: TextStyle(
                fontSize: 18,
                fontFamily: Constant.jostRegular,
                fontWeight: FontWeight.w500,
                color: Constant.locationServiceGreen
            ),
          ),
        ));
      }
    }


    if(widget.selectedBirthValue != null && widget.selectedBirthValue.isNotEmpty) {
      if(!widget.isSiteName) {
        int value = 0;
        value = int.tryParse(widget.selectedBirthValue)!;
        int index = _valuesList.indexOf(value);

        if(index != -1)
          _currentIndex = index;
      } else {
        int index = _valuesList.indexOf(widget.selectedBirthValue);

        if(index != -1)
          _currentIndex = index;
      }
    } else{
      if(!widget.isSiteName)
        _currentIndex = _valuesList.length - 1;
      else {
        _currentIndex = /*_valuesList.length ~/ 2*/0;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fixedExtentScrollController!.jumpToItem(_currentIndex);
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
                        if (widget.isSiteName) {
                          Navigator.pop(context, '${widget.siteNameList![_currentIndex].siteName}');
                        } else {
                          int dosageValue = _valuesList[_currentIndex];
                          Navigator.pop(context, '$dosageValue');
                        }
                      },
                      child: CustomTextWidget(
                        text: Constant.done,
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
                CustomTextWidget(
                    text: (widget.isSiteName) ? 'Site Name' : Constant.yearBirth,
                    style: TextStyle(
                        fontFamily: Constant.jostMedium,
                        fontSize: 16,
                        color: Constant.locationServiceGreen)),
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
