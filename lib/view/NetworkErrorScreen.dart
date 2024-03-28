import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class NetworkErrorScreen extends StatefulWidget {
  final String errorMessage;
  final void Function() tapToRetryFunction;
  final bool isNeedToRetry;

  const NetworkErrorScreen({Key? key, required this.errorMessage, required this.tapToRetryFunction, this.isNeedToRetry = true}) : super(key: key);
  @override
  _NetworkErrorScreenState createState() => _NetworkErrorScreenState();
}

class _NetworkErrorScreenState extends State<NetworkErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Align(
            alignment: Alignment.center,
            child: CustomTextWidget(
              text: widget.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: Constant.jostMedium,
                  color: Constant.chatBubbleGreen),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Align(
          alignment: Alignment.center,
          child: BouncingWidget(
            onPressed: widget.tapToRetryFunction,
            child: Container(
              padding:
              EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Constant.chatBubbleGreen,
              ),
              child: CustomTextWidget(
                text: widget.isNeedToRetry ? Constant.tapToRetry : Constant.close,
                style: TextStyle(
                    color: Constant.bubbleChatTextView,
                    fontSize: 14,
                    fontFamily: Constant.jostMedium),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
