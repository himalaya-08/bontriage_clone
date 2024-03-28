import 'package:flutter/material.dart';
import 'package:mobile/util/constant.dart';

class CustomTextWidget extends StatelessWidget {
   final String text;
   TextStyle? style;
   TextAlign? textAlign;
   TextOverflow? overflow;
   int? maxLines;

   CustomTextWidget({
    Key? key,
     required this.text,
     this.style,
     this.textAlign,
     this.overflow,
     this.maxLines
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQueryData.copyWith(
        textScaleFactor: mediaQueryData.textScaleFactor.clamp(Constant.minTextScaleFactor, Constant.maxTextScaleFactor),
      ),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}
