import 'package:flutter/material.dart';
import 'package:millime/core/app_export.dart';
import 'package:millime/widgets/custom_text_form_field.dart';
import 'package:millime/localizationMillime/localization/app_localization.dart';
import 'provider/password_update_provider.dart';

class PasswordUpdateScreen extends StatefulWidget {
  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PasswordUpdateProvider(),
      child: PasswordUpdateScreen(),
    );
  }

  @override
  State<PasswordUpdateScreen> createState() => _PasswordUpdateScreenState();
}

class _PasswordUpdateScreenState extends State<PasswordUpdateScreen> {
  late PasswordUpdateProvider provider;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<PasswordUpdateProvider>(context, listen: false);
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final phoneNumber = args?['phoneNumber'] as String?;
      provider.initialize(phoneNumber, _newPasswordController, _confirmPasswordController);
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<PasswordUpdateProvider>(context);
    
    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: appTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appTheme.onBackground),
          onPressed: () => provider.navigateToLogin(context),
        ),
        title: Text(
          "key_password_update_title".tr,
          style: TextStyleHelper.instance.title18SemiBoldQuicksand.copyWith(
            color: appTheme.onBackground,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info message
              Container(
                padding: EdgeInsets.all(16.h),
                decoration: BoxDecoration(
                  color: appTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: appTheme.borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: appTheme.primaryColor, size: 24),
                    SizedBox(width: 12.h),
                    Expanded(
                      child: Text(
                         "key_first_login_description".tr,
                          style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                            color: appTheme.onSurface,
                          ),
                        ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              
              // New password field
              Text(
                "key_new_password".tr,
                style: TextStyleHelper.instance.title14SemiBoldQuicksand.copyWith(
                  color: appTheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextFormField(
                controller: _newPasswordController,
                obscureText: provider.obscureNewPassword,
                textInputAction: TextInputAction.next,
                onChanged: (value) => provider.updateNewPassword(value),
                suffix: IconButton(
                  icon: Icon(
                    provider.obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                    color: appTheme.onSurfaceVariant,
                  ),
                  onPressed: () => provider.toggleNewPasswordVisibility(),
                ),
                validator: (value) => provider.newPasswordError,
              ),
              
         
              
              SizedBox(height: 15.h),
              
              // Confirm password field
              Text(
                "key_confirm_password".tr,
                style: TextStyleHelper.instance.title14SemiBoldQuicksand.copyWith(
                  color: appTheme.onSurface,
                ),
              ),
                   // Password requirements
              SizedBox(height: 15.h),
              _buildPasswordRequirements(),

              SizedBox(height: 8.h),
              CustomTextFormField(
                controller: _confirmPasswordController,
                obscureText: provider.obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onChanged: (value) => provider.updateConfirmPassword(value),
                suffix: IconButton(
                  icon: Icon(
                    provider.obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: appTheme.onSurfaceVariant,
                  ),
                  onPressed: () => provider.toggleConfirmPasswordVisibility(),
                ),
                validator: (value) => provider.confirmPasswordError,
              ),
              
              SizedBox(height: 32.h),
              
              // Error message
              if (provider.errorMessage != null)
                Container(
                  padding: EdgeInsets.all(12.h),
                  decoration: BoxDecoration(
                    color: appTheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: appTheme.errorColor, size: 20),
                      SizedBox(width: 8.h),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: TextStyleHelper.instance.body14MediumManrope.copyWith(
                            color: appTheme.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 16.h),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : () => provider.submitPassword(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: appTheme.disabledColor,
                  ),
                  child: provider.isLoading
                      ? SizedBox(
                          width: 24.h,
                          height: 24.h,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "key_password_update_title".tr,
                          style: TextStyleHelper.instance.title16SemiBoldManrope.copyWith(
                            color: Colors.white,
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

  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "key_password_requirements".tr,
          style: TextStyleHelper.instance.title14SemiBoldQuicksand.copyWith(
            color: appTheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 8.h),
        _buildRequirementItem("mdp_8_char_min".tr, provider.hasMinLength),
        _buildRequirementItem("mdp_1_char_maj".tr, provider.hasUpperCase),
        _buildRequirementItem("mdp_1_char_min".tr, provider.hasLowerCase),
        _buildRequirementItem("mdp_1_chiffre".tr, provider.hasNumber),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? appTheme.successColor : appTheme.onSurfaceVariant,
            size: 18,
          ),
          SizedBox(width: 8.h),
          Text(
            text,
            style: TextStyleHelper.instance.label10RegularManrope.copyWith(
              color: isMet ? appTheme.successColor : appTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
