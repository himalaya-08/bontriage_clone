import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/util/constant.dart';

import 'CustomTextWidget.dart';

class MedicalHelpActionSheet extends StatefulWidget {
  @override
  _MedicalHelpActionSheetState createState() => _MedicalHelpActionSheetState();
}

class _MedicalHelpActionSheetState extends State<MedicalHelpActionSheet> {

  TextStyle _textStyle = TextStyle(
    fontFamily: Constant.jostRegular,
    color: Constant.cancelBlueColor,
    fontSize: 16
  );

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
          title: CustomTextWidget(
            text: Constant.medicalHelp,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontFamily: Constant.jostRegular
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              child: CustomTextWidget(
                text: Constant.call911,
                overflow: TextOverflow.ellipsis,
                style: _textStyle.copyWith(
                  color: Constant.deleteLogRedColor,
                ),
              ),
              onPressed: () {
                Navigator.pop(context, Constant.call911);
              },
            ),
            CupertinoActionSheetAction(
              child: CustomTextWidget(
                text: Constant.callADoctor,
                overflow: TextOverflow.ellipsis,
                style: _textStyle,
              ),
              onPressed: () {
                Navigator.pop(context, Constant.callADoctor);
              },
            ),
            CupertinoActionSheetAction(
              child: CustomTextWidget(
                text: Constant.findALocalDoctor,
                overflow: TextOverflow.ellipsis,
                style: _textStyle,
              ),
              onPressed: () {
                Navigator.pop(context, Constant.findALocalDoctor);
              },
            ),
            CupertinoActionSheetAction(
              child: CustomTextWidget(
                text: Constant.openYourProviderApp,
                overflow: TextOverflow.ellipsis,
                style: _textStyle,
              ),
              onPressed: () {
                Navigator.pop(context, Constant.openYourProviderApp);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: CustomTextWidget(
              text: Constant.cancel,
              overflow: TextOverflow.ellipsis,
              style: _textStyle,
            ),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, Constant.cancel);
            },
          )
      );
  }
}
