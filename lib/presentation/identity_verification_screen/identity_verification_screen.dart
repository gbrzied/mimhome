import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import './provider/identity_verification_provider.dart';

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
        // Show backend error message if any
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.identityVerificationModel.backendError == true &&
              provider.identityVerificationModel.backendErrorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.identityVerificationModel.backendErrorMessage!),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    // Clear the error after user acknowledges it
                    provider.identityVerificationModel.backendError = false;
                    provider.identityVerificationModel.backendErrorMessage = '';
                    provider.notifyListeners();
                  },
                ),
              ),
            );
          }
        });

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
                  valueColor: AlwaysStoppedAnimation<Color>(appTheme.primaryColor),
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

                      // Dynamic Document List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.identityVerificationModel.docManquants?.length ?? 0,
                        itemBuilder: (context, index) {
                          final docCode = provider.identityVerificationModel.docManquants![index];
                          final isEnabled = provider.identityVerificationModel.enableDocButton?[docCode] ?? false;
                          final imagePath = provider.identityVerificationModel.tituimages?[index];

                          String displayName;
                          switch (docCode) {
                            case 'CINR':
                              displayName = 'CIN Recto';
                              break;
                            case 'CINV':
                              displayName = 'CIN Verso';
                              break;
                            case 'SELFIE':
                              displayName = 'Selfie';
                              break;
                            case 'PREUVEIE':
                              displayName = 'Preuve de vie';
                              break;
                            default:
                              displayName = docCode;
                          }

                          final isProcessingThisDocument = provider.identityVerificationModel.isProcessingImage == true &&
                              provider.identityVerificationModel.processingDocumentIndex == index;

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Document Button
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: (isEnabled && !provider.identityVerificationModel.isProcessingImage!) ? () => provider.getImage(index) : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isEnabled && !provider.identityVerificationModel.isProcessingImage! ? appTheme.primaryColor : appTheme.gray_300,
                                          foregroundColor: appTheme.white_A700,
                                          minimumSize: Size(double.infinity, 48.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.h),
                                          ),
                                        ),
                                        child: isProcessingThisDocument
                                            ? Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 20.h,
                                                    height: 20.h,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(appTheme.white_A700),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.h),
                                                  Text(
                                                    'Traitement...',
                                                    style: TextStyleHelper.instance.title16MediumSyne
                                                        .copyWith(height: 1.25, color: appTheme.white_A700),
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                displayName,
                                                style: TextStyleHelper.instance.title16MediumSyne
                                                    .copyWith(height: 1.25, color: appTheme.white_A700),
                                              ),
                                      ),
                                    ),
                                    SizedBox(width: 12.h),

                                    // Image Preview
                                    if (imagePath != null && imagePath.isNotEmpty)
                                      Container(
                                        width: 50.h,
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.h),
                                          image: DecorationImage(
                                            image: FileImage(File(imagePath)),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 50.h,
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          color: appTheme.gray_200,
                                          borderRadius: BorderRadius.circular(8.h),
                                        ),
                                        child: Icon(
                                          Icons.image,
                                          color: appTheme.gray_600,
                                          size: 24.h,
                                        ),
                                      ),
                                  ],
                                ),

                                // Processing Message
                                if (isProcessingThisDocument && provider.identityVerificationModel.processingMessage!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: Text(
                                      provider.identityVerificationModel.processingMessage!,
                                      style: TextStyleHelper.instance.body12RegularManrope
                                          .copyWith(height: 1.5, color: appTheme.primaryColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
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
                      backgroundColor: appTheme.primaryColor,
                      foregroundColor: appTheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.h),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text(
                      'Précédent',
                      style: TextStyleHelper.instance.title16MediumSyne
                          .copyWith(height: 1.25, color: appTheme.onPrimary),
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
                      backgroundColor: provider.allDocumentsCaptured ? appTheme.primaryColor : appTheme.gray_200,
                      foregroundColor: provider.allDocumentsCaptured ? appTheme.onPrimary : appTheme.gray_600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.h),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text(
                      'Suivant',
                      style: TextStyleHelper.instance.title16MediumSyne
                          .copyWith(height: 1.25, color: provider.allDocumentsCaptured ? appTheme.onPrimary : appTheme.gray_600),
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


}