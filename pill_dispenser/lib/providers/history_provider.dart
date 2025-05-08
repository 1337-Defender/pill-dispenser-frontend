// lib/providers/history_provider.dart

import 'package:flutter/material.dart';

/// Represents one entry in the dispensing history.
class DispensingHistory {
  final String medicationName;
  final DateTime dispensedAt;
  final int quantityDispensed;

  DispensingHistory({
    required this.medicationName,
    required this.dispensedAt,
    required this.quantityDispensed,
  });

  /// Returns a formatted string with date and time (e.g., "2025-04-07 15:30").
  String get formattedTime => dispensedAt.toLocal().toString().split('.')[0];
}

/// Manages the list of dispensing history entries.
class HistoryProvider with ChangeNotifier {
  List<DispensingHistory> _history = [];

  List<DispensingHistory> get history => List.unmodifiable(_history);

  /// Adds a new dispensing history entry.
  void addHistory(String medicationName, int quantity) {
    final newEntry = DispensingHistory(
      medicationName: medicationName,
      dispensedAt: DateTime.now(),
      quantityDispensed: quantity,
    );

    _history.add(newEntry);
    notifyListeners();
  }

  /// Clears all dispensing history (for testing/demo purposes).
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}