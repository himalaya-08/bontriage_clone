import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/util/constant.dart';

import 'CustomTextWidget.dart';

class YesterdayLogDialog extends StatefulWidget {
  final String title;

  const YesterdayLogDialog({Key? key, required this.title}) : super(key: key);

  @override
  _YesterdayLogDialogState createState() => _YesterdayLogDialogState();
}

class _YesterdayLogDialogState extends State<YesterdayLogDialog> {
  @override
  Widget build(BuildContext context) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(),
                      CustomTextWidget(
                        text: 'Yesterday\'s Log',
                        style: TextStyle(
                            fontSize: 16,
                            color: Constant.chatBubbleGreen,
                            fontFamily: Constant.jostMedium
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image(
                            image: AssetImage(Constant.closeIcon),
                            width: Platform.isAndroid? 18:22,
                            height: Platform.isAndroid? 18:22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context, Constant.addEditLogYourDay);
                    },
                    icon: Image.asset(
                      Constant.addCircleIcon,
                      width: Platform.isAndroid? 16:18,
                      height: Platform.isAndroid? 16:18,
                    ),
                    label: CustomTextWidget(
                      text: Constant.addEditLogYourDay,
                      style: TextStyle(
                          color: Constant.chatBubbleGreen,
                          fontFamily: Constant.jostRegular,
                          fontWeight: FontWeight.w500,
                          fontSize: Platform.isAndroid? 14:16),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context, Constant.addEditLogStudyMedication);
                    },
                    icon: Image.asset(
                      Constant.addCircleIcon,
                      width: Platform.isAndroid? 16:18,
                      height: Platform.isAndroid? 16:18,
                    ),
                    label: CustomTextWidget(
                      text: Constant.addEditLogStudyMedication,
                      style: TextStyle(
                          color: Constant.chatBubbleGreen,
                          fontFamily: Constant.jostRegular,
                          fontWeight: FontWeight.w500,
                          fontSize: Platform.isAndroid? 14:16,),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
