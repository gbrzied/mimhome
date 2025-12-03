import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_progress_app_bar.dart';
import './provider/identity_verification_provider.dart';
import 'models/identity_verification_model.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<IdentityVerificationProvider>(
      create: (context) => IdentityVerificationProvider(),
      child: const IdentityVerificationScreen(),
    );
  }

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IdentityVerificationProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IdentityVerificationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: appTheme.white_A700,
          appBar: CustomProgressAppBar(
            currentStep: 4,
            totalSteps: 5,
            onBackPressed: () => NavigatorService.goBack(),
          ),
          body: Column(
            children: [
              // Progress Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.h),
                child: LinearProgressIndicator(
                  value: 0.8,
                  backgroundColor: appTheme.gray_200,
                  valueColor: AlwaysStoppedAnimation<Color>(appTheme.cyan_900),
                  minHeight: 6.h,
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        "Vérification d'identité",
                        style: TextStyleHelper.instance.title18SemiBoldQuicksand
                            .copyWith(height: 1.28),
                      ),
                      SizedBox(height: 12.h),

                      // Description
                      Text(
                        "Veuillez téléverser des photos claires de votre CIN, votre signature et un selfie pour vérifier votre identité",
                        style: TextStyleHelper.instance.body12RegularManrope
                            .copyWith(height: 1.5, color: appTheme.gray_600),
                      ),
                      SizedBox(height: 24.h),

                      // CIN Recto Button
                      ElevatedButton(
                        onPressed: () {
                          provider.toggleCardVisibility();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme.cyan_900,
                          foregroundColor: appTheme.white_A700,
                          minimumSize: Size(double.infinity, 48.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.h),
                          ),
                        ),
                        child: Text(
                          'CIN Recto',
                          style: TextStyleHelper.instance.title16MediumSyne
                              .copyWith(height: 1.25, color: appTheme.white_A700),
                        ),
                      ),

                      // ID Card Preview (conditionally shown)
                      if (provider.identityVerificationModel.showCard ?? false) ...[
                        Container(
                          padding: EdgeInsets.all(16.h),
                          decoration: BoxDecoration(
                            color: appTheme.white_A700,
                            border: Border.all(
                              color: appTheme.gray_300,
                              width: 2.h,
                            ),
                            borderRadius: BorderRadius.circular(12.h),
                          ),
                          child: Column(
                            children: [
                              // Card Header
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: appTheme.blue_gray_700_01,
                                  borderRadius: BorderRadius.circular(4.h),
                                ),
                                child: Text(
                                  'IDENTIFICATION CARD',
                                  textAlign: TextAlign.center,
                                  style: TextStyleHelper.instance.label10BoldManrope
                                      .copyWith(color: appTheme.white_A700),
                                ),
                              ),
                              SizedBox(height: 16.h),

                              // Card Content
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Photo
                                  Container(
                                    width: 80.h,
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                      color: appTheme.gray_200,
                                      borderRadius: BorderRadius.circular(4.h),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 50.h,
                                      color: appTheme.gray_600,
                                    ),
                                  ),
                                  SizedBox(width: 16.h),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildDetailRow('Name', 'James Johnson'),
                                        _buildDetailRow('ID No.', '646-25-4060'),
                                        _buildDetailRow('Country', 'United States'),
                                        _buildDetailRow('Issued', 'Dec 2023'),
                                        _buildDetailRow('Expires', 'Nov 2026'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Retake photo logic
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appTheme.deep_orange_100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.h),
                                  ),
                                ),
                                child: Text(
                                  'Reprendre la photo',
                                  style: TextStyleHelper.instance.body12RegularManrope
                                      .copyWith(color: appTheme.white_A700),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.h),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Confirm photo logic
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: appTheme.cyan_900,
                                    width: 2.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.h),
                                  ),
                                ),
                                child: Text(
                                  'Confirmer la photo',
                                  style: TextStyleHelper.instance.body12RegularManrope
                                      .copyWith(color: appTheme.cyan_900),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // Other Document Buttons
                      _buildDocumentButton('CIN Verso'),
                      SizedBox(height: 12.h),
                      _buildDocumentButton('Selfie'),
                      SizedBox(height: 12.h),
                      _buildDocumentButton('Signature Digitale'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      NavigatorService.goBack();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.cyan_900,
                      foregroundColor: appTheme.white_A700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.h),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text(
                      'Précédent',
                      style: TextStyleHelper.instance.title16MediumSyne
                          .copyWith(height: 1.25, color: appTheme.white_A700),
                    ),
                  ),
                ),
                SizedBox(width: 12.h),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.navigateToNextScreen(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.gray_200,
                      foregroundColor: appTheme.gray_600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.h),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text(
                      'Suivant',
                      style: TextStyleHelper.instance.title16MediumSyne
                          .copyWith(height: 1.25, color: appTheme.gray_600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentButton(String title) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          // Document upload logic
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!, width: 1.5),
          backgroundColor: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1B5E78),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}