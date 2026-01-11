import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import '../models/accordion_document_model.dart';

class AccordionDocumentProvider extends ChangeNotifier {
  AccordionDocumentModel accordionDocumentModel = AccordionDocumentModel();

  void initialize(int documentIndex, String lang, bool showReadAndApprouved) {
    accordionDocumentModel.documentIndex = documentIndex;
    accordionDocumentModel.lang = lang;
    accordionDocumentModel.showReadAndApprouved = showReadAndApprouved;
    readJson(documentIndex, lang, showReadAndApprouved);
    // Note: LoginStore logic removed as it's not defined in the project
    // If needed, add back when LoginStore is properly imported
    notifyListeners();
  }

  Future<void> readJson(int documentIndex, String lang, bool showReadAndApprouved) async {
    final String response = await rootBundle.loadString('assets/files/docs_$lang.json');
    final data = json.decode(response);
    accordionDocumentModel.articles = data["documents"][documentIndex]["articles"];
    accordionDocumentModel.title = data["documents"][documentIndex]["titre"];
    accordionDocumentModel.fileName = data["documents"][documentIndex]["file"];
    accordionDocumentModel.collapseAll = data["documents"][documentIndex]["collapseAll"] ?? true;
    accordionDocumentModel.showReadAndApprouved = data["documents"][documentIndex]["show_read_and_approuved"] ?? true;
    accordionDocumentModel.articleCount = accordionDocumentModel.articles!.length;
    accordionDocumentModel.sectionStates = List.generate(accordionDocumentModel.articles!.length, (index) => false);
    notifyListeners();
  }

  void toggleCollapseAll() {
    accordionDocumentModel.collapseAll = !accordionDocumentModel.collapseAll!;
    for (int i = 0; i < accordionDocumentModel.sectionStates!.length; i++) {
      accordionDocumentModel.sectionStates![i] = !accordionDocumentModel.collapseAll!;
    }
    notifyListeners();
  }

  void toggleSection(int index) {
    if (index < accordionDocumentModel.sectionStates!.length) {
      accordionDocumentModel.sectionStates![index] = !accordionDocumentModel.sectionStates![index];
      notifyListeners();
    }
  }

  void navigateToNextScreen(BuildContext context) {
    // Navigation logic if needed
  }
}