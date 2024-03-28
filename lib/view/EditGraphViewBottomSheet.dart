import 'package:flutter/material.dart';
import 'package:mobile/models/EditGraphViewFilterModel.dart';
import 'package:mobile/models/HeadacheListDataModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class EditGraphViewBottomSheet extends StatefulWidget {
  final EditGraphViewFilterModel editGraphViewFilterModel;

  const EditGraphViewBottomSheet({Key? key, required this.editGraphViewFilterModel})
      : super(key: key);

  @override
  _EditGraphViewBottomSheetState createState() =>
      _EditGraphViewBottomSheetState();
}

class _EditGraphViewBottomSheetState extends State<EditGraphViewBottomSheet> with SingleTickerProviderStateMixin {
  List<String> _headacheTypeRadioButtonList = [];
  List<HeadacheListDataModel> _singleHeadacheTypeList = [];
  List<HeadacheListDataModel> _compareHeadacheTypeList1 = [];
  List<HeadacheListDataModel> _compareHeadacheTypeList2 = [];
  List<String> _otherFactorsRadioButtonList = [];

  String? _headacheTypeRadioButtonSelected;
  String? _singleHeadacheTypeSelected;
  String? _compareHeadacheTypeSelected1;
  String? _compareHeadacheTypeSelected2;
  String? _otherFactorsSelected;

  TextStyle _headerTextStyle = TextStyle();
  TextStyle _radioTextStyle = TextStyle();
  TextStyle _dropDownTextStyle = TextStyle();
  int selectedTabIndex = 0;

  bool? _isShowAlert;

  String? _errorMsg;

