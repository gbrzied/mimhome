import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/app_export.dart';
import '../../../models/demOuvNewCompteNewMand.dart';
import '../../../models/NiveauCompte.dart';

class EnrollmentSuccessProvider extends ChangeNotifier {
  bool isLoading = false;
  String? submissionMessage;
  bool submissionSuccess = false;

  // Collected data from SharedPreferences
  String? nom;
  String? prenom;
  String? dateNaissance;
  String? adresse;
  String? numeroTelephone;
  String? email;
  String? typePiece;
  String? numeroPiece;
  String? selectedAccountType;
  bool? isPhysicalPerson;
  List<String>? documentImages;
  String? cinr;
  bool? pieceIdVerifiee;
  String? selectedPieceType;
  String? recoveryPhone;
  String? recoveryEmail;
  String? signaturePath;

  void initialize() async {
    isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load personal info
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

    // Load identity verification data
    documentImages = prefs.getStringList('identity_document_images');
    cinr = prefs.getString('identity_cinr');
    pieceIdVerifiee = prefs.getBool('identity_piece_id_verifiee');
    selectedPieceType = prefs.getString('identity_selected_piece_type');

    // Load recovery data
    recoveryPhone = prefs.getString('recovery_phone');
    recoveryEmail = prefs.getString('recovery_email');
    signaturePath = prefs.getString('signature_path');

    isLoading = false;
    notifyListeners();

    // Auto-submit the request
    submitAccountOpeningRequest();
  }

  Future<void> submitAccountOpeningRequest() async {
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
        tituPpNaissanceDate: dateNaissance != null ? DateTime.parse(dateNaissance!.split('-').reversed.join('-')) : null, // Convert DD-MM-YYYY to DateTime
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
        mandPpNaissanceDate: dateNaissance != null ? DateTime.parse(dateNaissance!.split('-').reversed.join('-')) : null,
        mandPpAdresse: adresse ?? '',
        mandPpEmail: email ?? '',
        mandPpTelMobileNo: numeroTelephone ?? '',
        mandPpBoolTun: true,
        mandPpBoolResiden: true,
        walletNoTelGestion: recoveryPhone ?? '',
        walletEmailGestion: recoveryEmail ?? '',
        demNewCompteNewMandGesSecours: recoveryPhone ?? '',
        demNewCompteNewMandEmailSecours: recoveryEmail ?? '',
        niveauCompte: NiveauCompte(niveauCompteId: selectedAccountType == 'Niveau1' ? 1 : 2, niveauCompteDsg: selectedAccountType ?? 'Niveau1'),
      );

      // Prepare images and titles
      List<String> images = [];
      List<String> titres = [];

      if (documentImages != null) {
        for (int i = 0; i < documentImages!.length; i++) {
          String imagePath = documentImages![i];
          if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
            images.add(imagePath);
            titres.add('document_$i');
          }
        }
      }

      // Upload files first
      await uploadFiles(images, titres);

      // Submit the request
      final response = await http.post(
        Uri.parse('http://192.168.1.13:8081/demOuvCompte/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'demOuvCompteMandBool': dmd.demOuvCompteMandBool,
          'demOuvCompteMandEmisDate': dmd.demOuvCompteMandEmisDate?.toIso8601String().split('T')[0],
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
          'mandPpNaissanceDate': dmd.mandPpNaissanceDate?.toIso8601String().split('T')[0],
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
          dmd.niveauCompte?.niveauCompteId.toString() ?? '1', // niveauCompteId
          '1', // statutDemandeOuvCompteId
          '1', // uniteGestionId
          jsonDecode(response.body)['demOuvCompteMandId'],
          response.body,
        );

        submissionSuccess = true;
        submissionMessage = 'Votre demande d\'ouverture de compte a été déposée avec succès.';
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
    var url = Uri.parse("http://192.168.1.13:8081/demOuvCompte/upload");
    var request = http.MultipartRequest("POST", url);

    for (var i = 0; i < titres.length; i++) {
      final fileBytes = await File.fromUri(Uri.parse(images[i])).readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'files',
        fileBytes,
        filename: titres[i],
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      print("Uploaded!");
    } else {
      print("Upload failed with status ${response.statusCode}");
    }
  }


  Future<dynamic> updateDemOuvNewCompteNewMand(
      String modeOuvCompteId,
      String niveauCompteId,
      String statutDemandeOuvCompteId,
      String uniteGestionId,
      dynamic demOuvCompteMandId,
      dynamic dmd) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.13:8081/demOuvCompte/$modeOuvCompteId/$niveauCompteId/P/$statutDemandeOuvCompteId/$uniteGestionId/demOuvCompte/$demOuvCompteMandId'),
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
}