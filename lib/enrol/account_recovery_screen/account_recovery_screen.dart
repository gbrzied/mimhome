import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_export.dart';
import '../../localizationMillime/localization/app_localization.dart';

class AccountRecoveryScreen extends StatefulWidget {
  const AccountRecoveryScreen({super.key});

  static Widget builder(BuildContext context) {
    return const AccountRecoveryScreen();
  }

  @override
  State<AccountRecoveryScreen> createState() => _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends State<AccountRecoveryScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _canConfirm = false;
  String? _phoneError;
  String? _emailError;
  String? _storedPhoneNumber;
  String? _storedEmail;
  String? _storedRecoveryPhoneNumber;
  String? _storedRecoveryEmail;

  @override
  void initState() {
    super.initState();
    _loadStoredValues();
    _phoneController.addListener(_checkConfirmationStatus);
    _emailController.addListener(_checkConfirmationStatus);
  }

  Future<void> _loadStoredValues() async {
    final prefs = await SharedPreferences.getInstance();
    _storedPhoneNumber = prefs.getString('terms_phone_number');
    _storedEmail = prefs.getString('terms_email');
    _storedRecoveryPhoneNumber = prefs.getString('recovery_phone');
    _storedRecoveryEmail = prefs.getString('recovery_email');
    _validateInputs();
  }

