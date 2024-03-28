import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:math' show pi, cos, sin;

import 'constant.dart';

const defaultGraphColors = [
  Color(0xffB8FFFF),
  Color(0xffB8FFFF),
  Color(0x80B8FFFF),
  Color(0xffB8FFFF),
];

const compareCompassGraphColors = [
  Color(0xffB8FFFF),
  Constant.compareCompassChartValueColor,
  Color(0x80B8FFFF),
  Color(0xffB8FFFF),
];
const compareCompassFirstLoggedGraphColors = [
  Color(0xffB8FFFF),
  Constant.compareCompassChartFirstLoggedValueColor,
  Color(0x80B8FFFF),
  Color(0xffB8FFFF),
];



const personalizedDefaultGraphColors = [
  Color(0xff97c289),
  Color(0xffB8FFFF),
  Color(0xB8E1FF),
  Color(0xffafd794),
];

List<Color> setRadarChartColor(compassValue) {
  switch (compassValue) {
    case 0:
      return defaultGraphColors;
    case 1:
      return personalizedDefaultGraphColors;
    case 2:
      return compareCompassGraphColors;
    case 3:
      return compareCompassFirstLoggedGraphColors;
    default:
      return defaultGraphColors;
  }
}

class RadarChart extends StatefulWidget {
  final List<int> ticks;
  final List<String> features;
  final List<List<int>> data;
  final bool reverseAxis;
  final int compassValue;
  final TextStyle ticksTextStyle;
  final TextStyle featuresTextStyle;
  final Color? outlineColor;
  final Color? axisColor;
  final List<Color> graphColors;

  const RadarChart(
      {Key? key,
      required this.ticks,
      required this.features,
      required this.data,
      this.reverseAxis = false,
      this.compassValue = 0,
      this.ticksTextStyle = const TextStyle(color: Colors.grey, fontSize: 0),
      this.featuresTextStyle =
          const TextStyle(color: Color(0xffafd794), fontSize: 12),
      this.outlineColor = const Color(0xff0e232f),
      this.axisColor = const Color(0xfff0e4945),
      this.graphColors = defaultGraphColors})
      : super(key: key);

  factory RadarChart.light({
    required List<int> ticks,
    required List<String> features,
    required List<List<int>> data,
    bool reverseAxis = false,
    int compassValue = 0,
    Color? axisColor,
    Color? outlineColor,
  }) {
    return RadarChart(
        ticks: ticks,
        features: features,
        data: data,
        reverseAxis: reverseAxis,
        compassValue: compassValue,
        graphColors: setRadarChartColor(compassValue),
        axisColor: axisColor == null ? Color(0xfff0e4945) : axisColor,
        outlineColor: outlineColor == null ? Color(0xff0e232f) : outlineColor);
  }

  factory RadarChart.dark(
      {required List<int> ticks,
      required List<String> features,
      required List<List<int>> data,
      bool reverseAxis = false,
      int compassValue = 0}) {
    return RadarChart(
      ticks: ticks,
      features: features,
      data: data,
      featuresTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
      outlineColor: Color(0xff0e232f),
      axisColor: Colors.grey,
      reverseAxis: reverseAxis,
      compassValue: compassValue,
    );
  }

  @override
  _RadarChartState createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChart>
    with SingleTickerProviderStateMixin {
  double fraction = 0;
  Animation<double>? animation;
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);

    animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: animationController!,
    ))
      ..addListener(() {
        setState(() {
          fraction = animation!.value;
        });
      });

    animationController!.forward();
  }

  @override
  void didUpdateWidget(RadarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.compassValue == 1) {
      animationController!.reset();
      animationController!.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, double.infinity),
      painter: RadarChartPainter(
          widget.ticks,
          widget.features,
          widget.data,
          widget.reverseAxis,
          widget.ticksTextStyle,
          widget.featuresTextStyle,
          widget.outlineColor!,
          widget.axisColor!,
          widget.graphColors,
          this.fraction),
    );
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }
}

