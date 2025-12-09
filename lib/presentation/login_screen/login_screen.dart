import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import 'provider/login_screen_provider.dart';
import 'models/login_screen_model.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custum_button.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginScreenProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<LoginScreenProvider>(
          builder: (context, provider, child) {
            return Column(
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
                              // TODO: Implement drawer navigation
                            },
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Logo Section
                        _buildLogoSection(),

                        SizedBox(height: 25.h),

                        // Phone Number Input Section
                        _buildPhoneNumberSection(provider),

                        SizedBox(height: 25.h),

                        // Validate Button
                        _buildValidateButton(provider),

                        SizedBox(height: 30.h),

                        // Error Message
                        if (provider.loginScreenModel.errorMessage != null)
                          _buildErrorMessage(provider),

                        // Add some bottom padding to ensure content doesn't touch the registration link
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),

                // Registration Link at the bottom
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
                  child: _buildRegistrationLink(provider),
                ),
              ],
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
          // Text(
          //   "MILLIME",
          //   style: TextStyleHelper.instance.title18SemiBoldQuicksand.copyWith(
          //     color: appTheme.black_900,
          //   ),
          // ),
        ],
      ),
    );
  }

  /// Section Widget: Phone Number Input Section
  Widget _buildPhoneNumberSection(LoginScreenProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Numéro de téléphone *",
          style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
            color: appTheme.gray_500,
            //fontSize: 14
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextFormField(
          controller: _phoneController,
          textInputType: TextInputType.phone,
          hintText: "Entrer votre numéro de téléphone",
          prefixConstraints: BoxConstraints(
            maxHeight: 56.h,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 15.h,
            horizontal: 15.h,
          ),
          filled: true,
          fillColor: appTheme.surfaceColor,
          onChanged: (value) {
            provider.updatePhoneNumber(value);
          },
        ),
      ],
    );
  }

  /// Section Widget: Validate Button
  Widget _buildValidateButton(LoginScreenProvider provider) {
    return CustomButton(
      text: "Valider",
      width: double.maxFinite,
      variant: CustomButtonVariant.filled,
      onPressed: () {
        provider.validatePhoneNumber(context);
      },
    );
  }

  /// Section Widget: Error Message
  Widget _buildErrorMessage(LoginScreenProvider provider) {
    return Container(
      padding: EdgeInsets.all(15.h),
      decoration: BoxDecoration(
        color: appTheme.backgroundErrColor,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(
          color: appTheme.errorColor.withOpacity(0.5),
          width: 1.h,
        ),
      ),
      child: Text(
        provider.loginScreenModel.errorMessage!,
        style: TextStyleHelper.instance.body14RegularSyne.copyWith(
          color: appTheme.errorColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Section Widget: Registration Link
  Widget _buildRegistrationLink(LoginScreenProvider provider) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Vous n'avez pas de compte ? ",
            style: TextStyleHelper.instance.body14RegularSyne.copyWith(
              color: appTheme.black_900,
            ),
          ),
          GestureDetector(
            onTap: () {
              provider.navigateToRegistration(context);
            },
            child: Text(
              "S'inscrire",
              style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                color: appTheme.breakColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}