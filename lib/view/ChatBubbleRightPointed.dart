import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChatBubbleRightPointed extends SingleChildRenderObjectWidget {
  ChatBubbleRightPointed({
    Key? key,
    required this.painter,
    required Widget child,
  }) : super(key: key, child: child);

  final CustomPainter painter;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomPaint(
      painter: painter,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCustomPaint renderObject) {
    renderObject..painter = painter;
  }
}

class ChatBubbleRightPointedPainter extends CustomPainter {
  Color color;

  ChatBubbleRightPointedPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(10)), paint);

    final pointerPath = Path();

    double x = (size.width / 2) - 55;
    double y = 0;

    pointerPath.moveTo(x, y);

    pointerPath.arcToPoint(
      Offset(x + 12, y - 20),
      radius: Radius.circular(20),
    );

    pointerPath.arcToPoint(
        Offset(x - 12, y),
        radius: Radius.circular(30),
        clockwise: false
    );

    canvas.drawPath(pointerPath, paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}