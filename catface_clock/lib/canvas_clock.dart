import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'dart:math' as math;

abstract class ClockPainter extends CustomPainter {
  final int designWidth = 800;
  final int designHeight = 480;

  final List eyesCenter = [225, 575];

  final faceColor = {'LIGHT': Color(0xfff2f2f2), 'DARK': Color(0xff1a1a1a)};

  final eyebackColor = {'LIGHT': Color(0xffd9d9d9), 'DARK': Color(0xfff2f2f2)};

  final noseColor = {'LIGHT': Color(0xff1a1a1a), 'DARK': Color(0xffd9d9d9)};

  double r;

  void computeRatio(Size size) {
    this.r = size.width / designWidth;
  }
}

class EyesLayer extends ClockPainter {
  final double hourAngle;
  final double hourAngle2;
  final double minuteAngle;
  final double adjustShadow;
  final String theme;

  EyesLayer(this.hourAngle, this.hourAngle2, this.minuteAngle,
      this.adjustShadow, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    computeRatio(size);
    var paint = Paint();
    var xEyeball = [
      225 + (62.5 * math.cos(hourAngle)),
      575 + (62.5 * math.cos(minuteAngle))
    ];
    var yEyeball = [
      240 + (62.5 * math.sin(hourAngle)),
      240 + (62.5 * math.sin(minuteAngle))
    ];

    for (int eye = 0; eye < 2; eye += 1) {
      // Draw Background Face
      paint.color = eyebackColor[this.theme];
      canvas.drawCircle(Offset(eyesCenter[eye] * r, 240 * r), 125 * r, paint);

      // Draw Eyeball
      paint.color = Color(0xff1a1a1a);
      canvas.drawCircle(
          Offset(xEyeball[eye] * r, yEyeball[eye] * r), 62.5 * r, paint);

      // Draw Big shadow
      Offset shadowCenter = Offset(
          (eyesCenter[eye] + (15 * math.cos(hourAngle2) * adjustShadow)) * r,
          (240 + (25 * math.sin(hourAngle2) * adjustShadow)) * r);
      double shadowRadius = 150 * r;
      var radialShadow = RadialGradient(
          colors: [Color(0x00000000), Color(0x001a1a1a), Color(0x551a1a1a)],
          stops: [0, 0.8, 1]);

      var rect = Rect.fromCircle(
        center: shadowCenter,
        radius: shadowRadius,
      );
      var paintRect = Paint();
      paintRect.shader = radialShadow.createShader(rect);
      canvas.drawCircle(shadowCenter, shadowRadius, paintRect);

      // Draw Eyeball shadow
      Offset shadowEyeballCenter = Offset(
          (xEyeball[eye] + (7.5 * math.cos(hourAngle2) * adjustShadow)) * r,
          (yEyeball[eye] + (7.5 * math.sin(hourAngle2) * adjustShadow)) * r);
      double shadowEyeballRadius = 70 * r;

      radialShadow = RadialGradient(
          colors: [Color(0x991a1a1a), Color(0x991a1a1a), Color(0x00000000)],
          stops: [0, 0.6, 1]);

      rect = Rect.fromCircle(
        center: shadowEyeballCenter,
        radius: shadowEyeballRadius,
      );
      paintRect.shader = radialShadow.createShader(rect);
      canvas.drawCircle(shadowEyeballCenter, shadowEyeballRadius, paintRect);
    }
  }

  @override
  bool shouldRepaint(EyesLayer oldDelegate) {
    return oldDelegate.minuteAngle != minuteAngle;
  }
}

class FaceLayer extends ClockPainter {
  final String theme;

  FaceLayer(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    computeRatio(size);

    var paint = Paint();
    paint.color = faceColor[this.theme];

    var rect = Path();
    rect.addRect(Rect.fromPoints(Offset(0, 0), Offset(800 * r, 480 * r)));

    var leftCircle = Path();
    leftCircle.addOval(
        Rect.fromCircle(center: Offset(225 * r, 240 * r), radius: 125 * r));

    var rightCircle = Path();
    rightCircle.addOval(
        Rect.fromCircle(center: Offset(575 * r, 240 * r), radius: 125 * r));

    var path = Path.combine(PathOperation.difference, rect, leftCircle);
    path = Path.combine(PathOperation.difference, path, rightCircle);
    canvas.drawPath(path, paint);

    // Hours marker
    for (int eye = 0; eye < 2; eye += 1) {
      var linesPath = Path();
      var line = Path();
      line.addRect(
          Rect.fromPoints(Offset(-2 * r, -125 * r), Offset(2 * r, 125 * r)));

      for (int i = 0; i < 180; i += 30) {
        var trans = Float64List(16);
        var ma = Matrix4.fromFloat64List(trans);
        ma.setIdentity();
        ma.translate(eyesCenter[eye] * r, 240.0 * r, 0);
        ma.rotateZ(radians(i * 1.0));
        linesPath =
            Path.combine(PathOperation.union, linesPath, line.transform(trans));
      }

      var frontCircle = Path();
      frontCircle.addOval(Rect.fromCircle(
          center: Offset(eyesCenter[eye] * r, 240.0 * r), radius: 120 * r));

      linesPath =
          Path.combine(PathOperation.difference, linesPath, frontCircle);
      canvas.drawPath(linesPath, paint);
    }

    // Nose
    var nosePath = Path();
    nosePath.moveTo(400 * r, 397 * r);
    nosePath.relativeCubicTo(
        16.557 * r, 0 * r, 30 * r, 14.462 * r, 30 * r, 25.5 * r);
    nosePath.relativeCubicTo(
        0 * r, 11.038 * r, -13.443 * r, 14.5 * r, -30 * r, 14.5 * r);
    nosePath.relativeCubicTo(
        -16.557 * r, 0 * r, -30 * r, -3.462 * r, -30 * r, -14.5 * r);
    nosePath.relativeCubicTo(
        0 * r, -11.038 * r, 13.443 * r, -25.5 * r, 30 * r, -25.5 * r);
    nosePath.close();

    paint.color = noseColor[this.theme];
    canvas.drawPath(nosePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