class RadarChartPainter extends CustomPainter {
  final List<int> ticks;
  final List<String> features;
  final List<List<int>> data;
  final bool reverseAxis;
  final TextStyle ticksTextStyle;
  final TextStyle featuresTextStyle;
  final Color outlineColor;
  final Color axisColor;
  final List<Color> graphColors;
  final double fraction;

  RadarChartPainter(
      this.ticks,
      this.features,
      this.data,
      this.reverseAxis,
      this.ticksTextStyle,
      this.featuresTextStyle,
      this.outlineColor,
      this.axisColor,
      this.graphColors,
      this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2.0;
    final centerY = size.height / 2.0;
    final centerOffset = Offset(centerX, centerY);
    final radius = math.min(centerX, centerY) * 0.9;
    final scale = radius / ticks.last;

    // Painting the chart outline
    var outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    var ticksPaint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..isAntiAlias = true;

    canvas.drawCircle(centerOffset, radius, outlinePaint);

    // Painting the circles and labels for the given ticks (could be auto-generated)
    // The last tick is ignored, since it overlaps with the feature label
    var tickDistance = radius / (ticks.length);
    var tickLabels = reverseAxis ? ticks.reversed.toList() : ticks;

    tickLabels.sublist(0, ticks.length - 1).asMap().forEach((index, tick) {
      var tickRadius = tickDistance * (index + 1);

      canvas.drawCircle(centerOffset, tickRadius, ticksPaint);

      TextPainter(
        text: TextSpan(text: tick.toString(), style: ticksTextStyle),
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: size.width)
        ..paint(canvas,
            Offset(centerX, centerY - tickRadius - ticksTextStyle.fontSize!));
    });

    // Painting the axis for each given feature
    var angle = (2 * pi) / features.length;

    features.asMap().forEach((index, feature) {
      var xAngle = cos(angle * index - pi / 2);
      var yAngle = sin(angle * index - pi / 2);

      var featureOffset =
          Offset(centerX + radius * xAngle, centerY + radius * yAngle);

      canvas.drawLine(centerOffset, featureOffset, ticksPaint);

      var featureLabelFontHeight = (featuresTextStyle as TextStyle).fontSize;
      var featureLabelFontWidth = (featuresTextStyle as TextStyle).fontSize !- 4;
      var labelYOffset = yAngle < 0 ? -featureLabelFontHeight! : 0;
      var labelXOffset =
          xAngle < 0 ? -featureLabelFontWidth * feature.length : 0;

      /* TextPainter(
        text: TextSpan(text: feature, style: featuresTextStyle),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,

      )
        ..layout(minWidth: 0, maxWidth: size.width)
        ..paint(
            canvas,
            Offset(featureOffset.dx + labelXOffset,
                featureOffset.dy + labelYOffset));*/
    });

    // Painting each graph
    data.asMap().forEach((index, graph) {
      try {
        var graphPaint = Paint()
          ..color = graphColors[index % graphColors.length].withOpacity(0.3)
          ..style = PaintingStyle.fill;

        var graphOutlinePaint = Paint()
          ..color = graphColors[index % graphColors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..isAntiAlias = true;

        // Start the graph on the initial point
        var scaledPoint = scale * graph[0] * fraction;
        var path = Path();

        if (reverseAxis) {
          path.moveTo(centerX, centerY - (radius * fraction - scaledPoint));
        } else {
          path.moveTo(centerX, centerY - scaledPoint);
        }

        graph.asMap().forEach((index, point) {
          if (index == 0) return;

          var xAngle = cos(angle * index - pi / 2);
          var yAngle = sin(angle * index - pi / 2);
          var scaledPoint = scale * point * fraction;

          if (reverseAxis) {
            path.lineTo(centerX + (radius * fraction - scaledPoint) * xAngle,
                centerY + (radius * fraction - scaledPoint) * yAngle);
          } else {
            path.lineTo(
                centerX + scaledPoint * xAngle, centerY + scaledPoint * yAngle);
          }
        });

        path.close();
        canvas.drawPath(path, graphPaint);
        canvas.drawPath(path, graphOutlinePaint);
      } catch (e) {
        debugPrint('Radar Chart Error');
      }
    });
  }

  @override
  bool shouldRepaint(RadarChartPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}
