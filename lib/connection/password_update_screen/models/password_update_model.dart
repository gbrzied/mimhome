// ignore_for_file: must_be_immutable
class PasswordUpdateModel {
  PasswordUpdateModel({
    this.newPasswordController,
    this.confirmPasswordController,
  }) {
    newPasswordController = newPasswordController ?? '';
    confirmPasswordController = confirmPasswordController ?? '';
  }

  String? newPasswordController;
  String? confirmPasswordController;
}
