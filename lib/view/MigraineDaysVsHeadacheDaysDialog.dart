import 'package:flutter/material.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class MigraineDaysVsHeadacheDaysDialog extends StatefulWidget {
  final bool isFromTrigger;

  const MigraineDaysVsHeadacheDaysDialog({Key? key, this.isFromTrigger = false}) : super(key: key);

  @override
  _MigraineDaysVsHeadacheDaysDialogState createState() => _MigraineDaysVsHeadacheDaysDialogState();
}

class _MigraineDaysVsHeadacheDaysDialogState extends State<MigraineDaysVsHeadacheDaysDialog> {
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
                    text: widget.isFromTrigger ? Constant.migraineDaysVsHeadacheDaysDialogTriggerText : Constant.migraineDaysVsHeadacheDaysDialogText,
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
