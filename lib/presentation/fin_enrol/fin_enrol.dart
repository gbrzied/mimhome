import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../localizationMillime/localization/app_localization.dart';
import './provider/enrollment_success_provider.dart';

// Définition de la classe de l'écran de fin d'inscription
class EnrollmentSuccessScreen extends StatefulWidget {
  const EnrollmentSuccessScreen({super.key});

  @override
  State<EnrollmentSuccessScreen> createState() => _EnrollmentSuccessScreenState();
}

class _EnrollmentSuccessScreenState extends State<EnrollmentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // The provider will auto-submit on initialization
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EnrollmentSuccessProvider>(
      create: (context) => EnrollmentSuccessProvider()..initialize(),
      child: Consumer<EnrollmentSuccessProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: appTheme.white_A700,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 1.0,
                      backgroundColor: const Color(0xFFF0F0F0),
                      valueColor: AlwaysStoppedAnimation<Color>(appTheme.primaryColor),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('key_progress_5_of_5'.tr, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (provider.isLoading)
                      Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(appTheme.primaryColor),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'key_submission_in_progress'.tr,
                            style: TextStyleHelper.instance.title16MediumSyne,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    else if (provider.submissionSuccess)
                      Column(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0F0F0),
                              shape: BoxShape.circle,
                            ),
                            child:CustomImageView(imagePath: ImageConstant.imghand,)
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'key_thank_you'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyleHelper.instance.title38BoldQuicksand,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            //provider.submissionMessage ?? 
                            'key_registration_successful'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyleHelper.instance.title20RegularQuicksand,
                          ),
                          const SizedBox(height: 8),
                             Text(
                            // provider.submissionMessage ?? 
                            'key_request_under_review'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyleHelper.instance.body12RegularManrope,
                          ),
                          const SizedBox(height: 15),
                          // ElevatedButton(
                          //   onPressed: () => provider.navigateToDashboard(context),
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: appTheme.primaryColor,
                          //     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(25),
                          //     ),
                          //   ),
                          //   child: Text(
                          //     'Terminer',
                          //     style: TextStyleHelper.instance.title16MediumSyne.copyWith(
                          //       color: appTheme.onPrimary,
                          //     ),
                          //   ),
                          // ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0F0F0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error,
                              size: 80,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'key_error'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyleHelper.instance.title38BoldQuicksand,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            provider.submissionMessage ?? 'key_submission_error'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyleHelper.instance.title20RegularQuicksand,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () => provider.submit(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'key_retry'.tr,
                              style: TextStyleHelper.instance.title16MediumSyne.copyWith(
                                color: appTheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
