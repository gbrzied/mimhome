import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import './provider/accordion_document_provider.dart';
import './accordion_document_screen.dart'; // Import AccordionDocumentPage

class AccordionDocumentWrapperScreen extends StatefulWidget {
  const AccordionDocumentWrapperScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<AccordionDocumentProvider>(
      create: (context) => AccordionDocumentProvider(),
      child: AccordionDocumentWrapperScreen(),
    );
  }

  @override
  State<AccordionDocumentWrapperScreen> createState() => _AccordionDocumentWrapperScreenState();
}

class _AccordionDocumentWrapperScreenState extends State<AccordionDocumentWrapperScreen> {
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