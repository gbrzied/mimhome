
class ReceiptModel {
  final String title;
  final DateTime timestamp;
  final String authorizationCode;
  final String beneficiary;
  final String invoiceReference;
  final double amount;
  final double commission;
  final double tva;
  final double total;
  final double initialBalance;
  final double newBalance;
  final String description;

  const ReceiptModel({
    required this.title,
    required this.timestamp,
    required this.authorizationCode,
    required this.beneficiary,
    required this.invoiceReference,
    required this.amount,
    required this.commission,
    required this.tva,
    required this.total,
    required this.initialBalance,
    required this.newBalance,
    required this.description,
  });
}