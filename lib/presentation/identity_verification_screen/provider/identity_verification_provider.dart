import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/app_export.dart';
import '../models/identity_verification_model.dart';

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
const String BACKEND_SERVER = '192.168.1.13'; // Default backend server
const int BACKEND_PORT = 8081;

// Add piece type constants
const String TNCIN = 'TNCIN';
const String TNPASS = 'TNPASS';

class IdentityVerificationProvider extends ChangeNotifier {
  IdentityVerificationModel identityVerificationModel =
      IdentityVerificationModel();

  @override
  void dispose() {
    super.dispose();
  }

  void initialize() {
    // Initialize default values
    identityVerificationModel.showCard = false;

    // Load required documents
    loadDocuments();

    notifyListeners();
  }

  Future<void> loadDocuments() async {
    try {
      // Set loading state
      identityVerificationModel.isProcessingImage = true;
      identityVerificationModel.processingMessage = 'Chargement des documents requis...';
      notifyListeners();

      // Simulate API call to get required documents based on account level and person type
      // This replaces the hardcoded logic with dynamic loading similar to chargerDocInRequisNvCompte
      final documents = await _chargerDocInRequisNvCompte(
        signataireEtTitulaire: identityVerificationModel.signataireEtTitulaire ?? DEFAULT_SIGNATAIRE_TITULAIRE,
        niveau: identityVerificationModel.accountLevel ?? DEFAULT_ACCOUNT_LEVEL,
        pp: identityVerificationModel.isPhysicalPerson ?? DEFAULT_IS_PHYSICAL_PERSON,
      );

      // Store the full document list for filtering
      identityVerificationModel.documentsRequis = documents;

      // Update model with loaded documents
      identityVerificationModel.docManquants = documents.map((doc) => doc.docInCode ?? '').toList();
      identityVerificationModel.tituimages = List.filled(documents.length, null);

      // Initialize button states - only first document is enabled
      identityVerificationModel.enableDocButton = {};
      for (var i = 0; i < documents.length; i++) {
        final docCode = documents[i].docInCode ?? '';
        identityVerificationModel.enableDocButton![docCode] = (i == 0); // Only first document enabled
      }

      // Initialize legacy disable flags for backward compatibility
      identityVerificationModel.disableCINR = true;
      identityVerificationModel.disableCINV = true;
      identityVerificationModel.disableSELFIE = true;
      identityVerificationModel.disablePreuveDeVie = true;

      // Update disable flags based on loaded documents
      if (documents.isNotEmpty) {
        identityVerificationModel.disableCINR = false; // First document is always enabled
      }

    } catch (e) {
      debugPrint('Error loading documents: $e');
      // Fallback to basic documents if API fails
      identityVerificationModel.docManquants = ['CINR', 'CINV', 'SELFIE', 'PREUVEIE'];
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

  Future<bool> getImage(int index) async {
    try {
      debugPrint('Starting getImage for index: $index');

      // Set loading state for camera capture
      identityVerificationModel.isProcessingImage = true;
      identityVerificationModel.processingDocumentIndex = index;
      identityVerificationModel.processingMessage = 'Ouverture de l\'appareil photo...';
      notifyListeners();

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) {
        debugPrint('No image picked for index: $index');
        // Reset loading state
        identityVerificationModel.isProcessingImage = false;
        identityVerificationModel.processingDocumentIndex = -1;
        identityVerificationModel.processingMessage = '';
        notifyListeners();
        return false;
      }

      debugPrint('Image picked successfully for index: $index, path: ${pickedFile.path}');

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
          IOSUiSettings(
            title: 'Crop Image',
          ),
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
        identityVerificationModel.processingMessage = 'Analyse du texte en cours...';
        notifyListeners();
        await _processCINR(croppedFile.path, index);
      } else if (docType == 'CINV') {
        identityVerificationModel.processingMessage = 'Lecture du code-barres...';
        notifyListeners();
        await _processCINV(croppedFile.path, index);
      } else if (docType == 'SELFIE' || docType == 'PREUVEIE') {
        // No special processing needed for SELFIE and PREUVEIE
        identityVerificationModel.processingMessage = 'Traitement de l\'image...';
        notifyListeners();
        // Simulate brief processing for consistency
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('Captured $docType successfully');
      }

      // Enable next document (only if not the last document)
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

      // Reset loading state
      identityVerificationModel.isProcessingImage = false;
      identityVerificationModel.processingDocumentIndex = -1;
      identityVerificationModel.processingMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error in getImage: $e');
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
      final TextRecognizer textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );

      if (recognizedText.blocks.isNotEmpty && recognizedText.text.length >= 8) {
        for (final block in recognizedText.blocks) {
          if (block.text.length == 8 && RegExp(r'^\d{8}$').hasMatch(block.text)) {
            identityVerificationModel.cinr = block.text;
            identityVerificationModel.disableCINV = false;
            break;
          }
        }
      }

      await textRecognizer.close();
    } catch (e) {
      debugPrint('Error processing CINR: $e');
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
          }
        }
      }

      await barcodeScanner.close();
    } catch (e) {
      debugPrint('Error processing CINV: $e');
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
                  e['docIn']['docInBoolLignePpMand'] != 'N' &&
                  e['operation']['operationCode'] == CODE_OPERATION_NOUVELLE_COMPTE)
              .toList();
        }

        // Convert to DocumentRequis format and filter out SIGN documents
        List<DocumentRequis> docsRequis = filtredDocInNivComptes!
            .map((e) => DocumentRequis.fromJson(e['docIn']))
            .toList();
        docsRequis.removeWhere((e) => e.docInCode == 'SIGN');

        debugPrint('Loaded ${docsRequis.length} documents from backend');
        return docsRequis;
      } else {
        debugPrint('Backend returned status ${response.statusCode} with no content');
        throw Exception('Backend returned status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error calling backend API: $e');
      // Set backend error flag for UI notification
      identityVerificationModel.backendError = true;
      identityVerificationModel.backendErrorMessage = 'Impossible de contacter le serveur. Utilisation des documents par défaut.';
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

  bool get allDocumentsCaptured {
    return identityVerificationModel.tituimages?.every((image) => image != null) ?? false;
  }

  void navigateToNextScreen(BuildContext context) {
    if (allDocumentsCaptured) {
      NavigatorService.pushNamed(AppRoutes.finEnrolScreen);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez capturer tous les documents requis')),
      );
    }
  }

  // Method to handle piece type selection and filter documents accordingly
  void onPieceTypeSelected(String? selectedValueTypePiece) {
    if (selectedValueTypePiece != null && identityVerificationModel.documentsRequis != null) {
      filterDocumentsByPieceType(selectedValueTypePiece);
    }
  }

  // Add document filtering method based on selected piece type
  // This implements the same logic as wallet11_page.dart lines 1278-1289
  void filterDocumentsByPieceType(String? selectedValueTypePiece) {
    if (selectedValueTypePiece == null || identityVerificationModel.documentsRequis == null) {
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

    final filteredDocs = identityVerificationModel.documentsRequis!.where((doc) =>
        doc != null &&
        ((doc.docInBoolTypePieceIdent == 'O' &&
            doc.pieceIdentite != null &&
            doc.pieceIdentite?.pieceIdentiteCode == selectedValueTypePiece) ||
        doc.pieceIdentite == null)
    ).toList();

    // Update the model with filtered documents
    identityVerificationModel.documentsRequis = filteredDocs;
    identityVerificationModel.docManquants = filteredDocs.map((doc) => doc.docInCode ?? '').toList();

    // Reset image capture state for filtered documents
    identityVerificationModel.tituimages = List.filled(filteredDocs.length, null);

    // Reset button states - only first document is enabled
    identityVerificationModel.enableDocButton = {};
    for (var i = 0; i < filteredDocs.length; i++) {
      final docCode = filteredDocs[i].docInCode ?? '';
      identityVerificationModel.enableDocButton![docCode] = (i == 0); // Only first document enabled
    }

    // Reset disable flags
    identityVerificationModel.disableCINR = filteredDocs.length > 0;
    identityVerificationModel.disableCINV = true;
    identityVerificationModel.disableSELFIE = true;
    identityVerificationModel.disablePreuveDeVie = true;

    notifyListeners();
  }
}