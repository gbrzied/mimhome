/// This class is used in the [AccountTypeSelectionScreen] screen.

enum AccountType {
  individual,
  business,
}

// ignore_for_file: must_be_immutable
class AccountTypeSelectionModel {
  AccountTypeSelectionModel({
    this.selectedAccountType,
    this.id,
  }) {
    selectedAccountType = selectedAccountType ?? AccountType.individual;
    id = id ?? "";
  }

  AccountType? selectedAccountType;
  String? id;
}
