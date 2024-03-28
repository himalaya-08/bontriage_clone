import 'package:flutter/cupertino.dart';
import 'package:mobile/util/constant.dart';

import 'package:mobile/view/CustomTextWidget.dart';

class SaveAndExitActionSheet extends StatefulWidget {
  @override
  _SaveAndExitActionSheetState createState() => _SaveAndExitActionSheetState();
}

class _SaveAndExitActionSheetState extends State<SaveAndExitActionSheet> {
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
              style: _textStyle
            ),
            onPressed: () {
              Navigator.pop(context, Constant.saveAndExit);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: CustomTextWidget(
              text: Constant.cancel,
              overflow: TextOverflow.ellipsis,
              style: _textStyle.copyWith(
                color: Constant.deleteLogRedColor,
              ),
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context, Constant.cancel);
          },
        )
    );
  }
}
