import 'package:flutter/material.dart';
import '../models/terms_conditions_model.dart';

class TermsConditionsProvider extends ChangeNotifier {
  TermsConditionsModel termsConditionsModel = TermsConditionsModel();

  void initialize() {
    // Initialize default values
    notifyListeners();
  }

  void toggleSection(String key) {
    termsConditionsModel.expandedSections![key] = !(termsConditionsModel.expandedSections![key] ?? false);
    notifyListeners();
  }

  void setTermsAccepted(bool value) {
    termsConditionsModel.termsAccepted = value;
    notifyListeners();
  }

  void setPrivacyAccepted(bool value) {
    termsConditionsModel.privacyAccepted = value;
    notifyListeners();
  }

  void toggleArticleExpansion(int documentIndex, int articleIndex) {
    // Initialize the document articles map if it doesn't exist
    termsConditionsModel.documentArticles ??= {};

    // Initialize the document map if it doesn't exist
    termsConditionsModel.documentArticles![documentIndex] ??= {};

    // Toggle the article expansion state
    termsConditionsModel.documentArticles![documentIndex]![articleIndex] =
        !(termsConditionsModel.documentArticles![documentIndex]![articleIndex] ?? false);
    notifyListeners();
  }

  bool getArticleExpandedState(int documentIndex, int articleIndex) {
    return termsConditionsModel.documentArticles?[documentIndex]?[articleIndex] ?? false;
  }

  void setDocumentAccepted(int documentIndex, bool value) {
    // Initialize the document accepted map if it doesn't exist
    termsConditionsModel.documentAccepted ??= {};

    // Set the document acceptance state
    termsConditionsModel.documentAccepted![documentIndex] = value;
    notifyListeners();
  }

  bool getDocumentAcceptedState(int documentIndex) {
    return termsConditionsModel.documentAccepted?[documentIndex] ?? false;
  }

  void navigateToNextScreen(BuildContext context) {
    // Navigation logic if needed
  }
}