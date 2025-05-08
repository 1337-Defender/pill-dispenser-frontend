// lib/providers/medication_provider.dart

import 'package:flutter/material.dart';
import '../models/medication.dart'; // ✅ Import Medication from models

class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [];

  List<Medication> get medications => _medications;

  void addMedication(Medication medication) {
    _medications.add(medication);
    notifyListeners();
  }

  void removeMedication(String id) {
    _medications.removeWhere((med) => med.id == id);
    notifyListeners();
  }
}