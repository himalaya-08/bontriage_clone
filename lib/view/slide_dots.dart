import 'package:flutter/material.dart';

class SlideDots extends StatelessWidget {
  final bool isActive;

  const SlideDots({Key? key, required this.isActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? Color(0xffafd794) : Color(0xff5e7d61),
        borderRadius: BorderRadius.circular(12)
      ),
    );
  }
}
