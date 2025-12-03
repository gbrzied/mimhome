import 'package:cible/presentation/account_level_selection_screen/account_level_selection_screen.dart';
import 'package:cible/presentation/account_type_selection_screen/account_type_selection_screen.dart';
import 'package:cible/presentation/bill_payment_selection_screen/bill_payment_selection_screen.dart';
import 'package:cible/presentation/identity_verification_screen/identity_verification_screen.dart';
import 'package:cible/presentation/wallet_setup_confirmation_screen/wallet_setup_confirmation_screen.dart';
import 'package:flutter/material.dart';
import '../presentation/account_dashboard_screen/account_dashboard_screen.dart';

import '../presentation/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  
    static const String identityVerificationScreen = '/identity_verification_screen';

    static const String accountTypeSelectionScreen =
      '/account_type_selection_screen';
  static const String accountLevelSelectionScreen =
      '/account_level_selection_screen';

  // static const String accountOpeningPage = '/account_opening_screen';

  static const String accountDashboardScreen = '/account_dashboard_screen';

  static const String appNavigationScreen = '/app_navigation_screen';

  static const String billPaymentSelectionScreen = '/bill_payment_selection_screen';

  static const String walletSetupConfirmationScreen =      '/wallet_setup_confirmation_screen';
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
        initialRoute: AppNavigationScreen.builder,
    
       // accountOpeningPage: (context) => AccountOpeningPage(),
        accountDashboardScreen: AccountDashboardScreen.builder,
      };
}

