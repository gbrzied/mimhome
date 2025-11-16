import 'package:cible/presentation/account_opening_screen/account_opening_screen.dart';
import 'package:flutter/material.dart';
import '../presentation/account_dashboard_screen/account_dashboard_screen.dart';

import '../presentation/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  
  static const String accountOpeningPage = '/account_opening_screen';

  static const String accountDashboardScreen = '/account_dashboard_screen';

  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
    
        accountOpeningPage: (context) => AccountOpeningPage(),

        accountDashboardScreen: AccountDashboardScreen.builder,
        appNavigationScreen: AppNavigationScreen.builder,
        initialRoute: AccountDashboardScreen.builder
      };
}
