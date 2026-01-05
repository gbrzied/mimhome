import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:millime/core/utils/functions.dart';
import 'package:millime/presentation/account_type_selection_screen/models/account_type_selection_screen_model.dart';
import 'package:millime/presentation/personal_informations_screen/models/personal_informations_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart';
import 'package:millime/core/build_info.dart';

import '../../../core/app_export.dart';
import '../../../core/utils/document_manager.dart';
import '../models/identity_verification_mand_model.dart';

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

// Backend server configuration (to be moved to environment config)
const String BACKEND_SERVER = '${backendServer}'; // Default backend server
const int BACKEND_PORT = 8081;

// Add piece type constants
const String TNCIN = 'TNCIN';
const String TNPASS = 'TNPASS';

class IdentityVerificationMandProvider extends ChangeNotifier {
  IdentityVerificationMandModel identityVerificationMandModel =
      IdentityVerificationMandModel();

  // Store the CIN entered in PersonalInformationsScreen
  String? enteredCinNumber;

  // Track CIN validation status
  bool cinValidationPassed = false;

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
    return (identityVerificationMandModel.pieceIdVerifiee ?? false) &&
        (cinValidationPassed) &&
        (identityVerificationMandModel.cinr != null &&
            identityVerificationMandModel.cinr!.isNotEmpty);
  }

  // Enhanced enable document button logic
  void updateDocumentButtonStates() {
    if (identityVerificationMandModel.enableDocButton == null) return;

    final docManquants = identityVerificationMandModel.docManquants ?? [];
    final enableDocButton = identityVerificationMandModel.enableDocButton!;

    for (var i = 0; i < docManquants.length; i++) {
      final docCode = docManquants[i];

      // if (docCode == 'SELFIE' || docCode == 'PREUVEIE') {
      //   // Apply enhanced logic from old app
      //   enableDocButton[docCode] = canEnableSelfieDocument();

      //   // Also update disable flags (like old app)
      //   if (docCode == 'SELFIE') {
      //     identityVerificationMandModel.disableSELFIE = !canEnableSelfieDocument();
      //   } else if (docCode == 'PREUVEIE') {
      //     identityVerificationMandModel.disablePreuveDeVie = !canEnableSelfieDocument();
      //   }
      // }
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

  late bool mandExist;
  late SharedPreferences prefs ;
  void initialize() async {
    // Initialize default values
    identityVerificationMandModel.showCard = false;

    // Load selected piece type and entered CIN from SharedPreferences
    prefs = await SharedPreferences.getInstance();
    String? personalMandTypePiece = prefs.getString('personal_mand_type_piece');
    debugPrint(
      'Loaded selected_piece_type from SharedPreferences: $personalMandTypePiece',
    );
    if (personalMandTypePiece != null) {
      identityVerificationMandModel.selectedPieceType = personalMandTypePiece;
    }

    enteredCinNumber = prefs.getString('personal_mand_numero_piece') ?? "";
    debugPrint(
      'Loaded entered_id_number from SharedPreferences: $enteredCinNumber',
    );
    mandExist = prefs.getBool('personne_mand_exist') ?? false;

    // Load required documents
    await loadDocuments();

    if (mandExist) {
      await loadDocsOfPpMand(personalMandTypePiece!, enteredCinNumber!);
    }

    notifyListeners();
  }

  Future <void> loadDocsOfPpMand(String selectedValueTypePiece, String numPieceMand) async {
    List<String> docManquants =
        identityVerificationMandModel.docManquants ?? [];
    List<String?> mandimages = identityVerificationMandModel.mandimages ?? [];
    bool? disableCINRMand;
    bool? disableCINVMand;
    bool? disableSELFIEMand;
    bool? disablePROCB;
    
    // Reset database availability flags
    for (var docCode in docManquants) {
      identityVerificationMandModel.documentsAvailableInDatabase?[docCode] = false;
      identityVerificationMandModel.databaseDocumentsChecked?[docCode] = false;
    }
    
    for (var i = 0; i < docManquants.length; i++) {
      dynamic doc = await fetchDocInYByNoPieceIdentite(
        numPieceMand,
        selectedValueTypePiece.toString(),
        'P',
        docManquants[i],
      );

      if (doc != null) {
        //nableDocButtonMand[docManquants[i]] = false;
        dynamic docinfos=jsonDecode(doc);
        //identityVerificationMandModel.enableDocButton![docManquants[i]] = false;
        
        String isDocId=docinfos['docin']['docInBoolTypePieceIdent'];

if (isDocId=='O'){
        String docincode=docinfos['docin']['docInCode'];

        // Mark document as available in database
        identityVerificationMandModel.documentsAvailableInDatabase?[docManquants[i]] = true;
        identityVerificationMandModel.enableDocButton?[docincode]=true;


        String dir = (await getApplicationDocumentsDirectory()).path;
        File file = File(
          dir + '/' +docincode.toString() + '.png',
        );
        Uint8List bytes = base64.decode((docinfos['docInYImageScan']).toString());
        File f = await file.writeAsBytes(bytes, flush: true);

         identityVerificationMandModel.mandimages![i] =
            dir + '/' + (docincode).toString() + '.png';



        if ([
          'CINR',
          'CINV',
        ].contains(docincode)) {
          switch ([
            'CINR',
            'CINV',
          ].indexOf(docincode)) {
            case 0:
              disableCINRMand = true;
              cinValidationPassed=true;
              break;
            case 1:
              disableCINVMand = true;
              identityVerificationMandModel.pieceIdVerifiee=true;
              break;
            
          }
        }
}
      } 
    //  identityVerificationMandModel.disableCINR = disableCINRMand;
    //  identityVerificationMandModel.disableCINV = disableCINVMand;
     // identityVerificationMandModel.disableSELFIE = disableSELFIEMand;
      //identityVerificationMandModel.disablePreuveDeVie = disablePROCB;
    }


     for (var i = 0; i < docManquants.length; i++) {
      final docCode = docManquants[i];
      if (!(identityVerificationMandModel.enableDocButton?[docCode] ?? false)){
        identityVerificationMandModel.enableDocButton?[docCode]=true;
        break;
      }
     }
            notifyListeners();
        await Future.delayed(const Duration(milliseconds: 500));

  }

  Future<void> loadDocuments() async {
    try {
      // Set loading state
      identityVerificationMandModel.isProcessingImage = true;
      identityVerificationMandModel.processingMessage =
          'Chargement des documents requis...';

      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Simulate API call to get required documents based on account level and person type
      // This replaces the hardcoded logic with dynamic loading similar to chargerDocInRequisNvCompte
      String? selectedAccountType = prefs.getString(
        'personal_selected_account_type',
      );
      //bool signataireEtTitulaire= selectedAccountType ==AccountType.titulaireEtSignataire.toString();
      identityVerificationMandModel.accountLevel=prefs.getString('niveau_compte_code');

      final documents = await _chargerDocInRequisNvCompte(
        signataireEtTitulaire: false,
        niveau:
            identityVerificationMandModel.accountLevel ?? DEFAULT_ACCOUNT_LEVEL,
        pp:
            identityVerificationMandModel.isPhysicalPerson ??
            DEFAULT_IS_PHYSICAL_PERSON,
      );

      // Store the full document list for filtering
      identityVerificationMandModel.documentsRequis = documents;
      // String? selectedAccountType = prefs.getString('personal_selected_account_type');
      // if ( selectedAccountType ==AccountType.titulaire.toString() )

      // Update model with loaded documents
      identityVerificationMandModel.docManquants = documents
          .map((doc) => doc.docInCode ?? '')
          .toList();
     // if (!mandExist)
      identityVerificationMandModel.mandimages = List.filled(
        documents.length,
        null,
      );

      // Initialize button states - only first document is enabled
      identityVerificationMandModel.enableDocButton = {};
      for (var i = 0; i < documents.length; i++) {
        final docCode = documents[i].docInCode ?? '';
        identityVerificationMandModel.enableDocButton![docCode] =
            (i == 0); // Only first document enabled
      }

      // Initialize database availability tracking
      identityVerificationMandModel.documentsAvailableInDatabase = {};
      identityVerificationMandModel.databaseDocumentsChecked = {};
      for (var i = 0; i < documents.length; i++) {
        final docCode = documents[i].docInCode ?? '';
        identityVerificationMandModel.documentsAvailableInDatabase![docCode] = false;
        identityVerificationMandModel.databaseDocumentsChecked![docCode] = false;
      }

      // Reset preview states when documents change
      identityVerificationMandModel.showPreview = {};

      // Initialize legacy disable flags for backward compatibility
      identityVerificationMandModel.disableCINR = true;
      identityVerificationMandModel.disableCINV = true;
      identityVerificationMandModel.disableSELFIE = true;
      identityVerificationMandModel.disablePreuveDeVie = true;

      // Update disable flags based on loaded documents
      if (documents.isNotEmpty) {
        identityVerificationMandModel.disableCINR =
            false; // First document is always enabled
      }
    } catch (e) {
      debugPrint('Error loading documents: $e');
      // Fallback to basic documents if API fails
      identityVerificationMandModel.docManquants = [
        'CINR',
        'CINV',
        'SELFIE',
        'PREUVEIE',
      ];
      identityVerificationMandModel.mandimages = List.filled(4, null);
      identityVerificationMandModel.enableDocButton = {
        'CINR': true,
        'CINV': false,
        'SELFIE': false,
        'PREUVEIE': false,
      };
      
      // Initialize database availability tracking for fallback documents
      identityVerificationMandModel.documentsAvailableInDatabase = {
        'CINR': false,
        'CINV': false,
        'SELFIE': false,
        'PREUVEIE': false,
      };
      identityVerificationMandModel.databaseDocumentsChecked = {
        'CINR': false,
        'CINV': false,
        'SELFIE': false,
        'PREUVEIE': false,
      };

      identityVerificationMandModel.disableCINR = false;
      identityVerificationMandModel.disableCINV = true;
      identityVerificationMandModel.disableSELFIE = true;
      identityVerificationMandModel.disablePreuveDeVie = true;

      // Show error message to user
      // Note: We can't show SnackBar here as we don't have BuildContext
      // This will be handled by the UI when it detects the error
    } finally {
      // Reset loading state
      identityVerificationMandModel.isProcessingImage = false;
      identityVerificationMandModel.processingMessage = '';
      //notifyListeners();
    }
  }

  void toggleCardVisibility() {
    identityVerificationMandModel.showCard =
        !(identityVerificationMandModel.showCard ?? false);
    notifyListeners();
  }

  void togglePreview(int index) {
    identityVerificationMandModel.showPreview ??= <int, bool>{};
    identityVerificationMandModel.showPreview![index] =
        !(identityVerificationMandModel.showPreview![index] ?? false);
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
        identityVerificationMandModel.backendError = false;
        identityVerificationMandModel.backendErrorMessage = '';
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
          identityVerificationMandModel.backendError = true;
          identityVerificationMandModel.backendErrorMessage =
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
          identityVerificationMandModel.backendError = true;
          identityVerificationMandModel.backendErrorMessage =
              'Accès à la galerie refusé. Veuillez autoriser l\'accès aux photos pour continuer.';
          notifyListeners();
          return false;
        }

        debugPrint('Gallery permission granted, proceeding...');
      }

      // Set loading state
      identityVerificationMandModel.isProcessingImage = true;
      identityVerificationMandModel.processingDocumentIndex = index;
      identityVerificationMandModel.processingMessage =
          source == ImageSource.camera
          ? 'Ouverture de l\'appareil photo...'
          : 'Ouverture de la galerie...';
      notifyListeners();

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) {
        debugPrint('No image picked for index: $index');
        // Reset loading state
        identityVerificationMandModel.isProcessingImage = false;
        identityVerificationMandModel.processingDocumentIndex = -1;
        identityVerificationMandModel.processingMessage = '';
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
      identityVerificationMandModel.isProcessingImage = false;
      identityVerificationMandModel.processingDocumentIndex = -1;
      identityVerificationMandModel.processingMessage = '';
      notifyListeners();
      return false;
    }
  }

  Future<bool> _processCapturedImage(XFile pickedFile, int index) async {
    bool validationPassed = true;

    try {
      // Set loading state for cropping
      identityVerificationMandModel.processingMessage =
          'Recadrage de l\'image...';
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
        identityVerificationMandModel.isProcessingImage = false;
        identityVerificationMandModel.processingDocumentIndex = -1;
        identityVerificationMandModel.processingMessage = '';
        notifyListeners();
        return false;
      }

      // Get document type for renaming
      final docType = identityVerificationMandModel.docManquants?[index];
      debugPrint('Processing document type: $docType at index: $index');

      // Rename and store document with document code (no file extension)
      String? renamedFilePath;
      if (docType != null && docType.isNotEmpty) {
        try {
          debugPrint('Renaming document $docType to use document code');
          renamedFilePath = await DocumentManager.renameAndStoreDocument(
            croppedFile.path,
            docType,
            fileExtension: '', // Don't use extension when naming file images
            prefix: 'mand', // Use 'mand' prefix for directory separation
          );
          debugPrint('Document renamed and stored at: $renamedFilePath');
        } catch (e) {
          debugPrint('Error renaming document $docType: $e');
          // Fallback to original cropped file path if renaming fails
          renamedFilePath = croppedFile.path;
        }
      } else {
        // Fallback if no document type available
        renamedFilePath = croppedFile.path;
      }

      // Store renamed image path with safety checks
      if (identityVerificationMandModel.mandimages != null &&
          index >= 0 &&
          index < identityVerificationMandModel.mandimages!.length) {
        identityVerificationMandModel.mandimages![index] = renamedFilePath;
      } else {
        debugPrint('Warning: Invalid index $index for mandimages array');
        return false;
      }

      // Process based on document type
      debugPrint('Processing document type: $docType at index: $index');

      if (docType == 'CINR') {
        identityVerificationMandModel.processingMessage =
            'Analyse du texte et vérification du document en cours...';
        notifyListeners();
        await _processCINR(croppedFile.path, index);
        // Check if CINR validation passed
        validationPassed = cinValidationPassed;
      } else if (docType == 'CINV') {
        identityVerificationMandModel.processingMessage =
            'Lecture du code-barres...';
        notifyListeners();
        await _processCINV(croppedFile.path, index);
        // CINV validation passed if pieceIdVerifiee is true
        validationPassed =
            identityVerificationMandModel.pieceIdVerifiee ?? false;
      } else if (docType == 'SELFIE' || docType == 'PREUVEIE') {
        // No special processing needed for SELFIE and PREUVEIE
        identityVerificationMandModel.processingMessage =
            'Traitement de l\'image...';
        notifyListeners();
        // Simulate brief processing for consistency
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('Captured $docType successfully');
        validationPassed = true; // Selfie/PreuveIE always pass
      } else if (docType == 'SIGN') {
        // No special processing needed for SIGN, just mark as valid
        identityVerificationMandModel.processingMessage =
            'Traitement de la signature...';
        notifyListeners();
        // Simulate brief processing for consistency
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('Captured $docType successfully');
        validationPassed = true; // Signature always passes
      }

      // Only enable next document if current validation passed
      if (validationPassed) {
        final docLength =
            identityVerificationMandModel.docManquants?.length ?? 0;
        debugPrint('Document length: $docLength, current index: $index');

        if (index + 1 < docLength) {
          final nextDoc =
              identityVerificationMandModel.docManquants![index + 1];
          debugPrint('Enabling next document: $nextDoc');
          if (identityVerificationMandModel.enableDocButton != null) {
            identityVerificationMandModel.enableDocButton![nextDoc] = true;
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
      identityVerificationMandModel.isProcessingImage = false;
      identityVerificationMandModel.processingDocumentIndex = -1;
      identityVerificationMandModel.processingMessage = '';
      notifyListeners();
      return validationPassed;
    } catch (e) {
      debugPrint('Error in _processCapturedImage: $e');
      // Reset loading state on error
      identityVerificationMandModel.isProcessingImage = false;
      identityVerificationMandModel.processingDocumentIndex = -1;
      identityVerificationMandModel.processingMessage = '';
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
            identityVerificationMandModel.cinr = block.text;

            // Validate CIN matches entered CIN from PersonalInformationsScreen
            if (enteredCinNumber != null && enteredCinNumber!.isNotEmpty) {
              if (block.text == enteredCinNumber) {
                cinValidationPassed = true;
                identityVerificationMandModel.disableCINV = false;
                debugPrint(
                  'CIN detected and validated: ${block.text} - matches entered CIN',
                );

                // Update document button states after successful CIN validation (like old app)
                updateDocumentButtonStates();
              } else {
                cinValidationPassed = false;
                identityVerificationMandModel.disableCINV = true;
                identityVerificationMandModel.disableSELFIE = true;
                identityVerificationMandModel.disablePreuveDeVie = true;
                debugPrint(
                  'CIN detected but does not match entered CIN: extracted=${block.text}, entered=${enteredCinNumber}',
                );

                // Disable all subsequent documents in the enableDocButton map
                if (identityVerificationMandModel.enableDocButton != null) {
                  // Find current document index
                  final currentIndex =
                      identityVerificationMandModel.docManquants?.indexOf(
                        'CINR',
                      ) ??
                      -1;
                  if (currentIndex >= 0) {
                    // Disable all documents after CINR
                    for (
                      var i = currentIndex + 1;
                      i <
                          (identityVerificationMandModel.docManquants?.length ??
                              0);
                      i++
                    ) {
                      final docCode =
                          identityVerificationMandModel.docManquants![i];
                      identityVerificationMandModel.enableDocButton![docCode] =
                          false;
                    }
                  }
                }

                // Show mismatch error
                identityVerificationMandModel.backendError = true;
                identityVerificationMandModel.backendErrorMessage =
                    'Le numéro CIN extrait (${block.text}) ne correspond pas au numéro CIN saisi (${enteredCinNumber}). Veuillez vérifier vos informations.';
                notifyListeners();
                return; // Exit early on mismatch
              }
            } else {
              // No entered CIN to compare with, allow if CIN is extracted
              cinValidationPassed = true;
              identityVerificationMandModel.disableCINV = false;
              debugPrint(
                'CIN detected: ${block.text} - no entered CIN to validate against',
              );
            }
            break;
          }
        }
      } else {
        // Reset CIN state if validation fails
        identityVerificationMandModel.cinr = '';
        identityVerificationMandModel.disableCINV = true;
        identityVerificationMandModel.disableSELFIE = true;
        identityVerificationMandModel.disablePreuveDeVie = true;
        cinValidationPassed = false;

        // Disable all subsequent documents in the enableDocButton map
        if (identityVerificationMandModel.enableDocButton != null) {
          // Find current document index
          final currentIndex =
              identityVerificationMandModel.docManquants?.indexOf('CINR') ?? -1;
          if (currentIndex >= 0) {
            // Disable all documents after CINR
            for (
              var i = currentIndex + 1;
              i < (identityVerificationMandModel.docManquants?.length ?? 0);
              i++
            ) {
              final docCode = identityVerificationMandModel.docManquants![i];
              identityVerificationMandModel.enableDocButton![docCode] = false;
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
        identityVerificationMandModel.backendError = true;
        identityVerificationMandModel.backendErrorMessage = errorMessage;
        notifyListeners();
      }

      await textRecognizer.close();
    } catch (e) {
      debugPrint('Error processing CINR: $e');
      // Reset state on error
      identityVerificationMandModel.cinr = '';
      identityVerificationMandModel.disableCINV = true;
      identityVerificationMandModel.backendError = true;
      identityVerificationMandModel.backendErrorMessage =
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
          if (cin == identityVerificationMandModel.cinr) {
            identityVerificationMandModel.disableSELFIE = false;
            identityVerificationMandModel.disablePreuveDeVie = false;
            identityVerificationMandModel.pieceIdVerifiee = true;
            debugPrint('CINV barcode matches CINR: $cin');

            // Update document button states after successful CINV validation (like old app)
            updateDocumentButtonStates();
          } else {
            // Barcode doesn't match CINR - disable subsequent documents
            identityVerificationMandModel.disableSELFIE = true;
            identityVerificationMandModel.disablePreuveDeVie = true;
            identityVerificationMandModel.pieceIdVerifiee = false;

            // Disable all subsequent documents in the enableDocButton map
            if (identityVerificationMandModel.enableDocButton != null) {
              // Find current document index
              final currentIndex =
                  identityVerificationMandModel.docManquants?.indexOf('CINV') ??
                  -1;
              if (currentIndex >= 0) {
                // Disable all documents after CINV
                for (
                  var i = currentIndex + 1;
                  i < (identityVerificationMandModel.docManquants?.length ?? 0);
                  i++
                ) {
                  final docCode =
                      identityVerificationMandModel.docManquants![i];
                  identityVerificationMandModel.enableDocButton![docCode] =
                      false;
                }
              }
            }

            // Show mismatch error
            identityVerificationMandModel.backendError = true;
            identityVerificationMandModel.backendErrorMessage =
                'Le code-barres du CIN Verso (${cin}) ne correspond pas au numéro CIN Recto (${identityVerificationMandModel.cinr}). Veuillez vérifier vos documents.';
            notifyListeners();

            debugPrint(
              'CINV barcode mismatch: barcode=$cin, cinr=${identityVerificationMandModel.cinr}',
            );
          }
        } else {
          // Invalid barcode length - disable subsequent documents
          identityVerificationMandModel.disableSELFIE = true;
          identityVerificationMandModel.disablePreuveDeVie = true;
          identityVerificationMandModel.pieceIdVerifiee = false;

          // Disable all subsequent documents
          if (identityVerificationMandModel.enableDocButton != null) {
            final currentIndex =
                identityVerificationMandModel.docManquants?.indexOf('CINV') ??
                -1;
            if (currentIndex >= 0) {
              for (
                var i = currentIndex + 1;
                i < (identityVerificationMandModel.docManquants?.length ?? 0);
                i++
              ) {
                final docCode = identityVerificationMandModel.docManquants![i];
                identityVerificationMandModel.enableDocButton![docCode] = false;
              }
            }
          }

          identityVerificationMandModel.backendError = true;
          identityVerificationMandModel.backendErrorMessage =
              'Code-barres invalide sur le CIN Verso. Veuillez réessayer avec une image plus claire.';
          notifyListeners();

          debugPrint('Invalid CINV barcode length: $code');
        }
      } else {
        // No barcode found - disable subsequent documents
        identityVerificationMandModel.disableSELFIE = true;
        identityVerificationMandModel.disablePreuveDeVie = true;
        identityVerificationMandModel.pieceIdVerifiee = false;

        // Disable all subsequent documents
        if (identityVerificationMandModel.enableDocButton != null) {
          final currentIndex =
              identityVerificationMandModel.docManquants?.indexOf('CINV') ?? -1;
          if (currentIndex >= 0) {
            for (
              var i = currentIndex + 1;
              i < (identityVerificationMandModel.docManquants?.length ?? 0);
              i++
            ) {
              final docCode = identityVerificationMandModel.docManquants![i];
              identityVerificationMandModel.enableDocButton![docCode] = false;
            }
          }
        }

        identityVerificationMandModel.backendError = true;
        identityVerificationMandModel.backendErrorMessage =
            'Code-barres non détecté sur le CIN Verso. Veuillez réessayer avec une image plus claire.';
        notifyListeners();

        debugPrint('No barcode found in CINV');
      }

      await barcodeScanner.close();
    } catch (e) {
      debugPrint('Error processing CINV: $e');
      // On error, disable subsequent documents
      identityVerificationMandModel.disableSELFIE = true;
      identityVerificationMandModel.disablePreuveDeVie = true;
      identityVerificationMandModel.pieceIdVerifiee = false;

      if (identityVerificationMandModel.enableDocButton != null) {
        final currentIndex =
            identityVerificationMandModel.docManquants?.indexOf('CINV') ?? -1;
        if (currentIndex >= 0) {
          for (
            var i = currentIndex + 1;
            i < (identityVerificationMandModel.docManquants?.length ?? 0);
            i++
          ) {
            final docCode = identityVerificationMandModel.docManquants![i];
            identityVerificationMandModel.enableDocButton![docCode] = false;
          }
        }
      }

      identityVerificationMandModel.backendError = true;
      identityVerificationMandModel.backendErrorMessage =
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
        Uri.parse('http://${BACKEND_SERVER}:8081/docInNiveauCompte/'),
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
                    e['docIn']['docInBoolLignePpMand'] != 'N' &&
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
          'Selected piece type: ${identityVerificationMandModel.selectedPieceType}',
        );
        debugPrint(
          'Documents before filtering: ${docsRequis.map((d) => '${d.docInCode}: pieceIdentite=${d.pieceIdentite?.pieceIdentiteCode}, boolTypePieceIdent=${d.docInBoolTypePieceIdent}').toList()}',
        );

        // Apply piece type filtering if a piece type is selected
        if (identityVerificationMandModel.selectedPieceType != null) {
          docsRequis = _applyPieceTypeFilter(
            docsRequis,
            identityVerificationMandModel.selectedPieceType!,
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
      identityVerificationMandModel.backendError = true;
      identityVerificationMandModel.backendErrorMessage =
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
              (doc.docInCode == 'SIGN' ||
                  doc.docInCode == 'SELFIE' ||
                  (doc.pieceIdentite == null) ||
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
    if (identityVerificationMandModel.documentsRequis == null) return [];

    final pieceTypes = <String>{};
    for (final doc in identityVerificationMandModel.documentsRequis!) {
      if (doc.docInBoolTypePieceIdent == 'O' && doc.pieceIdentite != null) {
        pieceTypes.add(doc.pieceIdentite!.pieceIdentiteCode!);
      }
    }
    return pieceTypes.toList();
  }

  // Check if piece type selection is needed
  bool get requiresPieceTypeSelection {
    return identityVerificationMandModel.documentsRequis?.any(
          (doc) =>
              doc.docInBoolTypePieceIdent == 'O' && doc.pieceIdentite != null,
        ) ??
        false;
  }

  bool get allDocumentsCaptured {
    bool allImagesCaptured =
        identityVerificationMandModel.mandimages?.every(
          (image) => image != null,
        ) ??
        false;

    // For CIN documents, also require CIN validation to pass
    if (identityVerificationMandModel.docManquants?.contains('CINR') ?? false) {
      return allImagesCaptured && cinValidationPassed;
    }

    return allImagesCaptured;
  }

  // Check if a document at given index can be previewed (captured and validated)
  bool canPreviewDocument(int index) {
    // Must have an image
    if (identityVerificationMandModel.mandimages == null ||
        index >= identityVerificationMandModel.mandimages!.length ||
        identityVerificationMandModel.mandimages![index] == null ||
        identityVerificationMandModel.mandimages![index]!.isEmpty) {
      return false;
    }

    // Check document type and validation status
    final docType = identityVerificationMandModel.docManquants?[index];
    if (docType == 'CINR') {
      // CINR requires validation to pass
      return cinValidationPassed;
    } else if (docType == 'CINV') {
      // CINV requires pieceIdVerifiee to be true
      return identityVerificationMandModel.pieceIdVerifiee ?? false;
    } else {
      // Selfie and PreuveIE can always be previewed once captured
      return true;
    }
  }

  void navigateToNextScreen(BuildContext context) async {
    if (allDocumentsCaptured) {
      // Use DocumentManager to store documents with their codes
      if (identityVerificationMandModel.docManquants != null &&
          identityVerificationMandModel.mandimages != null) {
        await DocumentManager.storeDocumentsWithCodes(
          identityVerificationMandModel.mandimages!,
          identityVerificationMandModel.docManquants!,
          prefix:
              'mand', // Use 'mand' prefix to separate from titulaire documents
        );
      }

      // Save other identity verification data to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'identity_cinr_mand',
        identityVerificationMandModel.cinr ?? '',
      );
      await prefs.setBool(
        'identity_piece_id_verifiee_mand',
        identityVerificationMandModel.pieceIdVerifiee ?? false,
      );
      //await prefs.setString('identity_selected_piece_type_mand', identityVerificationMandModel.selectedPieceType ?? '');

      String? selectedAccountType = prefs.getString(
        'personal_selected_account_type',
      );

      //if ( selectedAccountType ==AccountType.titulaireEtSignataire.toString() )
      NavigatorService.pushNamed(AppRoutes.accountRecoveryScreen);

      // else if ( selectedAccountType ==AccountType.titulaire.toString() )
      //   NavigatorService.pushNamed(AppRoutes.personalInformationsMandScreen);
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
        identityVerificationMandModel.documentsRequis == null) {
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

    final filteredDocs = identityVerificationMandModel.documentsRequis!
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
    identityVerificationMandModel.documentsRequis = filteredDocs;
    identityVerificationMandModel.docManquants = filteredDocs
        .map((doc) => doc.docInCode ?? '')
        .toList();

    // Reset image capture state for filtered documents
    identityVerificationMandModel.mandimages = List.filled(
      filteredDocs.length,
      null,
    );

    // Reset button states - only first document is enabled
    identityVerificationMandModel.enableDocButton = {};
    for (var i = 0; i < filteredDocs.length; i++) {
      final docCode = filteredDocs[i].docInCode ?? '';
      identityVerificationMandModel.enableDocButton![docCode] =
          (i == 0); // Only first document enabled
    }

    // Reset disable flags
    identityVerificationMandModel.disableCINR = filteredDocs.length > 0;
    identityVerificationMandModel.disableCINV = true;
    identityVerificationMandModel.disableSELFIE = true;
    identityVerificationMandModel.disablePreuveDeVie = true;

    notifyListeners();
  }

  // Toggle checkbox state for database available documents
  void toggleDatabaseDocumentCheck(String docCode) {
    if (identityVerificationMandModel.documentsAvailableInDatabase?[docCode] == true) {
      bool? currentState = identityVerificationMandModel.databaseDocumentsChecked?[docCode];
      identityVerificationMandModel.databaseDocumentsChecked?[docCode] = !(currentState ?? false);
      notifyListeners();
      
      debugPrint('Toggled database document $docCode: ${identityVerificationMandModel.databaseDocumentsChecked?[docCode]}');
    }
  }
  
  // Check if document is available in database
  bool isDocumentAvailableInDatabase(String docCode) {
    return identityVerificationMandModel.documentsAvailableInDatabase?[docCode] == true;
  }
  
  // Check if database document is checked
  bool isDatabaseDocumentChecked(String docCode) {
    return identityVerificationMandModel.databaseDocumentsChecked?[docCode] == true;
  }

  // Mimic checkLogoAndFlag from old wallet11_page.dart login_store.dart
  Future<bool?> checkLogoAndFlag(String imagePath) async {
    try {
      var url = Uri.parse("http://${BACKEND_SERVER}:5000/");

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
