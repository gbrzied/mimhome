import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:millime/enrol/account_type_selection_screen/models/account_type_selection_screen_model.dart';
import 'package:millime/enrol/personal_informations_screen/models/personal_informations_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart';
import 'package:millime/core/build_info.dart';

import '../../../core/app_export.dart';
import '../models/identity_verification_titu_pp_model.dart';

// Constants for document management
const String CODE_NIVEAU_COMPTE = 'NVC';
const String CODE_OPERATION_NOUVELLE_COMPTE = 'NVCOMPTE';

// Document type codes
const String DOC_CINR = 'CINR';
const String DOC_CINV = 'CINV';
const String DOC_PASSPORT = 'PASSPORT';
const String DOC_SELFIE = 'SELFIE';
const String DOC_PREUVE_VIE = 'PREUVEIE';

// Account level and person type constants (to be replaced with dynamic values later)
const String DEFAULT_ACCOUNT_LEVEL = 'Niveau1'; // Niveau1 or Niveau2
const bool DEFAULT_IS_PHYSICAL_PERSON =
    true; // true for physical person, false for legal entity
const bool DEFAULT_SIGNATAIRE_TITULAIRE =
    true; // true if signer and holder are the same person

// Backend server configuration (uses global backendServer from build_info.dart)
const int BACKEND_PORT = 8081;

// Add piece type constants
const String TNCIN = 'TNCIN';
const String TNPASS = 'TNPASS';

class IdentityVerificationProvider extends ChangeNotifier {
  IdentityVerificationModel identityVerificationModel =
      IdentityVerificationModel();

  // Store the CIN entered in PersonalInformationsScreen
  String? enteredCinNumber;

  // Track CIN validation status
  bool cinValidationPassed = false;
  bool signataireEtTitulaire = false;

  // Countdown timer for selfie validation (from old app)
  Timer? _selfieCountdownTimer;
  int _selfieRemainingTime = 0;
  bool _selfieTimerStarted = false;
  static const int SELFIE_COUNTDOWN_DURATION = 5;

