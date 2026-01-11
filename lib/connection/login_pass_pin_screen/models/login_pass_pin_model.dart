// ignore_for_file: must_be_immutable
class LoginPassPinModel {
  LoginPassPinModel({
    this.phoneNumberController,
    this.passwordController,
    this.isLoading,
  });

  String? phoneNumberController;
  String? passwordController;
  bool? isLoading;
}
