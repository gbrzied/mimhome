import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_export.dart';
import '../models/personal_informations_model.dart';

// Constants from old version
final Map<String, Map<String, String>> codePieceToLabelMapper = {
  'fr': {
    'TNCIN': 'CIN',
    'TNPASS': 'PS',
    'TNRNE': 'RNE',
    'CIN': 'CIN',
  },
  'en': {
    'TNCIN': 'CIN',
    'TNPASS': 'PS',
    'TNRNE': 'RNE'
  },
  'ar': {
    'TNCIN': 'CIN',
    'TNPASS': 'PS',
    'TNRNE': 'RNE'
  },
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
    errorMessage: 'err_tncin_regex',
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
    return ValidationResult(isValid: false, errorMessage: regexInfo.errorMessage);
  }
}

const int tncinLength = 8;
const int tnpassLength = 7;

class PersonalInformationsProvider extends ChangeNotifier {
  PersonalInformationsModel personalInformationsModel = PersonalInformationsModel();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController nomController =TextEditingController();//= TextEditingController(text: 'Ben foulen');
  late  final TextEditingController prenomController =TextEditingController();//= TextEditingController(text: 'Foulen');
  late final TextEditingController dateController =TextEditingController() ;//= TextEditingController(text: '06-10-2005');
  late final TextEditingController adresseController=TextEditingController() ;//= TextEditingController(text: 'Nabeul');
  late final TextEditingController phoneController =TextEditingController();//= TextEditingController(text: '98989898');
  late final TextEditingController emailController =TextEditingController();//= TextEditingController(text: 'foulenbenfoulen@gmail.com');
  late final TextEditingController typePieceController = TextEditingController();
  late final TextEditingController numeroPieceController = TextEditingController();

  AccountType selectedAccountType = AccountType.titulaireEtSignataire;

  bool isLoading = false;

  // Person type: true for physical person (PP), false for moral person (PM)
  bool isPhysicalPerson = true; // Default to physical person

  // Dynamic document types
  List<Map<String, String>> documentTypes = [];
  bool isLoadingDocumentTypes = false;

  void initialize() async {
    // Read person type from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accountType = prefs.getString('selected_account_type');
    isPhysicalPerson = accountType == 'individual'; // individual = physical person

    // Initialize with default values
    personalInformationsModel = PersonalInformationsModel(
      nom: nomController.text,
      prenom: prenomController.text,
      dateNaissance: dateController.text,
      adresse: adresseController.text,
      numeroTelephone: phoneController.text,
      email: emailController.text,
      typePiece: typePieceController.text,
      numeroPiece: numeroPieceController.text,
      typeCompte: selectedAccountType,
      isPhysicalPerson: isPhysicalPerson,
    );

    // Load dynamic document types
    loadDocumentTypes();

    notifyListeners();
  }

  Future<void> loadDocumentTypes() async {
    isLoadingDocumentTypes = true;
    notifyListeners();

    try {
      final types = await chargerListePiece(isPhysicalPerson); // Use the person type
      documentTypes = types.map((type) {
        final code = type['pieceIdentiteCode'] as String;
        final label = codePieceToLabelMapper['fr']?[code] ?? code; // Default to French
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
    final response = await http.get(Uri.parse('http://192.168.1.13:8081/pieceIdentite/'));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      final listePieces = jsonDecode(response.body) as List<dynamic>;
      List<dynamic> filtrelistePieces;
      if (physique) {
        filtrelistePieces = listePieces.where((e) => !e['pieceIdentiteBoolPmTun']).toList();
      } else {
        filtrelistePieces = listePieces.where((e) => e['pieceIdentiteBoolPmTun']).toList();
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
        return ValidationResult(isValid: false, errorMessage: 'La CIN doit contenir $tncinLength chiffres');
      } else if (documentType == 'TNPASS' && value.length != tnpassLength) {
        return ValidationResult(isValid: false, errorMessage: 'Le passeport doit contenir $tnpassLength caractères');
      }
      return ValidationResult(isValid: true);
    }
  }

  void updateNom(String value) {
    personalInformationsModel.nom = value;
    notifyListeners();
  }

  void updatePrenom(String value) {
    personalInformationsModel.prenom = value;
    notifyListeners();
  }

  void updateDateNaissance(String value) {
    personalInformationsModel.dateNaissance = value;
    notifyListeners();
  }

  void updateAdresse(String value) {
    personalInformationsModel.adresse = value;
    notifyListeners();
  }

  void updateNumeroTelephone(String value) {
    personalInformationsModel.numeroTelephone = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    personalInformationsModel.email = value;
    notifyListeners();
  }

  void updateTypePiece(String value) {
    personalInformationsModel.typePiece = value;
    notifyListeners();
  }

  void updateNumeroPiece(String value) {
    personalInformationsModel.numeroPiece = value;
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appTheme.cyan_900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate = '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      dateController.text = formattedDate;
      updateDateNaissance(formattedDate);
      // Validate immediately after date selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState?.validate();
      });
    }
  }

  void onSubmit(BuildContext context) {
    if (formKey.currentState!.validate()) {
      isLoading = true;
      notifyListeners();

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

        // Navigate to next screen (placeholder - update with actual route when available)
        // NavigatorService.pushNamed(AppRoutes.nextScreen);
              NavigatorService.pushNamed(AppRoutes.identityVerificationScreen);

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
    super.dispose();
  }
}