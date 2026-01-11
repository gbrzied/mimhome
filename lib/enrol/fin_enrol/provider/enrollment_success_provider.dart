import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/app_export.dart';
import '../../../models/demOuvNewCompteNewMand.dart';
import '../../../models/NiveauCompte.dart';
import 'package:millime/core/build_info.dart';


class EnrollmentSuccessProvider extends ChangeNotifier {
  bool isLoading = false;
  String? submissionMessage;
  bool submissionSuccess = false;

  // Collected data from SharedPreferences
  //pp
  String? nom;
  String? prenom;
  String? dateNaissance;
  String? adresse;
  String? numeroTelephone;
  String? email;
  String? typePiece;
  String? numeroPiece;
  String? selectedAccountType;
//pm
  String? raisonSociale;
  String? dateCreation;
  String? pmAdresse;
  String? pmNumeroTelephone;
  String? pmEmail;
  String? pmTypePiece;
  String? pmNumeroPiece;


  bool? isPhysicalPerson;
  List<String>? documentImages;
  String? cinr;
  bool? pieceIdVerifiee;
  String? selectedPieceType;
  String? recoveryPhone;
  String? recoveryEmail;
  String? signaturePath;

  String? nomMand;
  String? prenomMand;
  String? dateNaissanceMand;
  String? adresseMand;
  String? numeroTelephoneMand;
  String? emailMand;
  String? typePieceMand;
  String? numeroPieceMand;
  String? selectedAccountTypeMand;
  bool? isPhysicalPersonMand;
  List<String>? documentImagesMand;
  String? cinrMand;
  bool? pieceIdVerifieeMand;
  String? selectedPieceTypeMand;
  String? recoveryPhoneMand;
  String? recoveryEmailMand;
  String? signaturePathMand;

  String? niveau;

  String? telGestion;
  String? mailGestion;

  void initialize() async {
    isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load info of titu pp
    nom = prefs.getString('personal_nom');
    prenom = prefs.getString('personal_prenom');
    dateNaissance = prefs.getString('personal_date_naissance');
    adresse = prefs.getString('personal_adresse');
    numeroTelephone = prefs.getString('personal_numero_telephone');
    email = prefs.getString('personal_email');
    typePiece = prefs.getString('personal_type_piece');
    numeroPiece = prefs.getString('personal_numero_piece');
    selectedAccountType = prefs.getString('personal_selected_account_type');
    isPhysicalPerson = prefs.getBool('personal_is_physical_person');

 // Load info of titu pm
    raisonSociale = prefs.getString('pm_raison_sociale');
    dateCreation = prefs.getString('pm_date_creation');
    pmAdresse= prefs.getString('pm_adresse');
    pmNumeroTelephone = prefs.getString('pm_numero_telephone');
    pmEmail = prefs.getString('pm_email');
    pmTypePiece = prefs.getString('pm_type_piece');
    pmNumeroPiece = prefs.getString('pm_numero_piece');
    selectedAccountType = prefs.getString('pm_selected_account_type');
    isPhysicalPerson = prefs.getBool('pm_is_physical_person');

    // Load personal info of mand pp
    nomMand = prefs.getString('personal_mand_nom');
    prenomMand = prefs.getString('personal_mand_prenom');
    dateNaissanceMand = prefs.getString('personal_mand_date_naissance');
    adresseMand = prefs.getString('personal_mand_adresse');
    numeroTelephoneMand = prefs.getString('personal_mand_numero_telephone');
    emailMand = prefs.getString('personal_mand_email');
    typePieceMand = prefs.getString('personal_mand_type_piece');
    numeroPieceMand = prefs.getString('personal_mand_numero_piece');
    selectedAccountTypeMand = prefs.getString(
      'personal_mand_selected_account_type',
    );


    // Load identity verification data of titu
    documentImages = prefs.getStringList('identity_document_images');
    cinr = prefs.getString('identity_cinr');
    pieceIdVerifiee = prefs.getBool('identity_piece_id_verifiee');
    selectedPieceType = prefs.getString('identity_selected_piece_type');

    // Load identity verification data of mand
    documentImagesMand = prefs.getStringList('identity_document_images_mand');
    cinrMand = prefs.getString('identity_cinr_mand');
    pieceIdVerifieeMand = prefs.getBool('identity_piece_id_verifiee_mand');
    selectedPieceTypeMand = prefs.getString(
      'identity_selected_piece_type_mand',
    );

    // Load selected account level
    niveau = prefs.getString('niveau_compte_code');

    telGestion = prefs.getString('terms_phone_number');
    mailGestion = prefs.getString('terms_email');

    // Load recovery data
    recoveryPhone = prefs.getString('recovery_phone');
    recoveryEmail = prefs.getString('recovery_email');
    signaturePath = prefs.getString('signature_path');

    isLoading = false;
    await submit();
    notifyListeners();
  }

