import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:millime/core/utils/functions.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_export.dart';
import '../models/personal_informations_mand_model.dart';
import 'package:millime/core/build_info.dart';

// Constants from old version
final Map<String, Map<String, String>> codePieceToLabelMapper = {
  'fr': {'TNCIN': 'CIN', 'TNPASS': 'PS', 'TNRNE': 'RNE', 'CIN': 'CIN'},
  'en': {'TNCIN': 'CIN', 'TNPASS': 'PS', 'TNRNE': 'RNE'},
  'ar': {'TNCIN': 'CIN', 'TNPASS': 'PS', 'TNRNE': 'RNE'},
};

class RegexInfo {
  final RegExp regEx;
  final String errorMessage;

  RegexInfo({required this.regEx, required this.errorMessage});
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({required this.isValid, this.errorMessage});
}

final Map<String, RegexInfo> regexMap = {
  'TNCIN': RegexInfo(
    regEx: RegExp(r'^[0-9]{8}$'),
    errorMessage: 'Numéro CIN érroné',
  ),
  'TNPASS': RegexInfo(
    regEx: RegExp(r'^[A-Z][0-9]{6}$'),
    errorMessage: 'err_tnpassport_regex',
  ),
  'YYYY_MM_DD': RegexInfo(
    regEx: RegExp(r'^\d{4}-\d{2}-\d{2}$'),
    errorMessage: 'La valeur doit être une date au format YYYY-MM-DD.',
  ),
};

ValidationResult doesValueMatchRegex(String key, String value) {
  final RegexInfo? regexInfo = regexMap[key];
  if (regexInfo == null) {
    throw ArgumentError('La clé $key n\'existe pas dans la map.');
  }

  if (regexInfo.regEx.hasMatch(value)) {
    return ValidationResult(isValid: true);
  } else {
    return ValidationResult(
      isValid: false,
      errorMessage: regexInfo.errorMessage,
    );
  }
}

const int tncinLength = 8;
const int tnpassLength = 7;

class PersonalInformationsMandProvider extends ChangeNotifier {
  PersonalInformationsMandModel personalInformationsModel =
      PersonalInformationsMandModel();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController nomController =
      TextEditingController(); //= TextEditingController(text: 'Ben foulen');
  late final TextEditingController prenomController =
      TextEditingController(); //= TextEditingController(text: 'Foulen');
  late final TextEditingController dateController =
      TextEditingController(); //= TextEditingController(text: '06-10-2005');
  late final TextEditingController adresseController =
      TextEditingController(); //= TextEditingController(text: 'Nabeul');
  late final TextEditingController phoneController =
      TextEditingController(); //= TextEditingController(text: '98989898');
  late final TextEditingController emailController =
      TextEditingController(); //= TextEditingController(text: 'foulenbenfoulen@gmail.com');
  late final TextEditingController typePieceController =
      TextEditingController();
  late final TextEditingController numeroPieceController =
      TextEditingController();

  AccountType selectedAccountType = AccountType.titulaireEtSignataire;

  bool isLoading = false;

  // Add state for phone number mismatch error
  String? phoneNumberMismatchError;

  // Add state for email mismatch error
  String? emailMismatchError;

  // Add state for handicap checkbox
  bool isHandicapChecked = false;
  final TextEditingController handicapMotifController = TextEditingController();

  // Person type: true for physical person (PP), false for moral person (PM)
  bool isPhysicalPerson = true; // Default to physical person

  // Dynamic document types
  List<Map<String, String>> documentTypes = [];
  bool isLoadingDocumentTypes = false;

  void initialize() async {
    // Read person type from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accountTypePPPM = prefs.getString('selected_account_typePPPM');
    isPhysicalPerson =
        accountTypePPPM == 'individual'; // individual = physical person

    // Retrieve stored phone number and email from TermsConditionsScreenV2
    String? storedPhoneNumber = prefs.getString('terms_phone_number');
    String? storedEmail = prefs.getString('terms_email');

    // Initialize with default values or stored values
    personalInformationsModel = PersonalInformationsMandModel(
      nom: nomController.text,
      prenom: prenomController.text,
      dateNaissance: dateController.text,
      adresse: adresseController.text,
      numeroTelephone: storedPhoneNumber ?? phoneController.text,
      email: storedEmail ?? emailController.text,
      typePiece: typePieceController.text,
      numeroPiece: numeroPieceController.text,
      typeCompte: selectedAccountType,
      isPhysicalPerson: isPhysicalPerson,
    );

    // Set the stored values to the controllers
    //  if (storedPhoneNumber != null) {
    //    phoneController.text = storedPhoneNumber;
    //  }
    //  if (storedEmail != null) {
    //    emailController.text = storedEmail;
    //  }

    // Load dynamic document types
    loadDocumentTypes();

    notifyListeners();
  }

