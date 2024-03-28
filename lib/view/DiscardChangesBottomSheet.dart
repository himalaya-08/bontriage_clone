import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/util/constant.dart';

import 'CustomTextWidget.dart';

class DiscardChangesBottomSheet extends StatefulWidget {
  @override
  _DiscardChangesBottomSheetState createState() =>
      _DiscardChangesBottomSheetState();
}

class _DiscardChangesBottomSheetState
    extends State<DiscardChangesBottomSheet> {
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
              text: Constant.saveAndExit,
              overflow: TextOverflow.ellipsis,
              style: _textStyle,
            ),
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              Navigator.pop(context, Constant.saveAndExit);
            },
          ),
          CupertinoActionSheetAction(
            child: CustomTextWidget(
                text: 'Discard Changes',
                overflow: TextOverflow.ellipsis,
                style: _textStyle.copyWith(
                  color: Constant.deleteLogRedColor,
                )
            ),
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              Navigator.pop(context, Constant.discardChanges);
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
            FocusScope.of(context).requestFocus(FocusNode());
            Navigator.pop(context);
          },
        ),
    );
  }
}
