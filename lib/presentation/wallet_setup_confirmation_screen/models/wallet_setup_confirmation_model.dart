/// This class is used in the [WalletSetupConfirmationScreen] screen.

// ignore_for_file: must_be_immutable
class WalletSetupConfirmationModel {
  WalletSetupConfirmationModel({
    this.isDefaultWalletDefined,
    this.userChoice,
    this.dialogTitle,
    this.dialogDescription,
    this.id,
  }) {
    isDefaultWalletDefined = isDefaultWalletDefined ?? false;
    userChoice = userChoice ?? "";
    dialogTitle = dialogTitle ?? "Do you want to define\n a default Wallet ?";
    dialogDescription = dialogDescription ??
        "define a default wallet to recieve all transactions into it";
    id = id ?? "";
  }

  bool? isDefaultWalletDefined;
  String? userChoice;
  String? dialogTitle;
  String? dialogDescription;
  String? id;
}
