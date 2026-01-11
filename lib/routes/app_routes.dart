import 'package:millime/connection/login_pass_pin_screen/login_pass_pin_screen.dart';
import 'package:millime/enrol/account_level_selection_screen/account_level_selection_screen.dart';
import 'package:millime/enrol/account_type_selection_screen/account_type_pers_selection_screen.dart';
import 'package:millime/enrol/bill_payment_selection_screen/bill_payment_selection_screen.dart';
import 'package:millime/enrol/identity_verification_titu_pp_screen/identity_verification_screen.dart';
import 'package:millime/enrol/identity_verification_mand_screen/identity_verification_mand_screen.dart';
import 'package:millime/enrol/identity_verification_pm_screen/identity_verification_pm_screen.dart';

import 'package:millime/connection/password_update_screen/password_update_screen.dart';
import 'package:millime/enrol/otp_screen/otp_screen.dart';
import 'package:millime/enrol/wallet_setup_confirmation_screen/wallet_setup_confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../enrol/account_dashboard_screen/account_dashboard_screen.dart';
import '../enrol/accordion_document_screen/terms_conditions_screen.dart';
import '../enrol/accordion_document_screen/terms_conditions_screen_v2.dart';
import '../enrol/accordion_document_screen/accordion_document_wrapper_screen.dart';
import '../enrol/accordion_document_screen/provider/terms_conditions_provider.dart';
import '../enrol/personal_informations_screen/personal_informations_screen.dart';
import '../enrol/personal_informations_mand_screen/personal_informations_mand_screen.dart';
import '../enrol/pm_informations_screen/pm_informations_screen.dart';


import '../enrol/account_recovery_screen/account_recovery_screen.dart';
import '../enrol/millime_settings/millime_settings.dart';
import '../enrol/millime_settings/language_selection_screen.dart';

import '../enrol/fin_enrol/fin_enrol.dart';
import '../enrol/onboarding/on_boarding.dart';

import '../enrol/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  
    static const String identityVerificationScreen = '/identity_verification_screen';
    static const String identityVerificationMandScreen = '/identity_verification_mand_screen';
    static const String identityVerificationPmScreen = '/identity_verification_pm_screen';


 
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
    static const String pmInformationsScreen = '/pm_informations_screen';


  static const String personalInformationsMandScreen = '/personal_informations_mand_screen';

  static const String accountRecoveryScreen = '/account_recovery_screen';
  static const String loginScreen = '/login_screen';
  static const String passwordUpdateScreen = '/password_update_screen';
  static const String finEnrolScreen = '/fin_enrol_screen';
  static const String millimeSettingsScreen = '/millime_settings_screen';
  static const String languageSelectionScreen = '/language_selection_screen';
  static const String onboardingScreen = '/onboarding_screen';

  static const String loginPassPinScreen = '/login_pass_pin_screen';

  static const String initialRoute = '/';

//account_dashboard_screen  account_opening_screen  app_navigation_screen  bill_payment_selection_screen  wallet_setup_confirmation_screen

  static Map<String, WidgetBuilder> get routes => {
      ///onTapScreenTitle: () => onTapDialogTitle(context,  WalletSetupConfirmationScreen.builder(context))


        loginPassPinScreen: LoginPassPinScreen.builder,

        accountTypeSelectionScreen: AccountTypePersSelectionScreen.builder, 

        billPaymentSelectionScreen: BillPaymentSelectionScreen.builder, 

        walletSetupConfirmationScreen: WalletSetupConfirmationScreen.builder,
        accountLevelSelectionScreen: AccountLevelSelectionScreen.builder,

        appNavigationScreen: AppNavigationScreen.builder,
        initialRoute: LoginPassPinScreen.builder,
        //initialRoute: IdentityVerificationScreen.builder,

        termsConditionsScreen: TermsConditionsScreen.builder,
        termsConditionsScreenV2: TermsConditionsScreenV2.builder,
        accordionDocumentScreen: AccordionDocumentWrapperScreen.builder,
        otpScreen: (context) => ChangeNotifierProvider<TermsConditionsProvider>(
          create: (context) => TermsConditionsProvider(),
          child: OtpVerificationPage.builder(context),
        ),
        
        personalInformationsScreen: PersonalInformationsScreen.builder,
        pmInformationsScreen: PmInformationsScreen.builder,
        personalInformationsMandScreen: PersonalInformationsMandScreen.builder,

        identityVerificationScreen: IdentityVerificationScreen.builder, 
        identityVerificationMandScreen: IdentityVerificationMandScreen.builder, 
        identityVerificationPmScreen: IdentityVerificationPmScreen.builder, 


        
        accountRecoveryScreen: (context) => AccountRecoveryScreen(),
        passwordUpdateScreen: PasswordUpdateScreen.builder,
        finEnrolScreen: (context) => EnrollmentSuccessScreen(),
        millimeSettingsScreen: MillimeSettings.builder,
        languageSelectionScreen: LanguageSelectionScreen.builder,
        onboardingScreen: (context) => OnboardingScreen(),

       // accountOpeningPage: (context) => AccountOpeningPage(),
        accountDashboardScreen: AccountDashboardScreen.builder,
      };
}
