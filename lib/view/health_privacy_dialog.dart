import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/constant.dart';
import 'CustomRichTextWidget.dart';

class HealthPrivacyDialog extends StatefulWidget {
  const HealthPrivacyDialog({super.key});

  @override
  State<HealthPrivacyDialog> createState() => _HealthPrivacyDialogState();
}

class _HealthPrivacyDialogState extends State<HealthPrivacyDialog> {
  TextStyle _textStyle = TextStyle(
    color: Constant.chatBubbleGreen,
    fontSize: 14,
    fontFamily: Constant.jostRegular,
  );

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    margin: EdgeInsets.only(bottom: 20),
                    child: CustomRichTextWidget(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                "MigraineMentor respects your privacy. We use Google user data in compliance with the ",
                            style: _textStyle,
                          ),
                          TextSpan(
                            text: "Google API Services User Data Policy",
                            style: _textStyle.copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: Constant.chatBubbleGreen,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                Uri uri = Uri.parse(
                                    'https://developers.google.com/terms/api-services-user-data-policy');
                                await launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              },
                          ),
                          TextSpan(
                            text:
                                ", including Limited Use. For more details, please review our ",
                            style: _textStyle,
                          ),
                          TextSpan(
                            text: "privacy policy",
                            style: _textStyle.copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: Constant.chatBubbleGreen,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                Uri uri = Uri.parse(Constant.privacyPolicyUrl);
                                await launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              },
                          ),
                          TextSpan(
                            text: ".",
                            style: _textStyle,
                          ),
                        ],
                      ),
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
}
