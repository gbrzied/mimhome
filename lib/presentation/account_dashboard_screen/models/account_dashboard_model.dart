import './service_item_model.dart';
import './transaction_item_model.dart';

/// This class is used in the [AccountDashboardScreen] screen.

class AccountDashboardModel {
  AccountDashboardModel({
    this.balance,
    this.serviceItems,
    this.transactionItems,
    this.id,
  }) {
    balance = balance ?? "1 234,567 TND";
    serviceItems = serviceItems ?? [];
    transactionItems = transactionItems ?? [];
    id = id ?? "";
  }

  String? balance;
  List<ServiceItemModel>? serviceItems;
  List<TransactionItemModel>? transactionItems;
  String? id;
}
