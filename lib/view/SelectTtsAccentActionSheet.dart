import 'package:flutter/cupertino.dart';
import 'package:mobile/util/constant.dart';

import 'package:mobile/view/CustomTextWidget.dart';

class SelectTtsAccentActionSheet extends StatefulWidget {
  @override
  _SelectTtsAccentActionSheetState createState() => _SelectTtsAccentActionSheetState();
}

class _SelectTtsAccentActionSheetState extends State<SelectTtsAccentActionSheet> {
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
                text: Constant.play,
                overflow: TextOverflow.ellipsis,
                style: _textStyle
            ),
            onPressed: () {
              Navigator.pop(context, Constant.play);
            },
          )
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
