import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custum_button.dart';
import './provider/terms_conditions_provider.dart';
import './widgets/accordion_document_web_view_widget.dart';

class TermsConditionsScreenV2 extends StatefulWidget {
  const TermsConditionsScreenV2({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<TermsConditionsProvider>(
      create: (context) => TermsConditionsProvider(),
      child: TermsConditionsScreenV2(),
    );
  }

  @override
  State<TermsConditionsScreenV2> createState() => _TermsConditionsScreenV2State();
}

class _TermsConditionsScreenV2State extends State<TermsConditionsScreenV2> {
  List<dynamic> documents = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TermsConditionsProvider>().initialize();
      loadAllDocuments();
    });
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'description':
        return Icons.description;
      case 'shield':
        return Icons.shield;
      case 'help':
        return Icons.help_outline;
      default:
        return Icons.description_outlined; // Fallback
    }
  }

  Future<void> loadAllDocuments() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final String response = await rootBundle.loadString('assets/files/docs_fr.json');
      final data = json.decode(response);

      if (data["documents"] != null && data["documents"].isEmpty == false) {
        
        setState(() {
          documents = data["documents"];
          documents = documents.where((doc) => !(doc["disable"] ?? false)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Aucun document trouvé';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de chargement: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TermsConditionsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
      backgroundColor: appTheme.gray_50_01,
      appBar: CustomAppBar(
        leadingIcon: ImageConstant.imgArrowLeft,
        onLeadingPressed: () => NavigatorService.goBack(),
        backgroundColor: appTheme.whiteCustom,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Conditions d'utilisation",
              style: TextStyleHelper.instance.headline30MediumDMSans.copyWith(
                color: appTheme.black_900,
                fontSize: 24.fSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),

            // Subtitle
            Text(
              "Veuillez lire et accepter les conditions suivantes",
              style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                color: appTheme.gray_600,
                fontSize: 12.fSize,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // Documents Content
            if (isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(appTheme.cyan_900),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Chargement des documents...',
                      style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                        color: appTheme.gray_600,
                        fontSize: 12.fSize,
                      ),
                    ),
                  ],
                ),
              )
            else if (errorMessage.isNotEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.h,
                      color: appTheme.gray_400,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      errorMessage,
                      style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                        color: appTheme.gray_600,
                        fontSize: 12.fSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...documents.map((document) => _buildDocumentSection(document, provider)),

            SizedBox(height: 20.h),

            // Contact Coordinates Card
            Container(
              padding: EdgeInsets.all(20.h),
              decoration: BoxDecoration(
                color: appTheme.whiteCustom,
                borderRadius: BorderRadius.circular(16.h),
                boxShadow: [
                  BoxShadow(
                    color: appTheme.black_900.withOpacity(0.05),
                    blurRadius: 10.h,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.h),
                        decoration: BoxDecoration(
                          color: appTheme.gray_50_01,
                          borderRadius: BorderRadius.circular(12.h),
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          color: appTheme.teal_400,
                          size: 24.h,
                        ),
                      ),
                      SizedBox(width: 12.h),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Coordonnées de contact",
                              style: TextStyleHelper.instance.body14BoldManrope.copyWith(
                                color: appTheme.black_900,
                                fontSize: 14.fSize,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Pour la récupération de compte",
                              style: TextStyleHelper.instance.label11MediumManrope.copyWith(
                                color: appTheme.gray_600,
                                fontSize: 11.fSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Phone Number
                  CustomTextFormField(
                    controller: TextEditingController(text: '98989898'),
                    textInputType: TextInputType.phone,
                    textStyle: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                      color: appTheme.black_900,
                      fontSize: 13.fSize,
                    ),
                    fillColor: appTheme.gray_50_01,
                    contentPadding: EdgeInsets.all(16.h),
                  ),
                  SizedBox(height: 12.h),

                  // Email
                  CustomTextFormField(
                    controller: TextEditingController(text: 'gbrzied@gmail.com'),
                    textInputType: TextInputType.emailAddress,
                    textStyle: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                      color: appTheme.black_900,
                      fontSize: 13.fSize,
                    ),
                    fillColor: appTheme.gray_50_01,
                    contentPadding: EdgeInsets.all(16.h),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Security Info Banner
            Container(
              padding: EdgeInsets.all(20.h),
              decoration: BoxDecoration(
                color: appTheme.cyan_50_19,
                borderRadius: BorderRadius.circular(16.h),
                border: Border.all(
                  color: appTheme.cyan_200_16,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.h),
                    decoration: BoxDecoration(
                      color: appTheme.whiteCustom,
                      borderRadius: BorderRadius.circular(10.h),
                    ),
                    child: Icon(
                      Icons.security,
                      color: appTheme.cyan_900,
                      size: 28.h,
                    ),
                  ),
                  SizedBox(width: 16.h),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vos données sont protégées",
                          style: TextStyleHelper.instance.body14BoldManrope.copyWith(
                            color: appTheme.blue_gray_900,
                            fontSize: 13.fSize,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Nous utilisons un cryptage de niveau bancaire pour protéger vos informations personnelles.",
                          style: TextStyleHelper.instance.body12RegularManrope.copyWith(
                            color: appTheme.blue_gray_700,
                            fontSize: 10.fSize,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.h),
        decoration: BoxDecoration(
          color: appTheme.whiteCustom,
          boxShadow: [
            BoxShadow(
              color: appTheme.black_900.withOpacity(0.05),
              blurRadius: 10.h,
              offset: Offset(0, -5.h),
            ),
          ],
        ),
        child: CustomButton(
          text: 'Valider',
          width: double.maxFinite,
          onPressed: _areAllDocumentsAccepted(provider)
              ? () {
                  // Navigate to OTP screen
                  NavigatorService.pushNamed(AppRoutes.otpScreen);
                }
              : null,
        ),
      ),
    );
      },
    );
  }

  Widget _buildDocumentSection(dynamic document, TermsConditionsProvider provider) {
    final documentTitle = document["titre"] ?? "Document sans titre";
    final articles = document["articles"] ?? [];
    final documentIndex = documents.indexOf(document);
    final isAccepted = provider.getDocumentAcceptedState(documentIndex);
    final iconName = document["icon"] ?? "description";
    final iconData = _getIconFromName(iconName);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.whiteCustom,
        borderRadius: BorderRadius.circular(12.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.black_900.withOpacity(0.05),
            blurRadius: 8.h,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.h),
                decoration: BoxDecoration(
                  color: appTheme.cyan_900.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.h),
                ),
                child: Icon(
                  iconData,
                  color: appTheme.cyan_900,
                  size: 20.h,
                ),
              ),
              SizedBox(width: 12.h),
              Expanded(
                child: Text(
                  documentTitle,
                  style: TextStyleHelper.instance.title16SemiBoldManrope.copyWith(
                    color: appTheme.black_900,
                    fontSize: 14.fSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Articles for this document
          if (articles.isNotEmpty)
            Column(
              children: articles.map<Widget>((article) {
                final articleIndex = articles.indexOf(article);
                return _buildArticleItem(document, documentIndex, article, articleIndex, provider);
              }).toList(),
            ),

          SizedBox(height: 16.h),

          // Checkbox and Actions
          Row(
            children: [
              Checkbox(
                value: isAccepted,
                onChanged: (value) {
                  provider.setDocumentAccepted(documentIndex, value ?? false);
                },
                activeColor: appTheme.teal_400,
              ),
              Text(
                'Lu et approuvé',
                style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                  color: appTheme.black_900,
                  fontSize: 12.fSize,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.download_outlined, size: 18.h),
                color: appTheme.gray_600,
                onPressed: () {
                  // Download logic
                },
              ),
              IconButton(
                icon: Icon(Icons.share_outlined, size: 18.h),
                color: appTheme.gray_600,
                onPressed: () {
                  // Share logic
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _areAllDocumentsAccepted(TermsConditionsProvider provider) {
    for (int i = 0; i < documents.length; i++) {
      if (!(provider.getDocumentAcceptedState(i))) {
        return false;
      }
    }
    return true;
  }

  Widget _buildArticleItem(dynamic document, int documentIndex, dynamic article, int articleIndex, TermsConditionsProvider provider) {
    final isExpanded = provider.getArticleExpandedState(documentIndex, articleIndex);

    return Container(
      margin: EdgeInsets.only(bottom: 0.h),
      decoration: BoxDecoration(
        color: appTheme.gray_50_01,
        borderRadius: BorderRadius.circular(8.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.black_900.withOpacity(0.03),
            blurRadius: 4.h,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              provider.toggleArticleExpansion(documentIndex, articleIndex);
            },
            borderRadius: BorderRadius.circular(8.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      article["titre"] ?? "Article ${articleIndex + 1}",
                      style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                        color: appTheme.black_900,
                        fontSize: 12.fSize,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: appTheme.gray_600,
                    size: 20.h,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(16.h, 0, 16.h, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article["résumé"] ?? "",
                    style: TextStyleHelper.instance.body12RegularManrope.copyWith(
                      color: appTheme.gray_700,
                      fontSize: 11.fSize,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  InkWell(
                    onTap: () {
                      // Navigate to full article view
                      final fileName = document["file"] ?? "";
                      final fullUrl = "assets/files/$fileName";
                      final articleTitle = article["titre"] ?? document["titre"] ?? "Article";

                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AccordionDocumentWebViewWidget(
                          fullUrl,
                          articleTitle,
                        ),
                      ));
                    },
                    borderRadius: BorderRadius.circular(20.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            appTheme.cyan_900.withOpacity(0.1),
                            appTheme.cyan_900.withOpacity(0.05),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20.h),
                        border: Border.all(
                          color: appTheme.cyan_900.withOpacity(0.3),
                          width: 1.h,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            color: appTheme.cyan_900,
                            size: 16.h,
                          ),
                          SizedBox(width: 6.h),
                          Text(
                            "Lire la suite...",
                            style: TextStyleHelper.instance.body12RegularManrope.copyWith(
                              color: appTheme.cyan_900,
                              fontSize: 11.fSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4.h),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: appTheme.cyan_900,
                            size: 12.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}