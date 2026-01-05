import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/app_export.dart';
import '../../localizationMillime/localization/app_localization.dart';
import 'provider/identity_verification_pm_provider.dart';

class IdentityVerificationPmScreen extends StatefulWidget {
  const IdentityVerificationPmScreen({super.key});

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<IdentityVerificationPmProvider>(
      create: (context) => IdentityVerificationPmProvider(),
      child: const IdentityVerificationPmScreen(),
    );
  }

  @override
  State<IdentityVerificationPmScreen> createState() => _IdentityVerificationPmScreenState();
}

class _IdentityVerificationPmScreenState extends State<IdentityVerificationPmScreen> {
  late SignatureController _signatureController;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: appTheme.primaryColor,
      exportBackgroundColor: Colors.transparent,
      exportPenColor: appTheme.primaryColor,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IdentityVerificationPmProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IdentityVerificationPmProvider>(
      builder: (context, provider, child) {
        // Show backend error message if any
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.identityVerificationPmModel.backendError == true &&
              provider.identityVerificationPmModel.backendErrorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.identityVerificationPmModel.backendErrorMessage!),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: "key_ok".tr,
                  textColor: Colors.white,
                  onPressed: () {
                    // Clear the error after user acknowledges it
                    provider.identityVerificationPmModel.backendError = false;
                    provider.identityVerificationPmModel.backendErrorMessage = '';
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
            totalSteps: 7,
            onBackPressed: () => NavigatorService.goBack(),
          ),
          body: Column(
            children: [
              // Progress Bar
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 16.h),
              //   child: LinearProgressIndicator(
              //     value: 0.8,
              //     backgroundColor: appTheme.gray_200,
              //     valueColor: AlwaysStoppedAnimation<Color>(appTheme.primaryColor),
              //     minHeight: 6.h,
              //   ),
              // ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        "key_identity_verification_pm".tr,
                        style: TextStyleHelper.instance.title18SemiBoldQuicksand
                            .copyWith(height: 1.28),
                      ),
                      SizedBox(height: 12.h),

                      // Description
                      Text(
                        "key_identity_verification_pm_description".tr,
                        style: TextStyleHelper.instance.body12RegularManrope
                            .copyWith(height: 1.5, color: appTheme.gray_600),
                      ),
                      SizedBox(height: 24.h),


                      // Dynamic Document List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.identityVerificationPmModel.docPmManquants?.length ?? 0,
                        itemBuilder: (context, index) {
                          final docCode = provider.identityVerificationPmModel.docPmManquants![index];
                          final isEnabled = provider.identityVerificationPmModel.enableDocButton?[docCode] ?? false;
                          final imagePath = provider.identityVerificationPmModel.tituPmimages?[index];

                          String displayName;
                          switch (docCode) {
                            case 'CINR':
                              displayName = "key_cin_recto".tr;
                              break;
                            case 'CINV':
                              displayName = "key_cin_verso".tr;
                              break;
                            case 'SELFIE':
                              displayName = "key_selfie".tr;
                              break;
                            case 'PREUVEIE':
                              displayName = "key_proof_of_life".tr;
                              break;
                            case 'SIGN':
                              displayName = "key_signature".tr;
                              break;
                            default:
                              displayName = docCode;
                          }

                          final isProcessingThisDocument = provider.identityVerificationPmModel.isProcessingImage == true &&
                              provider.identityVerificationPmModel.processingDocumentIndex == index;

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Document Button
                                    Expanded(
                                      child: ElevatedButton(
                  onPressed: _getOnPressedHandler(isEnabled, provider, index, imagePath),
                                                      //     onTap: () => provider.togglePreview(index),            provider.togglePreview(index)
                                                      //(imagePath != null && imagePath.isNotEmpty && provider.canPreviewDocument(index))

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isEnabled && !provider.identityVerificationPmModel.isProcessingImage! ? appTheme.primaryColor : appTheme.gray_300,
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
                                                Expanded(
                                                  child: Text(
                                                    displayName,
                                                    style: TextStyleHelper.instance.title16MediumSyne
                                                        .copyWith(height: 1.25, color: appTheme.white_A700),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            )
                                            : _isDocumentValidated(provider, index)
                                                ? Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        width: 24.h,
                                                        child: Icon(
                                                          Icons.check_circle,
                                                          color: appTheme.white_A700,
                                                          size: 20.h,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8.h),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 8.h),
                                                          child: Text(
                                                            displayName,
                                                            style: TextStyleHelper.instance.title16MediumSyne
                                                                .copyWith(height: 1.25, color: appTheme.white_A700),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      SizedBox(width: 24.h),
                                                      SizedBox(width: 8.h),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 8.h),
                                                          child: Text(
                                                            displayName,
                                                            style: TextStyleHelper.instance.title16MediumSyne
                                                                .copyWith(height: 1.25, color: appTheme.white_A700),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                      ),
                                    ),
                                    // SizedBox(width: 12.h),

                                    // // Image Preview
                                    // if (imagePath != null && imagePath.isNotEmpty && provider.canPreviewDocument(index))
                                    //   GestureDetector(
                                    //     onTap: () => provider.togglePreview(index),
                                    //     child: Container(
                                    //       width: 50.h,
                                    //       height: 50.h,
                                    //       decoration: BoxDecoration(
                                    //         borderRadius: BorderRadius.circular(8.h),
                                    //         image: DecorationImage(
                                    //           image: FileImage(File(imagePath)),
                                    //           fit: BoxFit.cover,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   )
                                    // else
                                    //   Container(
                                    //     width: 50.h,
                                    //     height: 50.h,
                                    //     decoration: BoxDecoration(
                                    //       color: appTheme.gray_200,
                                    //       borderRadius: BorderRadius.circular(8.h),
                                    //     ),
                                    //     child: Icon(
                                    //       Icons.image,
                                    //       color: appTheme.gray_600,
                                    //       size: 24.h,
                                    //     ),
                                    //   ),
                                  ],
                                ),

                                // Processing Message
                                if (isProcessingThisDocument && provider.identityVerificationPmModel.processingMessage!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: Text(
                                      provider.identityVerificationPmModel.processingMessage!,
                                      style: TextStyleHelper.instance.body12RegularManrope
                                          .copyWith(height: 1.5, color: appTheme.primaryColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                // Document Preview
                                if (provider.identityVerificationPmModel.showPreview?[index] ?? false)
                                  _buildDocumentPreview(context, provider, index, displayName, imagePath!),
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
                      "key_precedent".tr,
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
                      "key_suivant".tr,
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

  void _showImageSourceDialog(BuildContext context, IdentityVerificationPmProvider provider, int index) {
    final docCode = provider.identityVerificationPmModel.docPmManquants![index];
    
    if (docCode == 'SIGN') {
      _showSignatureDialog(context, provider, index);
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text("key_camera".tr),
                onTap: () {
                  Navigator.of(context).pop();
                  provider.getImage(index, context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text("key_gallery".tr),
                onTap: () {
                  Navigator.of(context).pop();
                  provider.getImageFromGallery(index, context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentPreview(BuildContext context, IdentityVerificationPmProvider provider, int index, String displayName, String imagePath) {

                              final docCode = provider.identityVerificationPmModel.docPmManquants![index];
                          final isEnabled = provider.identityVerificationPmModel.enableDocButton?[docCode] ?? false;

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        border: Border.all(
          color: appTheme.gray_300,
          width: 1.h,
        ),
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Column(
        children: [
          // Document Name
          // Text(
          //   displayName,
          //   style: TextStyleHelper.instance.title16MediumSyne
          //       .copyWith(height: 1.25, color: appTheme.primaryColor),
          // ),
        //  SizedBox(height: 16.h),

          // Full-size Image with Zoom
          Container(
            constraints: BoxConstraints(
              maxHeight: 300.h,
              maxWidth: double.infinity,
            ),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200.h,
                    color: appTheme.gray_200,
                    child: Center(
                      child: Icon(
                        Icons.error,
                        color: appTheme.gray_600,
                        size: 50.h,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  
                  onPressed: () {
                    _handleRetakePhoto(context, provider, index);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.colorF98600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                  ),
                  child: Text(
                    "key_retake_photo".tr,
                    style: TextStyleHelper.instance.body12RegularManrope
                        .copyWith(color: appTheme.white_A700),
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              SizedBox(width: 12.h),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Mark as confirmed and hide preview
                    provider.togglePreview(index);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCFFCF9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                  ),
                  child: Text(
                    "key_confirm_photo".tr,
                    style: TextStyleHelper.instance.body12RegularManrope
                        .copyWith(color: Colors.black),
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleRetakePhoto(BuildContext context, IdentityVerificationPmProvider provider, int index) async {
    final docCode = provider.identityVerificationPmModel.docPmManquants![index];
    
    try {


                                final docCode = provider.identityVerificationPmModel.docPmManquants![index];
                          final isEnabled = provider.identityVerificationPmModel.enableDocButton?[docCode] ?? false;
                          final imagePath = provider.identityVerificationPmModel.tituPmimages?[index];
      // Clear current image
      provider.identityVerificationPmModel.tituPmimages?[index] = null;
      
      // Reset validation states for the document being retaken
      _resetDocumentValidation(provider, index);
      
      // Hide preview
      provider.togglePreview(index);
      

       _getOnPressedHandler(isEnabled, provider, index, imagePath);

      
      debugPrint('✅ Retake photo completed for document: $docCode at index: $index');
    } catch (e) {
      debugPrint('❌ Error during retake photo: $e');
      
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("key_capture_error".tr),
          backgroundColor: appTheme.colorF98600,
        ),
      );
    }
  }

  void _resetDocumentValidation(IdentityVerificationPmProvider provider, int index) {
    final docCode = provider.identityVerificationPmModel.docPmManquants![index];
    
    // Reset validation states based on document type
    switch (docCode) {
      case 'CINR':
        provider.cinValidationPassed = false;
        provider.identityVerificationPmModel.cinr = null;
        provider.identityVerificationPmModel.disableCINV = true;
        provider.identityVerificationPmModel.disableSELFIE = true;
        provider.identityVerificationPmModel.disablePreuveDeVie = true;
        
        // Disable all subsequent documents
        if (index + 1 < (provider.identityVerificationPmModel.docPmManquants?.length ?? 0)) {
          for (var i = index + 1; i < provider.identityVerificationPmModel.docPmManquants!.length; i++) {
            final subsequentDoc = provider.identityVerificationPmModel.docPmManquants![i];
            if (provider.identityVerificationPmModel.enableDocButton != null) {
              provider.identityVerificationPmModel.enableDocButton![subsequentDoc] = false;
            }
          }
        }
        break;
        
      case 'CINV':
        provider.identityVerificationPmModel.pieceIdVerifiee = false;
        provider.identityVerificationPmModel.disableSELFIE = true;
        provider.identityVerificationPmModel.disablePreuveDeVie = true;
        
        // Disable all subsequent documents
        if (index + 1 < (provider.identityVerificationPmModel.docPmManquants?.length ?? 0)) {
          for (var i = index + 1; i < provider.identityVerificationPmModel.docPmManquants!.length; i++) {
            final subsequentDoc = provider.identityVerificationPmModel.docPmManquants![i];
            if (provider.identityVerificationPmModel.enableDocButton != null) {
              provider.identityVerificationPmModel.enableDocButton![subsequentDoc] = false;
            }
          }
        }
        break;
        
      case 'SELFIE':
      case 'PREUVEIE':
      case 'SIGN':
        // No special validation to reset for these document types
        break;
    }
    
    // Update document button states
    provider.updateDocumentButtonStates();
    provider.notifyListeners();
  }

  VoidCallback? _getOnPressedHandler(
    bool isEnabled,
    IdentityVerificationPmProvider provider,
    int index,
    String? imagePath,
  ) {
    final docCode = provider.identityVerificationPmModel.docPmManquants![index];
    
    if (isEnabled &&
        !provider.identityVerificationPmModel.isProcessingImage! &&
        imagePath == null) {

      // Use regular image picker for other documents
      return () => _showImageSourceDialog(context, provider, index);
    } else if (imagePath != null &&
               imagePath.isNotEmpty &&
               provider.canPreviewDocument(index)) {
      return () => provider.togglePreview(index);
    } else {
      if (isEnabled) {

        return () => _showImageSourceDialog(context, provider, index);
      }
    }
  }

  bool _isDocumentValidated(IdentityVerificationPmProvider provider, int index) {
    final docType = provider.identityVerificationPmModel.docPmManquants?[index];
    if (docType == 'CINR') {
      return provider.cinValidationPassed;
    } else if (docType == 'CINV') {
      return provider.identityVerificationPmModel.pieceIdVerifiee ?? false;
    } else {
      return provider.identityVerificationPmModel.tituPmimages?[index] != null &&
             provider.identityVerificationPmModel.tituPmimages![index]!.isNotEmpty;
    }
  }


  void _showSignatureDialog(BuildContext context, IdentityVerificationPmProvider provider, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("key_signature".tr),
          content: Container(
            height: 300,
            child: Column(
              children: [
                Expanded(
                  child: Signature(
                    controller: _signatureController,
                    height: 200,
                    width: double.infinity,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.undo),
                      onPressed: () => _signatureController.undo(),
                    ),
                    IconButton(
                      icon: Icon(Icons.redo),
                      onPressed: () => _signatureController.redo(),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => _signatureController.clear(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("key_cancel".tr),
            ),
            TextButton(
              onPressed: () async {
                if (_signatureController.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("key_please_sign".tr)));
                  return;
                }
                final bytes = await _signatureController.toPngBytes();
                if (bytes != null) {
                  final dir = await getApplicationDocumentsDirectory();
                  final file = File('${dir.path}/SIGN_$index.png');
                  await file.writeAsBytes(bytes);
                  provider.identityVerificationPmModel.tituPmimages?[index] = file.path;
                  
                  // Enable next document
                  if (index + 1 < provider.identityVerificationPmModel.docPmManquants!.length) {
                    final nextDoc = provider.identityVerificationPmModel.docPmManquants![index + 1];
                    if (provider.identityVerificationPmModel.enableDocButton != null) {
                      provider.identityVerificationPmModel.enableDocButton![nextDoc] = true;
                    }
                  }
                  provider.notifyListeners();
                }
                Navigator.of(context).pop();
              },
              child: Text("key_confirm".tr),
            ),
          ],
        );
      },
    );
  }
}

