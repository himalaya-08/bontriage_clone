import 'package:flutter/material.dart';

import 'constant.dart';

class TutorialsSliderDots extends StatelessWidget {
  final bool isActive;

  const TutorialsSliderDots({Key? key, required this.isActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
          color: isActive ? Constant.chatBubbleGreen : Colors.transparent,
          border: Border.all(width: 1,color: Constant.chatBubbleGreen),
          borderRadius: BorderRadius.circular(12)
      ),
    );
  }
}
