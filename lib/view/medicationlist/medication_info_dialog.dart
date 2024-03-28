import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class MedicationInfoDialog extends StatefulWidget {
  final String dialogTitle;
  final String dialogContent;

  const MedicationInfoDialog({Key? key, required this.dialogTitle, required this.dialogContent})
      : super(key: key);

  @override
  State<MedicationInfoDialog> createState() => _MedicationInfoDialogState();
}

class _MedicationInfoDialogState extends State<MedicationInfoDialog> {

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Constant.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image(
                    image: AssetImage(Constant.closeIcon),
                    width: 22,
                    height: 22,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: CustomTextWidget(
                text: widget.dialogTitle,
                style: TextStyle(
                    fontSize: 16,
                    color: Constant.chatBubbleGreen,
                    fontFamily: Constant.jostMedium
                ),
              ),
            ),
            SizedBox(height: 10,),
            CustomTextWidget(
              text: widget.dialogContent,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Constant.locationServiceGreen,
                  fontSize: 14,
                  fontFamily: Constant.jostRegular,
                  fontWeight: FontWeight.w400
              ),
            ),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}
