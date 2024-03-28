import 'package:flutter/material.dart';
import 'package:mobile/util/constant.dart';

class CustomRichTextWidget extends StatelessWidget {
  final InlineSpan text;
  final TextAlign textAlign;

  const CustomRichTextWidget({Key? key, required this.text, this.textAlign = TextAlign.start}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(Constant.minTextScaleFactor, Constant.maxTextScaleFactor),
      text: text,
      textAlign: textAlign,
    );
  }
}
