import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/util/constant.dart';

import 'CustomTextWidget.dart';

class ValidationErrorDialog extends StatefulWidget {
  final String errorMessage;
  final String errorTitle;
  final bool isShowErrorIcon;

  const ValidationErrorDialog({Key? key, required this.errorMessage, required this.errorTitle, this.isShowErrorIcon = false}) : super(key: key);

  @override
  _ValidationErrorDialogState createState() => _ValidationErrorDialogState();
}

class _ValidationErrorDialogState extends State<ValidationErrorDialog> {
  @override
  Widget build(BuildContext context) {
    var appConfig = AppConfig.of(context);
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Constant.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      _getErrorTitleWidget(appConfig!),
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image(
                            image: AssetImage(Constant.closeIcon),
                            width: 22,
                            height: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  CustomTextWidget(
                    text: widget.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Constant.chatBubbleGreen,
                        fontFamily: Constant.jostRegular,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getErrorTitleWidget(AppConfig appConfig) {
    if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
      return Align(
        alignment: Alignment.topCenter,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: widget.isShowErrorIcon,
              child: Image(
                image: AssetImage(Constant.errorGreen),
                height: 25,
              ),
            ),
            SizedBox(width: 5,),
            CustomTextWidget(
              text: widget.errorTitle ?? 'Error!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Constant.chatBubbleGreen,
                fontFamily: Constant.jostMedium,
              ),
            ),
          ],
        ),
      );
    else
      return Align(
        alignment: Alignment.topCenter,
        child: Visibility(
          visible: widget.errorTitle != null && widget.errorTitle.isNotEmpty,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: widget.errorTitle != null ? widget.errorTitle.contains('Start and end times') ? 30.0 : 0 : 0),
                  child: CustomTextWidget(
                    text: widget.errorTitle ?? 'Error!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Constant.chatBubbleGreen,
                      fontFamily: Constant.jostMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
