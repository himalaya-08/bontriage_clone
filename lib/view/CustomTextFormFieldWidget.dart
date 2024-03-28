import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/util/constant.dart';

class CustomTextFormFieldWidget extends StatelessWidget {
  final String? questionTag;
  final bool? obscureText;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final TextStyle? style;
  final Color? cursorColor;
  final TextAlign? textAlign;
  final InputDecoration? decoration;
  final void Function()? onEditingComplete;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization? textCapitalization;
  final int? maxLines;
  final int? minLines;
  final String? initialValue;
  final void Function()? onTap;
  final bool? readOnly;

  const CustomTextFormFieldWidget({
    Key? key,
    this.questionTag,
    this.obscureText,
    this.focusNode,
    this.textInputAction,
    this.controller,
    this.onChanged,
    this.onFieldSubmitted,
    this.style,
    this.cursorColor,
    this.textAlign,
    this.decoration,
    this.onEditingComplete,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization,
    this.maxLines,
    this.minLines,
    this.initialValue,
    this.onTap,
    this.readOnly
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    debugPrint('ZZZZZZ????$questionTag?????$initialValue');
    return MediaQuery(
      data: mediaQueryData.copyWith(
        textScaleFactor: mediaQueryData.textScaleFactor.clamp(Constant.minTextScaleFactor, Constant.maxTextScaleFactor),
      ),
      child: TextFormField(
        obscureText: obscureText ?? false,
        focusNode: focusNode,
        textInputAction: textInputAction,
        controller: controller,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        style: style,
        cursorColor: cursorColor,
        textAlign: textAlign ?? TextAlign.start,
        decoration: decoration,
        onEditingComplete: onEditingComplete,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        maxLines: maxLines ?? 1,
        minLines: minLines,
        //initialValue: initialValue,
        onTap: onTap,
        readOnly: readOnly ?? false,
      ),
    );
  }
}
