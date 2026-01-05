import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:millime/presentation/account_type_selection_screen/models/account_type_selection_screen_model.dart';
import 'package:millime/presentation/personal_informations_screen/models/personal_informations_model.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:millime/core/build_info.dart';

import '../../../core/app_export.dart';
import '../models/identity_verification_pm_model.dart';

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
const bool DEFAULT_IS_PHYSICAL_PERSON = true; // true for physical person, false for legal entity
const bool DEFAULT_SIGNATAIRE_TITULAIRE = true; // true if signer and holder are the same person

// Backend server configuration (to be moved to environment config)
const String BACKEND_SERVER = '${backendServer}'; // Default backend server
const int BACKEND_PORT = 8081;

// Add piece type constants
const String TNCIN = 'TNCIN';
const String TNPASS = 'TNPASS';

class IdentityVerificationPmProvider extends ChangeNotifier {
  IdentityVerificationPmModel identityVerificationPmModel =
      IdentityVerificationPmModel();

  // Store the CIN entered in PersonalInformationsScreen
  String? enteredNumPiece;

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
    return (identityVerificationPmModel.pieceIdVerifiee ?? false) && 
           (cinValidationPassed) &&
           (identityVerificationPmModel.cinr != null && identityVerificationPmModel.cinr!.isNotEmpty);
  }

  // Enhanced enable document button logic
  void updateDocumentButtonStates() {
    if (identityVerificationPmModel.enableDocButton == null) return;
    
    final docManquants = identityVerificationPmModel.docPmManquants ?? [];
    final enableDocButton = identityVerificationPmModel.enableDocButton!;
    
    for (var i = 0; i < docManquants.length; i++) {
      final docCode = docManquants[i];
      
      if (docCode == 'SELFIE' || docCode == 'PREUVEIE') {
        // Apply enhanced logic from old app
        enableDocButton[docCode] = canEnableSelfieDocument();
        
        // Also update disable flags (like old app)
        if (docCode == 'SELFIE') {
          identityVerificationPmModel.disableSELFIE = !canEnableSelfieDocument();
        } else if (docCode == 'PREUVEIE') {
          identityVerificationPmModel.disablePreuveDeVie = !canEnableSelfieDocument();
        }
      }
    }
    
    debugPrint('🔄 Document button states updated: SELFIE enabled=${enableDocButton['SELFIE']}, PREUVEIE enabled=${enableDocButton['PREUVEIE']}');
    notifyListeners();
  }

  @override
  void dispose() {
    _selfieCountdownTimer?.cancel();
    super.dispose();
  }

  void initialize() async {
    // Initialize default values
    identityVerificationPmModel.showCard = false;

    // Load selected piece type and entered CIN from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPieceType = prefs.getString('pm_type_piece');
    debugPrint('Loaded selected_piece_type from SharedPreferences: $savedPieceType');
    if (savedPieceType != null) {
      identityVerificationPmModel.selectedPieceType = savedPieceType;
    }
//pm_numero_piece
    enteredNumPiece = prefs.getString('pm_numero_piece') ??  "";
    debugPrint('Loaded entered_id_number from SharedPreferences: $enteredNumPiece');

    // Load required documents
    loadDocuments();

    notifyListeners();
  }

  Future<void> loadDocuments() async {
    try {
      // Set loading state
      identityVerificationPmModel.isProcessingImage = true;
      identityVerificationPmModel.processingMessage = 'Chargement des documents requis...';
      notifyListeners();
       SharedPreferences prefs = await SharedPreferences.getInstance();

      // Simulate API call to get required documents based on account level and person type
      // This replaces the hardcoded logic with dynamic loading similar to chargerDocInRequisNvCompte


      final documents = await _chargerDocInRequisNvCompte(
        signataireEtTitulaire: false ,
        niveau: identityVerificationPmModel.accountLevel ?? DEFAULT_ACCOUNT_LEVEL,
        pp: false,
      );

      // Store the full document list for filtering
      identityVerificationPmModel.documentsRequis = documents;  


      // Update model with loaded documents
      identityVerificationPmModel.docPmManquants = documents.map((doc) => doc.docInCode ?? '').toList();
      identityVerificationPmModel.tituPmimages = List.filled(documents.length, null);

      // Initialize button states - only first document is enabled
      identityVerificationPmModel.enableDocButton = {};
      for (var i = 0; i < documents.length; i++) {
        final docCode = documents[i].docInCode ?? '';
        identityVerificationPmModel.enableDocButton![docCode] = (i == 0); // Only first document enabled
      }



      // Reset preview states when documents change
      identityVerificationPmModel.showPreview = {};

      // Initialize legacy disable flags for backward compatibility
      identityVerificationPmModel.disableCINR = true;
      identityVerificationPmModel.disableCINV = true;
      identityVerificationPmModel.disableSELFIE = true;
      identityVerificationPmModel.disablePreuveDeVie = true;

      // Update disable flags based on loaded documents
      if (documents.isNotEmpty) {
        identityVerificationPmModel.disableCINR = false; // First document is always enabled
      }

    } catch (e) {
      debugPrint('Error loading documents: $e');
      // Fallback to basic documents if API fails
      identityVerificationPmModel.docPmManquants = ['CINR', 'CINV', 'SELFIE', 'PREUVEIE'];
      identityVerificationPmModel.tituPmimages = List.filled(4, null);
      identityVerificationPmModel.enableDocButton = {
        'CINR': true,
        'CINV': false,
        'SELFIE': false,
        'PREUVEIE': false,
      };
      identityVerificationPmModel.disableCINR = false;
      identityVerificationPmModel.disableCINV = true;
      identityVerificationPmModel.disableSELFIE = true;
      identityVerificationPmModel.disablePreuveDeVie = true;

      // Show error message to user
      // Note: We can't show SnackBar here as we don't have BuildContext
      // This will be handled by the UI when it detects the error
    } finally {
      // Reset loading state
      identityVerificationPmModel.isProcessingImage = false;
      identityVerificationPmModel.processingMessage = '';
      notifyListeners();
    }
  }

  void toggleCardVisibility() {
    identityVerificationPmModel.showCard =
        !(identityVerificationPmModel.showCard ?? false);
    notifyListeners();
  }

  void togglePreview(int index) {
    identityVerificationPmModel.showPreview ??= <int, bool>{};
    identityVerificationPmModel.showPreview![index] =
        !(identityVerificationPmModel.showPreview![index] ?? false);
    notifyListeners();
  }

  Future<bool> getImage(int index, BuildContext context) async {
    return await _getImageFromSource(index, ImageSource.camera, context);
  }

  Future<bool> getImageFromGallery(int index, BuildContext context) async {
    return await _getImageFromSource(index, ImageSource.gallery, context);
  }

  Future<bool> _getImageFromSource(int index, ImageSource source, BuildContext context) async {
    try {
      debugPrint('Starting _getImageFromSource for index: $index, source: $source');

      // Request permissions if accessing gallery (skip on web)
      if (source == ImageSource.gallery && !kIsWeb) {
        // Clear any previous error messages
        identityVerificationPmModel.backendError = false;
        identityVerificationPmModel.backendErrorMessage = '';
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
          debugPrint('Photos permission not granted, trying storage permission...');
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
          identityVerificationPmModel.backendError = true;
          identityVerificationPmModel.backendErrorMessage = 'Accès à la galerie refusé. Veuillez autoriser l\'accès aux photos dans les paramètres de l\'application.';
          notifyListeners();
          // Open app settings after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            openAppSettings();
          });
          return false;
        } else if (!status.isGranted) {
          debugPrint('Gallery permission still not granted');
          // Show error message to user
          identityVerificationPmModel.backendError = true;
          identityVerificationPmModel.backendErrorMessage = 'Accès à la galerie refusé. Veuillez autoriser l\'accès aux photos pour continuer.';
          notifyListeners();
          return false;
        }

        debugPrint('Gallery permission granted, proceeding...');
      } else if (kIsWeb && source == ImageSource.gallery) {
        debugPrint('Running on web, skipping permission check for gallery');
      }

      // Set loading state
      identityVerificationPmModel.isProcessingImage = true;
      identityVerificationPmModel.processingDocumentIndex = index;
      identityVerificationPmModel.processingMessage = source == ImageSource.camera
          ? 'Ouverture de l\'appareil photo...'
          : 'Ouverture de la galerie...';
      notifyListeners();

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) {
        debugPrint('No image picked for index: $index');
        // Reset loading state
        identityVerificationPmModel.isProcessingImage = false;
        identityVerificationPmModel.processingDocumentIndex = -1;
        identityVerificationPmModel.processingMessage = '';
        notifyListeners();
        return false;
      }

      debugPrint('Image picked successfully for index: $index, path: ${pickedFile.path}');

      // Process the captured image
      return await _processCapturedImage(pickedFile, index, context);
    } catch (e) {
      debugPrint('Error in _getImageFromSource: $e');
      // Reset loading state on error
      identityVerificationPmModel.isProcessingImage = false;
      identityVerificationPmModel.processingDocumentIndex = -1;
      identityVerificationPmModel.processingMessage = '';
      notifyListeners();
      return false;
    }
  }

  Future<bool> _processCapturedImage(XFile pickedFile, int index, BuildContext context) async {
    bool validationPassed = false;

    try {
      CroppedFile? croppedFile;
      
      // Handle web platform differently to avoid BuildContext issues
      if (kIsWeb) {
        // On web, skip cropping to avoid BuildContext issues
        // Use the original file directly for web
        debugPrint('Running on web, skipping cropping for index: $index');
        
        // For web, we can convert the blob URL to a proper file path
        // The image picker already provides a valid file path for web
        croppedFile = CroppedFile(pickedFile.path);
      } else {
        // Set loading state for cropping
        identityVerificationPmModel.processingMessage = 'Recadrage de l\'image...';
        notifyListeners();

        // Crop the image for mobile platforms
        List<PlatformUiSettings> uiSettings = [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF1A7B8E),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ];

        croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 85,
          uiSettings: uiSettings,
        );
      }

      if (croppedFile == null) {
        // Reset loading state
        identityVerificationPmModel.isProcessingImage = false;
        identityVerificationPmModel.processingDocumentIndex = -1;
        identityVerificationPmModel.processingMessage = '';
        notifyListeners();
        return false;
      }

      // Store cropped image path with safety checks
      if (identityVerificationPmModel.tituPmimages != null &&
          index >= 0 &&
          index < identityVerificationPmModel.tituPmimages!.length) {
        identityVerificationPmModel.tituPmimages![index] = croppedFile.path;
      } else {
        debugPrint('Warning: Invalid index $index for tituimages array');
        return false;
      }

      // Process based on document type
      final docType = identityVerificationPmModel.docPmManquants?[index];
      debugPrint('Processing document type: $docType at index: $index');

     validationPassed=true;
      // Only enable next document if current validation passed
      if (validationPassed) {
        final docLength = identityVerificationPmModel.docPmManquants?.length ?? 0;
        debugPrint('Document length: $docLength, current index: $index');

        if (index + 1 < docLength) {
          final nextDoc = identityVerificationPmModel.docPmManquants![index + 1];
          debugPrint('Enabling next document: $nextDoc');
          if (identityVerificationPmModel.enableDocButton != null) {
            identityVerificationPmModel.enableDocButton![nextDoc] = true;
          }
        } else {
          debugPrint('This is the last document, no next document to enable');
        }
      } else {
        debugPrint('Validation failed for $docType, not enabling next document');
      }

      // Reset loading state
      identityVerificationPmModel.isProcessingImage = false;
      identityVerificationPmModel.processingDocumentIndex = -1;
      identityVerificationPmModel.processingMessage = '';
      notifyListeners();
      return validationPassed;
    } catch (e) {
      debugPrint('Error in _processCapturedImage: $e');
      // Reset loading state on error
      identityVerificationPmModel.isProcessingImage = false;
      identityVerificationPmModel.processingDocumentIndex = -1;
      identityVerificationPmModel.processingMessage = '';
      notifyListeners();
      return false;
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
              ?.where((e) =>
                  e['niveauCompte']['niveauCompteDsg'] == niveau &&
                  e['docIn']['docInBoolLignePpTituSign'] != 'N' &&
                  e['operation']['operationCode'] == CODE_OPERATION_NOUVELLE_COMPTE)
              .toList();
        } else if (!pp) {
          filtredDocInNivComptes = docInNivComptes
              ?.where((e) =>
                  e['niveauCompte']['niveauCompteDsg'] == niveau &&
                  e['docIn']['docInBoolLignePmTitu'] != 'N' &&
                  e['operation']['operationCode'] == CODE_OPERATION_NOUVELLE_COMPTE)
              .toList();
        } else {
          filtredDocInNivComptes = docInNivComptes
              ?.where((e) =>
                  e['niveauCompte']['niveauCompteDsg'] == niveau &&
                  e['docIn']['docInBoolLignePpTituOnly'] != 'N' &&
                  e['operation']['operationCode'] == CODE_OPERATION_NOUVELLE_COMPTE)
              .toList();
        }

        debugPrint('filtredDocInNivComptes: ${filtredDocInNivComptes?.map((e) => e['docIn']['docInCode']).toList()}');

        // Convert to DocumentRequis format and filter out SIGN documents
        List<DocumentRequis> docsRequis = filtredDocInNivComptes!
            .map((e) => DocumentRequis.fromJson(e['docIn']))
            .toList();
       // docsRequis.removeWhere((e) => e.docInCode == 'SIGN');
       debugPrint('docsRequis before sorting: ${docsRequis.map((d) => '${d.docInCode}: pieceIdentite=${d.pieceIdentite?.pieceIdentiteCode}').toList()}');
       docsRequis.sort((a, b) {
             if (a.docInCode == 'SIGN' && b.docInCode != 'SIGN') return 1;
             if (a.docInCode != 'SIGN' && b.docInCode == 'SIGN') return -1;
             return 0; // Keep original order for others
        });
        debugPrint('docsRequis after sorting: ${docsRequis.map((d) => d.docInCode).toList()}');

        debugPrint('Loaded ${docsRequis.length} documents from backend before piece type filtering');
        debugPrint('Selected piece type: ${identityVerificationPmModel.selectedPieceType}');
        debugPrint('Documents before filtering: ${docsRequis.map((d) => '${d.docInCode}: pieceIdentite=${d.pieceIdentite?.pieceIdentiteCode}, boolTypePieceIdent=${d.docInBoolTypePieceIdent}').toList()}');

        // Apply piece type filtering if a piece type is selected
        if (identityVerificationPmModel.selectedPieceType != null) {
          docsRequis = _applyPieceTypeFilter(docsRequis, identityVerificationPmModel.selectedPieceType!);
        }

        debugPrint('Loaded ${docsRequis.length} documents from backend (after piece type filtering)');
        debugPrint('Documents after filtering: ${docsRequis.map((d) => d.docInCode).toList()}');
        return docsRequis;
      } else {
        debugPrint('Backend returned status ${response.statusCode} with no content');
        throw Exception('Backend returned status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error calling backend API: $e');
      // Set backend error flag for UI notification
      identityVerificationPmModel.backendError = true;
      identityVerificationPmModel.backendErrorMessage = 'Impossible de contacter le serveur. Utilisation des documents par défaut.';
      // Return default documents based on business rules when backend is unavailable
      return _getDefaultDocuments(signataireEtTitulaire, niveau, pp);
    }
  }

  // Default document logic based on business rules from login_store.dart
  List<DocumentRequis> _getDefaultDocuments(bool signataireEtTitulaire, String niveau, bool pp) {
    // Match the original fallback logic from login_store.dart
    // which returns ['CINR', 'CINV', 'SELFIE'] for physical persons

    final documents = <DocumentRequis>[];

    // For physical persons (pp = true), return the standard documents
    if (pp) {
      documents.add(DocumentRequis(
        docInCode: DOC_CINR,
        docInLibelle: 'Carte d\'Identité Nationale Recto',
        obligatoire: true,
      ));

      documents.add(DocumentRequis(
        docInCode: DOC_CINV,
        docInLibelle: 'Carte d\'Identité Nationale Verso',
        obligatoire: true,
      ));

      documents.add(DocumentRequis(
        docInCode: DOC_SELFIE,
        docInLibelle: 'Selfie',
        obligatoire: true,
      ));
    } else {
      // For legal entities, return passport and selfie
      documents.add(DocumentRequis(
        docInCode: DOC_PASSPORT,
        docInLibelle: 'Passeport',
        obligatoire: true,
      ));

      documents.add(DocumentRequis(
        docInCode: DOC_SELFIE,
        docInLibelle: 'Selfie',
        obligatoire: true,
      ));
    }

    debugPrint('Using default documents: ${documents.map((d) => d.docInCode).toList()}');
    return documents;
  }

  // Apply piece type filtering logic from the old version
  // Only show SIGN, SELFIE and documents that match the selected piece type
  List<DocumentRequis> _applyPieceTypeFilter(List<DocumentRequis> documents, String selectedPieceType) {
    debugPrint('_applyPieceTypeFilter input: ${documents.map((d) => '${d.docInCode}: pieceIdentite=${d.pieceIdentite?.pieceIdentiteCode}, boolType=${d.docInBoolTypePieceIdent}').toList()}');
    final filtered = documents.where((doc) =>
        doc != null && ((doc.pieceIdentite == null) ||  (doc.pieceIdentite != null &&
          doc.pieceIdentite?.pieceIdentiteCode == selectedPieceType) )
    ).toList();
    debugPrint('_applyPieceTypeFilter output: ${filtered.map((d) => d.docInCode).toList()}');
    return filtered;
  }

  // Get available piece types from documents
  List<String> getAvailablePieceTypes() {
    if (identityVerificationPmModel.documentsRequis == null) return [];

    final pieceTypes = <String>{};
    for (final doc in identityVerificationPmModel.documentsRequis!) {
      if (doc.docInBoolTypePieceIdent == 'O' && doc.pieceIdentite != null) {
        pieceTypes.add(doc.pieceIdentite!.pieceIdentiteCode!);
      }
    }
    return pieceTypes.toList();
  }

  // Check if piece type selection is needed
  bool get requiresPieceTypeSelection {
    return identityVerificationPmModel.documentsRequis?.any((doc) =>
        doc.docInBoolTypePieceIdent == 'O' && doc.pieceIdentite != null) ?? false;
  }

  bool get allDocumentsCaptured {
    bool allImagesCaptured = identityVerificationPmModel.tituPmimages?.every((image) => image != null) ?? false;

    // For CIN documents, also require CIN validation to pass
    if (identityVerificationPmModel.docPmManquants?.contains('CINR') ?? false) {
      return allImagesCaptured && cinValidationPassed;
    }

    return allImagesCaptured;
  }

  // Check if a document at given index can be previewed (captured and validated)
  bool canPreviewDocument(int index) {
    // Must have an image
    if (identityVerificationPmModel.tituPmimages == null ||
        index >= identityVerificationPmModel.tituPmimages!.length ||
        identityVerificationPmModel.tituPmimages![index] == null ||
        identityVerificationPmModel.tituPmimages![index]!.isEmpty) {
      return false;
    }

    // Check document type and validation status
    final docType = identityVerificationPmModel.docPmManquants?[index];
    if (docType == 'CINR') {
      // CINR requires validation to pass
      return cinValidationPassed;
    } else if (docType == 'CINV') {
      // CINV requires pieceIdVerifiee to be true
      return identityVerificationPmModel.pieceIdVerifiee ?? false;
    } else {
      // Selfie and PreuveIE can always be previewed once captured
      return true;
    }
  }

  void navigateToNextScreen(BuildContext context) async {
    if (allDocumentsCaptured) {
      // Use DocumentManager to store documents with their codes
      if (identityVerificationPmModel.docPmManquants != null && 
          identityVerificationPmModel.tituPmimages != null) {
        await DocumentManager.storeDocumentsWithCodes(
          identityVerificationPmModel.tituPmimages!,
          identityVerificationPmModel.docPmManquants!,
          prefix: 'titu', // Use 'titu' prefix to separate from mandataire documents
        );
      }

      // Save other identity verification data to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
    //  await prefs.setString('identity_titupm', identityVerificationPmModel.cinr ?? '');
      await prefs.setBool('identity_piece_id_verifiee', identityVerificationPmModel.pieceIdVerifiee ?? false);
    //  await prefs.setString('identity_selected_piece_type_pm', identityVerificationPmModel.selectedPieceType ?? '');

      NavigatorService.pushNamed(AppRoutes.personalInformationsMandScreen);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez capturer tous les documents requis')),
      );
    }
  }


  // Add document filtering method based on selected piece type
  // This implements the same logic as wallet11_page.dart lines 1278-1289
  void filterDocumentsByPieceType(String? selectedValueTypePiece) {
    if (selectedValueTypePiece == null || identityVerificationPmModel.documentsRequis == null) {
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

    final filteredDocs = identityVerificationPmModel.documentsRequis!.where((doc) =>
        doc != null &&
        ((doc.docInBoolTypePieceIdent == 'O' &&
            doc.pieceIdentite != null &&
            doc.pieceIdentite?.pieceIdentiteCode == selectedValueTypePiece) ||
        doc.pieceIdentite == null)
    ).toList();

    // Update the model with filtered documents
    identityVerificationPmModel.documentsRequis = filteredDocs;
    identityVerificationPmModel.docPmManquants = filteredDocs.map((doc) => doc.docInCode ?? '').toList();

    // Reset image capture state for filtered documents
    identityVerificationPmModel.tituPmimages = List.filled(filteredDocs.length, null);

    // Reset button states - only first document is enabled
    identityVerificationPmModel.enableDocButton = {};
    for (var i = 0; i < filteredDocs.length; i++) {
      final docCode = filteredDocs[i].docInCode ?? '';
      identityVerificationPmModel.enableDocButton![docCode] = (i == 0); // Only first document enabled
    }

    // Reset disable flags
    identityVerificationPmModel.disableCINR = filteredDocs.length > 0;
    identityVerificationPmModel.disableCINV = true;
    identityVerificationPmModel.disableSELFIE = true;
    identityVerificationPmModel.disablePreuveDeVie = true;

    notifyListeners();
  }

  // Mimic checkLogoAndFlag from old wallet11_page.dart login_store.dart
  Future<bool?> checkLogoAndFlag(String imagePath) async {
    try {
      var url = Uri.parse("http://${backendServer}:5000/");

      var request = http.MultipartRequest('POST', url);

      request.files.add(await http.MultipartFile.fromPath(
          'sampleImage', imagePath,
          contentType: MediaType('image', 'jpeg')));

      request.headers
          .addEntries(<String, String>{'enctype': 'multipart/form-data'}.entries);

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