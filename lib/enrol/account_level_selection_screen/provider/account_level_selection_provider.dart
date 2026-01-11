import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:millime/core/build_info.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_export.dart';
import '../models/account_level_selection_model.dart';

class AccountLevelSelectionProvider extends ChangeNotifier {
  AccountLevelSelectionModel accountLevelSelectionModel =
      AccountLevelSelectionModel();

  int selectedLevelIndex = 0; // Default to first level
  bool isLoading = false;
  late SharedPreferences prefs;

  bool isIndividual = true; // true for PP, false for PM
  // Backend server URL - adjust as needed

  // Currency decimal places
  final int deviseNbrDec = 3;

  String formatDoubleToString(dynamic value, int decimalPlaces) {
    if (value == null || value == '') return '';
    try {
      double numValue;
      if (value is String) {
        if (value.isEmpty) return '';
        numValue = double.parse(value);
      } else if (value is double) {
        numValue = value;
      } else if (value is int) {
        numValue = value.toDouble();
      } else {
        return value.toString();
      }
      // Shift decimal point left by decimalPlaces positions
      numValue = numValue / pow(10, decimalPlaces);
      return numValue.toStringAsFixed(decimalPlaces);
    } catch (e) {
      return '';
    }
  }

  Future<List<dynamic>> getNivCptIndicCpt() async {
    List<dynamic> listeNiveauCptIndicCpt = [];
    try {
      final response = await http.get(Uri.parse(
          'http://${backendServer}:8081/modeOuvCloCompte/niveauCompteIndicCompte/MOBILE'));

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        listeNiveauCptIndicCpt = jsonDecode(response.body);
      }
    } catch (e) {
      print("Error in getNivCptIndicCpt ");
    }
    return listeNiveauCptIndicCpt;
  }

  Map<String, List<dynamic>> transformListToMap(List<dynamic> list) {
    Map<String, List<dynamic>> resultMap = {};

    for (dynamic c in list) {
      if (resultMap.containsKey(c['niveauCompte']['niveauCompteDsg'])) {
        c['indicCompte']['maxvalue'] = c['niveauIndicAutoValeur'];
        resultMap[c['niveauCompte']['niveauCompteDsg']]!.add(c['indicCompte']);
      } else {
        c['indicCompte']['maxvalue'] = c['niveauIndicAutoValeur'];
        resultMap[c['niveauCompte']['niveauCompteDsg']] = [c['indicCompte']];
      }
    }
    return resultMap;
  }

  List<dynamic> mapIndicsNiv2Niveaux(List<dynamic> list) {
    final uniqueSet = <int, dynamic>{};

    for (var indicNiv in list) {
      final niveauCompte = indicNiv['niveauCompte'];
      if (niveauCompte != null) {
        uniqueSet[niveauCompte['niveauCompteId']] = niveauCompte;
      }
    }

    return uniqueSet.values.toList();
  }

  List<dynamic> getMatchingNiveaux(List<dynamic> niveaux, bool pp, bool kyc) {
    return niveaux.where((niveau) {
      // Select the appropriate KYC property
      final kycValue = kyc ? niveau['niveauCompteBoolEnrolKyc'] : niveau['niveauCompteBoolEnrolEkyc'];

      // Check PP or PM based on the `pp` parameter
      final ppValue = pp ? niveau['niveauCompteBoolEnrolPp'] : niveau['niveauCompteBoolEnrolPm'];

      // Return true if all conditions are met
      return kycValue == "O" && ppValue == "O";
    }).toList();
  }

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    try {
      // Get selected account type from shared preferences
       prefs = await SharedPreferences.getInstance();
      String? accountTypePPPMString = prefs.getString('selected_account_typePPPM') ;
      isIndividual = (accountTypePPPMString ?? 'individual')  == 'individual'; // true for PP, false for PM

      var nivsIndics = await getNivCptIndicCpt();
      if (nivsIndics.isNotEmpty) {
        var niveauxIndics = transformListToMap(nivsIndics);
        var allNiveaux = mapIndicsNiv2Niveaux(nivsIndics);

        // Filter niveaux based on account type
        var filteredNiveaux = getMatchingNiveaux(allNiveaux, isIndividual, true);

        // Create list of levels from filtered niveaux
        List<AccountLevelModel> levels = [];
        for (int i = 0; i < filteredNiveaux.length; i++) {
          var niveauData = niveauxIndics[filteredNiveaux[i]['niveauCompteDsg']];
          var maxBalanceData = niveauData?.firstWhere((e) => e['indicCompteCode'] == 'SOLDE', orElse: () => null);
          var monthlyLimitData = niveauData?.firstWhere((e) => e['indicCompteCode'] == 'CUMULT', orElse: () => null);

          var rawMaxBalance = maxBalanceData?['maxvalue'] ?? '';
          var rawMonthlyLimit = monthlyLimitData?['maxvalue'] ?? '';

          String formattedMaxBalance = formatDoubleToString(rawMaxBalance, deviseNbrDec);
          String formattedMonthlyLimit = formatDoubleToString(rawMonthlyLimit, deviseNbrDec);

          levels.add(AccountLevelModel(
            title: filteredNiveaux[i]['niveauCompteDsg'] ?? 'Niveau ${i + 1}',
            maxBalance: formattedMaxBalance.isNotEmpty ? '$formattedMaxBalance TND' : '',
            monthlyLimit: formattedMonthlyLimit.isNotEmpty ? '$formattedMonthlyLimit TND' : '',
            isSelected: i == 0, // Select first level by default
          ));
        }

        if (levels.isNotEmpty) {
          accountLevelSelectionModel.levels = levels;
        } else {
          // No levels available
          accountLevelSelectionModel.levels = [];
        }
      } else {
        // No levels available
        accountLevelSelectionModel.levels = [];
      }
    } catch (e) {
      print('Error fetching levels: $e');
      accountLevelSelectionModel.levels = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void selectAccountLevel(int levelIndex) {
    selectedLevelIndex = levelIndex;

    // Update selection state in models
    if (accountLevelSelectionModel.levels != null) {
      for (int i = 0; i < accountLevelSelectionModel.levels!.length; i++) {
        accountLevelSelectionModel.levels![i].isSelected = i == levelIndex;
      }
    }

    notifyListeners();
  }

  void onNextPressed(BuildContext context) {
    isLoading = true;
    notifyListeners();

    // Get the selected level and save its code
    _saveSelectedLevelCode();

    // Simulate form processing
    Future.delayed(Duration(milliseconds: 500), () {
      isLoading = false;
      notifyListeners();

      // Navigate to personal/buiness informations screen
      if (isIndividual) {
        NavigatorService.pushNamed(AppRoutes.personalInformationsScreen);
      } else {
        NavigatorService.pushNamed(AppRoutes.pmInformationsScreen);
      }

    });
  }

  Future<void> _saveSelectedLevelCode() async {
    try {
      prefs = await SharedPreferences.getInstance();
      
      // Get the selected level data
      if (accountLevelSelectionModel.levels != null && 
          selectedLevelIndex < accountLevelSelectionModel.levels!.length) {
        final selectedLevel = accountLevelSelectionModel.levels![selectedLevelIndex];
        final levelCode = selectedLevel.title ?? '';
        
        // Save the niveau_compte_code
        await prefs.setString('niveau_compte_code', levelCode);
        
        debugPrint('✅ Saved niveau_compte_code: $levelCode');
      }
    } catch (e) {
      debugPrint('❌ Error saving niveau_compte_code: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
