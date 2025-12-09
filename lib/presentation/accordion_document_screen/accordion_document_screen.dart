import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:accordion/accordion.dart';
import '../../core/app_export.dart';
import './provider/accordion_document_provider.dart';
import './widgets/accordion_document_web_view_widget.dart';

// Import AccordionDocumentPage from the same file or create it here
// Since AccordionDocumentPage is defined in this file, it should be accessible

class AccordionDocumentScreen extends StatefulWidget {
  const AccordionDocumentScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<AccordionDocumentProvider>(
      create: (context) => AccordionDocumentProvider(),
      child: AccordionDocumentScreen(),
    );
  }

  @override
  State<AccordionDocumentScreen> createState() => _AccordionDocumentScreenState();
}

class _AccordionDocumentScreenState extends State<AccordionDocumentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccordionDocumentProvider>().initialize(0, 'fr', true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccordionDocumentProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: AccordionDocumentPage(
            provider.accordionDocumentModel.documentIndex ?? 0,
            provider.accordionDocumentModel.lang ?? 'fr',
            provider.accordionDocumentModel.showReadAndApprouved ?? true,
          ),
        );
      },
    );
  }
}

/// Main example page
class AccordionDocumentPage extends StatefulWidget {
  final int documentIndex;
  final String lang;
  final bool show_read_and_approuved;
  const AccordionDocumentPage(this.documentIndex, this.lang, this.show_read_and_approuved, {Key? key}) : super(key: key);

  @override
  AccordionState createState() => AccordionState();
}

class AccordionState extends State<AccordionDocumentPage> {
  bool collapseAll = true;
  List<bool> sectionStates = [];
  int _accordionKey = 0;
  int? articleCount;
  List articles = [];
  String title = '';
  String fileName = '';
  bool bDocApprouve = false;
  bool alignRight = false;
  String? key_read_next = "   Lire la Suite...  ";
  String? key_read_and_approuved = "Lu et approuvé";

  Future<void> loadHtmlFromAssets(String filename, controller) async {
    String fileText = await rootBundle.loadString(filename);
    controller.loadUrl(Uri.dataFromString(fileText, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
  }

  // Fetch content from the json file
  Future<void> readJson(int documentIndex, String lang, bool show_read_and_approuved) async {
    try {
      print('Loading JSON file: assets/files/docs_$lang.json');
      final String response = await rootBundle.loadString('assets/files/docs_$lang.json');
      print('JSON file loaded successfully');
      final data = await json.decode(response);
      print('JSON decoded successfully');
      
      if (data["documents"] == null || data["documents"].isEmpty) {
        throw Exception('No documents found in JSON');
      }
      
      if (documentIndex >= data["documents"].length) {
        throw Exception('Document index $documentIndex out of range. Available documents: ${data["documents"].length}');
      }
      
      setState(() {
        articles = data["documents"][documentIndex]["articles"] ?? [];
        title = data["documents"][documentIndex]["titre"] ?? "Document sans titre";
        fileName = data["documents"][documentIndex]["file"] ?? "";
        collapseAll = data["documents"][documentIndex]["collapseAll"] ?? true;
        show_read_and_approuved = data["documents"][documentIndex]["show_read_and_approuved"] ?? true;
        articleCount = articles.length;
        // Initialize section states - all closed initially
        sectionStates = List.generate(articles.length, (index) => false);
      });
      
      print('Data loaded: title=$title, articleCount=$articleCount');
    } catch (e, stackTrace) {
      print('Error loading JSON: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        title = 'Erreur de chargement';
        articles = [];
        articleCount = 0;
        sectionStates = [];
      });
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement des documents: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    readJson(widget.documentIndex, widget.lang, widget.show_read_and_approuved);
    key_read_next = "key_read_next" ?? " " + "   ";
    key_read_and_approuved = "key_read_and_approuved";
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator if data is not loaded yet
    if (articles.isEmpty && title.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(
            'Chargement...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              SizedBox(height: 16),
              Text(
                'Chargement des documents...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: (widget.show_read_and_approuved) ? null : AppBar(
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      collapseAll = !collapseAll;
                      _accordionKey++;
                      // Update all section states
                      for (int i = 0; i < sectionStates.length; i++) {
                        sectionStates[i] = !collapseAll;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 50,
                    height: 26,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: collapseAll ? Colors.white.withOpacity(0.3) : Colors.white,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          left: collapseAll ? 2 : 26,
                          top: 2,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: collapseAll ? Colors.white : Colors.green,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              collapseAll ? Icons.visibility_off : Icons.visibility,
                              color: collapseAll ? Colors.green : Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        backgroundColor: Colors.green,
        elevation: 2,
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: articleCount == 0 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucun document disponible',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : Accordion(
                  key: ValueKey(_accordionKey),
                  maxOpenSections: articleCount ?? 10,
                  headerBackgroundColorOpened: Colors.green.withOpacity(0.8),
                  headerBackgroundColor: Colors.green,
                  scaleWhenAnimating: false,
                  openAndCloseAnimation: true,
                  flipRightIconIfOpen: true,
                  paddingListTop: 5,
                  paddingListBottom: 5,
                  children: _buildList(context, articles),
                ),
          ),
        ],
      ),
    );
  }

  bool bPCCheckBox = false;

  List<AccordionSection> _buildList(BuildContext context, List<dynamic> articles) {
    return articles
        .asMap()
        .entries
        .map((entry) {
          int index = entry.key;
          dynamic article = entry.value;

          return AccordionSection(
            isOpen: index < sectionStates.length ? sectionStates[index] : false,
            headerBackgroundColor: Colors.green,
            headerBackgroundColorOpened: Colors.green.withOpacity(0.8),
            contentBackgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.white,
            contentBorderColor: Colors.green.withOpacity(0.3),
            contentBorderWidth: 1,
            headerPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            contentHorizontalPadding: 16,
            contentVerticalPadding: 16,
            header: Container(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      article["titre"] ?? "Section ${index + 1}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: alignRight ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                  Icon(
                    Icons.expand_more,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
            content: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                            height: 1.5,
                          ),
                          text: article["résumé"],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      try {
                        String fullUrl = "assets/files/" + fileName;
                        if (article["ancre"] != null && article["ancre"].toString().isNotEmpty) {
                          fullUrl += "#" + article["ancre"];
                        }
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => AccordionDocumentWebViewWidget(
                                  fullUrl,
                                  article["titre"] ?? title,
                                )));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.1),
                            Colors.green.withOpacity(0.05),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            key_read_next ?? 'Lire la suite...',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.green,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        })
        .toList();
  }
}