  void _checkConfirmationStatus() {
    _validateInputs();
    
    final bool hasInput = _phoneController.text.isNotEmpty || _emailController.text.isNotEmpty;
    final bool isValid = (_phoneError == null || _phoneController.text.isEmpty) && 
                        (_emailError == null || _emailController.text.isEmpty);
    
    if (hasInput && isValid != _canConfirm) {
      setState(() {
        _canConfirm = hasInput && isValid;
      });
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _validateInputs() {
    setState(() {
      _phoneError = null;
      _emailError = null;
      
      // Validation for phone number
      if (_phoneController.text.isNotEmpty) {
        // Check if phone number is different from management phone
        if (_storedPhoneNumber != null && _phoneController.text.trim() == _storedPhoneNumber!.trim()) {
          _phoneError = 'key_phone_different_from_management'.tr;
        }
        // Check if phone number is different from existing recovery phone
        else if (_storedRecoveryPhoneNumber != null && _phoneController.text.trim() == _storedRecoveryPhoneNumber!.trim()) {
          _phoneError = 'key_phone_different_from_existing'.tr;
        }
      } else {
        _phoneError = 'key_phone_required'.tr;
      }
      
      // Validation for email
      if (_emailController.text.isNotEmpty) {
        // Check email format
        if (!_isValidEmail(_emailController.text)) {
          _emailError = 'key_email_invalid'.tr;
        }
        // Check if email is different from management email
        else if (_storedEmail != null && _emailController.text.trim().toLowerCase() == _storedEmail!.trim().toLowerCase()) {
          _emailError = 'key_email_different_from_management'.tr;
        }
        // Check if email is different from existing recovery email
        else if (_storedRecoveryEmail != null && _emailController.text.trim().toLowerCase() == _storedRecoveryEmail!.trim().toLowerCase()) {
          _emailError = 'key_email_different_from_existing'.tr;
        }
      } else {
        _emailError = 'key_email_required'.tr;
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: CustomProgressAppBar(
        currentStep: 5,
        totalSteps: 5,
        onBackPressed: () => NavigatorService.goBack(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "key_account_recovery_title".tr,
                style: TextStyleHelper.instance.title18SemiBoldQuicksand
                    .copyWith(height: 1.28),
              ),
              SizedBox(height: 12.h),

              // Description
              Text(
                "key_account_recovery_description".tr,
                style: TextStyleHelper.instance.body12RegularManrope
                    .copyWith(height: 1.5, color: appTheme.gray_600),
              ),
              SizedBox(height: 32.h),

              // Phone Recovery Section
              Text(
                "key_tel_recup".tr,
                style: TextStyleHelper.instance.body12RegularManrope
                    .copyWith(color: appTheme.onBackground),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _phoneController,
                maxLength: 8,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.phone,
                style: TextStyleHelper.instance.body12RegularManrope.copyWith(color: appTheme.black_900),
                decoration: InputDecoration(
                  hintText: "key_recovery_phone_hint".tr,
                  hintStyle: TextStyleHelper.instance.body12RegularManrope
                      .copyWith(color: appTheme.black_900),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15.h,
                    horizontal: 16.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.h),
                    borderSide: BorderSide(
                      color: appTheme.gray_300,
                      width: 1.h,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.h),
                    borderSide: BorderSide(
                      color: appTheme.gray_300,
                      width: 1.h,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.h),
                    borderSide: BorderSide(
                      color: appTheme.primaryColor,
                      width: 1.h,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.h),
                    borderSide: BorderSide(
                      color: appTheme.errorColor,
                      width: 1.h,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.h),
                    borderSide: BorderSide(
                      color: appTheme.errorColor,
                      width: 1.h,
                    ),
                  ),
                  errorText: _phoneError,
                  errorMaxLines: 2,
                  errorStyle: TextStyleHelper.instance.body12RegularManrope
                      .copyWith(color: appTheme.errorColor),
                  counterText: '',
                ),
              ),
              SizedBox(height: 24.h),

              // Email Recovery Section
              Text(
                "key_email_recup".tr,
                style: TextStyleHelper.instance.body12RegularManrope
                    .copyWith(color: appTheme.onBackground),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyleHelper.instance.body12RegularManrope.copyWith(color: appTheme.black_900),
                
                decoration: InputDecoration(
                  hintText: "key_recovery_email_hint".tr,
                  hintStyle: TextStyleHelper.instance.body12RegularManrope
                      .copyWith(color: appTheme.black_900),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15.h,
                    horizontal: 16.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.h),
                    borderSide: BorderSide(
                      color: appTheme.gray_300,
                      width: 1.h,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.h),
                    borderSide: BorderSide(
                      color: appTheme.gray_300,
                      width: 1.h,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.h),
                    borderSide: BorderSide(
                      color: appTheme.primaryColor,
                      width: 1.h,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.h),
                    borderSide: BorderSide(
                      color: appTheme.errorColor,
                      width: 1.h,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.h),
                    borderSide: BorderSide(
                      color: appTheme.errorColor,
                      width: 1.h,
                    ),
                  ),
                  errorText: _emailError,
                  errorMaxLines: 2,
                  errorStyle: TextStyleHelper.instance.body12RegularManrope
                      .copyWith(color: appTheme.errorColor),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 16.h),
        decoration: BoxDecoration(
          color: appTheme.white_A700,
          boxShadow: [
            BoxShadow(
              color: appTheme.gray_200.withOpacity(0.5),
              spreadRadius: 0.h,
              blurRadius: 10.h,
              offset: Offset(0, -2.h),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Previous Button
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: () => NavigatorService.goBack(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: appTheme.white_A700,
                      side: BorderSide(
                        color: appTheme.primaryColor,
                        width: 1.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.h),
                      ),
                    ),
                    child: Text(
                      'key_precedent'.tr,
                      style: TextStyleHelper.instance.title16MediumSyne
                          .copyWith(
                            height: 1.25,
                            color: appTheme.primaryColor,
                          ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.h),

              // Confirm Button
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _canConfirm && _phoneError == null && _emailError == null ? _handleConfirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canConfirm 
                          ? appTheme.primaryColor 
                          : appTheme.gray_300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.h),
                      ),
                    ),
                    child: Text(
                      'key_confirmer'.tr,
                      style: TextStyleHelper.instance.title16MediumSyne
                          .copyWith(
                            height: 1.25,
                            color: _canConfirm 
                                ? appTheme.onPrimary 
                                : appTheme.gray_600,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleConfirm() async {
    try {
      // Save recovery data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('recovery_phone', _phoneController.text.trim());
      await prefs.setString('recovery_email', _emailController.text.trim());

      // Navigate to enrollment success screen
      NavigatorService.pushNamed(AppRoutes.finEnrolScreen);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'key_save_error'.tr}: $e'),
          backgroundColor: appTheme.errorColor,
        ),
      );
    }
  }
}
