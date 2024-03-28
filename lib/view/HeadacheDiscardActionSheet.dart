import 'package:flutter/cupertino.dart';
import 'package:mobile/util/constant.dart';

import 'package:mobile/view/CustomTextWidget.dart';

class HeadacheDiscardActionSheet extends StatefulWidget {
  @override
  _HeadacheDiscardActionSheetState createState() => _HeadacheDiscardActionSheetState();
}

class _HeadacheDiscardActionSheetState extends State<HeadacheDiscardActionSheet> {
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
                text: Constant.keepHeadacheAndExit,
                overflow: TextOverflow.ellipsis,
                style: _textStyle
            ),
            onPressed: () {
              Navigator.pop(context, Constant.keepHeadacheAndExit);
            },
          ),
          CupertinoActionSheetAction(
            child: CustomTextWidget(
                text: Constant.discardHeadache,
                overflow: TextOverflow.ellipsis,
                style: _textStyle.copyWith(
                  color: Constant.deleteLogRedColor,
                )
            ),
            onPressed: () {
              Navigator.pop(context, Constant.discardHeadache);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: CustomTextWidget(
            text: Constant.cancel,
            overflow: TextOverflow.ellipsis,
            style: _textStyle.copyWith(fontFamily: Constant.jostMedium)
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context, Constant.cancel);
          },
        )
    );
  }
}