  Future<void> loadDocumentTypes() async {
    isLoadingDocumentTypes = true;
    notifyListeners();

    try {
      final types = await chargerListePiece(true); // Use the person type
      documentTypes = types.map((type) {
        final code = type['pieceIdentiteCode'] as String;
        final label =
            codePieceToLabelMapper['fr']?[code] ?? code; // Default to French
        return {'code': code, 'label': label};
      }).toList();
    } catch (e) {
      // Fallback to static types if API fails
      documentTypes = [
        {'code': 'TNCIN', 'label': 'CIN'},
        {'code': 'TNPASS', 'label': 'PS'},
        {'code': 'TNRNE', 'label': 'RNE'},
      ];
    }

    isLoadingDocumentTypes = false;
    notifyListeners();
  }

  Future<List<dynamic>> chargerListePiece(bool physique) async {
    final response = await http.get(
      Uri.parse('http://${backendServer}:8081/pieceIdentite/'),
    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      final listePieces = jsonDecode(response.body) as List<dynamic>;
      List<dynamic> filtrelistePieces;
      if (physique) {
        filtrelistePieces = listePieces
            .where((e) => !e['pieceIdentiteBoolPmTun'])
            .toList();
      } else {
        filtrelistePieces = listePieces
            .where((e) => e['pieceIdentiteBoolPmTun'])
            .toList();
      }
      return filtrelistePieces;
    } else {
      throw Exception('Failed to load document types');
    }
  }

