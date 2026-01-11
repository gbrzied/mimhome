import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:millime/connection/login_pass_pin_screen/provider/login_pass_pin_provider.dart';
import 'package:millime/core/app_export.dart';
import 'package:millime/widgets/custom_text_form_field.dart';

/// Responsive design constants based on Figma design (375x812)
const double kScreenPadding = 12.0;
const double kSectionSpacing = 8.0;
const double kTouchTargetMin = 48.0;
const double kTouchTargetAbsolute = 44.0;
const double kInputFieldHeight = 56.0;
const double kPinDigitWidth = 45.0;
const double kPinDigitHeight = 48.0;
const double kKeypadButtonSize = 72.0;
const double kToggleButtonHeight = 48.0;
const double kPrimaryButtonHeight = 50.0;
const double kPrimaryButtonBorderRadius = 28.0;

class LoginPassPinScreen extends StatefulWidget {
  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<LoginPassPinProvider>(
      create: (context) => LoginPassPinProvider(),
      child: const LoginPassPinScreen(),
    );
  }

  const LoginPassPinScreen({super.key});

  @override
  State<LoginPassPinScreen> createState() => _LoginPassPinScreenState();
}

class _LoginPassPinScreenState extends State<LoginPassPinScreen> {
  bool _isPinMode = false; // Default to password mode
  String _pin = "";
  bool _obscurePassword = true;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  void _onKeypadTap(String value) {
    setState(() {
      if (value == 'X') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else if (value == '✓') {
        // PIN validation
        debugPrint('LoginPassPinProvider: Attempting PIN login for phone: ${_provider ?? value}');

        _provider?.handleLogin(context);
        debugPrint('PIN Validated: $_pin (PIN auth to be implemented)');
      } else {
        if (_pin.length < 6) _pin += value;
      }
    });
    _provider?.updatePin(_pin);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

LoginPassPinProvider? _provider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = context.read<LoginPassPinProvider>();
      _provider?.setAuthMode("password");
      _provider?.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: kScreenPadding.h),
                child: Consumer<LoginPassPinProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogoSection(),
                        SizedBox(height: 10.h),
                        _buildPhoneInputSection(provider),
                        SizedBox(height: kSectionSpacing.h),
                if (provider.isPhoneNumberValid && (provider.bAccountExists ?? false))
                        _buildToggleSection(provider),
                        SizedBox(height: kSectionSpacing.h),
                if (provider.isPhoneNumberValid && (provider.bAccountExists ?? false))
                        _buildConditionalContent(provider),
                        SizedBox(height: 15.h),
                      ],
                    );
                  },
                ),
              ),
            ),
            _buildSignupLink(),
          ],
        ),
      ),
    );
  }

  /// AppBar with proper styling and system UI overlay
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: appTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: appTheme.primaryColor,
          size: 24.h,
        ),
        onPressed: () {
          NavigatorService.pushNamed(
            AppRoutes.millimeSettingsScreen,
          );
        },
        constraints: BoxConstraints(
          minWidth: kTouchTargetMin.h,
          minHeight: kTouchTargetMin.h,
        ),
        splashRadius: 24.h,
        tooltip: 'Menu',
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: appTheme.backgroundColor,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Logo section with responsive dimensions
  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgMillimeLogo,
            height: 60.h,
            width: 130.h,
          ),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  /// Phone input section with semantic colors and proper styling
  Widget _buildPhoneInputSection(LoginPassPinProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _buildPhoneTextField(provider),
        // if (provider.errorMessage != null && provider.errorMessage!.isNotEmpty)
        //   _buildErrorMessage(provider),
      ],
    );
  }

  /// Phone number text field with prefix and responsive sizing
  Widget _buildPhoneTextField(LoginPassPinProvider provider) {
    return Focus(
  onFocusChange: (hasfocus) async {
            if (!hasfocus) {
              String userTel = _phoneController.text;
              bool bUpdatePassActions = false;

              //dynamic compte = await myStore?.getCompteByTelGestion((myStore?.userTel)!);
              dynamic compte = null;
              try {
                compte = await provider.getCompteByTelGestionPlus(userTel);
              } catch (e) {
                var msg = 'message';

              }
  
            }
          },

      child: CustomTextFormField(
        controller: _phoneController,
        textStyle: TextStyleHelper.instance.body14RegularSyne.copyWith(
          color: appTheme.onBackground,
          fontSize: 14.fSize,
        ),
        hintText: 'Entrez votre numéro de téléphone',
        hintStyle: TextStyleHelper.instance.body14RegularSyne.copyWith(
          color: appTheme.onSurfaceVariant,
          fontSize: 14.fSize,
        ),
        prefix: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.h),
          constraints: BoxConstraints(maxHeight: kInputFieldHeight.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+216',
                style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                  color: appTheme.onSurface,
                  fontSize: 14.fSize,
                ),
              ),
              SizedBox(width: 8.h),
              Container(
                width: 1.h,
                height: 24.h,
                color: appTheme.borderColor,
              ),
            ],
          ),
        ),
        prefixConstraints: BoxConstraints(
          maxHeight: kInputFieldHeight.h,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.h,
          vertical: 18.h,
        ),
        borderDecoration: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.h),
          borderSide: BorderSide(
            color: appTheme.borderColor,
            width: 1.5.h,
          ),
        ),
        errorText: provider.phoneNumberError,
        errorStyle: TextStyleHelper.instance.body14RegularSyne.copyWith(
          color: appTheme.errorColor,
          fontSize: 12.fSize,
        ),
        textInputType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(8),
        ],
        onChanged: (value) {
          _onPhoneNumberChanged(value, provider);
        },
      ),
    );
  }

  /// Handle phone number change - clear password and update provider
  void _onPhoneNumberChanged(String value, LoginPassPinProvider provider) {
    provider.updatePhoneNumber(value);
    provider.clearPassword();
    _passwordController.clear();
  }

  /// Error message display
  Widget _buildErrorMessage(LoginPassPinProvider provider) {
    final errorMessage = provider.errorMessage;
    if (errorMessage == null || errorMessage.isEmpty) {
      return const SizedBox.shrink();
    }

    debugPrint('LoginPassPinScreen: Building error message: "$errorMessage"');
    debugPrint('LoginPassPinScreen: Error message length: ${errorMessage.length}');

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: appTheme.errorContainer,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(
          color: appTheme.errorColor.withValues(alpha: 0.5),
          width: 1.h,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: appTheme.errorColor, size: 20.h),
          SizedBox(width: 8.h),
          Flexible(
            child: Text(
              errorMessage,
              style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                color: appTheme.errorColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  /// Toggle section for switching between PIN and password modes
  Widget _buildToggleSection(LoginPassPinProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisir méthode *',
          style: TextStyleHelper.instance.body14RegularSyne.copyWith(
            color: appTheme.onSurfaceVariant,
          ),
        ),
        if (provider.errorMessage != null && provider.errorMessage!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: _buildErrorMessage(provider),
          ),
        SizedBox(height: 8.h),
        _buildToggleButtons(),
      ],
    );
  }

  /// Toggle buttons with proper touch targets and visual states
  Widget _buildToggleButtons() {
    return Container(
      height: kToggleButtonHeight.h,
      decoration: BoxDecoration(
        color: appTheme.surfaceColor,
        borderRadius: BorderRadius.circular(28.h),
        border: Border.all(color: appTheme.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              text: 'Code PIN',
              isActive: _isPinMode,
              onTap: () => {_isPinMode = true, _provider?.setAuthMode("pin")},
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              text: 'Mot De Passe',
              isActive: !_isPinMode,
              onTap: () => {_isPinMode = false,_provider?.setAuthMode("password"),}
            ),
          ),
        ],
      ),
    );
  }

  /// Individual toggle button with animation and proper styling
  Widget _buildToggleButton({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28.h),
        overlayColor: WidgetStateProperty.all(
          appTheme.primaryColor.withValues(alpha: 0.1),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? appTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(28.h),
          ),
          child: Text(
            text,
            style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
              color: isActive ? appTheme.onPrimary : appTheme.onSurface,
              fontSize: 14.fSize,
            ),
          ),
        ),
      ),
    );
  }

  /// Conditional content based on selected mode (PIN or Password)
  Widget _buildConditionalContent(LoginPassPinProvider provider) {
    return _isPinMode ? _buildPinModeContent() : _buildPasswordModeContent(provider);
  }

  /// PIN mode content with responsive PIN display and keypad
  /// Note: PIN authentication is not yet implemented
  Widget _buildPinModeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saisir votre code PIN *',
          textAlign: TextAlign.left,
          style: TextStyleHelper.instance.body14RegularSyne.copyWith(
            color: appTheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 10.h),
        _buildPinDisplay(),
        SizedBox(height: 10.h),
        _buildForgotPinLink(),
        SizedBox(height: 12.h),
        _buildPinKeypad(),
      ],
    );
  }
  /// PIN digit display with responsive sizing and visual feedback
  Widget _buildPinDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        final isFilled = index < _pin.length;
        return Semantics(
          label: 'PIN digit ${index + 1} sur 6',
          child: Container(
            width: kPinDigitWidth.h,
            height: kPinDigitHeight.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFilled
                  ? appTheme.primaryColor.withValues(alpha: 0.1)
                  : appTheme.surfaceColor,
              border: Border.all(
                color: isFilled ? appTheme.primaryColor : appTheme.borderColor,
              ),
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: Text(
              isFilled ? '●' : '',
              style: TextStyleHelper.instance.headline30MediumDMSans.copyWith(
                color: appTheme.primaryColor,
                fontSize: 28.fSize,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Forgot PIN link with proper touch target
  Widget _buildForgotPinLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Text(
            'Avez-vous oublié votre code PIN ?',
            style: TextStyleHelper.instance.body12MediumPoppins.copyWith(
              color: appTheme.primaryColor,
              fontSize: 12.fSize,
            ),
          ),
        ),
      ),
    );
  }

  /// PIN keypad with proper touch targets and accessibility
  /// Note: This is UI only - authentication logic to be implemented later
  Widget _buildPinKeypad() {
    final keys = ['7', '0', '4', '9', '2', '8', '6', '3', '5', 'X', '1', '✓'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 75.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12.h,
          mainAxisSpacing: 12.h,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          final isSpecial = key == 'X' || key == '✓';

          return Semantics(
            label: isSpecial
                ? (key == 'X' ? 'Supprimer' : 'Valider')
                : 'Chiffre $key',
            button: true,
            child: GestureDetector(
              onTap: () => _onKeypadTap(key),
              behavior: HitTestBehavior.opaque,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSpecial
                      ? (key == 'X' ? appTheme.breakColor : appTheme.primaryColor)
                      : appTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16.h),
                  border: Border.all(
                    color: isSpecial ? Colors.transparent : appTheme.primaryColor,
                    width: 1.5.h,
                  ),
                ),
                child: isSpecial && key == '✓'
                    ? Icon(
                        Icons.check,
                        color: appTheme.onPrimary,
                        size: 28.h,
                      )
                    : Text(
                        key,
                        style: TextStyleHelper.instance.headline30MediumDMSans.copyWith(
                          color: isSpecial ? appTheme.onPrimary : appTheme.onSurface,
                          fontSize: 24.fSize,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Password mode content with responsive input field
  Widget _buildPasswordModeContent(LoginPassPinProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saisir votre mot de passe *',
          textAlign: TextAlign.left,
          style: TextStyleHelper.instance.body14RegularSyne.copyWith(
            color: appTheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 8.h),
        _buildPasswordTextField(provider),
        SizedBox(height: 16.h),
        if (provider.isPhoneNumberValid && (provider.bAccountExists ?? false))
          _buildForgotPasswordLink(provider),
        SizedBox(height: 30.h),
        _buildValidateButton(provider),
      ],
    );
  }

  /// Password text field with visibility toggle
  Widget _buildPasswordTextField(LoginPassPinProvider provider) {
    return CustomTextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textStyle: TextStyleHelper.instance.body14RegularSyne.copyWith(
        color: appTheme.onBackground,
        fontSize: 14.fSize,
      ),
      hintText: 'Entrez votre mot de passe',
      hintStyle: TextStyleHelper.instance.body14RegularSyne.copyWith(
        color: appTheme.onSurfaceVariant,
        fontSize: 14.fSize,
      ),
      prefix: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.h),
        child: Icon(
          Icons.lock_outline,
          color: appTheme.onSurfaceVariant,
          size: 20.h,
        ),
      ),
      prefixConstraints: BoxConstraints(maxHeight: kInputFieldHeight.h),
      suffix: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: appTheme.onSurfaceVariant,
          size: 20.h,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        constraints: BoxConstraints(
          minWidth: kTouchTargetMin.h,
          minHeight: kTouchTargetMin.h,
        ),
        splashRadius: 20.h,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.h,
        vertical: 18.h,
      ),
      borderDecoration: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.h),
        borderSide: BorderSide(
          color: appTheme.borderColor,
          width: 1.5.h,
        ),
      ),
      errorText: provider.passwordError,
      errorStyle: TextStyleHelper.instance.body14RegularSyne.copyWith(
        color: appTheme.errorColor,
        fontSize: 12.fSize,
      ),
      onChanged: (value) {
        provider.updatePassword(value);
      },
    );
  }

  /// Forgot password link with proper touch target
  Widget _buildForgotPasswordLink(LoginPassPinProvider provider) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          provider.navigateToAccountRecovery(context);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(
            'Avez-vous oublié votre mot de passe ?',
            style: TextStyleHelper.instance.body12MediumPoppins.copyWith(
              color: appTheme.primaryColor,
              fontSize: 12.fSize,
            ),
          ),
        ),
      ),
    );
  }

  /// Validate button with proper styling and touch target
  Widget _buildValidateButton(LoginPassPinProvider provider) {
    final isDisabled = provider.isLoading || 
        !provider.isPhoneNumberValid || 
        provider.password.isEmpty;

    return SizedBox(
      width: double.infinity,
      height: kPrimaryButtonHeight.h,
      child: ElevatedButton(
        onPressed: isDisabled ? null : () => provider.handleLogin(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: appTheme.primaryColor,
          foregroundColor: appTheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kPrimaryButtonBorderRadius.h),
          ),
          elevation: 0,
          disabledBackgroundColor: appTheme.disabledColor,
        ),
        child: provider.isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.h,
                  color: appTheme.onPrimary,
                ),
              )
            : Text(
                'Valider',
                style: TextStyleHelper.instance.title16MediumSyne.copyWith(
                  color: appTheme.onPrimary,
                  fontSize: 16.fSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  /// Perform password login


  /// Signup link with proper accessibility
  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Vous n'avez pas un compte ? ",
          style: TextStyleHelper.instance.body14RegularSyne.copyWith(
            color: appTheme.onSurfaceVariant,
            fontSize: 14.fSize,
          ),
        ),
        GestureDetector(
          onTap: () {
            context.read<LoginPassPinProvider>().navigateToRegistration(context);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              "s'inscrire",
              style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                color: appTheme.breakColor,
                fontSize: 14.fSize,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