  Future<void> submit() async {
    String scenario = await getScenarioNumber();

    // Auto-submit the request
    if (scenario == "Scenario1") {
      await submitScenario1();
    } else if (scenario == "Scenario2") {
      await submitScenario2();
    } else if (scenario == "Scenario3")
      submitScenario3();
  }

  Future<void> submitScenario1() async {
    isLoading = true;
    submissionMessage = null;
    notifyListeners();

    try {
      // Create DemOuvNewCompteNewMand object
      DemOuvNewCompteNewMand dmd = DemOuvNewCompteNewMand(
        demOuvCompteMandBool: false, // No mandate
        demOuvCompteMandEmisDate: DateTime.now(),
        tituPpPieceIdentiteCode: typePiece ?? '',
        tituPpPieceIdentiteNo: numeroPiece ?? '',
        tituPpNom: nom ?? '',
        tituPpPrenom: prenom ?? '',
        tituPpNaissanceDate: dateNaissance != null
            ? DateTime.parse(dateNaissance!.split('-').reversed.join('-'))
            : null, // Convert DD-MM-YYYY to DateTime
        tituPpAdresse: adresse ?? '',
        tituPpEmail: email ?? '',
        tituPpTelMobileNo: numeroTelephone ?? '',
        tituPpBoolTun: true, // Assuming Tunisian
        tituPpBoolResident: true, // Assuming resident
        tituPpBoolFatca: false,
        tituPpBoolVip: false,
        tituPpBoolExemptRS: false,
        tituPpBoolExemptTva: false,
        tituPpBoolPep: false,
        tituPpBoolHandicap: false,
        // For non-mandate, set mandPp to same as tituPp
        mandPpPieceIdentiteCode: typePiece ?? '',
        mandPpPieceIdentiteNo: numeroPiece ?? '',
        mandPpNom: nom ?? '',
        mandPpPrenom: prenom ?? '',
        mandPpNaissanceDate: dateNaissance != null
            ? DateTime.parse(dateNaissance!.split('-').reversed.join('-'))
            : null,
        mandPpAdresse: adresse ?? '',
        mandPpEmail: email ?? '',
        mandPpTelMobileNo: numeroTelephone ?? '',
        mandPpBoolTun: true,
        mandPpBoolResiden: true,
        walletNoTelGestion: telGestion ?? '',
        walletEmailGestion: mailGestion ?? '',
        demNewCompteNewMandGesSecours: recoveryPhone ?? '',
        demNewCompteNewMandEmailSecours: recoveryEmail ?? '',

      );

      // Prepare images and titles using DocumentManager
      List<String> images = [];
      List<String> titres = [];

      // Load documents with their codes
      final documentsWithCodes = await DocumentManager.loadDocumentsWithCodes(
        'titu',
      );

      documentsWithCodes.forEach((imagePath, documentCode) {
        if (File(imagePath).existsSync()) {
          images.add(imagePath);
          titres.add(documentCode); // Use document code as title
        }
      });

      // Upload files first
      await uploadFiles(images, titres);

      // Submit the request
      final response = await http.post(
        Uri.parse('http://${backendServer}:8081/demOuvCompte/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'demOuvCompteMandBool': dmd.demOuvCompteMandBool,
          'demOuvCompteMandEmisDate': dmd.demOuvCompteMandEmisDate
              ?.toIso8601String()
              .split('T')[0],
          'tituPpPieceIdentiteCode': dmd.tituPpPieceIdentiteCode,
          'tituPpPieceIdentiteNo': dmd.tituPpPieceIdentiteNo,
          'tituPpNom': dmd.tituPpNom,
          'tituPpPrenom': dmd.tituPpPrenom,
          'tituPpAdresse': dmd.tituPpAdresse,
          'tituPpEmail': dmd.tituPpEmail,
          'tituPpTelMobileNo': dmd.tituPpTelMobileNo,
          'tituPpBoolTun': dmd.tituPpBoolTun,
          'tituPpBoolResident': dmd.tituPpBoolResident,
          'tituPpBoolFatca': dmd.tituPpBoolFatca,
          'tituPpBoolVip': dmd.tituPpBoolVip,
          'tituPpBoolExemptRs': dmd.tituPpBoolExemptRS,
          'tituPpBoolExemptTva': dmd.tituPpBoolExemptTva,
          'tituPpBoolPep': dmd.tituPpBoolPep,
          'tituPpBoolHandicap': dmd.tituPpBoolHandicap,
          'mandPpPieceIdentiteCode': dmd.mandPpPieceIdentiteCode,
          'mandPpPieceIdentiteNo': dmd.mandPpPieceIdentiteNo,
          'mandPpNom': dmd.mandPpNom,
          'mandPpPrenom': dmd.mandPpPrenom,
          'mandPpNaissanceDate': dmd.mandPpNaissanceDate
              ?.toIso8601String()
              .split('T')[0],
          'mandPpAdresse': dmd.mandPpAdresse,
          'mandPpEmail': dmd.mandPpEmail,

          'mandPpTelMobileNo': dmd.mandPpTelMobileNo,
          'mandPpBoolTun': dmd.mandPpBoolTun! ? 'O' : 'N',
          'mandPpBoolResident': dmd.mandPpBoolResiden! ? 'O' : 'N',
          'mandPpBoolHandicapSign': 'N', // Assuming no handicap
          'walletNoTelGestion': dmd.walletNoTelGestion,
          'walletEmailGestion': dmd.walletEmailGestion,
          'demNewCompteGesSecours': dmd.demNewCompteNewMandGesSecours,
          'demNewCompteEmailSecours': dmd.demNewCompteNewMandEmailSecours,
          'demNewCompteLang': 'fr', // Assuming French
        }),
      );

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        // Update the request status
        final response2 = await updateDemOuvNewCompteNewMand(
          '3', // modeOuvCompteId

          // dmd.niveauCompte?.niveauCompteId.toString() ?? '1', // niveauCompteId
          niveau == 'Niveau1' ? '1' : '2',

          '1', // statutDemandeOuvCompteId
          '1', // uniteGestionId
          jsonDecode(response.body)['demOuvCompteMandId'],
          response.body,
        );

        submissionSuccess = true;
        submissionMessage =
            'Votre demande d\'ouverture de compte a été déposée avec succès.';
      } else {
        submissionSuccess = false;
        submissionMessage = 'Erreur lors de la soumission de la demande.';
      }
    } catch (e) {
      submissionSuccess = false;
      submissionMessage = 'Erreur lors de la soumission: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> submitScenario2() async {
    isLoading = true;
    submissionMessage = null;
    notifyListeners();

    try {
      // Create DemOuvNewCompteNewMand object
      DemOuvNewCompteNewMand dmd = DemOuvNewCompteNewMand(
        demOuvCompteMandBool: false, // No mandate
        demOuvCompteMandEmisDate: DateTime.now(),
        tituPpPieceIdentiteCode: typePiece ?? '',
        tituPpPieceIdentiteNo: numeroPiece ?? '',
        tituPpNom: nom ?? '',
        tituPpPrenom: prenom ?? '',
        tituPpNaissanceDate: dateNaissance != null
            ? DateTime.parse(dateNaissance!.split('-').reversed.join('-'))
            : null, // Convert DD-MM-YYYY to DateTime
        tituPpAdresse: adresse ?? '',
        tituPpEmail: email ?? '',
        tituPpTelMobileNo: numeroTelephone ?? '',
        tituPpBoolTun: true, // Assuming Tunisian
        tituPpBoolResident: true, // Assuming resident
        tituPpBoolFatca: false,
        tituPpBoolVip: false,
        tituPpBoolExemptRS: false,
        tituPpBoolExemptTva: false,
        tituPpBoolPep: false,
        tituPpBoolHandicap: false,
        // For non-mandate, set mandPp to same as tituPp
        mandPpPieceIdentiteCode: typePieceMand ?? '',
        mandPpPieceIdentiteNo: numeroPieceMand ?? '',
        mandPpNom: nomMand ?? '',
        mandPpPrenom: prenomMand ?? '',
        mandPpNaissanceDate: dateNaissanceMand != null
            ? DateTime.parse(dateNaissanceMand!.split('-').reversed.join('-'))
            : null,
        mandPpAdresse: adresseMand ?? '',
        mandPpEmail: emailMand ?? '',
        mandPpTelMobileNo: numeroTelephoneMand ?? '',
        mandPpBoolTun: true,
        mandPpBoolResiden: true,
        walletNoTelGestion: telGestion ?? '',
        walletEmailGestion: mailGestion ?? '',
        demNewCompteNewMandGesSecours: recoveryPhone ?? '',
        demNewCompteNewMandEmailSecours: recoveryEmail ?? '',

      );

      // Prepare images and titles for titu using DocumentManager
      List<String> images = [];
      List<String> titres = [];

      // Load documents with their codes
      final documentsWithCodesTitu =
          await DocumentManager.loadDocumentsWithCodes('titu');

      documentsWithCodesTitu.forEach((imagePath, documentCode) {
        if (File(imagePath).existsSync()) {
          images.add(imagePath);
          titres.add(documentCode); // Use document code as title
        }
      });

      // Prepare images and titles for mand (placeholder - implement similar logic)
      List<String> imagesMand = [];
      List<String> titresMand = [];

      final documentsWithCodesMand =
          await DocumentManager.loadDocumentsWithCodes('mand');

      documentsWithCodesMand.forEach((imagePath, documentCode) {
        if (File(imagePath).existsSync()) {
          imagesMand.add(imagePath);
          titresMand.add(documentCode); // Use document code as title
        }
      });

      // Upload files first
      await uploadFilesAndMandfiles(images, titres, imagesMand, titresMand);

      // Submit the request
      final response = await http.post(
        Uri.parse('http://${backendServer}:8081/demOuvCompte/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'demOuvCompteMandBool': dmd.demOuvCompteMandBool,
          'demOuvCompteMandEmisDate': dmd.demOuvCompteMandEmisDate
              ?.toIso8601String()
              .split('T')[0],
          'tituPpPieceIdentiteCode': dmd.tituPpPieceIdentiteCode,
          'tituPpPieceIdentiteNo': dmd.tituPpPieceIdentiteNo,
          'tituPpNom': dmd.tituPpNom,
          'tituPpPrenom': dmd.tituPpPrenom,
          'tituPpAdresse': dmd.tituPpAdresse,
          'tituPpEmail': dmd.tituPpEmail,
          'tituPpTelMobileNo': dmd.tituPpTelMobileNo,
          'tituPpBoolTun': dmd.tituPpBoolTun,
          'tituPpBoolResident': dmd.tituPpBoolResident,
          'tituPpBoolFatca': dmd.tituPpBoolFatca,
          'tituPpBoolVip': dmd.tituPpBoolVip,
          'tituPpBoolExemptRs': dmd.tituPpBoolExemptRS,
          'tituPpBoolExemptTva': dmd.tituPpBoolExemptTva,
          'tituPpBoolPep': dmd.tituPpBoolPep,
          'tituPpBoolHandicap': dmd.tituPpBoolHandicap,
          'mandPpPieceIdentiteCode': dmd.mandPpPieceIdentiteCode,
          'mandPpPieceIdentiteNo': dmd.mandPpPieceIdentiteNo,
          'mandPpNom': dmd.mandPpNom,
          'mandPpPrenom': dmd.mandPpPrenom,
          'mandPpNaissanceDate': dmd.mandPpNaissanceDate
              ?.toIso8601String()
              .split('T')[0],
          'mandPpAdresse': dmd.mandPpAdresse,
          'mandPpEmail': dmd.mandPpEmail,

          'mandPpTelMobileNo': dmd.mandPpTelMobileNo,
          'mandPpBoolTun': dmd.mandPpBoolTun! ? 'O' : 'N',
          'mandPpBoolResident': dmd.mandPpBoolResiden! ? 'O' : 'N',
          'mandPpBoolHandicapSign': 'N', // Assuming no handicap
          'walletNoTelGestion': dmd.walletNoTelGestion,
          'walletEmailGestion': dmd.walletEmailGestion,
          'demNewCompteGesSecours': dmd.demNewCompteNewMandGesSecours,
          'demNewCompteEmailSecours': dmd.demNewCompteNewMandEmailSecours,
          'demNewCompteLang': 'fr', // Assuming French
        }),
      );

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        // Update the request status
        final response2 = await updateDemOuvNewCompteNewMand(
          '3', // modeOuvCompteId
          // dmd.niveauCompte?.niveauCompteId.toString() ?? '1', // niveauCompteId
          niveau == 'Niveau1' ? '1' : '2',

          '1', // statutDemandeOuvCompteId
          '1', // uniteGestionId
          jsonDecode(response.body)['demOuvCompteMandId'],
          response.body,
        );

        submissionSuccess = true;
        submissionMessage =
            'Votre demande d\'ouverture de compte a été déposée avec succès.';
      } else {
        submissionSuccess = false;
        submissionMessage = 'Erreur lors de la soumission de la demande.';
      }
    } catch (e) {
      submissionSuccess = false;
      submissionMessage = 'Erreur lors de la soumission: $e';
    }

    isLoading = false;
    notifyListeners();
  }

 Future<void> submitScenario3() async {
    isLoading = true;
    submissionMessage = null;
    notifyListeners();

    try {
      // Create DemOuvNewCompteNewMand object
      DemOuvNewCompteNewMand dmd = DemOuvNewCompteNewMand(
        demOuvCompteMandBool: false, // No mandate
        demOuvCompteMandEmisDate: DateTime.now(),
        tituPmPieceIdentiteCode: pmTypePiece ?? '',
        tituPmPieceIdentiteNo: pmNumeroPiece ?? '',
       tituPmRaisonSociale: raisonSociale ?? '' ,
        tituPmCreationDate : dateCreation != null
            ? DateTime.parse(dateCreation!.split('-').reversed.join('-'))
            : null, // Convert DD-MM-YYYY to DateTime
        tituPmAdresse: adresse ?? '',
        tituPmEmail: email ?? '',
        tituPmTelNo: numeroTelephone ?? '',
     
        // For non-mandate, set mandPp to same as tituPp
        mandPpPieceIdentiteCode: typePieceMand ?? '',
        mandPpPieceIdentiteNo: numeroPieceMand ?? '',
        mandPpNom: nomMand ?? '',
        mandPpPrenom: prenomMand ?? '',
        mandPpNaissanceDate: dateNaissanceMand != null
            ? DateTime.parse(dateNaissanceMand!.split('-').reversed.join('-'))
            : null,
        mandPpAdresse: adresseMand ?? '',
        mandPpEmail: emailMand ?? '',
        mandPpTelMobileNo: numeroTelephoneMand ?? '',
        mandPpBoolTun: true,
        mandPpBoolResiden: true,
        walletNoTelGestion: telGestion ?? '',
        walletEmailGestion: mailGestion ?? '',
        demNewCompteNewMandGesSecours: recoveryPhone ?? '',
        demNewCompteNewMandEmailSecours: recoveryEmail ?? '',

      );

      // Prepare images and titles for titu using DocumentManager
      List<String> images = [];
      List<String> titres = [];

      // Load documents with their codes
      final documentsWithCodesTitu =
          await DocumentManager.loadDocumentsWithCodes('titu');

      documentsWithCodesTitu.forEach((imagePath, documentCode) {
        if (File(imagePath).existsSync()) {
          images.add(imagePath);
          titres.add(documentCode); // Use document code as title
        }
      });

      // Prepare images and titles for mand (placeholder - implement similar logic)
      List<String> imagesMand = [];
      List<String> titresMand = [];

      final documentsWithCodesMand =
          await DocumentManager.loadDocumentsWithCodes('mand');

      documentsWithCodesMand.forEach((imagePath, documentCode) {
        if (File(imagePath).existsSync()) {
          imagesMand.add(imagePath);
          titresMand.add(documentCode); // Use document code as title
        }
      });

      // Upload files first
      await uploadFilesAndMandfiles(images, titres, imagesMand, titresMand);

      // Submit the request
      final response = await http.post(
        Uri.parse('http://${backendServer}:8081/demOuvCompte/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'demOuvCompteMandBool': dmd.demOuvCompteMandBool,
          'demOuvCompteMandEmisDate': dmd.demOuvCompteMandEmisDate
              ?.toIso8601String()
              .split('T')[0],
          'tituPmPieceIdentiteCode': dmd.tituPmPieceIdentiteCode,
          'tituPmPieceIdentiteNo': dmd.tituPmPieceIdentiteNo,
          'tituPmRaisonSociale': dmd.tituPmRaisonSociale,
         'tituPmCreationDate'      : dmd.tituPmCreationDate   ?.toIso8601String()
              .split('T')[0],
        
          'tituPmAdresse': dmd.tituPmAdresse,
          'tituPmEmail': dmd.tituPmEmail,
          'tituPmTelNo': dmd.tituPmTelNo,
         
          'mandPpPieceIdentiteCode': dmd.mandPpPieceIdentiteCode,
          'mandPpPieceIdentiteNo': dmd.mandPpPieceIdentiteNo,
          'mandPpNom': dmd.mandPpNom,
          'mandPpPrenom': dmd.mandPpPrenom,
          'mandPpNaissanceDate': dmd.mandPpNaissanceDate
              ?.toIso8601String()
              .split('T')[0],
          'mandPpAdresse': dmd.mandPpAdresse,
          'mandPpEmail': dmd.mandPpEmail,

          'mandPpTelMobileNo': dmd.mandPpTelMobileNo,
          'mandPpBoolTun': dmd.mandPpBoolTun! ? 'O' : 'N',
          'mandPpBoolResident': dmd.mandPpBoolResiden! ? 'O' : 'N',
          'mandPpBoolHandicapSign': 'N', // Assuming no handicap
          'walletNoTelGestion': dmd.walletNoTelGestion,
          'walletEmailGestion': dmd.walletEmailGestion,
          'demNewCompteGesSecours': dmd.demNewCompteNewMandGesSecours,
          'demNewCompteEmailSecours': dmd.demNewCompteNewMandEmailSecours,
          'demNewCompteLang': 'fr', // Assuming French
        }),
      );

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        // Update the request status
        final response2 = await updateDemOuvNewCompteNewMand(
          '3', // modeOuvCompteId
          // dmd.niveauCompte?.niveauCompteId.toString() ?? '1', // niveauCompteId
          niveau == 'Niveau1' ? '1' : '2',

          '1', // statutDemandeOuvCompteId
          '1', // uniteGestionId
          jsonDecode(response.body)['demOuvCompteMandId'],
          response.body,
        );

        submissionSuccess = true;
        submissionMessage =
            'Votre demande d\'ouverture de compte a été déposée avec succès.';
      } else {
        submissionSuccess = false;
        submissionMessage = 'Erreur lors de la soumission de la demande.';
      }
    } catch (e) {
      submissionSuccess = false;
      submissionMessage = 'Erreur lors de la soumission: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> uploadFiles(List<String> images, List<String> titres) async {
    var url = Uri.parse("http://${backendServer}:8081/demOuvCompte/upload");
    var request = http.MultipartRequest("POST", url);

    // Load documents with their codes using DocumentManager
    final documentsWithCodes = await DocumentManager.loadDocumentsWithCodes(
      'titu',
    );

    for (var i = 0; i < titres.length; i++) {
      final fileBytes = await File.fromUri(Uri.parse(images[i])).readAsBytes();

      // Get document code for this image
      final documentCode = documentsWithCodes[images[i]] ?? 'DOC_${i + 1}';

      // Use document code as filename (without extension)
      final filename = DocumentManager.getDocumentFilename(documentCode);

      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          fileBytes,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      print("Uploaded!");
    } else {
      print("Upload failed with status ${response.statusCode}");
    }
  }

  uploadFilesAndMandfiles(
    tituimages,
    titutitres,
    mandimages,
    mandtitres,
  ) async {
    var url = Uri.parse("http://${backendServer}:8081/demOuvCompte/upload");
    var request = http.MultipartRequest("POST", url);

    // Load documents with their codes using DocumentManager
    final documentsWithCodes = await DocumentManager.loadDocumentsWithCodes(
      'titu',
    );
    final documentsWithCodesMand = await DocumentManager.loadDocumentsWithCodes(
      'mand',
    );

    // Load mandate documents with their codes (assuming similar structure)
    // Note: You may need to implement similar logic for mandate documents

    if (titutitres.length == tituimages.length) {
      for (var i = 0; i < titutitres.length; i++) {
        print(titutitres[i]);

        final fileBytes = await File.fromUri(
          Uri.parse(tituimages[i]),
        ).readAsBytes();

        // Get document code for this image
        final documentCode =
            documentsWithCodes[tituimages[i]] ?? 'TITU_DOC_${i + 1}';

        // Use document code as filename (without extension)
        final filename = DocumentManager.getDocumentFilename(documentCode);

        request.files.add(
          http.MultipartFile.fromBytes(
            'files',
            fileBytes,
            contentType: MediaType('image', 'jpeg'),
            filename: filename,
          ),
        );
      }
    }

    if (mandimages.length == mandtitres.length) {
      for (var i = 0; i < mandtitres.length; i++) {
        print(mandtitres[i]);

        final fileBytes = await File.fromUri(
          Uri.parse(mandimages[i]),
        ).readAsBytes();

        // Get document code for this image (use fallback for mandate)
        final documentCode =
            documentsWithCodesMand[mandimages[i]] ?? 'MAND_DOC_${i + 1}';

        // Use document code as filename (without extension)
        final filename = DocumentManager.getDocumentFilename(documentCode);

        request.files.add(
          http.MultipartFile.fromBytes(
            'filesMandataire',
            fileBytes,
            contentType: MediaType('image', 'jpeg'),
            filename: filename,
          ),
        );
      }
    }

    await request.send().then((response) {
      if (response.statusCode == 200) print("Titu and mand files Uploaded!");
    });
  }

  Future<dynamic> updateDemOuvNewCompteNewMand(
    String modeOuvCompteId,
    String niveauCompteId,
    String statutDemandeOuvCompteId,
    String uniteGestionId,
    dynamic demOuvCompteMandId,
    dynamic dmd,
  ) async {
    final response = await http.put(
      Uri.parse(
        'http://${backendServer}:8081/demOuvCompte/$modeOuvCompteId/$niveauCompteId/P/$statutDemandeOuvCompteId/$uniteGestionId/demOuvCompte/$demOuvCompteMandId',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: dmd,
    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      return DemOuvNewCompteNewMand.fromJson(jsonDecode(response.body));
    }
  }

  void navigateToDashboard(BuildContext context) {
    // Navigate to dashboard or main screen
    NavigatorService.pushNamed(AppRoutes.appNavigationScreen);
  }

  getScenarioNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? accountTypePPPM = prefs.getString('selected_account_typePPPM');
    isPhysicalPerson =
        accountTypePPPM == 'individual'; // individual = physical person
    // String numeroPiece = prefs.getString('personal_mand_numero_piece');

    if (!isPhysicalPerson!)
      return "Scenario3";
    else if (numeroPieceMand != null)
      return "Scenario2";
    else
      return "Scenario1";
  }
}
