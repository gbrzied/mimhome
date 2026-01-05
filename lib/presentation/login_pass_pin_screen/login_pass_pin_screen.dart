import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_export.dart';
import 'provider/login_pass_pin_provider.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custum_button.dart';
import '../../localizationMillime/localization/app_localization.dart';

class LoginPassPinScreen extends StatefulWidget {
  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<LoginPassPinProvider>(
      create: (context) => LoginPassPinProvider(),
      child: LoginPassPinScreen(),
    );
  }

  @override
  State<LoginPassPinScreen> createState() => _LoginPassPinScreenState();
}

class _LoginPassPinScreenState extends State<LoginPassPinScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  
  bool _isPasswordHidden = true;
  bool _isPinHidden = true;
  bool _rememberMe = false;
  String _authMethod = 'password'; // 'password' or 'pin'
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginPassPinProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<LoginPassPinProvider>(
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

                          SizedBox(height: 25.h),

                          // Welcome Message
                          _buildWelcomeMessage(),

                          SizedBox(height: 25.h),

                          // Authentication Method Selection
                          _buildAuthMethodSelection(),

                          SizedBox(height: 25.h),

                          // Phone Number Input Section
                          _buildPhoneNumberSection(provider),

                          SizedBox(height: 16.h),

                          // Password/PIN Input Section
                          if (_authMethod == 'password')
                            _buildPasswordSection()
                          else
                            _buildPinSection(),

                          SizedBox(height: 16.h),

                          // Remember Me Checkbox
                          _buildRememberMeSection(),

                          SizedBox(height: 24.h),

                          // Login Button
                          _buildLoginButton(provider),

                          SizedBox(height: 20.h),

                          // Error Message
                          if (provider.errorMessage != null)
                            _buildErrorMessage(provider),

                          SizedBox(height: 24.h),

                          // Forgot Password/PIN Link
                          _buildForgotAuthLink(provider),

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
          SizedBox(height: 8.h),
          Text(
            "lbl_bienvenue".tr,
            style: TextStyleHelper.instance.title18SemiBoldQuicksand.copyWith(
              color: appTheme.primaryColor,
            ),
          ),
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

  /// Section Widget: Authentication Method Selection
  Widget _buildAuthMethodSelection() {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(
          color: appTheme.borderColor,
          width: 1.h,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildAuthMethodButton(
              'password',
              'Mot de passe',
              Icons.lock,
              _authMethod == 'password',
            ),
          ),
          Container(
            width: 1.h,
            height: 50.h,
            color: appTheme.borderColor,
          ),
          Expanded(
            child: _buildAuthMethodButton(
              'pin',
              'Code PIN',
              Icons.pin,
              _authMethod == 'pin',
            ),
          ),
        ],
      ),
    );
  }

  /// Authentication Method Button
  Widget _buildAuthMethodButton(String method, String label, IconData icon, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _authMethod = method;
          });
          // Clear the input fields when switching methods
          _passwordController.clear();
          _pinController.clear();
          _formKey.currentState?.validate();
        },
        borderRadius: BorderRadius.circular(12.h),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.h),
          decoration: BoxDecoration(
            color: isSelected ? appTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12.h),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? appTheme.primaryColor : appTheme.onSurfaceVariant,
                size: 20.h,
              ),
              SizedBox(width: 8.h),
              Text(
                label,
                style: TextStyleHelper.instance.body14MediumManrope.copyWith(
                  color: isSelected ? appTheme.primaryColor : appTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget: Phone Number Input Section
  Widget _buildPhoneNumberSection(LoginPassPinProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "key_num_tel".tr,
          style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
            color: appTheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextFormField(
          controller: _phoneController,
          textInputType: TextInputType.phone,
          hintText: "key_entrer_num_tel".tr,
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

  /// Section Widget: PIN Input Section
  Widget _buildPinSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Code PIN",
          style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
            color: appTheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextFormField(
          controller: _pinController,
          obscureText: _isPinHidden,
          textInputType: TextInputType.number,
          hintText: "Entrez votre code PIN",
          maxLength: 6,
          prefixConstraints: BoxConstraints(
            maxHeight: 56.h,
          ),
          prefix: Container(
            margin: EdgeInsets.only(left: 16.h, right: 12.h),
            child: Icon(
              Icons.pin_outlined,
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
              return 'Veuillez entrer votre code PIN';
            }
            if (value.length != 6) {
              return 'Le code PIN doit contenir 6 chiffres';
            }
            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
              return 'Le code PIN ne doit contenir que des chiffres';
            }
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          suffix: IconButton(
            icon: Icon(
              _isPinHidden ? Icons.visibility_off : Icons.visibility,
              color: appTheme.onSurfaceVariant,
              size: 20.h,
            ),
            onPressed: () {
              setState(() {
                _isPinHidden = !_isPinHidden;
              });
            },
          ),
        ),
      ],
    );
  }

  /// Section Widget: Remember Me Section
  Widget _buildRememberMeSection() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
          activeColor: appTheme.primaryColor,
          side: BorderSide(
            color: appTheme.borderColor,
            width: 1.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.h),
          ),
        ),
        SizedBox(width: 8.h),
        Text(
          "Se souvenir de moi",
          style: TextStyleHelper.instance.body14RegularSyne.copyWith(
            color: appTheme.onSurface,
          ),
        ),
        Spacer(),
        if (_authMethod == 'password')
          GestureDetector(
            onTap: () {
              context.read<LoginPassPinProvider>().navigateToAccountRecovery(context);
            },
            child: Text(
              "Mot de passe oublié ?",
              style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                color: appTheme.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        if (_authMethod == 'pin')
          GestureDetector(
            onTap: () {
              context.read<LoginPassPinProvider>().navigateToAccountRecovery(context);
            },
            child: Text(
              "Code PIN oublié ?",
              style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                color: appTheme.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }

  /// Section Widget: Login Button
  Widget _buildLoginButton(LoginPassPinProvider provider) {
    return CustomButton(
      text: "Se connecter",
      width: double.maxFinite,
      variant: CustomButtonVariant.filled,
      // isLoading: provider.isLoading, // TODO: Add loading support to CustomButton
      onPressed: () => _performLogin(provider),
    );
  }

  /// Section Widget: Error Message
  Widget _buildErrorMessage(LoginPassPinProvider provider) {
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
              provider.errorMessage!,
              style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                color: appTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Widget: Registration Link
  Widget _buildRegistrationLink(LoginPassPinProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "key_no_account_question".tr,
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
                "key_register".tr,
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
              "key_discover_app_question".tr,
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
                "key_discover_app".tr,
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

  /// Perform login based on selected authentication method
  void _performLogin(LoginPassPinProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phoneNumber = _phoneController.text.trim();
    
    if (_authMethod == 'password') {
      final password = _passwordController.text;
      final success = await provider.loginWithPassword(context, phoneNumber, password);
      if (success) {
        _handleSuccessfulLogin(provider);
      }
    } else {
      final pin = _pinController.text;
      final success = await provider.loginWithPin(context, phoneNumber, pin);
      if (success) {
        _handleSuccessfulLogin(provider);
      }
    }
  }

  /// Handle successful login
  void _handleSuccessfulLogin(LoginPassPinProvider provider) {
    // Save remember me preference if needed
    if (_rememberMe) {
      // Implementation for remember me functionality
      // This could involve storing credentials securely
    }
    
    // Navigate to home screen
    provider.navigateToHome(context);
  }

  /// Section Widget: Forgot Authentication Link (kept for backward compatibility)
  Widget _buildForgotAuthLink(LoginPassPinProvider provider) {
    return Center(
      child: GestureDetector(
        onTap: () {
          provider.navigateToAccountRecovery(context);
        },
        child: Text(
          _authMethod == 'password' ? "Mot de passe oublié ?" : "Code PIN oublié ?",
          style: TextStyleHelper.instance.body14RegularSyne.copyWith(
            color: appTheme.primaryColor,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}