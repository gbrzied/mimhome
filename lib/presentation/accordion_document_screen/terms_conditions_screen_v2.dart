import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custum_button.dart';
import './provider/terms_conditions_provider.dart';
import './widgets/accordion_document_web_view_widget.dart';

class TermsConditionsScreenV2 extends StatefulWidget {
  const TermsConditionsScreenV2({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    // Use global TermsConditionsProvider instead of creating new one
    return TermsConditionsScreenV2();
  }

  @override
  State<TermsConditionsScreenV2> createState() => _TermsConditionsScreenV2State();
}

class _TermsConditionsScreenV2State extends State<TermsConditionsScreenV2> {
  List<dynamic> documents = [];
  bool isLoading = true;
  String errorMessage = '';

  // Form state management
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isPhoneValid = false;
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TermsConditionsProvider>().initialize();
      loadAllDocuments();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Validation methods
  bool _isValidPhoneNumber(String phone) {
    // Tunisian phone number validation (8 digits starting with 2,5,9)
    final phoneRegex = RegExp(r'^[2459]\d{7}$');
    return phoneRegex.hasMatch(phone.replaceAll(' ', ''));
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _onPhoneChanged(String value) {
    setState(() {
      _isPhoneValid = _isValidPhoneNumber(value);
      // Email field visibility is calculated in build method
      // Clear email if phone becomes invalid
      if (!_isPhoneValid) {
        _emailController.clear();
        _isEmailValid = false;
      }
    });
  }

  void _onEmailChanged(String value) {
    setState(() {
      _isEmailValid = _isValidEmail(value);
    });
  }

  Widget _getIconFromName(String iconName, {double? size, Color? color}) {
    // Handle SVG icons
    if (iconName.toLowerCase().endsWith('.svg')) {
      final svgPath = 'assets/images/$iconName';
      return SvgPicture.asset(
        svgPath,
        width: size ?? 20.h,
        height: size ?? 20.h,
        color: color ?? appTheme.cyan_900,
      );
    }
    
    // Handle Material icons
    IconData iconData;
    switch (iconName.toLowerCase()) {
      case 'description':
        iconData = Icons.description;
        break;
      case 'shield':
        iconData = Icons.shield;
        break;
      case 'help':
        iconData = Icons.help_outline;
        break;
      
      default:
        iconData = Icons.description_outlined; // Fallback
    }
    
    return Icon(
      iconData,
      size: size ?? 20.h,
      color: color ?? appTheme.cyan_900,
    );
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
        // Calculate visibility based on current state (no setState in build)
        final allDocumentsAccepted = _areAllDocumentsAccepted(provider);
        final shouldShowPhoneField = allDocumentsAccepted;
        final shouldShowEmailField = shouldShowPhoneField && _isPhoneValid;

        return Scaffold(
     // backgroundColor: appTheme.gray_50_01,
      appBar: CustomAppBar(
        //leadingIcon: ImageConstant.imgArrowLeft,
        //onLeadingPressed: () => NavigatorService.goBack(),
       // backgroundColor: appTheme.whiteCustom,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Container(
              constraints: BoxConstraints(
                maxWidth: 260.h,
                minHeight: 24.h,
              ),
              child: Text(
                "Conditions d'utilisation",
                style: TextStyleHelper.instance.title20SemiBoldQuicksandCentered.copyWith(
                  color: appTheme.black_900,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 12.h),

            // Subtitle
            Text(
              "Veuillez lire et accepter les conditions suivantes",
              style: TextStyleHelper.instance.label9BoldManrope.copyWith(
                color: appTheme.gray_600,
                fontSize: 14.fSize,
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 0.5, // Added letter spacing
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
          if (shouldShowPhoneField || shouldShowEmailField)                  
            Container(
              padding: EdgeInsets.all(20.h),
              decoration: BoxDecoration(
                color: appTheme.customLightGray,
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
                          color: appTheme.customLightGray,
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
                              style: TextStyleHelper.instance.label9BoldManrope.copyWith(
                                color: appTheme.gray_600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Phone Number - Show only when documents are accepted
                  if (shouldShowPhoneField) ...[
                    CustomTextFormField(
                      controller: _phoneController,
                      textInputType: TextInputType.phone,
                      hintText: "Entrez votre numéro de téléphone",
                      textStyle: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                        color: appTheme.black_900,
                        fontSize: 13.fSize,
                      ),
                      fillColor: appTheme.gray_50_01,
                      contentPadding: EdgeInsets.all(16.h),
                      onChanged: _onPhoneChanged,
                    ),
                    SizedBox(height: 12.h),
                  ],

                  // Email - Show only when phone is valid
                  if (shouldShowEmailField) ...[
                    CustomTextFormField(
                      controller: _emailController,
                      textInputType: TextInputType.emailAddress,
                      hintText: "Entrez votre adresse email",
                      textStyle: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                        color: appTheme.black_900,
                        fontSize: 13.fSize,
                      ),
                      fillColor: appTheme.gray_50_01,
                      contentPadding: EdgeInsets.all(16.h),
                      onChanged: _onEmailChanged,
                    ),
                    SizedBox(height: 12.h),
                  ],
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
                          style: TextStyleHelper.instance.label9BoldManrope.copyWith(
                            color: appTheme.blue_gray_700,
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
          onPressed: (allDocumentsAccepted && _isEmailValid)
              ? () {
                  // Update provider with user data - exact from old code
                  provider.termsConditionsModel.phoneNumber = _phoneController.text;
                  provider.termsConditionsModel.email = _emailController.text;

                  // Use exact handleNextButtonPress method from old login_store.dart
                  provider.handleNextButtonPress(context, _phoneController.text);
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
    final iconWidget = _getIconFromName(iconName);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.whiteCustom,
        borderRadius: BorderRadius.circular(15.h),
        border: Border.all(
          color: appTheme.borderColor,
          width: 1.h,
        ),
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
                  color: appTheme.customLightGray,
                  borderRadius: BorderRadius.circular(8.h),
                ),
                child: iconWidget,
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
              SizedBox(
                width: 24.h,
                height: 24.h,
                child: Checkbox(
                  value: isAccepted,
                  onChanged: (value) {
                    provider.setDocumentAccepted(documentIndex, value ?? false);
                  },
                  activeColor: appTheme.teal_400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.h),
                  ),
                  side: BorderSide(
                    color: appTheme.borderColor,
                    width: 1.h,
                  ),
                ),
              ),
              SizedBox(width: 12.h),
              Text(
                'Lu et approuvé',
                style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                  color: appTheme.black_900,
                  fontSize: 12.fSize,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.all(6.h),
                decoration: BoxDecoration(
                  color: appTheme.customLightGray,
                  borderRadius: BorderRadius.circular(6.h),
                ),
                child: _getIconFromName('download.svg', size: 12.h, color: appTheme.primaryColor),
              ),
              SizedBox(width: 8.h),
              Container(
                padding: EdgeInsets.all(6.h),
                decoration: BoxDecoration(
                  color: appTheme.customLightGray,
                  borderRadius: BorderRadius.circular(6.h),
                ),
                child: _getIconFromName('share.svg', size: 12.h, color: appTheme.primaryColor),
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
      margin: EdgeInsets.only(bottom:10.h),
      constraints: BoxConstraints(
        minHeight: 50.h,
      ),
      decoration: BoxDecoration(
        color: appTheme.customLightGray,
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
                    style: TextStyleHelper.instance.label9BoldManrope.copyWith(
                      color: appTheme.gray_700,
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
                            style: TextStyleHelper.instance.label9BoldManrope.copyWith(
                              color: appTheme.cyan_900,
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