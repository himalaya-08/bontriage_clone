import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChatBubble extends SingleChildRenderObjectWidget {
  ChatBubble({
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

class ChatBubblePainter extends CustomPainter {
  Color color;

  ChatBubblePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(10)), paint);

    final pointerPath = Path();

    double x = 0;
    double y = 15;

    pointerPath.moveTo(x, y);

    pointerPath.arcToPoint(
        Offset(x - 10, 0),
        radius: Radius.circular(20),
        clockwise: false
    );

    pointerPath.arcToPoint(
      Offset(x + 5, y - 10),
      radius: Radius.circular(20),
    );

    canvas.drawPath(pointerPath, paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
