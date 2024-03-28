import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class DeleteHeadacheTypeActionSheet extends StatefulWidget {
  @override
  _DeleteHeadacheTypeActionSheetState createState() =>
      _DeleteHeadacheTypeActionSheetState();
}

class _DeleteHeadacheTypeActionSheetState
    extends State<DeleteHeadacheTypeActionSheet> {

  TextStyle _textStyle = TextStyle(
      fontFamily: Constant.jostRegular,
      color: Constant.cancelBlueColor,
      fontSize: 16
  );

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: CustomTextWidget(
                text: Constant.deleteHeadacheType,
                overflow: TextOverflow.ellipsis,
                style: _textStyle.copyWith(
                  color: Constant.deleteLogRedColor,
                ),
              ),
              onPressed: () {
                Navigator.pop(context, Constant.deleteHeadacheType);
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
