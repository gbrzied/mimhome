/// This class is used for transaction items in the transactions section.

class TransactionItemModel {
  TransactionItemModel({
    this.type,
    this.name,
    this.amount,
    this.date,
    this.time,
    this.icon,
    this.isPositive,
    this.id,
  }) {
    type = type ?? "";
    name = name ?? "";
    amount = amount ?? "";
    date = date ?? "";
    time = time ?? "";
    icon = icon ?? "";
    isPositive = isPositive ?? false;
    id = id ?? "";
  }

  String? type;
  String? name;
  String? amount;
  String? date;
  String? time;
  String? icon;
  bool? isPositive;
  String? id;
}
