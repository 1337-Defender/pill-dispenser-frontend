// lib/providers/medication_provider.dart

import 'package:flutter/material.dart';

class Medication {
  final String id;
  final String name;
  final int quantity;
  final String schedule;

  Medication({
    required this.id,
    required this.name,
    required this.quantity,
    required this.schedule,
  });
}

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