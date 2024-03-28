import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile/models/HeadacheListDataModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompassHeadacheTypeActionSheet extends StatefulWidget {
  final CompassHeadacheTypeActionSheetModel compassHeadacheTypeActionSheetModel;

  CompassHeadacheTypeActionSheet({required this.compassHeadacheTypeActionSheetModel});

  @override
  _CompassHeadacheTypeActionSheetState createState() =>
      _CompassHeadacheTypeActionSheetState();
}

class _CompassHeadacheTypeActionSheetState
    extends State<CompassHeadacheTypeActionSheet> {
  String? _value;

  TextStyle? _textStyle;

  @override
  void initState() {
    super.initState();

    var userSelectedHeadache = widget.compassHeadacheTypeActionSheetModel.headacheListModelData
        .firstWhereOrNull((element) => element.isSelected!);

      if (userSelectedHeadache != null) {
        _value = userSelectedHeadache.text;
      } else {
           _value =  widget.compassHeadacheTypeActionSheetModel.initialSelectedHeadacheName;
      }

    _textStyle = TextStyle(
      fontFamily: Constant.jostRegular,
      fontSize: 14,
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
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: CustomTextWidget(
                  text: 'Headache Type',
                  style: TextStyle(
                    color: Constant.locationServiceGreen,
                    fontSize: 16,
                    fontFamily: Constant.jostRegular,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    Constant.closeIcon2,
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          CustomTextWidget(
            text: Constant.selectTheSavedHeadacheType,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Constant.jostRegular,
              fontSize: 14,
              color: Constant.locationServiceGreen,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: RawScrollbar(
              thickness: 2,
              thumbColor: Constant.locationServiceGreen,
              thumbVisibility: true,
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: widget.compassHeadacheTypeActionSheetModel.headacheListModelData.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor: Constant.locationServiceGreen,
                        ),
                        child: Radio<String>(
                          value: widget.compassHeadacheTypeActionSheetModel.headacheListModelData[index].text!,
                          activeColor: Constant.locationServiceGreen,
                          hoverColor: Constant.locationServiceGreen,
                          focusColor: Constant.locationServiceGreen,
                          groupValue: _value,
                          onChanged: (String? value) async{
                            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                            sharedPreferences.setString(Constant.updateCompassHeadacheList, Constant.falseString);
                            widget.compassHeadacheTypeActionSheetModel.headacheListModelData[index].isSelected = true;
                            Navigator.pop(context, value);
                          },
                        ),
                      ),
                      CustomTextWidget(
                        text: widget.compassHeadacheTypeActionSheetModel.headacheListModelData[index].text!,
                        style: _textStyle!,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

class CompassHeadacheTypeActionSheetModel {
  final String initialSelectedHeadacheName;
  final List<HeadacheListDataModel> headacheListModelData;
  CompassHeadacheTypeActionSheetModel({required this.initialSelectedHeadacheName, required this.headacheListModelData});
}
