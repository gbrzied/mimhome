import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import 'provider/app_navigation_provider.dart';

class AppNavigationScreen extends StatefulWidget {
  const AppNavigationScreen({Key? key}) : super(key: key);

  @override
  AppNavigationScreenState createState() => AppNavigationScreenState();
  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppNavigationProvider(),
      child: AppNavigationScreen(),
    );
  }
}

class AppNavigationScreenState extends State<AppNavigationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0XFFFFFFFF),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Column(
                    children: [
// IdentityVerificationScreen
                _buildScreenTitle(
                        context,
                        screenTitle: "identityVerificationScreen",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.identityVerificationScreen),
                      ),
                _buildScreenTitle(
                        context,
                        screenTitle: "accountTypeSelectionScreen",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.accountTypeSelectionScreen),
                      ),
                      
                      _buildScreenTitle(
                        context,
                        screenTitle: "walletSetupConfirmationScreen",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.walletSetupConfirmationScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "billPaymentSelectionScreen",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.billPaymentSelectionScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "choix_nivTwo",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.accountLevelSelectionScreen),
                      ),
                       _buildScreenTitle(
                        context,
                        screenTitle: "accordionDocumentScreen",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.accordionDocumentScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "accountDashboardScreen",
                        onTapScreenTitle: () => onTapScreenTitle(
                            context, AppRoutes.accountDashboardScreen),
                      ),
                      //  _buildScreenTitle(
                      //    context,
                      //    screenTitle: "termsConditionsScreen",
                      //    onTapScreenTitle: () => onTapScreenTitle(
                      //        context, AppRoutes.termsConditionsScreen),
                      //  ),
                       _buildScreenTitle(
                         context,
                         screenTitle: "termsConditionsScreenV2",
                         onTapScreenTitle: () => onTapScreenTitle(
                             context, AppRoutes.termsConditionsScreenV2),
                       ),
                       _buildScreenTitle(
                         context,
                         screenTitle: "otpScreen",
                         onTapScreenTitle: () => onTapScreenTitle(
                             context, AppRoutes.otpScreen),
                       ),
                       _buildScreenTitle(
                         context,
                         screenTitle: "personalInformationsScreen",
                         onTapScreenTitle: () => onTapScreenTitle(
                             context, AppRoutes.personalInformationsScreen),
                       ),
                       _buildScreenTitle(
                         context,
                         screenTitle: "accountRecoveryScreen",
                         onTapScreenTitle: () => onTapScreenTitle(
                             context, AppRoutes.accountRecoveryScreen),
                       ),
                       _buildScreenTitle(
                         context,
                         screenTitle: "loginScreen",
                         onTapScreenTitle: () => onTapScreenTitle(
                             context, AppRoutes.loginScreen),
                       ),
                       _buildScreenTitle(
                         context,
                         screenTitle: "finEnrolScreen",
                         onTapScreenTitle: () => onTapScreenTitle(
                             context, AppRoutes.finEnrolScreen),
                       ),
                       _buildScreenTitle(
                         context,
                         screenTitle: "millimeSettingsScreen",
                         onTapScreenTitle: () => onTapScreenTitle(
                             context, AppRoutes.millimeSettingsScreen),
                       ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Common widget
  Widget _buildScreenTitle(
    BuildContext context, {
    required String screenTitle,
    Function? onTapScreenTitle,
  }) {
    return GestureDetector(
      onTap: () {
        onTapScreenTitle?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.h),
        decoration: BoxDecoration(color: Color(0XFFFFFFFF)),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  screenTitle,
                  textAlign: TextAlign.center,
                  style: TextStyleHelper.instance.title20RegularRoboto
                      .copyWith(color: Color(0XFF000000)),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Color(0XFF343330),
                )
              ],
            ),
            SizedBox(height: 10.h),
            Divider(height: 1.h, thickness: 1.h, color: Color(0XFFD2D2D2)),
          ],
        ),
      ),
    );
  }

  /// Common click event
  void onTapScreenTitle(BuildContext context, String routeName) {
    NavigatorService.pushNamed(routeName);
  }

  /// Common click event for bottomsheet
  void onTapBottomSheetTitle(BuildContext context, Widget className) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return className;
      },
      isScrollControlled: true,
      backgroundColor: appTheme.transparentCustom,
    );
  }

  /// Common click event for dialog
  void onTapDialogTitle(BuildContext context, Widget className) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: className,
          backgroundColor: appTheme.transparentCustom,
          insetPadding: EdgeInsets.zero,
        );
      },
    );
  }
}
