// lib/providers/dispenser_config_provider.dart

import 'package:flutter/material.dart';

class DispenserConfigProvider with ChangeNotifier {
  int _servoCount = 7;
  int _sensorCount = 2;
  int _speakerCount = 1;

  int get servoCount => _servoCount;
  int get sensorCount => _sensorCount;
  int get speakerCount => _speakerCount;

  void setServoCount(int count) {
    _servoCount = count;
    notifyListeners();
  }

  void setSensorCount(int count) {
    _sensorCount = count;
    notifyListeners();
  }

  void setSpeakerCount(int count) {
    _speakerCount = count;
    notifyListeners();
  }
}