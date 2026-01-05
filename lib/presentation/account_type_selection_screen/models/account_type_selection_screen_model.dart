/// This class is used in the [AccountTypeSelectionScreen] screen.

enum AccountTypePMPP {
  individual,
  business,
}

// ignore_for_file: must_be_immutable
class AccountTypeSelectionModel {
  AccountTypeSelectionModel({
    this.selectedAccountTypePMPP,
    this.id,
  }) {
    selectedAccountTypePMPP = selectedAccountTypePMPP ?? AccountTypePMPP.individual;
    id = id ?? "";
  }

  AccountTypePMPP? selectedAccountTypePMPP;
  String? id;
}