  // Countdown timer control methods (from old app logic)
  void startSelfieCountdown() {
    _selfieTimerStarted = true;
    _selfieRemainingTime = SELFIE_COUNTDOWN_DURATION;

    _selfieCountdownTimer?.cancel();
    _selfieCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _selfieRemainingTime--;
      notifyListeners();

      if (_selfieRemainingTime <= 0) {
        timer.cancel();
        _selfieTimerStarted = false;
        notifyListeners();
      }
    });

    debugPrint('✅ Selfie countdown started: $_selfieRemainingTime seconds');
    notifyListeners();
  }

  void stopSelfieCountdown() {
    _selfieCountdownTimer?.cancel();
    _selfieTimerStarted = false;
    _selfieRemainingTime = 0;
    debugPrint('🛑 Selfie countdown stopped');
    notifyListeners();
  }

  void resetSelfieCountdown() {
    _selfieCountdownTimer?.cancel();
    _selfieTimerStarted = false;
    _selfieRemainingTime = 0;
    debugPrint('🔄 Selfie countdown reset');
    notifyListeners();
  }

  // Enhanced document enable logic (from old app lines 600-604)
  bool canEnableSelfieDocument() {
    // Selfie can only be enabled if CIN documents are verified (like old app)
    return (identityVerificationModel.pieceIdVerifiee ?? false) &&
        (cinValidationPassed) &&
        (identityVerificationModel.cinr != null &&
            identityVerificationModel.cinr!.isNotEmpty);
  }

  // Enhanced enable document button logic
  void updateDocumentButtonStates() {
    if (identityVerificationModel.enableDocButton == null) return;

    final docManquants = identityVerificationModel.docManquants ?? [];
    final enableDocButton = identityVerificationModel.enableDocButton!;

    for (var i = 0; i < docManquants.length; i++) {
      final docCode = docManquants[i];

      if (docCode == 'SELFIE' || docCode == 'PREUVEIE') {
        // Apply enhanced logic from old app
        enableDocButton[docCode] = canEnableSelfieDocument();

        // Also update disable flags (like old app)
        if (docCode == 'SELFIE') {
          identityVerificationModel.disableSELFIE = !canEnableSelfieDocument();
        } else if (docCode == 'PREUVEIE') {
          identityVerificationModel.disablePreuveDeVie =
              !canEnableSelfieDocument();
        }
      }
    }

    debugPrint(
      '🔄 Document button states updated: SELFIE enabled=${enableDocButton['SELFIE']}, PREUVEIE enabled=${enableDocButton['PREUVEIE']}',
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _selfieCountdownTimer?.cancel();
    super.dispose();
  }

  void initialize() async {
    // Initialize default values
    identityVerificationModel.showCard = false;

    // Load selected piece type and entered CIN from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPieceType = prefs.getString('selected_piece_type');
    debugPrint(
      'Loaded selected_piece_type from SharedPreferences: $savedPieceType',
    );
    if (savedPieceType != null) {
      identityVerificationModel.selectedPieceType = savedPieceType;
    }

    enteredCinNumber = prefs.getString('entered_id_number') ?? "";
    debugPrint(
      'Loaded entered_id_number from SharedPreferences: $enteredCinNumber',
    );

    // Load required documents
    loadDocuments();

    notifyListeners();
  }

  Future<void> loadDocuments() async {
    try {
      // Set loading state
      identityVerificationModel.isProcessingImage = true;
      identityVerificationModel.processingMessage =
          'Chargement des documents requis...';
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Simulate API call to get required documents based on account level and person type
      // This replaces the hardcoded logic with dynamic loading similar to chargerDocInRequisNvCompte
      String? selectedAccountType = prefs.getString(
        'personal_selected_account_type',
      );
      signataireEtTitulaire =
          selectedAccountType == AccountType.titulaireEtSignataire.toString();
      identityVerificationModel.accountLevel=prefs.getString('niveau_compte_code');
      final documents = await _chargerDocInRequisNvCompte(
        signataireEtTitulaire: signataireEtTitulaire,
        niveau: identityVerificationModel.accountLevel ?? DEFAULT_ACCOUNT_LEVEL,
        pp:
            identityVerificationModel.isPhysicalPerson ??
            DEFAULT_IS_PHYSICAL_PERSON,
      );

      // Store the full document list for filtering
      identityVerificationModel.documentsRequis = documents;
      // String? selectedAccountType = prefs.getString('personal_selected_account_type');
      // if ( selectedAccountType ==AccountType.titulaire.toString() )

      // Update model with loaded documents
      identityVerificationModel.docManquants = documents
          .map((doc) => doc.docInCode ?? '')
          .toList();
      identityVerificationModel.tituimages = List.filled(
        documents.length,
        null,
      );

      // Initialize button states - only first document is enabled
      identityVerificationModel.enableDocButton = {};
      for (var i = 0; i < documents.length; i++) {
        final docCode = documents[i].docInCode ?? '';
        identityVerificationModel.enableDocButton![docCode] =
            (i == 0); // Only first document enabled
      }

      // Reset preview states when documents change
      identityVerificationModel.showPreview = {};

      // Initialize legacy disable flags for backward compatibility
      identityVerificationModel.disableCINR = true;
      identityVerificationModel.disableCINV = true;
      identityVerificationModel.disableSELFIE = true;
      identityVerificationModel.disablePreuveDeVie = true;

      // Update disable flags based on loaded documents
      if (documents.isNotEmpty) {
        identityVerificationModel.disableCINR =
            false; // First document is always enabled
      }
    } catch (e) {
      debugPrint('Error loading documents: $e');
      // Fallback to basic documents if API fails
      identityVerificationModel.docManquants = [
        'CINR',
        'CINV',
        'SELFIE',
        'PREUVEIE',
      ];
      identityVerificationModel.tituimages = List.filled(4, null);
      identityVerificationModel.enableDocButton = {
        'CINR': true,
        'CINV': false,
        'SELFIE': false,
        'PREUVEIE': false,
      };
      identityVerificationModel.disableCINR = false;
      identityVerificationModel.disableCINV = true;
      identityVerificationModel.disableSELFIE = true;
      identityVerificationModel.disablePreuveDeVie = true;

      // Show error message to user
      // Note: We can't show SnackBar here as we don't have BuildContext
      // This will be handled by the UI when it detects the error
    } finally {
      // Reset loading state
      identityVerificationModel.isProcessingImage = false;
      identityVerificationModel.processingMessage = '';
      notifyListeners();
    }
  }

  void toggleCardVisibility() {
    identityVerificationModel.showCard =
        !(identityVerificationModel.showCard ?? false);
    notifyListeners();
  }

  void togglePreview(int index) {
    identityVerificationModel.showPreview ??= <int, bool>{};
    identityVerificationModel.showPreview![index] =
        !(identityVerificationModel.showPreview![index] ?? false);
    notifyListeners();
  }

  Future<bool> getImage(int index) async {
    return await _getImageFromSource(index, ImageSource.camera);
  }

  Future<bool> getImageFromGallery(int index) async {
    return await _getImageFromSource(index, ImageSource.gallery);
  }

  Future<bool> _getImageFromSource(int index, ImageSource source) async {
    try {
      debugPrint(
        'Starting _getImageFromSource for index: $index, source: $source',
      );

      // Request permissions if accessing gallery
      if (source == ImageSource.gallery) {
        // Clear any previous error messages
        identityVerificationModel.backendError = false;
        identityVerificationModel.backendErrorMessage = '';
        notifyListeners();

        // Try photos permission first (iOS and newer Android)
        PermissionStatus status = await Permission.photos.status;
        debugPrint('Gallery permission (photos) status: $status');

        if (!status.isGranted) {
          debugPrint('Requesting photos permission...');
          status = await Permission.photos.request();
          debugPrint('Photos permission after request: $status');
        }

        // If photos permission not available, try storage permission (older Android)
        if (!status.isGranted) {
          debugPrint(
            'Photos permission not granted, trying storage permission...',
          );
          PermissionStatus storageStatus = await Permission.storage.status;
          debugPrint('Storage permission status: $storageStatus');

          if (!storageStatus.isGranted) {
            debugPrint('Requesting storage permission...');
            storageStatus = await Permission.storage.request();
            debugPrint('Storage permission after request: $storageStatus');
            status = storageStatus;
          } else {
            status = storageStatus;
          }
        }

        if (status.isPermanentlyDenied) {
          debugPrint('Gallery permission permanently denied');
          // Show error message with option to open settings
          identityVerificationModel.backendError = true;
          identityVerificationModel.backendErrorMessage =
              'Accès à la galerie refusé. Veuillez autoriser l\'accès aux photos dans les paramètres de l\'application.';
          notifyListeners();
          // Open app settings after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            openAppSettings();
          });
          return false;
        } else if (!status.isGranted) {
          debugPrint('Gallery permission still not granted');
          // Show error message to user
          identityVerificationModel.backendError = true;
          identityVerificationModel.backendErrorMessage =
              'Accès à la galerie refusé. Veuillez autoriser l\'accès aux photos pour continuer.';
          notifyListeners();
          return false;
        }

        debugPrint('Gallery permission granted, proceeding...');
      }

      // Set loading state
      identityVerificationModel.isProcessingImage = true;
      identityVerificationModel.processingDocumentIndex = index;
      identityVerificationModel.processingMessage = source == ImageSource.camera
          ? 'Ouverture de l\'appareil photo...'
          : 'Ouverture de la galerie...';
      notifyListeners();

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) {
        debugPrint('No image picked for index: $index');
        // Reset loading state
        identityVerificationModel.isProcessingImage = false;
        identityVerificationModel.processingDocumentIndex = -1;
        identityVerificationModel.processingMessage = '';
        notifyListeners();
        return false;
      }

      debugPrint(
        'Image picked successfully for index: $index, path: ${pickedFile.path}',
      );

      // Process the captured image
      return await _processCapturedImage(pickedFile, index);
    } catch (e) {
      debugPrint('Error in _getImageFromSource: $e');
      // Reset loading state on error
      identityVerificationModel.isProcessingImage = false;
      identityVerificationModel.processingDocumentIndex = -1;
      identityVerificationModel.processingMessage = '';
      notifyListeners();
      return false;
    }
  }

  Future<bool> _processCapturedImage(XFile pickedFile, int index) async {
    bool validationPassed = false;

    try {
      // Set loading state for cropping
      identityVerificationModel.processingMessage = 'Recadrage de l\'image...';
      notifyListeners();

      // Crop the image
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF1A7B8E),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      if (croppedFile == null) {
        // Reset loading state
        identityVerificationModel.isProcessingImage = false;
        identityVerificationModel.processingDocumentIndex = -1;
        identityVerificationModel.processingMessage = '';
        notifyListeners();
        return false;
      }

      // Store cropped image path with safety checks
      if (identityVerificationModel.tituimages != null &&
          index >= 0 &&
          index < identityVerificationModel.tituimages!.length) {
        identityVerificationModel.tituimages![index] = croppedFile.path;
      } else {
        debugPrint('Warning: Invalid index $index for tituimages array');
        return false;
      }

      // Process based on document type
      final docType = identityVerificationModel.docManquants?[index];
      debugPrint('Processing document type: $docType at index: $index');

      if (docType == 'CINR') {
        identityVerificationModel.processingMessage =
            'Analyse du texte et vérification du document en cours...';
        notifyListeners();
        await _processCINR(croppedFile.path, index);
        // Check if CINR validation passed
        validationPassed = cinValidationPassed;
      } else if (docType == 'CINV') {
        identityVerificationModel.processingMessage =
            'Lecture du code-barres...';
        notifyListeners();
        await _processCINV(croppedFile.path, index);
        // CINV validation passed if pieceIdVerifiee is true
        validationPassed = identityVerificationModel.pieceIdVerifiee ?? false;
      } else if (docType == 'SELFIE' || docType == 'PREUVEIE') {
        // No special processing needed for SELFIE and PREUVEIE
        identityVerificationModel.processingMessage =
            'Traitement de l\'image...';
        notifyListeners();
        // Simulate brief processing for consistency
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('Captured $docType successfully');
        validationPassed = true; // Selfie/PreuveIE always pass
      } else if (docType == 'SIGN') {
        // No special processing needed for SIGN, just mark as valid
        identityVerificationModel.processingMessage =
            'Traitement de la signature...';
        notifyListeners();
        // Simulate brief processing for consistency
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('Captured $docType successfully');
        validationPassed = true; // Signature always passes
      }

      // Only enable next document if current validation passed
      if (validationPassed) {
        final docLength = identityVerificationModel.docManquants?.length ?? 0;
        debugPrint('Document length: $docLength, current index: $index');

        if (index + 1 < docLength) {
          final nextDoc = identityVerificationModel.docManquants![index + 1];
          debugPrint('Enabling next document: $nextDoc');
          if (identityVerificationModel.enableDocButton != null) {
            identityVerificationModel.enableDocButton![nextDoc] = true;
          }
        } else {
          debugPrint('This is the last document, no next document to enable');
        }
      } else {
        debugPrint(
          'Validation failed for $docType, not enabling next document',
        );
      }

      // Reset loading state
      identityVerificationModel.isProcessingImage = false;
      identityVerificationModel.processingDocumentIndex = -1;
      identityVerificationModel.processingMessage = '';
      notifyListeners();
      return validationPassed;
    } catch (e) {
      debugPrint('Error in _processCapturedImage: $e');
      // Reset loading state on error
      identityVerificationModel.isProcessingImage = false;
      identityVerificationModel.processingDocumentIndex = -1;
      identityVerificationModel.processingMessage = '';
      notifyListeners();
      return false;
    }
  }

  Future<void> _processCINR(String imagePath, int index) async {
    try {
      // Mimic old wallet11_page.dart logic with parallel processing
      final TextRecognizer textRecognizer = TextRecognizer();
      final recognizedTextFuture = textRecognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      final logoFlagFuture = checkLogoAndFlag(imagePath);

      // Use Future.wait for parallel processing like old version
      final resultsFuture = Future.wait([recognizedTextFuture]);
      final logoFlagResultFuture = Future.wait([logoFlagFuture]);

      final results = await resultsFuture;
      final logoFlagResults = await logoFlagResultFuture;

      final recognizedText = results[0] as RecognizedText;
      final hasLogoAndFlag = logoFlagResults[0] as bool?;

      // Require BOTH logo/flag detection AND valid CIN text (like old version)
      if ((hasLogoAndFlag ?? false) &&
          recognizedText.blocks.isNotEmpty &&
          recognizedText.text.length >= 8) {
        // Look for 8-digit CIN in text blocks
        for (final block in recognizedText.blocks) {
          if (block.text.length == 8 &&
              RegExp(r'^\d{8}$').hasMatch(block.text)) {
            identityVerificationModel.cinr = block.text;

            // Validate CIN matches entered CIN from PersonalInformationsScreen
            if (enteredCinNumber != null && enteredCinNumber!.isNotEmpty) {
              if (block.text == enteredCinNumber) {
                cinValidationPassed = true;
                identityVerificationModel.disableCINV = false;
                debugPrint(
                  'CIN detected and validated: ${block.text} - matches entered CIN',
                );

                // Update document button states after successful CIN validation (like old app)
                updateDocumentButtonStates();
              } else {
                cinValidationPassed = false;
                identityVerificationModel.disableCINV = true;
                identityVerificationModel.disableSELFIE = true;
                identityVerificationModel.disablePreuveDeVie = true;
                debugPrint(
                  'CIN detected but does not match entered CIN: extracted=${block.text}, entered=${enteredCinNumber}',
                );

                // Disable all subsequent documents in the enableDocButton map
                if (identityVerificationModel.enableDocButton != null) {
                  // Find current document index
                  final currentIndex =
                      identityVerificationModel.docManquants?.indexOf('CINR') ??
                      -1;
                  if (currentIndex >= 0) {
                    // Disable all documents after CINR
                    for (
                      var i = currentIndex + 1;
                      i < (identityVerificationModel.docManquants?.length ?? 0);
                      i++
                    ) {
                      final docCode =
                          identityVerificationModel.docManquants![i];
                      identityVerificationModel.enableDocButton![docCode] =
                          false;
                    }
                  }
                }

                // Show mismatch error
                identityVerificationModel.backendError = true;
                identityVerificationModel.backendErrorMessage =
                    'Le numéro CIN extrait (${block.text}) ne correspond pas au numéro CIN saisi (${enteredCinNumber}). Veuillez vérifier vos informations.';
                notifyListeners();
                return; // Exit early on mismatch
              }
            } else {
              // No entered CIN to compare with, allow if CIN is extracted
              cinValidationPassed = true;
              identityVerificationModel.disableCINV = false;
              debugPrint(
                'CIN detected: ${block.text} - no entered CIN to validate against',
              );
            }
            break;
          }
        }
      } else {
        // Reset CIN state if validation fails
        identityVerificationModel.cinr = '';
        identityVerificationModel.disableCINV = true;
        identityVerificationModel.disableSELFIE = true;
        identityVerificationModel.disablePreuveDeVie = true;
        cinValidationPassed = false;

        // Disable all subsequent documents in the enableDocButton map
        if (identityVerificationModel.enableDocButton != null) {
          // Find current document index
          final currentIndex =
              identityVerificationModel.docManquants?.indexOf('CINR') ?? -1;
          if (currentIndex >= 0) {
            // Disable all documents after CINR
            for (
              var i = currentIndex + 1;
              i < (identityVerificationModel.docManquants?.length ?? 0);
              i++
            ) {
              final docCode = identityVerificationModel.docManquants![i];
              identityVerificationModel.enableDocButton![docCode] = false;
            }
          }
        }

        // Show appropriate error message
        String errorMessage = 'Erreur de validation du document CIN';
        if (hasLogoAndFlag == false) {
          errorMessage =
              'Document non reconnu. Assurez-vous que la carte d\'identité tunisienne est clairement visible.';
        } else if (recognizedText.blocks.isEmpty ||
            recognizedText.text.length < 8) {
          errorMessage =
              'Texte illisible. Réessayez avec une image plus claire.';
        }

        // Set backend error for UI display
        identityVerificationModel.backendError = true;
        identityVerificationModel.backendErrorMessage = errorMessage;
        notifyListeners();
      }

      await textRecognizer.close();
    } catch (e) {
      debugPrint('Error processing CINR: $e');
      // Reset state on error
      identityVerificationModel.cinr = '';
      identityVerificationModel.disableCINV = true;
      identityVerificationModel.backendError = true;
      identityVerificationModel.backendErrorMessage =
          'Erreur lors de l\'analyse du document. Veuillez réessayer.';
      notifyListeners();
    }
  }

  Future<void> _processCINV(String imagePath, int index) async {
    try {
      final BarcodeScanner barcodeScanner = BarcodeScanner();
      final List<Barcode> barcodes = await barcodeScanner.processImage(
        InputImage.fromFilePath(imagePath),
      );

      if (barcodes.isNotEmpty && barcodes.first.displayValue != null) {
        final code = barcodes.first.displayValue!;
        if (code.length >= 8) {
          final cin = code.substring(0, 8);
          if (cin == identityVerificationModel.cinr) {
            identityVerificationModel.disableSELFIE = false;
            identityVerificationModel.disablePreuveDeVie = false;
            identityVerificationModel.pieceIdVerifiee = true;
            debugPrint('CINV barcode matches CINR: $cin');

            // Update document button states after successful CINV validation (like old app)
            updateDocumentButtonStates();
          } else {
            // Barcode doesn't match CINR - disable subsequent documents
            identityVerificationModel.disableSELFIE = true;
            identityVerificationModel.disablePreuveDeVie = true;
            identityVerificationModel.pieceIdVerifiee = false;

            // Disable all subsequent documents in the enableDocButton map
            if (identityVerificationModel.enableDocButton != null) {
              // Find current document index
              final currentIndex =
                  identityVerificationModel.docManquants?.indexOf('CINV') ?? -1;
              if (currentIndex >= 0) {
                // Disable all documents after CINV
                for (
                  var i = currentIndex + 1;
                  i < (identityVerificationModel.docManquants?.length ?? 0);
                  i++
                ) {
                  final docCode = identityVerificationModel.docManquants![i];
                  identityVerificationModel.enableDocButton![docCode] = false;
                }
              }
            }

            // Show mismatch error
            identityVerificationModel.backendError = true;
            identityVerificationModel.backendErrorMessage =
                'Le code-barres du CIN Verso (${cin}) ne correspond pas au numéro CIN Recto (${identityVerificationModel.cinr}). Veuillez vérifier vos documents.';
            notifyListeners();

            debugPrint(
              'CINV barcode mismatch: barcode=$cin, cinr=${identityVerificationModel.cinr}',
            );
          }
        } else {
          // Invalid barcode length - disable subsequent documents
          identityVerificationModel.disableSELFIE = true;
          identityVerificationModel.disablePreuveDeVie = true;
          identityVerificationModel.pieceIdVerifiee = false;

          // Disable all subsequent documents
          if (identityVerificationModel.enableDocButton != null) {
            final currentIndex =
                identityVerificationModel.docManquants?.indexOf('CINV') ?? -1;
            if (currentIndex >= 0) {
              for (
                var i = currentIndex + 1;
                i < (identityVerificationModel.docManquants?.length ?? 0);
                i++
              ) {
                final docCode = identityVerificationModel.docManquants![i];
                identityVerificationModel.enableDocButton![docCode] = false;
              }
            }
          }

          identityVerificationModel.backendError = true;
          identityVerificationModel.backendErrorMessage =
              'Code-barres invalide sur le CIN Verso. Veuillez réessayer avec une image plus claire.';
          notifyListeners();

          debugPrint('Invalid CINV barcode length: $code');
        }
      } else {
        // No barcode found - disable subsequent documents
        identityVerificationModel.disableSELFIE = true;
        identityVerificationModel.disablePreuveDeVie = true;
        identityVerificationModel.pieceIdVerifiee = false;

        // Disable all subsequent documents
        if (identityVerificationModel.enableDocButton != null) {
          final currentIndex =
              identityVerificationModel.docManquants?.indexOf('CINV') ?? -1;
          if (currentIndex >= 0) {
            for (
              var i = currentIndex + 1;
              i < (identityVerificationModel.docManquants?.length ?? 0);
              i++
            ) {
              final docCode = identityVerificationModel.docManquants![i];
              identityVerificationModel.enableDocButton![docCode] = false;
            }
          }
        }

        identityVerificationModel.backendError = true;
        identityVerificationModel.backendErrorMessage =
            'Code-barres non détecté sur le CIN Verso. Veuillez réessayer avec une image plus claire.';
        notifyListeners();

        debugPrint('No barcode found in CINV');
      }

      await barcodeScanner.close();
    } catch (e) {
      debugPrint('Error processing CINV: $e');
      // On error, disable subsequent documents
      identityVerificationModel.disableSELFIE = true;
      identityVerificationModel.disablePreuveDeVie = true;
      identityVerificationModel.pieceIdVerifiee = false;

      if (identityVerificationModel.enableDocButton != null) {
        final currentIndex =
            identityVerificationModel.docManquants?.indexOf('CINV') ?? -1;
        if (currentIndex >= 0) {
          for (
            var i = currentIndex + 1;
            i < (identityVerificationModel.docManquants?.length ?? 0);
            i++
          ) {
            final docCode = identityVerificationModel.docManquants![i];
            identityVerificationModel.enableDocButton![docCode] = false;
          }
        }
      }

      identityVerificationModel.backendError = true;
      identityVerificationModel.backendErrorMessage =
          'Erreur lors de la lecture du code-barres. Veuillez réessayer.';
      notifyListeners();
    }
  }

  // Implementation of chargerDocInRequisNvCompte from login_store.dart
  // This matches the original backend API integration
  Future<List<DocumentRequis>> _chargerDocInRequisNvCompte({
    required bool signataireEtTitulaire,
    required String niveau,
    required bool pp,
  }) async {
    List<dynamic>? docInNivComptes = [];

    try {
      // Use the original backend endpoint from login_store.dart
      final response = await http.get(
        Uri.parse('http://${backendServer}:8081/docInNiveauCompte/'),
      );

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        docInNivComptes = jsonDecode(response.body);

        // Apply the same filtering logic as login_store.dart
        List<dynamic>? filtredDocInNivComptes = [];
        if (signataireEtTitulaire) {
          filtredDocInNivComptes = docInNivComptes
              ?.where(
                (e) =>
                    e['niveauCompte']['niveauCompteDsg'] == niveau &&
                    e['docIn']['docInBoolLignePpTituSign'] != 'N' &&
                    e['operation']['operationCode'] ==
                        CODE_OPERATION_NOUVELLE_COMPTE,
              )
              .toList();
        } else if (!pp) {
          filtredDocInNivComptes = docInNivComptes
              ?.where(
                (e) =>
                    e['niveauCompte']['niveauCompteDsg'] == niveau &&
                    e['docIn']['docInBoolLignePmTitu'] != 'N' &&
                    e['operation']['operationCode'] ==
                        CODE_OPERATION_NOUVELLE_COMPTE,
              )
              .toList();
        } else {
          filtredDocInNivComptes = docInNivComptes
              ?.where(
                (e) =>
                    e['niveauCompte']['niveauCompteDsg'] == niveau &&
                    e['docIn']['docInBoolLignePpTituOnly'] != 'N' &&
                    e['operation']['operationCode'] ==
                        CODE_OPERATION_NOUVELLE_COMPTE,
              )
              .toList();
        }

        debugPrint(
          'filtredDocInNivComptes: ${filtredDocInNivComptes?.map((e) => e['docIn']['docInCode']).toList()}',
        );

        // Convert to DocumentRequis format and filter out SIGN documents
        List<DocumentRequis> docsRequis = filtredDocInNivComptes!
            .map((e) => DocumentRequis.fromJson(e['docIn']))
            .toList();
        // docsRequis.removeWhere((e) => e.docInCode == 'SIGN');
        debugPrint(
          'docsRequis before sorting: ${docsRequis.map((d) => '${d.docInCode}: pieceIdentite=${d.pieceIdentite?.pieceIdentiteCode}').toList()}',
        );
        //  docsRequis.sort((a, b) {
        //        if (a.docInCode == 'SIGN' && b.docInCode != 'SIGN') return 1;
        //        if (a.docInCode != 'SIGN' && b.docInCode == 'SIGN') return -1;
        //        return 0; // Keep original order for others
        //   });
        docsRequis.sort((a, b) {
          if (a.pieceIdentite != null && b.pieceIdentite == null) return -1;
          if (a.pieceIdentite == null && b.pieceIdentite != null) return 1;

          if (a.docInCode == 'SIGN' && b.docInCode != 'SIGN') return 1;
          if (a.docInCode != 'SIGN' && b.docInCode == 'SIGN') return -1;

          return 0; // keep original order for others
        });
        debugPrint(
          'docsRequis after sorting: ${docsRequis.map((d) => d.docInCode).toList()}',
        );

        debugPrint(
          'Loaded ${docsRequis.length} documents from backend before piece type filtering',
        );
        debugPrint(
          'Selected piece type: ${identityVerificationModel.selectedPieceType}',
        );
        debugPrint(
          'Documents before filtering: ${docsRequis.map((d) => '${d.docInCode}: pieceIdentite=${d.pieceIdentite?.pieceIdentiteCode}, boolTypePieceIdent=${d.docInBoolTypePieceIdent}').toList()}',
        );

        // Apply piece type filtering if a piece type is selected
        if (identityVerificationModel.selectedPieceType != null) {
          docsRequis = _applyPieceTypeFilter(
            docsRequis,
            identityVerificationModel.selectedPieceType!,
          );
        }

        debugPrint(
          'Loaded ${docsRequis.length} documents from backend (after piece type filtering)',
        );
        debugPrint(
          'Documents after filtering: ${docsRequis.map((d) => d.docInCode).toList()}',
        );
        return docsRequis;
      } else {
        debugPrint(
          'Backend returned status ${response.statusCode} with no content',
        );
        throw Exception('Backend returned status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error calling backend API: $e');
      // Set backend error flag for UI notification
      identityVerificationModel.backendError = true;
      identityVerificationModel.backendErrorMessage =
          'Impossible de contacter le serveur. Utilisation des documents par défaut.';
      // Return default documents based on business rules when backend is unavailable
      return _getDefaultDocuments(signataireEtTitulaire, niveau, pp);
    }
  }

  // Default document logic based on business rules from login_store.dart
  List<DocumentRequis> _getDefaultDocuments(
    bool signataireEtTitulaire,
    String niveau,
    bool pp,
  ) {
    // Match the original fallback logic from login_store.dart
    // which returns ['CINR', 'CINV', 'SELFIE'] for physical persons

    final documents = <DocumentRequis>[];

    // For physical persons (pp = true), return the standard documents
    if (pp) {
      documents.add(
        DocumentRequis(
          docInCode: DOC_CINR,
          docInLibelle: 'Carte d\'Identité Nationale Recto',
          obligatoire: true,
        ),
      );

      documents.add(
        DocumentRequis(
          docInCode: DOC_CINV,
          docInLibelle: 'Carte d\'Identité Nationale Verso',
          obligatoire: true,
        ),
      );

      documents.add(
        DocumentRequis(
          docInCode: DOC_SELFIE,
          docInLibelle: 'Selfie',
          obligatoire: true,
        ),
      );
    } else {
      // For legal entities, return passport and selfie
      documents.add(
        DocumentRequis(
          docInCode: DOC_PASSPORT,
          docInLibelle: 'Passeport',
          obligatoire: true,
        ),
      );

      documents.add(
        DocumentRequis(
          docInCode: DOC_SELFIE,
          docInLibelle: 'Selfie',
          obligatoire: true,
        ),
      );
    }

    debugPrint(
      'Using default documents: ${documents.map((d) => d.docInCode).toList()}',
    );
    return documents;
  }

  // Apply piece type filtering logic from the old version
  // Only show SIGN, SELFIE and documents that match the selected piece type
  List<DocumentRequis> _applyPieceTypeFilter(
    List<DocumentRequis> documents,
    String selectedPieceType,
  ) {
    debugPrint(
      '_applyPieceTypeFilter input: ${documents.map((d) => '${d.docInCode}: pieceIdentite=${d.pieceIdentite?.pieceIdentiteCode}, boolType=${d.docInBoolTypePieceIdent}').toList()}',
    );
    final filtered = documents
        .where(
          (doc) =>
              doc != null &&
              (doc.docInCode == 'SIGN' || doc.docInCode == 'SELFIE' ||   doc.pieceIdentite == null ||
                  (doc.pieceIdentite != null &&
                      doc.pieceIdentite?.pieceIdentiteCode ==
                          selectedPieceType)),
        )
        .toList();
    debugPrint(
      '_applyPieceTypeFilter output: ${filtered.map((d) => d.docInCode).toList()}',
    );
    return filtered;
  }

  // Get available piece types from documents
  List<String> getAvailablePieceTypes() {
    if (identityVerificationModel.documentsRequis == null) return [];

    final pieceTypes = <String>{};
    for (final doc in identityVerificationModel.documentsRequis!) {
      if (doc.docInBoolTypePieceIdent == 'O' && doc.pieceIdentite != null) {
        pieceTypes.add(doc.pieceIdentite!.pieceIdentiteCode!);
      }
    }
    return pieceTypes.toList();
  }

  // Check if piece type selection is needed
  bool get requiresPieceTypeSelection {
    return identityVerificationModel.documentsRequis?.any(
          (doc) =>
              doc.docInBoolTypePieceIdent == 'O' && doc.pieceIdentite != null,
        ) ??
        false;
  }

  bool get allDocumentsCaptured {
    bool allImagesCaptured =
        identityVerificationModel.tituimages?.every((image) => image != null) ??
        false;

    // For CIN documents, also require CIN validation to pass
    if (identityVerificationModel.docManquants?.contains('CINR') ?? false) {
      return allImagesCaptured && cinValidationPassed;
    }

    return allImagesCaptured;
  }

  // Check if a document at given index can be previewed (captured and validated)
  bool canPreviewDocument(int index) {
    // Must have an image
    if (identityVerificationModel.tituimages == null ||
        index >= identityVerificationModel.tituimages!.length ||
        identityVerificationModel.tituimages![index] == null ||
        identityVerificationModel.tituimages![index]!.isEmpty) {
      return false;
    }

    // Check document type and validation status
    final docType = identityVerificationModel.docManquants?[index];
    if (docType == 'CINR') {
      // CINR requires validation to pass
      return cinValidationPassed;
    } else if (docType == 'CINV') {
      // CINV requires pieceIdVerifiee to be true
      return identityVerificationModel.pieceIdVerifiee ?? false;
    } else {
      // Selfie and PreuveIE can always be previewed once captured
      return true;
    }
  }

  void navigateToNextScreen(BuildContext context) async {
    if (allDocumentsCaptured) {
      // Use DocumentManager to store documents with their codes
      if (identityVerificationModel.docManquants != null &&
          identityVerificationModel.tituimages != null) {
        await DocumentManager.storeDocumentsWithCodes(
          identityVerificationModel.tituimages!,
          identityVerificationModel.docManquants!,
          prefix:
              'titu', // Use 'titu' prefix to separate from mandataire documents
        );
      }

      // Save other identity verification data to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'identity_cinr',
        identityVerificationModel.cinr ?? '',
      );
      await prefs.setBool(
        'identity_piece_id_verifiee',
        identityVerificationModel.pieceIdVerifiee ?? false,
      );
      await prefs.setString(
        'identity_selected_piece_type',
        identityVerificationModel.selectedPieceType ?? '',
      );

      String? selectedAccountType = prefs.getString(
        'personal_selected_account_type',
      );

      if (selectedAccountType == AccountType.titulaireEtSignataire.toString()) {
        NavigatorService.pushNamed(AppRoutes.accountRecoveryScreen);
      } else if (selectedAccountType == AccountType.titulaire.toString()) {
        NavigatorService.pushNamed(AppRoutes.personalInformationsMandScreen);
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez capturer tous les documents requis'),
        ),
      );
    }
  }

  // Add document filtering method based on selected piece type
  // This implements the same logic as wallet11_page.dart lines 1278-1289
  void filterDocumentsByPieceType(String? selectedValueTypePiece) {
    if (selectedValueTypePiece == null ||
        identityVerificationModel.documentsRequis == null) {
      return;
    }

    // Filter documents based on the selected piece type
    // This matches the logic from wallet11_page.dart:
    // docss = docssALL?.where((doc) =>
    //     doc != null &&
    //     ((doc.docInBoolTypePieceIdent == 'O' &&
    //         doc.pieceIdentite != null &&
    //         doc.pieceIdentite?.pieceIdentiteCode == selectedValueTypePiece) ||
    //     doc.pieceIdentite == null))
    // .toList();

    final filteredDocs = identityVerificationModel.documentsRequis!
        .where(
          (doc) =>
              doc != null &&
              ((doc.docInBoolTypePieceIdent == 'O' &&
                      doc.pieceIdentite != null &&
                      doc.pieceIdentite?.pieceIdentiteCode ==
                          selectedValueTypePiece) ||
                  doc.pieceIdentite == null),
        )
        .toList();

    // Update the model with filtered documents
    identityVerificationModel.documentsRequis = filteredDocs;
    identityVerificationModel.docManquants = filteredDocs
        .map((doc) => doc.docInCode ?? '')
        .toList();

    // Reset image capture state for filtered documents
    identityVerificationModel.tituimages = List.filled(
      filteredDocs.length,
      null,
    );

    // Reset button states - only first document is enabled
    identityVerificationModel.enableDocButton = {};
    for (var i = 0; i < filteredDocs.length; i++) {
      final docCode = filteredDocs[i].docInCode ?? '';
      identityVerificationModel.enableDocButton![docCode] =
          (i == 0); // Only first document enabled
    }

    // Reset disable flags
    identityVerificationModel.disableCINR = filteredDocs.length > 0;
    identityVerificationModel.disableCINV = true;
    identityVerificationModel.disableSELFIE = true;
    identityVerificationModel.disablePreuveDeVie = true;

    notifyListeners();
  }

  // Mimic checkLogoAndFlag from old wallet11_page.dart login_store.dart
  Future<bool?> checkLogoAndFlag(String imagePath) async {
    try {
      var url = Uri.parse("http://${backendServer}:5000/");

      var request = http.MultipartRequest('POST', url);

      request.files.add(
        await http.MultipartFile.fromPath(
          'sampleImage',
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      request.headers.addEntries(
        <String, String>{'enctype': 'multipart/form-data'}.entries,
      );

      var sendRequest = await request.send();
      var response = await http.Response.fromStream(sendRequest);
      final responseData = json.decode(response.body);

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        var scannedObj = jsonDecode(response.body);
        if (scannedObj.length == 2) {
          return true; // Logo and flag detected
        }
      } else if (response.statusCode >= 400) {
        return Future.error('error on scanning flag and logo');
      }
      return false; // Not detected
    } catch (e) {
      debugPrint('Error in checkLogoAndFlag: $e');
      return null; // Service unavailable, allow manual validation
    }
  }
}
