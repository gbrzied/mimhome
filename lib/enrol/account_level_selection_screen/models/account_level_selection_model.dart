/// This class is used in the [AccountLevelSelectionScreen] screen.

// ignore_for_file: must_be_immutable
class AccountLevelSelectionModel {
  AccountLevelSelectionModel({
    this.levels,
  });

  List<AccountLevelModel>? levels;
}

// ignore_for_file: must_be_immutable
class AccountLevelModel {
  AccountLevelModel({
    this.title,
    this.maxBalance,
    this.monthlyLimit,
    this.isSelected,
  }) {
    title = title ?? '';
    maxBalance = maxBalance ?? '';
    monthlyLimit = monthlyLimit ?? '';
    isSelected = isSelected ?? false;
  }

  String? title;
  String? maxBalance;
  String? monthlyLimit;
  bool? isSelected;
}
