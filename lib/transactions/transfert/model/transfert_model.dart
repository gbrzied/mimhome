class TransferModel {
  String mobile;
  String? establishment;
  double amount;
  String description;

  TransferModel({
    this.mobile = '',
    this.establishment,
    this.amount = 0.0,
    this.description = '',
  });
}