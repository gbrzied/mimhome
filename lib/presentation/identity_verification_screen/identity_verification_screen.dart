import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/app_export.dart';
import './provider/identity_verification_provider.dart';
import './clean_selfie_page.dart';

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
      context.read<IdentityVerificationProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
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
                            case 'SIGN':
                              displayName = 'Signature';
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
                  onPressed: _getOnPressedHandler(isEnabled, provider, index, imagePath),
                                                      //     onTap: () => provider.togglePreview(index),            provider.togglePreview(index)
                                                      //(imagePath != null && imagePath.isNotEmpty && provider.canPreviewDocument(index))

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

                                // Document Preview
                                if (provider.identityVerificationModel.showPreview?[index] ?? false)
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

  void _showImageSourceDialog(BuildContext context, IdentityVerificationProvider provider, int index) {
    final docCode = provider.identityVerificationModel.docManquants![index];
    
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
                title: const Text('Appareil photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  provider.getImage(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () {
                  Navigator.of(context).pop();
                  provider.getImageFromGallery(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentPreview(BuildContext context, IdentityVerificationProvider provider, int index, String displayName, String imagePath) {
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
                    // Clear current image and reopen camera
                    provider.identityVerificationModel.tituimages?[index] = null;
                    provider.togglePreview(index); // Hide preview
                    provider.getImage(index); // Reopen camera
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.colorF98600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                  ),
                  child: Text(
                    'Reprendre la photo',
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
                    'Confirmer la photo',
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

  VoidCallback? _getOnPressedHandler(
    bool isEnabled,
    IdentityVerificationProvider provider,
    int index,
    String? imagePath,
  ) {
    final docCode = provider.identityVerificationModel.docManquants![index];
    
    if (isEnabled &&
        !provider.identityVerificationModel.isProcessingImage! &&
        imagePath == null) {
      // Use CleanSelfiePage for SELFIE documents (like old app)
      if (docCode == 'SELFIE' || docCode == 'PREUVEIE') {
        return () => _navigateToCleanSelfiePage(context, provider, index);
      }
      // Use regular image picker for other documents
      return () => _showImageSourceDialog(context, provider, index);
    } else if (imagePath != null &&
               imagePath.isNotEmpty &&
               provider.canPreviewDocument(index)) {
      return () => provider.togglePreview(index);
    } else {
      if (isEnabled) {
        // Use CleanSelfiePage for SELFIE documents
        if (docCode == 'SELFIE' || docCode == 'PREUVEIE') {
          return () => _navigateToCleanSelfiePage(context, provider, index);
        }
        return () => _showImageSourceDialog(context, provider, index);
      }
    }
  }

  bool _isDocumentValidated(IdentityVerificationProvider provider, int index) {
    final docType = provider.identityVerificationModel.docManquants?[index];
    if (docType == 'CINR') {
      return provider.cinValidationPassed;
    } else if (docType == 'CINV') {
      return provider.identityVerificationModel.pieceIdVerifiee ?? false;
    } else {
      return provider.identityVerificationModel.tituimages?[index] != null &&
             provider.identityVerificationModel.tituimages![index]!.isNotEmpty;
    }
  }

  void _navigateToCleanSelfiePage(BuildContext context, IdentityVerificationProvider provider, int index) async {
    // Get document code
    final docCode = provider.identityVerificationModel.docManquants![index];
    
    // Set processing state
    provider.identityVerificationModel.isProcessingImage = true;
    provider.identityVerificationModel.processingDocumentIndex = index;
    provider.identityVerificationModel.processingMessage = 'Préparation de la capture de selfie...';
    provider.notifyListeners();

    try {
      // Navigate to CleanSelfiePage (like old app)
      final File? capturedImage = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (context) => CleanSelfiePage(
            title: docCode == 'SELFIE' ? 'Prendre un selfie' : 'Preuve de vie',
            onImageCaptured: (File imageFile) {
              debugPrint('Selfie captured: ${imageFile.path}');
            },
          ),
        ),
      );

      if (capturedImage != null) {
        // Handle the returned image (like old app logic)
        final docCode = provider.identityVerificationModel.docManquants![index];
        
        // Store image path
        if (index < provider.identityVerificationModel.tituimages!.length) {
          provider.identityVerificationModel.tituimages![index] = capturedImage.path;
        } else {
          // Expand array if needed
          while (provider.identityVerificationModel.tituimages!.length <= index) {
            provider.identityVerificationModel.tituimages!.add(null);
          }
          provider.identityVerificationModel.tituimages![index] = capturedImage.path;
        }

        // Enable next document after successful capture (like old app)
        if (index + 1 < provider.identityVerificationModel.docManquants!.length) {
          final nextDoc = provider.identityVerificationModel.docManquants![index + 1];
          if (provider.identityVerificationModel.enableDocButton != null) {
            provider.identityVerificationModel.enableDocButton![nextDoc] = true;
          }
        }

        // For SELFIE and PREUVEIE, mark as validated immediately (like old app)
        provider.identityVerificationModel.processingMessage = 'Selfie capturé avec succès !';
        
        debugPrint('✅ Selfie integrated successfully at index $index: ${capturedImage.path}');
      } else {
        debugPrint('❌ No selfie captured or user cancelled');
        provider.identityVerificationModel.processingMessage = 'Capture annulée';
      }
    } catch (e) {
      debugPrint('❌ Error during selfie capture: $e');
      provider.identityVerificationModel.processingMessage = 'Erreur lors de la capture: $e';
      
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la capture du selfie'),
          backgroundColor: appTheme.colorF98600,
        ),
      );
    } finally {
      // Reset processing state
      provider.identityVerificationModel.isProcessingImage = false;
      provider.identityVerificationModel.processingDocumentIndex = -1;
      provider.notifyListeners();
    }
  }

  void _showSignatureDialog(BuildContext context, IdentityVerificationProvider provider, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Signature'),
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
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (_signatureController.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez signer')));
                  return;
                }
                final bytes = await _signatureController.toPngBytes();
                if (bytes != null) {
                  final dir = await getApplicationDocumentsDirectory();
                  final file = File('${dir.path}/SIGN_$index.png');
                  await file.writeAsBytes(bytes);
                  provider.identityVerificationModel.tituimages?[index] = file.path;
                  
                  // Enable next document
                  if (index + 1 < provider.identityVerificationModel.docManquants!.length) {
                    final nextDoc = provider.identityVerificationModel.docManquants![index + 1];
                    if (provider.identityVerificationModel.enableDocButton != null) {
                      provider.identityVerificationModel.enableDocButton![nextDoc] = true;
                    }
                  }
                  provider.notifyListeners();
                }
                Navigator.of(context).pop();
              },
              child: Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}

