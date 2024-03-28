import 'package:flutter/cupertino.dart';
import 'package:mobile/util/constant.dart';

import 'CustomTextWidget.dart';

class HealthScreenDialog extends StatefulWidget {

  final String healthType;
  const HealthScreenDialog({Key? key, required this.healthType}) : super(key: key);

  @override
  State<HealthScreenDialog> createState() => _HealthScreenDialogState();
}

class _HealthScreenDialogState extends State<HealthScreenDialog> {
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
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Image(
                          image: AssetImage(Constant.closeIcon),
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Align(
                    alignment: Alignment.topCenter,
                    child: CustomTextWidget(
                      text: Constant.migraineDaysVsHeadacheDays,
                      style: TextStyle(
                          fontSize: 16,
                          color: Constant.chatBubbleGreen,
                          fontFamily: Constant.jostMedium
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  CustomTextWidget(
                    text: Constant.migraineDaysVsHeadacheDaysDialogText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Constant.locationServiceGreen,
                        fontSize: 14,
                        fontFamily: Constant.jostRegular,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
