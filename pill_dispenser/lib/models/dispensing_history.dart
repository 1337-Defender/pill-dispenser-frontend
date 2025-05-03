class DispensingHistory {
  final String medicationName;
  final DateTime dispensedAt;
  final int quantityDispensed;

  DispensingHistory({
    required this.medicationName,
    required this.dispensedAt,
    required this.quantityDispensed,
  });
}