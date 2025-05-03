class PurchaseHistory {
  final String medicationName;
  final DateTime purchasedAt;
  final int quantityPurchased;
  final double amountPaid;

  PurchaseHistory({
    required this.medicationName,
    required this.purchasedAt,
    required this.quantityPurchased,
    required this.amountPaid,
  });
}