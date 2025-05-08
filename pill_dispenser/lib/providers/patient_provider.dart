// lib/providers/patient_provider.dart

import 'package:flutter/material.dart';
import '../models/patient.dart';

class PatientProvider with ChangeNotifier {
  Patient? _patient;

  Patient? get patient => _patient;

  void updatePatient(Patient newPatient) {
    _patient = newPatient;
    notifyListeners();
  }
}