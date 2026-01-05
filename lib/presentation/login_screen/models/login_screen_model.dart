// ignore_for_file: must_be_immutable
class LoginScreenModel {
  LoginScreenModel({
    this.phoneNumberController,
    this.passwordController,
    this.errorMessage,
    this.isLoading,
    this.authMethod,
  });

  String? phoneNumberController;
  String? passwordController;
  String? errorMessage;
  bool? isLoading;
  String? authMethod; // 'password' or null for phone-only validation
}