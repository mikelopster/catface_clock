import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'canvas_clock.dart';

class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  double hourAngle = 0;
  double hourAngle2 = 0;
  double minuteAngle = 0;
  double adjustShadow = 1;
  String theme = 'LIGHT';

  // Variable for Mock
  // int mockSecond = 0;
  // int hourDisplay = 0;
  // int minuteDisplay = 0;

  @override
  void initState() {
    super.initState();
    // Mock Time
    // Timer.periodic(
    //   Duration(microseconds: 900),
    //   (timer) {
    //     mockSecond = (mockSecond + 1) % (24 * 60 * 60);
    //   },
    // );
    _updateTime();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      int secondAmount =
          (_dateTime.hour * 3600) + (_dateTime.minute * 60) + _dateTime.second;
      // use mock time
      // int secondAmount = mockSecond;
      minuteAngle = ((secondAmount % 3600 / 3600) * 2 * math.pi) - math.pi / 2;
      hourAngle = ((secondAmount % (3600 * 12) / (3600 * 12)) * 2 * math.pi) -
          math.pi / 2;
      hourAngle2 = ((secondAmount % (3600 * 24) / (3600 * 24)) * 2 * math.pi) -
          math.pi / 2;

      // add display mock to clock
      // hourDisplay = secondAmount ~/ 3600;
      // minuteDisplay = secondAmount % 3600 ~/ 60;

      if (secondAmount < 5 * 3600) {
        adjustShadow = 0;
      } else if (secondAmount >= 5 * 3600 && secondAmount <= 6 * 3600) {
        adjustShadow = 1 - (((6 * 3600) - secondAmount) / 3600);
      } else if (secondAmount > 6 * 3600 && secondAmount < 18 * 3600) {
        adjustShadow = 1;
      } else if (secondAmount >= 18 * 3600 && secondAmount <= 19 * 3600) {
        adjustShadow = ((19 * 3600) - secondAmount) / 3600;
      } else {
        adjustShadow = 0;
      }

      if (secondAmount >= 6 * 3600 && secondAmount < 18 * 3600) {
        theme = 'LIGHT';
      } else {
        theme = 'DARK';
      }

      Timer(
        Duration(milliseconds: 40),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: EyesLayer(
                  hourAngle, hourAngle2, minuteAngle, adjustShadow, theme),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: FaceLayer(theme),
            ),
          ),
          // Widget for display time (Debug)
          // Positioned(
          //   bottom: 10,
          //   right: 10,
          //   child: Text(
          //     hourDisplay.toString().padLeft(2, '0') +
          //         ':' +
          //         minuteDisplay.toString().padLeft(2, '0'),
          //     style: TextStyle(fontSize: 80, color: Colors.red),
          //   ),
          // )
        ],
      )),
    );
  }
}