  ValidationResult validateDocumentNumber(String documentType, String value) {
    try {
      return doesValueMatchRegex(documentType, value);
    } catch (e) {
      // If regex not found, check length
      if (documentType == 'TNCIN' && value.length != tncinLength) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'La CIN doit contenir $tncinLength chiffres',
        );
      } else if (documentType == 'TNPASS' && value.length != tnpassLength) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Le passeport doit contenir $tnpassLength caractères',
        );
      }
      return ValidationResult(isValid: true);
    }
  }

  void updateNom(String value) async {
    personalInformationsModel.nom = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('personal_mand_nom', value);
    notifyListeners();
  }

  void updatePrenom(String value) async {
    personalInformationsModel.prenom = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('personal_mand_prenom', value);
    notifyListeners();
  }

  void updateDateNaissance(String value) async {
    personalInformationsModel.dateNaissance = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('personal_mand_date_naissance', value);
    notifyListeners();
  }

  void updateAdresse(String value) async {
    personalInformationsModel.adresse = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('personal_mand_adresse', value);
    notifyListeners();
  }

  void updateNumeroTelephone(String value) async {
    personalInformationsModel.numeroTelephone = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('personal_mand_numero_telephone', value);

    // Verify against stored phone number from TermsConditionsScreenV2
    String? storedPhoneNumber = prefs.getString('terms_phone_number');
    if (storedPhoneNumber != null && value != storedPhoneNumber) {
      // Phone number doesn't match - show error or handle accordingly
      // For now, we'll just log it, but you could show a snackbar or dialog
      debugPrint(
        'Phone number mismatch: entered=$value, stored=$storedPhoneNumber',
      );
    }

    notifyListeners();
  }

  Future<bool> validateNumPieceMatch(String codePiece, String numPiece) async {
    dynamic pp = await fetchPersonnePbyPieceIdentite(codePiece, numPiece);

    if (pp != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = jsonDecode(pp);

      await prefs.setBool('personne_mand_exist', true);

      nomController.text = data['ppNom'] ?? '';
      prenomController.text = data['ppPrenom'] ?? '';
      dateController.text = data['ppDateNaissance'] ?? '';
      adresseController.text = data['ppAdresse'] ?? '';
    }
    notifyListeners();
    return true; // Phone numbers match or no stored number
  }

  // New method to validate phone number against stored value
  Future<bool> validatePhoneNumberMatch(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPhoneNumber = prefs.getString('terms_phone_number');

    if (storedPhoneNumber != null && phoneNumber != storedPhoneNumber) {
      phoneNumberMismatchError =
          'utiliser le tél de gestion'; // err_numero_different
      notifyListeners();
      return false; // Phone numbers don't match
    }

    phoneNumberMismatchError = null;
    notifyListeners();
    return true; // Phone numbers match or no stored number
  }

  // New method to validate email against stored value
  Future<bool> validateEmailMatch(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('terms_email');

    if (storedEmail != null && email != storedEmail) {
      emailMismatchError = 'utiliser le mail de gestion'; //err_email_different
      notifyListeners();
      return false; // Emails don't match
    }

    emailMismatchError = null;
    notifyListeners();
    return true; // Emails match or no stored email
  }

  void updateEmail(String value) async {
    personalInformationsModel.email = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('personal_mand_email', value);

    // Verify against stored email from TermsConditionsScreenV2
    String? storedEmail = prefs.getString('terms_email');
    if (storedEmail != null && value != storedEmail) {
      // Email doesn't match - show error or handle accordingly
      debugPrint('Email mismatch: entered=$value, stored=$storedEmail');
    }

    notifyListeners();
  }

  void updateTypePiece(String value) async {
    personalInformationsModel.typePiece = value;
    // Save to SharedPreferences for global access
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('personal_mand_type_piece', value);
    notifyListeners();
  }

  void updateNumeroPiece(String value) async {
    personalInformationsModel.numeroPiece = value;
    // Save to SharedPreferences for global access
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('personal_mand_numero_piece', value);
    notifyListeners();
  }

  void selectAccountType(AccountType type) {
    selectedAccountType = type;
    personalInformationsModel.typeCompte = type;
    notifyListeners();
  }

  void setPersonType(bool isPhysical) {
    isPhysicalPerson = isPhysical;
    personalInformationsModel.isPhysicalPerson = isPhysical;
    // Reload document types if needed
    loadDocumentTypes();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 10, 6),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: appTheme.cyan_900),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      dateController.text = formattedDate;
      updateDateNaissance(formattedDate);
      // Validate immediately after date selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState?.validate();
      });
    }
  }

  void onSubmit(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      isLoading = true;
      notifyListeners();

      // Save all form data to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('personal_mand_nom', nomController.text);
      await prefs.setString('personal_mand_prenom', prenomController.text);
      await prefs.setString(
        'personal_mand_date_naissance',
        dateController.text,
      );
      await prefs.setString('personal_mand_adresse', adresseController.text);
      await prefs.setString(
        'personal_mand_numero_telephone',
        phoneController.text,
      );
      await prefs.setString('personal_mand_email', emailController.text);
      await prefs.setString(
        'personal_mand_type_piece',
        typePieceController.text,
      );
      await prefs.setString(
        'personal_mand_numero_piece',
        numeroPieceController.text,
      );
      await prefs.setString(
        'personal_mand_selected_account_type',
        selectedAccountType.toString(),
      );
      await prefs.setBool('personal_mand_is_physical_person', isPhysicalPerson);
      await prefs.setBool(
        'personal_mand_is_handicap_checked',
        isHandicapChecked,
      );
      if (isHandicapChecked) {
        await prefs.setString(
          'personal_mand_handicap_motif',
          handicapMotifController.text,
        );
      }

      // Simulate form processing
      Future.delayed(Duration(milliseconds: 500), () {
        isLoading = false;
        notifyListeners();

        // Show success message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Informations personnelles enregistrées avec succès'),
            backgroundColor: appTheme.cyan_900,
          ),
        );

        // Navigate to next screen
        NavigatorService.pushNamed(AppRoutes.identityVerificationMandScreen);
      });
    }
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    dateController.dispose();
    adresseController.dispose();
    phoneController.dispose();
    emailController.dispose();
    typePieceController.dispose();
    numeroPieceController.dispose();
    handicapMotifController.dispose();
    super.dispose();
  }
}
