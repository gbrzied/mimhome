import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:millime/core/utils/functions.dart';
import 'package:millime/localizationMillime/localization/app_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custum_button.dart';
import './provider/terms_conditions_provider.dart';
import './widgets/accordion_document_web_view_widget.dart';
import '../gen_dialogues/gen_dialogues.dart';
import '../../providers/app_language_provider.dart';

// Import PDF constants
import '../../core/utils/image_constant.dart';

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

  // PDF download state
  bool _isDownloadingPdf = false;
  String? _downloadingPdfTitle;

  // Form state management
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isPhoneValid = false;
  bool _isEmailValid = false;
  bool _isPhoneServerValid = false;
  bool _isEmailServerValid = false;
  String? _phoneError;
  String? _emailError;

  // Language change listener
  VoidCallback? _languageChangeListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TermsConditionsProvider>().initialize();
      loadAllDocuments();
      
      // Create and store listener for language changes
      _languageChangeListener = () {
        loadAllDocuments();
      };
      
      // Add listener to reload documents when language changes
      context.read<AppLanguageProvider>().addListener(_languageChangeListener!);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    
    // Remove language change listener
    if (_languageChangeListener != null) {
      try {
        context.read<AppLanguageProvider>().removeListener(_languageChangeListener!);
      } catch (e) {
        // Provider might not be available during dispose
      }
      _languageChangeListener = null;
    }
    
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

  // Language selector widget
  Widget _buildLanguageSelector(AppLanguageProvider languageProvider) {
    return Container(
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: appTheme.customLightGray,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(
          color: appTheme.borderColor,
          width: 1.h,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.language,
            color: appTheme.primaryColor,
            size: 20.h,
          ),
          SizedBox(width: 12.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'key_language'.tr,
                  style: TextStyleHelper.instance.body14BoldManrope.copyWith(
                    color: appTheme.black_900,
                    fontSize: 12.fSize,
                  ),
                  textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                ),
                SizedBox(height: 2.h),
                Text(
                  'key_select_language'.tr,
                  style: TextStyleHelper.instance.label9BoldManrope.copyWith(
                    color: appTheme.gray_600,
                    fontSize: 10.fSize,
                  ),
                  textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.arrow_drop_down,
              color: appTheme.primaryColor,
              size: 20.h,
            ),
            onSelected: (String language) {
              languageProvider.setLanguage(language);
              // Documents will be automatically reloaded by the language change listener
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'fr',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Français',
                      style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                        color: appTheme.black_900,
                      ),
                    ),
                    if (languageProvider.currentLanguage == 'fr')
                      Icon(
                        Icons.check_circle,
                        color: appTheme.primaryColor,
                        size: 16.h,
                      ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'en',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'English',
                      style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                        color: appTheme.black_900,
                      ),
                    ),
                    if (languageProvider.currentLanguage == 'en')
                      Icon(
                        Icons.check_circle,
                        color: appTheme.primaryColor,
                        size: 16.h,
                      ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'ar',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'العربية',
                      style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                        color: appTheme.black_900,
                      ),
                    ),
                    if (languageProvider.currentLanguage == 'ar')
                      Icon(
                        Icons.check_circle,
                        color: appTheme.primaryColor,
                        size: 16.h,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // PDF Download Methods
  Future<Uint8List> _loadPdfFromAssets(String pdfFilename) async {
    try {
      // Use PdfConstant to get the correct path
      // Use direct path construction for all PDFs
      String pdfPath = 'assets/files/pdfs/$pdfFilename';

      final ByteData data = await rootBundle.load(pdfPath);
      return data.buffer.asUint8List();
    } catch (e) {
      throw Exception('PDF file not found: $pdfFilename');
    }
  }

  // PDF Download Methods
  Future<void> _downloadPdfLocally(String pdfFilename, String documentTitle) async {
    if (_isDownloadingPdf) return; // Prevent multiple simultaneous downloads

    try {
      setState(() {
        _isDownloadingPdf = true;
        _downloadingPdfTitle = documentTitle;
      });

      // Request storage permission for Android
      if (Platform.isAndroid) {
        // Check current permission status
        PermissionStatus storageStatus = await Permission.storage.status;
        PermissionStatus manageStatus = await Permission.manageExternalStorage.status;

        // If neither permission is granted, request them
        if (!storageStatus.isGranted && !manageStatus.isGranted) {
          // Try storage permission first (for older Android versions)
          if (storageStatus.isDenied || storageStatus.isPermanentlyDenied) {
            storageStatus = await Permission.storage.request();
          }

          // If storage permission failed, try manage external storage (Android 11+)
          if (!storageStatus.isGranted) {
            if (manageStatus.isDenied || manageStatus.isPermanentlyDenied) {
              manageStatus = await Permission.manageExternalStorage.request();
            }
          }

          // Note: We don't throw exception here - we'll fallback to internal storage
          // if external storage permissions are denied
        }
      }

      // Load PDF from assets
      final pdfBytes = await _loadPdfFromAssets(pdfFilename);

      // Get the appropriate directory
      Directory? directory;
      String filePath;
      bool savedToExternalStorage = false;

      if (Platform.isAndroid) {
        // For Android, try to save to Downloads directory first
        try {
          directory = Directory('/storage/emulated/0/Download');
          if (await directory.exists()) {
            filePath = '${directory.path}/$documentTitle.pdf';
            savedToExternalStorage = true;
          } else {
            // Fallback to app documents directory
            directory = await getApplicationDocumentsDirectory();
            filePath = '${directory.path}/$documentTitle.pdf';
          }
        } catch (e) {
          // Fallback to app documents directory
          directory = await getApplicationDocumentsDirectory();
          filePath = '${directory.path}/$documentTitle.pdf';
        }
      } else if (Platform.isIOS) {
        // For iOS, save to app documents directory
        directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/$documentTitle.pdf';
      } else {
        throw Exception('key_unsupported_platform'.tr);
      }

      // Save the PDF file
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Show success message with file location
      if (mounted) {
        String locationMessage;
        if (Platform.isAndroid) {
          locationMessage = savedToExternalStorage
              ? 'key_downloaded_to_downloads_folder'.tr
              : 'key_downloaded_to_app_documents_android'.tr;
        } else {
          locationMessage = 'key_downloaded_to_app_documents'.tr;
        }

        showDialog(
          context: context,
          builder: (context) => GenDialogues(
            iconPath: "${ImageConstant.basePath}success-icon.svg",
            title: 'key_congratulations'.tr,
            message: ' $locationMessage',
            width: 335.h,
            height: 264.h,
            buttons: [
              CustomButton(
                text: 'key_close'.tr,
                width: double.infinity,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }

    } catch (e) {
      debugPrint('Error downloading PDF locally: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => GenDialogues(
            iconPath: "${ImageConstant.basePath}fail-icon.svg",
            title: 'key_error'.tr,
            message: '${'key_download_error'.tr}: ${e.toString()}',
            width: 335.h,
            height: 264.h,
            buttons: [
              CustomButton(
                text: 'key_close'.tr,
                width: double.infinity,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingPdf = false;
          _downloadingPdfTitle = null;
        });
      }
    }
  }

  Future<void> _sharePdf(String pdfFilename, String documentTitle) async {
    try {
      // Load PDF from assets
      final pdfBytes = await _loadPdfFromAssets(pdfFilename);

      // Share PDF using printing package
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '$documentTitle.pdf',
      );

    } catch (e) {
      debugPrint('Error sharing PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'key_share_pdf_error'.tr}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _getIconFromName(String iconName, {double? size, Color? color}) {
    // Handle SVG icons
    if (iconName.toLowerCase().endsWith('.svg')) {
      final svgPath = '${ImageConstant.basePath}$iconName';
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

  Future<void> loadAllDocuments([AppLanguageProvider? languageProvider]) async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Get language provider from context if not provided
      AppLanguageProvider? provider = languageProvider;
      if (provider == null) {
        try {
          provider = context.read<AppLanguageProvider>();
        } catch (e) {
          // Provider not available in context, use fallback
          provider = null;
        }
      }

      final currentLanguage = provider?.currentLanguage ?? 'fr';
      final String response = await rootBundle.loadString('assets/files/docs_$currentLanguage.json');
      final data = json.decode(response);

      if (data["documents"] != null && data["documents"].isEmpty == false) {
        
        setState(() {
          documents = data["documents"];
          documents = documents.where((doc) => !(doc["disable"] ?? false)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'key_no_documents_found'.tr;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '${'key_loading_error'.tr}: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TermsConditionsProvider, AppLanguageProvider>(
      builder: (context, provider, languageProvider, child) {
        // Calculate visibility based on current state (no setState in build)
        final allDocumentsAccepted = _areAllDocumentsAccepted(provider);
        final shouldShowPhoneField = allDocumentsAccepted;
        final shouldShowEmailField = shouldShowPhoneField && _isPhoneServerValid;

        return Scaffold(
          appBar: CustomAppBar(),
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
                    'key_terms_conditions_title'.tr,
                    style: TextStyleHelper.instance.title20SemiBoldQuicksandCentered.copyWith(
                      color: appTheme.black_900,
                    ),
                    textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                  ),
                ),
                SizedBox(height: 12.h),

                // Subtitle
                Text(
                  'key_terms_conditions_subtitle'.tr,
                  style: TextStyleHelper.instance.label9BoldManrope.copyWith(
                    color: appTheme.gray_600,
                    fontSize: 14.fSize,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                  textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                ),
              //  SizedBox(height: 4.h),
                
                // Language Selector
               // _buildLanguageSelector(languageProvider),
                
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
                          'key_loading_documents'.tr,
                          style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                            color: appTheme.gray_600,
                            fontSize: 12.fSize,
                          ),
                          textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
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
                          textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                        ),
                      ],
                    ),
                  )
                else
                  ...documents.map((document) => _buildDocumentSection(document, provider)),

                SizedBox(height: 20.h),

                // Contact Coordinates Card
                if (shouldShowPhoneField || shouldShowEmailField) ...[
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
                                    'key_contact_coordinates_title'.tr,
                                    style: TextStyleHelper.instance.body14BoldManrope.copyWith(
                                      color: appTheme.black_900,
                                      fontSize: 14.fSize,
                                    ),
                                    textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'key_contact_coordinates_subtitle'.tr,
                                    style: TextStyleHelper.instance.label9BoldManrope.copyWith(
                                      color: appTheme.gray_600,
                                    ),
                                    textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // Phone Number - Show only when documents are accepted
                        if (shouldShowPhoneField) ...[
                          Focus(
                            onFocusChange: (hasFocus) async {
                              if (!hasFocus) {
                                setState(() {
                                  _phoneError = null; // Clear previous error
                                });
                                try {
                                  if (_phoneController.text.length == 8) {
                                    if (_phoneController.text == '00000000' || !isValidTunisianMobile(_phoneController.text )) {
                                      setState(() {
                                        _phoneError = 'key_invalid_mobile_number'.tr;
                                        _isPhoneServerValid = false;
                                      });
                                      return;
                                    }
                                    _isPhoneServerValid = (await context.read<TermsConditionsProvider>().isValideNumTelGestion(_phoneController.text)) ?? false;
                                  } else {
                                    setState(() {
                                      _phoneError = 'key_invalid_number'.tr;
                                      _isPhoneServerValid = false;
                                    });
                                    return;
                                  }
                                } catch (e) {
                                  setState(() {
                                    _phoneError = 'key_server_error'.tr;
                                  });
                                  return;
                                }
                                if (!_isPhoneServerValid && _phoneController.text.length == 8) {
                                  setState(() {
                                    _phoneError = 'key_phone_number_already_used'.tr;
                                  });
                                }
                                setState(() {});
                              }
                            },
                            child: CustomTextFormField(
                              controller: _phoneController,
                              textInputType: TextInputType.phone,
                              hintText: 'key_phone_number_hint'.tr,
                              textStyle: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                                color: appTheme.black_900,
                                fontSize: 13.fSize,
                              ),
                              fillColor: appTheme.gray_50_01,
                              contentPadding: EdgeInsets.all(16.h),
                              onChanged: _onPhoneChanged,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              maxLength: 8,
                              errorText: _phoneError,
                            ),
                          ),
                          SizedBox(height: 12.h),
                        ],

                        // Email - Show only when phone is valid
                        if (shouldShowEmailField) ...[
                          Focus(
                            onFocusChange: (hasFocus) async {
                              if (!hasFocus) {
                                setState(() {
                                  _emailError = null;
                                });
                                if (_emailController.text.isEmpty) {
                                  setState(() {
                                    _emailError = 'key_email_required'.tr;
                                    _isEmailServerValid = false;
                                  });
                                  return;
                                }
                                if (!_isValidEmail(_emailController.text)) {
                                  setState(() {
                                    _emailError = 'key_invalid_email'.tr;
                                    _isEmailServerValid = false;
                                  });
                                  return;
                                }
                                try {
                                  _isEmailServerValid = (await context.read<TermsConditionsProvider>().isValideEmailGestion(_emailController.text)) ?? false;
                                } catch (e) {
                                  setState(() {
                                    _emailError = 'key_server_error'.tr;
                                    _isEmailServerValid = false;
                                  });
                                  return;
                                }
                                if (!_isEmailServerValid) {
                                  setState(() {
                                    _emailError = 'key_email_already_used'.tr;
                                  });
                                }
                                setState(() {});
                              }
                            },
                            child: CustomTextFormField(
                              controller: _emailController,
                              textInputType: TextInputType.emailAddress,
                              hintText: 'key_email_address_hint'.tr,
                              textStyle: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                                color: appTheme.black_900,
                                fontSize: 13.fSize,
                              ),
                              fillColor: appTheme.gray_50_01,
                              contentPadding: EdgeInsets.all(16.h),
                              onChanged: _onEmailChanged,
                              errorText: _emailError,
                            )
                          )
                         // SizedBox(height: 12.h),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Security Info Banner
                  Container(
                    padding: EdgeInsets.all(20.h),
                    decoration: BoxDecoration(
                      color: appTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.h),
                      border: Border.all(
                        color: appTheme.primaryColor,
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
                                'key_data_protection_title'.tr,
                                style: TextStyleHelper.instance.body14BoldManrope.copyWith(
                                  color: appTheme.primaryColor,
                                  fontSize: 12.fSize,
                                ),
                                textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'key_data_protection_description'.tr,
                                style: TextStyleHelper.instance.label9BoldManrope.copyWith(
                                  color: appTheme.gray_600,
                                  fontSize: 10.fSize,
                                ),
                                textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 20.h),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.only(left: 20.h, right: 20.h, top: 20.h, bottom: 10.h),
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
              text: 'key_validate'.tr,
              width: double.maxFinite,
              onPressed: (allDocumentsAccepted && _isEmailServerValid && _isPhoneServerValid)
                  ? () async {
                      // Update provider with user data - exact from old code
                      provider.termsConditionsModel.phoneNumber = _phoneController.text;
                      provider.termsConditionsModel.email = _emailController.text;

                      // Store phone number and email in SharedPreferences
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      await prefs.setString('terms_phone_number', _phoneController.text);
                      await prefs.setString('terms_email', _emailController.text);

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
    final documentTitle = document["titre"] ?? 'key_untitled_document'.tr;
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
                child: Consumer2<TermsConditionsProvider, AppLanguageProvider>(
                  builder: (context, provider, languageProvider, child) => Text(
                    documentTitle,
                    style: TextStyleHelper.instance.title16SemiBoldManrope.copyWith(
                      color: appTheme.black_900,
                      fontSize: 14.fSize,
                    ),
                    textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
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
                width: 28.h,
                height: 27.h,
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
              Consumer<AppLanguageProvider>(
                builder: (context, languageProvider, child) => Text(
                  'key_read_and_approved'.tr,
                  style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                    color: appTheme.black_900,
                    fontSize: 12.fSize,
                  ),
                  textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                ),
              ),
              const Spacer(),
              // Download button - saves locally
              InkWell(
                onTap: () {
                  final pdfFilename = document["pdf"];
                  if (pdfFilename != null && pdfFilename.isNotEmpty) {
                    _downloadPdfLocally(pdfFilename, documentTitle);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('key_no_pdf_available'.tr),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(6.h),
                  decoration: BoxDecoration(
                    color: _isDownloadingPdf && _downloadingPdfTitle == documentTitle
                        ? appTheme.gray_300
                        : appTheme.customLightGray,
                    borderRadius: BorderRadius.circular(6.h),
                  ),
                  child: _isDownloadingPdf && _downloadingPdfTitle == documentTitle
                      ? SizedBox(
                          width: 21.h,
                          height: 22.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(appTheme.primaryColor),
                          ),
                        )
                      : _getIconFromName('download.svg', size: 12.h, color: appTheme.primaryColor),
                ),
              ),
              SizedBox(width: 8.h),
              // Share button - opens share sheet
              InkWell(
                onTap: () {
                  final pdfFilename = document["pdf"];
                  if (pdfFilename != null && pdfFilename.isNotEmpty) {
                    _sharePdf(pdfFilename, documentTitle);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('key_no_pdf_available'.tr),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(6.h),
                  decoration: BoxDecoration(
                    color: appTheme.customLightGray,
                    borderRadius: BorderRadius.circular(6.h),
                  ),
                  child: _getIconFromName('share.svg', size: 12.h, color: appTheme.primaryColor),
                ),
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
                      textAlign: context.read<AppLanguageProvider>().isRTL ? TextAlign.right : TextAlign.left,
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
                    textAlign: context.read<AppLanguageProvider>().isRTL ? TextAlign.right : TextAlign.left,
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
                            'key_read_more'.tr,
                            style: TextStyleHelper.instance.label9BoldManrope.copyWith(
                              color: appTheme.cyan_900,
                            ),
                            textAlign: context.read<AppLanguageProvider>().isRTL ? TextAlign.right : TextAlign.left,
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
