import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../models/personal_informations_model.dart';

class PersonalInformationsProvider extends ChangeNotifier {
  PersonalInformationsModel personalInformationsModel = PersonalInformationsModel();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nomController = TextEditingController(text: 'Ben foulen');
  final TextEditingController prenomController = TextEditingController(text: 'Foulen');
  final TextEditingController dateController = TextEditingController(text: '06-10-2005');
  final TextEditingController adresseController = TextEditingController(text: 'Nabeul');
  final TextEditingController phoneController = TextEditingController(text: '98989898');
  final TextEditingController emailController = TextEditingController(text: 'foulenbenfoulen@gmail.com');

  AccountType selectedAccountType = AccountType.titulaireEtSignataire;

  bool isLoading = false;

  void initialize() {
    // Initialize with default values
    personalInformationsModel = PersonalInformationsModel(
      nom: nomController.text,
      prenom: prenomController.text,
      dateNaissance: dateController.text,
      adresse: adresseController.text,
      numeroTelephone: phoneController.text,
      email: emailController.text,
      typeCompte: selectedAccountType,
    );
    notifyListeners();
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

  void selectAccountType(AccountType type) {
    selectedAccountType = type;
    personalInformationsModel.typeCompte = type;
    notifyListeners();
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
    super.dispose();
  }
}