  @override
  void initState() {
    super.initState();

    _isShowAlert = false;
    _errorMsg = '';

    selectedTabIndex = widget.editGraphViewFilterModel.currentTabIndex;
    _headerTextStyle = TextStyle(
      fontSize: 16,
      color: Constant.locationServiceGreen,
      fontFamily: Constant.jostMedium,
    );

    _headacheTypeRadioButtonList = [
      Constant.viewSingleHeadache,
      Constant.compareHeadache
    ];
    _headacheTypeRadioButtonSelected =
        widget.editGraphViewFilterModel.headacheTypeRadioButtonSelected;

    _singleHeadacheTypeList = widget
        .editGraphViewFilterModel.recordsTrendsDataModel!.headacheListModelData!;
    _singleHeadacheTypeSelected =
        widget.editGraphViewFilterModel.singleTypeHeadacheSelected;

    _compareHeadacheTypeList1 = widget
        .editGraphViewFilterModel.recordsTrendsDataModel!.headacheListModelData!;
    _compareHeadacheTypeSelected1 =
        widget.editGraphViewFilterModel.compareHeadacheTypeSelected1;

    _compareHeadacheTypeList2 = widget
        .editGraphViewFilterModel.recordsTrendsDataModel!.headacheListModelData!;
    _compareHeadacheTypeSelected2 =
        widget.editGraphViewFilterModel.compareHeadacheTypeSelected2;

    _otherFactorsRadioButtonList = [
      Constant.noneRadioButtonText,
      Constant.loggedBehaviors,
      Constant.loggedPotentialTriggers,
      Constant.medications,
    ];
    _otherFactorsSelected =
        widget.editGraphViewFilterModel.whichOtherFactorSelected;

    _radioTextStyle = TextStyle(
      fontFamily: Constant.jostRegular,
      fontSize: 14,
      color: Constant.locationServiceGreen,
    );

    _dropDownTextStyle = TextStyle(
      fontFamily: Constant.jostRegular,
      fontSize: 12,
      color: Constant.locationServiceGreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: CustomTextWidget(
                  text: Constant.editGraphView,
                  style: TextStyle(
                    color: Constant.locationServiceGreen,
                    fontSize: 16,
                    fontFamily: Constant.jostMedium,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    if(_headacheTypeRadioButtonSelected == Constant.compareHeadache) {
                       if (_compareHeadacheTypeSelected1 == _compareHeadacheTypeSelected2) {
                         setState(() {
                           _isShowAlert = true;
                           _errorMsg = Constant.compareHeadacheErrorMessage;
                         });
                       } else {
                         _popBottomSheet();
                       }
                    } else {
                      _popBottomSheet();
                    }
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
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: CustomTextWidget(
                    text: Constant.cancel,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: Constant.jostMedium,
                        fontWeight: FontWeight.w500,
                        color: Constant.locationServiceGreen
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          DefaultTabController(
            length: 4,
            initialIndex: widget.editGraphViewFilterModel.currentTabIndex,
            child: Container(
              padding: EdgeInsets.all(5),
              height: 40,
              //width: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Constant.locationServiceGreen,
                  ),
                  color: Colors.transparent),
              child: TabBar(
                onTap: (index) {
                  selectedTabIndex = index;
                },
                dividerColor: Colors.transparent,
                indicatorPadding: EdgeInsets.all(0),
                labelPadding: EdgeInsets.all(0),
                labelStyle:
                    TextStyle(fontSize: 14, fontFamily: Constant.jostRegular),
                //For Selected tab
                unselectedLabelStyle:
                    TextStyle(fontSize: 14, fontFamily: Constant.jostRegular),
                //For Un-selected Tabs
                labelColor: Constant.backgroundColor,
                unselectedLabelColor: Constant.locationServiceGreen,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Constant.locationServiceGreen),
                tabs: [
                  Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(Constant.intensity,),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(Constant.disability,),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(Constant.frequency,),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(Constant.duration,),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            //vsync: this,
            child: Visibility(
              visible: _isShowAlert!,
              child: Container(
                padding: EdgeInsets.only(top: 20,),
                child: Row(
                  children: [
                    Image(
                      image: AssetImage(Constant.warningPink),
                      width: 22,
                      height: 22,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CustomTextWidget(
                      text: _errorMsg ?? '',
                      style: TextStyle(
                          fontSize: 14,
                          color: Constant.pinkTriggerColor,
                          fontFamily: Constant.jostRegular),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          CustomTextWidget(
            text: '${Constant.headacheType}:',
            style: _headerTextStyle,
          ),
          Row(
            children: [
              Theme(
                data: ThemeData(
                  unselectedWidgetColor: Constant.locationServiceGreen,
                ),
                child: Radio(
                  value: _headacheTypeRadioButtonList[0],
                  activeColor: Constant.locationServiceGreen,
                  hoverColor: Constant.locationServiceGreen,
                  focusColor: Constant.locationServiceGreen,
                  groupValue: _headacheTypeRadioButtonSelected,
                  onChanged: (String? value) {
                    setState(() {
                      _headacheTypeRadioButtonSelected = value;
                    });
                  },
                ),
              ),
              CustomTextWidget(
                text: _headacheTypeRadioButtonList[0],
                style: _radioTextStyle,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  height: 25,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Constant.locationServiceGreen,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButton(
                    value: _singleHeadacheTypeSelected,
                    onChanged: (String? value) {
                      setState(() {
                        _singleHeadacheTypeSelected = value;
                      });
                    },
                    isExpanded: true,
                    style: _dropDownTextStyle,
                    icon: Image.asset(
                      Constant.downArrow2,
                      height: 10,
                      width: 10,
                    ),
                    dropdownColor: Constant.backgroundColor,
                    items: _getDropDownMenuItems(_singleHeadacheTypeList),
                    underline: Container(),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: _singleHeadacheTypeList.length > 1,
            child: Row(
              children: [
                Theme(
                  data: ThemeData(
                    unselectedWidgetColor: Constant.locationServiceGreen,
                  ),
                  child: Radio(
                    value: _headacheTypeRadioButtonList[1],
                    activeColor: Constant.locationServiceGreen,
                    hoverColor: Constant.locationServiceGreen,
                    focusColor: Constant.locationServiceGreen,
                    groupValue: _headacheTypeRadioButtonSelected,
                    onChanged: (String? value) {
                      setState(() {
                        _headacheTypeRadioButtonSelected = value;
                      });
                    },
                  ),
                ),
                CustomTextWidget(
                  text: _headacheTypeRadioButtonList[1],
                  style: _radioTextStyle,
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
          Visibility(
            visible: (_singleHeadacheTypeList.length > 1 && _compareHeadacheTypeList1.isNotEmpty && _compareHeadacheTypeList2.isNotEmpty),
            child: Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Container(
                    height: 25,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Constant.locationServiceGreen,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButton(
                      value: _compareHeadacheTypeSelected1 ?? '',
                      onChanged: (String? value) {
                        setState(() {
                          _compareHeadacheTypeSelected1 = value;
                        });
                      },
                      isExpanded: true,
                      style: _dropDownTextStyle,
                      icon: Image.asset(
                        Constant.downArrow2,
                        height: 10,
                        width: 10,
                      ),
                      dropdownColor: Constant.backgroundColor,
                      items: _getDropDownMenuItems(_compareHeadacheTypeList1),
                      underline: Container(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Container(
                    height: 25,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Constant.locationServiceGreen,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButton(
                      value: _compareHeadacheTypeSelected2,
                      onChanged: (String? value) {
                        setState(() {
                          _compareHeadacheTypeSelected2 = value;
                        });
                      },
                      isExpanded: true,
                      style: _dropDownTextStyle,
                      icon: Image.asset(
                        Constant.downArrow2,
                        height: 10,
                        width: 10,
                      ),
                      dropdownColor: Constant.backgroundColor,
                      items: _getDropDownMenuItems(_compareHeadacheTypeList2),
                      underline: Container(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Divider(
            color: Constant.locationServiceGreen,
            thickness: 0.5,
            height: 0.5,
          ),
          SizedBox(
            height: 10,
          ),
          CustomTextWidget(
            text: Constant.otherFactors,
            style: _headerTextStyle,
          ),
          Column(
            children: _getOtherFactorsRadioButton(),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDropDownMenuItems(
      List<HeadacheListDataModel> dropDownStringList) {
    List<DropdownMenuItem<String>> dropDownMenuItemList = [];

    dropDownStringList.forEach((element) {
      dropDownMenuItemList.add(DropdownMenuItem(
        value: element.text,
        child: CustomTextWidget(
          text: element.text!,
        ),
      ));
    });

    return dropDownMenuItemList;
  }

  List<Widget> _getOtherFactorsRadioButton() {
    List<Widget> widgetList = [];

    _otherFactorsRadioButtonList.forEach((element) {
      widgetList.add(Row(
        children: [
          Theme(
            data: ThemeData(
              unselectedWidgetColor: Constant.locationServiceGreen,
            ),
            child: Radio(
              value: element,
              activeColor: Constant.locationServiceGreen,
              hoverColor: Constant.locationServiceGreen,
              focusColor: Constant.locationServiceGreen,
              groupValue: _otherFactorsSelected,
              onChanged: (String? value) {
                setState(() {
                  _otherFactorsSelected = value;
                });
              },
            ),
          ),
          CustomTextWidget(text: element, style: _radioTextStyle),
        ],
      ));
    });

    return widgetList;
  }

  void _popBottomSheet() {
    setState(() {
      _isShowAlert = false;
      _errorMsg = Constant.blankString;
    });
    widget.editGraphViewFilterModel.singleTypeHeadacheSelected =
        _singleHeadacheTypeSelected;
    widget.editGraphViewFilterModel.compareHeadacheTypeSelected1 = _compareHeadacheTypeSelected1;
    widget.editGraphViewFilterModel
        .compareHeadacheTypeSelected2 =
        _compareHeadacheTypeSelected2;
    widget.editGraphViewFilterModel.whichOtherFactorSelected =
        _otherFactorsSelected!;
    widget.editGraphViewFilterModel
        .headacheTypeRadioButtonSelected =
        _headacheTypeRadioButtonSelected!;
    widget.editGraphViewFilterModel.currentTabIndex = selectedTabIndex;
    Navigator.pop(context, Constant.success);
  }
}
