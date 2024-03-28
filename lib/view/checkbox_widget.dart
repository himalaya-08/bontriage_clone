import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/view/CustomTextWidget.dart';

import '../util/constant.dart';

class CheckboxWidget extends StatefulWidget {
  final String questionTag;
  final String checkboxTitle;
  final Function(String, bool) onChanged;
  final bool initialValue;
  final Color checkboxColor;
  final Color textColor;

  const CheckboxWidget({
    Key? key,
    required this.questionTag,
    this.checkboxTitle = Constant.blankString,
    required this.onChanged,
    this.initialValue = false,
    required this.checkboxColor,
    required this.textColor
  }) : super(key: key);

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {

  bool _isChecked = false;

  @override
  void initState() {
    super.initState();

    _isChecked = widget.initialValue;
  }

  Color _getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return widget.checkboxColor;
    }
    return widget.checkboxColor;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          checkColor: Constant.backgroundColor,
          //fillColor: MaterialStateProperty.resolveWith(_getColor),
          activeColor: Constant.locationServiceGreen,
          focusColor: Constant.locationServiceGreen,
          autofocus: true,
          value: _isChecked,
          onChanged: (bool? value) {
            setState(() {
              _isChecked = value!;
              widget.onChanged(widget.questionTag, _isChecked);
            });
          },
        ),
        Expanded(
          child: CustomTextWidget(
            text: widget.checkboxTitle,
            style: TextStyle(
              color: widget.checkboxColor,
              fontFamily: Constant.jostRegular,
              fontSize: Platform.isAndroid ? 14 : 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
