import 'package:millime/presentation/account_level_selection_screen/account_level_selection_screen.dart';
import 'package:millime/presentation/account_type_selection_screen/account_type_selection_screen.dart';
import 'package:millime/presentation/bill_payment_selection_screen/bill_payment_selection_screen.dart';
import 'package:millime/presentation/identity_verification_screen/identity_verification_screen.dart';
import 'package:millime/presentation/login_screen/login_screen.dart';
import 'package:millime/presentation/otp_screen/otp_screen.dart';
import 'package:millime/presentation/wallet_setup_confirmation_screen/wallet_setup_confirmation_screen.dart';
import 'package:flutter/material.dart';
import '../presentation/account_dashboard_screen/account_dashboard_screen.dart';
import '../presentation/accordion_document_screen/terms_conditions_screen.dart';
import '../presentation/accordion_document_screen/terms_conditions_screen_v2.dart';
import '../presentation/accordion_document_screen/accordion_document_wrapper_screen.dart';
import '../presentation/personal_informations_screen/personal_informations_screen.dart';
import '../presentation/account_recovery_screen/account_recovery_screen.dart';
import '../presentation/millime_settings/millime_settings.dart';

import '../presentation/fin_enrol/fin_enrol.dart';
import '../presentation/onboarding/on_boarding.dart';

import '../presentation/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  
    static const String identityVerificationScreen = '/identity_verification_screen';
 
      static const String accountTypeSelectionScreen =
        '/account_type_selection_screen';
    static const String accountLevelSelectionScreen =
        '/account_level_selection_screen';
 
    static const String otpScreen = '/otp_screen';

  // static const String accountOpeningPage = '/account_opening_screen';

  static const String accountDashboardScreen = '/account_dashboard_screen';

  static const String appNavigationScreen = '/app_navigation_screen';

  static const String billPaymentSelectionScreen = '/bill_payment_selection_screen';

  static const String walletSetupConfirmationScreen =      '/wallet_setup_confirmation_screen';
  static const String termsConditionsScreen = '/terms_conditions_screen';
  static const String termsConditionsScreenV2 = '/terms_conditions_screen_v2';
  static const String accordionDocumentScreen = '/accordion_document_screen';
  static const String personalInformationsScreen = '/personal_informations_screen';
  static const String accountRecoveryScreen = '/account_recovery_screen';
  static const String loginScreen = '/login_screen';
  static const String finEnrolScreen = '/fin_enrol_screen';
  static const String millimeSettingsScreen = '/millime_settings_screen';
  static const String onboardingScreen = '/onboarding_screen';
  static const String initialRoute = '/';

//account_dashboard_screen  account_opening_screen  app_navigation_screen  bill_payment_selection_screen  wallet_setup_confirmation_screen

  static Map<String, WidgetBuilder> get routes => {
      ///onTapScreenTitle: () => onTapDialogTitle(context,  WalletSetupConfirmationScreen.builder(context))
      ///
    
        identityVerificationScreen: IdentityVerificationScreen.builder, 

        accountTypeSelectionScreen: AccountTypeSelectionScreen.builder, 

        billPaymentSelectionScreen: BillPaymentSelectionScreen.builder, 

        walletSetupConfirmationScreen: WalletSetupConfirmationScreen.builder,
        accountLevelSelectionScreen: AccountLevelSelectionScreen.builder,

        appNavigationScreen: AppNavigationScreen.builder,
        // initialRoute: LoginScreen.builder,
        
        initialRoute: IdentityVerificationScreen.builder,

        termsConditionsScreen: TermsConditionsScreen.builder,
        termsConditionsScreenV2: TermsConditionsScreenV2.builder,
        accordionDocumentScreen: AccordionDocumentWrapperScreen.builder,
        otpScreen: OtpVerificationPage.builder,
        personalInformationsScreen: PersonalInformationsScreen.builder,
        accountRecoveryScreen: (context) => AccountRecoveryScreen(),
        loginScreen: LoginScreen.builder,
        finEnrolScreen: (context) => EnrollmentSuccessScreen(),
        millimeSettingsScreen: MillimeSettings.builder,
        onboardingScreen: (context) => OnboardingScreen(),

       // accountOpeningPage: (context) => AccountOpeningPage(),
        accountDashboardScreen: AccountDashboardScreen.builder,
      };
}
