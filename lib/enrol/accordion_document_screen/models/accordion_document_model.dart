// ignore_for_file: must_be_immutable
class AccordionDocumentModel {
  AccordionDocumentModel({
    this.documentIndex,
    this.lang,
    this.showReadAndApprouved,
    this.articles,
    this.title,
    this.fileName,
    this.collapseAll,
    this.articleCount,
    this.sectionStates,
  }) {
    documentIndex = documentIndex ?? 0;
    lang = lang ?? 'fr';
    showReadAndApprouved = showReadAndApprouved ?? true;
    articles = articles ?? [];
    title = title ?? '';
    fileName = fileName ?? '';
    collapseAll = collapseAll ?? true;
    articleCount = articleCount ?? 0;
    sectionStates = sectionStates ?? [];
  }

  int? documentIndex;
  String? lang;
  bool? showReadAndApprouved;
  List<dynamic>? articles;
  String? title;
  String? fileName;
  bool? collapseAll;
  int? articleCount;
  List<bool>? sectionStates;
}