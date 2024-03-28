import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/util/constant.dart';

import 'CustomTextWidget.dart';

class GenerateReportActionSheet extends StatefulWidget {
  final UserProfileInfoModel userProfileInfoModel;

  const GenerateReportActionSheet({Key? key, required this.userProfileInfoModel}) : super(key: key);

  @override
  _GenerateReportActionSheetState createState() => _GenerateReportActionSheetState();
}

class _GenerateReportActionSheetState extends State<GenerateReportActionSheet> {

  TextStyle _textStyle = TextStyle(
      fontFamily: Constant.jostRegular,
      color: Constant.cancelBlueColor,
      fontSize: 16
  );

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
          title: CustomTextWidget(
            text: '${widget.userProfileInfoModel.profileName}.pdf',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 18,
                fontFamily: Constant.jostRegular
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              child: CustomTextWidget(
                text: Constant.email,
                overflow: TextOverflow.ellipsis,
                style: _textStyle,
              ),
              onPressed: () {
                Navigator.pop(context, Constant.email);
              },
            ),
            CupertinoActionSheetAction(
              child: CustomTextWidget(
                text: Constant.text,
                overflow: TextOverflow.ellipsis,
                style: _textStyle,
              ),
              onPressed: () {
                Navigator.pop(context, Constant.text);
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
            CupertinoActionSheetAction(
              child: CustomTextWidget(
                text: Constant.print,
                overflow: TextOverflow.ellipsis,
                style: _textStyle,
              ),
              onPressed: () {
                Navigator.pop(context, Constant.print);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: CustomTextWidget(
                text: Constant.cancel,
                overflow: TextOverflow.ellipsis,
                style: _textStyle
            ),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, Constant.cancel);
            },
          )
      );
  }
}
