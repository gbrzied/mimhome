// ignore_for_file: must_be_immutable
class TermsConditionsModel {
  TermsConditionsModel({
    this.expandedSections,
    this.documentArticles,
    this.documentAccepted,
    this.termsAccepted,
    this.privacyAccepted,
  }) {
    expandedSections = expandedSections ?? {
      'terms_0': false,
      'terms_1': false,
      'terms_2': false,
      'privacy_0': false,
      'privacy_1': false,
      'privacy_2': false,
    };
    documentArticles = documentArticles ?? {};
    documentAccepted = documentAccepted ?? {};
    termsAccepted = termsAccepted ?? false;
    privacyAccepted = privacyAccepted ?? false;
  }

  Map<String, bool>? expandedSections;
  Map<int, Map<int, bool>>? documentArticles;
  Map<int, bool>? documentAccepted;
  bool? termsAccepted;
  bool? privacyAccepted;
}