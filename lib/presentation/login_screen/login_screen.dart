import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import 'provider/login_screen_provider.dart';
import 'models/login_screen_model.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custum_button.dart';
import '../../localizationMillime/localization/app_localization.dart';

class LoginScreen extends StatefulWidget {
  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<LoginScreenProvider>(
      create: (context) => LoginScreenProvider(),
      child: LoginScreen(),
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isPasswordHidden = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LoginScreenProvider>();
      provider.initialize();
      // Debug AuthProvider status
      provider.debugAuthProviderStatus();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<LoginScreenProvider>(
          builder: (context, provider, child) {
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Scrollable content area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 10.h),

                          // Menu Icon
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: Icon(
                                Icons.menu,
                                color: appTheme.primaryColor,
                                size: 30.h,
                              ),
                              onPressed: () {
                                NavigatorService.pushNamed(AppRoutes.millimeSettingsScreen);
                              },
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Logo Section
                          _buildLogoSection(),

                        //  SizedBox(height: 25.h),

                          // Welcome Message
                        //  _buildWelcomeMessage(),

                          SizedBox(height: 25.h),

                          // Phone Number Input Section
                          _buildPhoneNumberSection(provider),

                          SizedBox(height: 16.h),

                          // Password Input Section (conditionally shown)
                          if (provider.isPhoneNumberValid)
                            _buildPasswordSection(),

                          SizedBox(height: 24.h),

                          // Login Button (conditionally shown)
                          provider.isPhoneNumberValid 
                            ? _buildLoginButton(provider)
                            : _buildValidateButton(provider),

                          SizedBox(height: 20.h),

                          // Error Message
                          if (provider.errorMessage != null || provider.loginScreenModel.errorMessage != null)
                            _buildErrorMessage(provider),

                          SizedBox(height: 24.h),

                          // Forgot Password Link (conditionally shown)
                          if (provider.isPhoneNumberValid)
                            _buildForgotPasswordLink(provider),

                          // Add some bottom padding
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),

                  // Registration Link at the bottom
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: appTheme.surfaceColor,
                      border: Border(
                        top: BorderSide(
                          color: appTheme.borderColor,
                          width: 1.h,
                        ),
                      ),
                    ),
                    child: _buildRegistrationLink(provider),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Section Widget: Logo Section
  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgMillimeLogo,
            height: 67.h,
            width: 137.h,
          ),
         // SizedBox(height: 8.h),
          // Text(
          //   "lbl_bienvenue".tr,
          //   style: TextStyleHelper.instance.title18SemiBoldQuicksand.copyWith(
          //     color: appTheme.primaryColor,
          //   ),
          // ),
        ],
      ),
    );
  }

  /// Section Widget: Welcome Message
  Widget _buildWelcomeMessage() {
    return Center(
      child: Text(
        "Connectez-vous à votre compte Millime",
        style: TextStyleHelper.instance.title16MediumManrope.copyWith(
          color: appTheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Section Widget: Phone Number Input Section
  Widget _buildPhoneNumberSection(LoginScreenProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of().getString("key_num_tel"),
          style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
            color: appTheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextFormField(
          controller: _phoneController,
          textInputType: TextInputType.phone,
          hintText: AppLocalization.of().getString("key_entrer_num_tel"),
          prefixConstraints: BoxConstraints(
            maxHeight: 56.h,
          ),
          prefix: Container(
            margin: EdgeInsets.only(left: 16.h, right: 12.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "+216",
                  style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                    color: appTheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: 8.h),
                Container(
                  width: 1.h,
                  height: 20.h,
                  color: appTheme.borderColor,
                ),
              ],
            ),
          ),
          contentPadding: EdgeInsets.only(
            top: 15.h,
            bottom: 15.h,
            left: 0.h,
            right: 15.h,
          ),
          filled: true,
          fillColor: appTheme.surfaceColor,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez entrer votre numéro de téléphone';
            }
            if (value.length < 8) {
              return 'Numéro de téléphone invalide';
            }
            return null;
          },
          onChanged: (value) {
            provider.updatePhoneNumber(value);
            // Clear password when phone number changes
            _passwordController.clear();
          },
        ),
      ],
    );
  }

  /// Section Widget: Password Input Section
  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "key_password".tr,
          style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
            color: appTheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextFormField(
          controller: _passwordController,
          obscureText: _isPasswordHidden,
          textInputType: TextInputType.visiblePassword,
          hintText: "key_entrer_password".tr,
          prefixConstraints: BoxConstraints(
            maxHeight: 56.h,
          ),
          prefix: Container(
            margin: EdgeInsets.only(left: 16.h, right: 12.h),
            child: Icon(
              Icons.lock_outline,
              color: appTheme.onSurfaceVariant,
              size: 20.h,
            ),
          ),
          contentPadding: EdgeInsets.only(
            top: 15.h,
            bottom: 15.h,
            left: 0.h,
            right: 15.h,
          ),
          filled: true,
          fillColor: appTheme.surfaceColor,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre mot de passe';
            }
            if (value.length < 6) {
              return 'Le mot de passe doit contenir au moins 6 caractères';
            }
            return null;
          },
          onChanged: (value) {
            context.read<LoginScreenProvider>().updatePassword(value);
          },
          suffix: IconButton(
            icon: Icon(
              _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
              color: appTheme.onSurfaceVariant,
              size: 20.h,
            ),
            onPressed: () {
              setState(() {
                _isPasswordHidden = !_isPasswordHidden;
              });
            },
          ),
        ),
      ],
    );
  }

  /// Section Widget: Login Button
  Widget _buildLoginButton(LoginScreenProvider provider) {
    final isDisabled = provider.isLoading || !provider.isAuthProviderAvailable;
    
    return CustomButton(
      text: provider.isLoading ? "Connexion..." : "Se connecter",
      width: double.maxFinite,
      variant: CustomButtonVariant.filled,
      onPressed: isDisabled ? null : () => _performLogin(provider),
    );
  }

  /// Section Widget: Validate Button (for initial phone validation)
  Widget _buildValidateButton(LoginScreenProvider provider) {
    return CustomButton(
      text: AppLocalization.of().getString("key_next"),
      width: double.maxFinite,
      variant: CustomButtonVariant.filled,
      onPressed: () {
        provider.validatePhoneNumber(context);
      },
    );
  }

  /// Section Widget: Error Message
  Widget _buildErrorMessage(LoginScreenProvider provider) {
    final errorMessage = provider.errorMessage ?? provider.loginScreenModel.errorMessage;
    if (errorMessage == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(15.h),
      decoration: BoxDecoration(
        color: appTheme.errorContainer,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(
          color: appTheme.errorColor.withOpacity(0.5),
          width: 1.h,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: appTheme.errorColor,
            size: 20.h,
          ),
          SizedBox(width: 8.h),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                color: appTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Widget: Forgot Password Link
  Widget _buildForgotPasswordLink(LoginScreenProvider provider) {
    return Center(
      child: GestureDetector(
        onTap: () {
          provider.navigateToAccountRecovery(context);
        },
        child: Text(
          "Mot de passe oublié ?",
          style: TextStyleHelper.instance.body14RegularSyne.copyWith(
            color: appTheme.primaryColor,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  /// Section Widget: Registration Link
  Widget _buildRegistrationLink(LoginScreenProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalization.of().getString("key_no_account_question"),
              style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                color: appTheme.onSurface,
              ),
            ),
            SizedBox(width: 4.h),
            GestureDetector(
              onTap: () {
                provider.navigateToRegistration(context);
              },
              child: Text(
                AppLocalization.of().getString("key_register"),
                style: TextStyleHelper.instance.title16MediumSyne.copyWith(
                  color: appTheme.primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 16.h),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalization.of().getString("key_discover_app_question"),
              style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                color: appTheme.onSurface,
              ),
            ),
            SizedBox(width: 4.h),
            GestureDetector(
              onTap: () {
                NavigatorService.pushNamed(AppRoutes.onboardingScreen);
              },
              child: Text(
                AppLocalization.of().getString("key_discover_app"),
                style: TextStyleHelper.instance.title16MediumSyne.copyWith(
                  color: appTheme.primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Perform login with password
  void _performLogin(LoginScreenProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Check if AuthProvider is available
    if (!provider.isAuthProviderAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Service d\'authentification non disponible'),
          backgroundColor: appTheme.errorColor,
        ),
      );
      return;
    }
    
    final success = await provider.loginWithPassword(context);
    if (success) {
      _handleSuccessfulLogin(provider);
    }
  }

  /// Handle successful login
  void _handleSuccessfulLogin(LoginScreenProvider provider) {
    // Navigate to home screen
    provider.navigateToHome(context);
  }
}