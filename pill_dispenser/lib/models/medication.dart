// lib/models/medication.dart

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