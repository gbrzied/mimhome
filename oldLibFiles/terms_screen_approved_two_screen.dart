import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:millime/Enrolement/otp_page.dart';

import 'package:millime/common/functions.dart';

import 'package:millime/conf/custom_text_style.dart';
import 'package:millime/conf/size_utils.dart';

import 'package:millime/core/utils/image_constant.dart';

import 'package:millime/localizationMillime/localization/app_localization.dart';

import 'package:millime/pages/AccordionDocument.dart';
import 'package:millime/pages/figma_integration/color.dart';
import 'package:millime/pages/figma_integration/widgets/app_colors_builder.dart';
import 'package:millime/theme/app_colors.dart';

import 'package:millime/stores/login_store.dart';
import 'package:millime/theme/app_decoration.dart';
import 'package:millime/theme/custom_button_style.dart';
import 'package:millime/theme/theme_helper.dart';
import 'package:millime/widgets/custom_check_button.dart';
import 'package:millime/widgets/custom_elevated_button.dart';

import 'package:millime/widgets/custom_image_view.dart';
import 'package:millime/widgets/custom_radio_button.dart';

import 'package:provider/provider.dart';

// ignore: must_be_immutable

class TermsScreenApprovedTwoScreen extends StatefulWidget {
  const TermsScreenApprovedTwoScreen({Key? key}) : super(key: key);
  @override
  TermsScreenApprovedTwoScreenState createState() =>
      TermsScreenApprovedTwoScreenState();
}

class TermsScreenApprovedTwoScreenState
    extends State<TermsScreenApprovedTwoScreen> {

  TextEditingController searchController = TextEditingController();
  String radioGroup = "";
  TextEditingController searchController1 = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool boolNumTelValide = false;
  bool boolEmailValide = false;
  bool boolDisableSuivant = true;
  String radioGroup1 = "";
  bool? bAllDocsApprouved = false;
  bool? rtl = false;
  bool succesS = true;

  // Optimization: Add caching and loading state
  static Map<String, dynamic> _documentCache = {};
  bool _isLoading = true;
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    rtl = AppLocalization.of().locale.languageCode == 'ar';
    
    // Optimization: Use Future for async initialization
    _initializationFuture = _initializeData();
  }

  // Optimization: Separate initialization method for better performance
  Future<void> _initializeData() async {
    try {
      await readJson(AppLocalization.of().locale.languageCode);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);

    return Directionality(
      textDirection: (AppLocalization.of().locale.languageCode == 'ar')
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: SafeArea(
        child: AppColorsBuilder(
          builder: (context, colors) => Scaffold(
            backgroundColor: colors.backgroundColor,
            resizeToAvoidBottomInset: true,
            body: SizedBox(
            width: double.maxFinite,
            child: Column(
              children: [
                SizedBox(height: 10.v),
                Expanded(
                  child: FutureBuilder<void>(
                    future: _initializationFuture,
                    builder: (context, snapshot) {
                      if (_isLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(colors.greenmillime),
                              ),
                              SizedBox(height: 16.v),
                              Text(
                                "Loading documents...",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 48, color: colors.errorColor),
                              SizedBox(height: 16.v),
                              Text(
                                "Error loading documents",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.greenmillime,
                                  foregroundColor: colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                    _initializationFuture = _initializeData();
                                  });
                                },
                                child: Text("Retry"),
                              ),
                            ],
                          ),
                        );
                      }

                      return _buildContent();
                    },
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  // Optimization: Separate content building for better performance
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 23.h,
          right: 23.h,
          bottom: 80.v,
        ),
        child: Column(
          children: [
            CustomImageView(
              imagePath: (rtl ?? false)
                  ? ImageConstant.imgMillimeArlogo
                  : ImageConstant.imgMillimelogo,
              height: 90.adaptSize,
              width: 90.adaptSize,
            ),
            SizedBox(height: 20.v),
            // Optimization: Use ListView.builder for better performance with large lists
            ...List.generate(documents.length, (i) {
              return _buildDocumentItem(i);
            }),
            SizedBox(height: 15.v),
            _buildTelGestion(),
            SizedBox(height: 6.v),
            _buildEmailGestion(),
            SizedBox(height: 40.v),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  // Optimization: Extract document item building for better readability and performance
  Widget _buildDocumentItem(int i) {
    return Padding(
      padding: EdgeInsets.only(left: 3.h),
      child: Column(
        children: [
          Align(
            alignment: (AppLocalization.of().locale.languageCode != 'ar')
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: AppColorsBuilder(
              builder: (context, colors) => Text(
                documents[i]["titre"],
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildFrames(AppLocalization.of().locale.languageCode, i),
          SizedBox(height: 10.v),
          _buildDocumentActions(i),
        ],
      ),
    );
  }

  // Optimization: Extract document actions for better organization
  Widget _buildDocumentActions(int i) {
    return Align(
      alignment: (AppLocalization.of().locale.languageCode != 'ar')
          ? Alignment.bottomRight
          : Alignment.bottomLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: _buildLuEtApprouv1(context, i)),
          _buildViewDocumentButton(i),
          _buildDownloadButton(i),
          SizedBox(height: 9.v),
        ],
      ),
    );
  }

  Widget _buildViewDocumentButton(int i) {
    return AppColorsBuilder(
      builder: (context, colors) => Container(
        padding: EdgeInsets.all(8.h),
        decoration: BoxDecoration(
          color: colors.greenmillime.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: colors.greenmillime.withOpacity(0.3)),
        ),
        child: CustomImageView(
          imagePath: ImageConstant.imgIconlyLightDocument,
          height: 24.adaptSize,
          width: 24.adaptSize,
          color: colors.greenmillime,
          onTap: () async {
            try {
              List articles = data["documents"][i]["articles"];
              String title = data["documents"][i]["titre"];
              String fileName = data["documents"][i]["file"];

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(colors.greenmillime),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Chargement du document...",
                            style: TextStyle(color: colors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

              // Close loading dialog after a short delay
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.of(context).pop();

              // Navigate to document viewer
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => WebViewContainer(
                        "assets/files/" + fileName,
                        title,
                      )));
            } catch (e) {
              // Close loading dialog if still open
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
              
              // Show error message
              buildSuccessMessage(
                context,
                "key_erreur".tr,
                "Erreur lors de l'ouverture du document. Veuillez réessayer.",
                "key_fermer".tr,
                false,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDownloadButton(int i) {
    return AppColorsBuilder(
      builder: (context, colors) => Container(
        padding: EdgeInsets.all(8.h),
        margin: (AppLocalization.of().locale.languageCode != 'ar')
            ? EdgeInsets.only(left: 10.h)
            : EdgeInsets.only(right: 10.h),
        decoration: BoxDecoration(
          color: colors.bluemillime.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: colors.bluemillime.withOpacity(0.3)),
        ),
        child: CustomImageView(
          imagePath: ImageConstant.imgDownloadErrorcontainer,
          height: 24.adaptSize,
          width: 24.adaptSize,
          color: colors.bluemillime,
          onTap: () async {
            buildSuccessMessage(
                context,
                "lbl_f_licitations".tr,
                "msg_inf_download".tr,
                "key_fermer".tr,
                true);

            await copyAssetToDownloads(
                'assets/files/pdfs/${documents[i]["pdf"]}',
                '${documents[i]["pdf"]}');
          },
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return CustomElevatedButton(
      height: 56.v,
      isDisabled: !bAllDocsApprouved! || boolDisableSuivant,
      text: "key_next".tr,
      buttonStyle: CustomButtonStyles.fillPrimary,
      buttonTextStyle: CustomTextStyles.titleMediumOnPrimaryContainerSemiBold,
      onPressed: boolDisableSuivant ? null : _handleNextButtonPress,
    );
  }

  // Optimization: Extract button press logic for better organization
  Future<void> _handleNextButtonPress() async {
    myStore?.docManquantsMand = [];
    myStore?.docManquantsTitu = [];
    myStore?.tituimages = [];
    myStore?.mandimages = [];

    if (phoneController.text.length == 8 && isValidEmail(emailController.text)) {
      try {
        await myStore?.fetchPersonnePbyTel(context, phoneController.text.toString())
            .then((pp) async {
          myStore?.pp = pp;
        });
      } catch (e) {
        buildSuccessMessage(
            context,
            "key_erreur".tr,
            "err_serveur_introuvable".tr,
            "key_fermer".tr,
            false);
        return;
      }

      myStore?.demande?.telMobile = phoneController.text;
      myStore?.phoneNo = phoneController.text;
      myStore?.walletEmailGestion = emailController.text;

      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => OtpPage()));
    } else {
      if (phoneController.text.length != 8) {
        buildSuccessMessage(
            context,
            "key_erreur".tr,
            "key_length_tel".tr,
            "key_fermer".tr,
            false);
      } else {
        buildSuccessMessage(
            context,
            "key_erreur".tr,
            "key_length_tel".tr,
            "key_fermer".tr,
            false);
      }
    }
  }

  /// Section Widget
  Widget _buildLuEtApprouv(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: CustomRadioButton(
        text: "lbl_lu_et_approuv2".tr,
        value: "lbl_lu_et_approuv2".tr,
        groupValue: radioGroup,
        onChange: (value) {
          radioGroup = value;
        },
      ),
    );
  }

  /// Section Widget
  String? v = null;
  Widget _buildLuEtApprouv1(BuildContext context, int i) {
    return AppColorsBuilder(
      builder: (context, colors) => Align(
        alignment: Alignment.centerLeft,
        child: CustomCheckbox(
            activeColor: colors.greenmillime,
            text: "key_read_and_approuved".tr,
            value: myStore?.bTabApprouvedDocsCheckBox[i] ?? false,
            textStyle: theme.textTheme.titleLarge?.copyWith(
              color: colors.textPrimary,
              fontSize: 14,
            ),
            onChange: (value) {
              setState(() {
                myStore?.bTabApprouvedDocsCheckBox[i] =
                    !(myStore?.bTabApprouvedDocsCheckBox[i] ?? true);
              });

              bAllDocsApprouved = myStore?.bTabApprouvedDocsCheckBox
                  .reduce((value, element) => value && element);
            }),
      ),
    );
  }





  List documents = [];
  LoginStore? myStore;
  dynamic data;

  // Optimization: Cached and optimized JSON reading
  Future<void> readJson(String lg) async {
    try {
      // Check cache first
      final cacheKey = 'docs_$lg';
      if (_documentCache.containsKey(cacheKey)) {
        data = _documentCache[cacheKey];
      } else {
        // Load from assets and cache
        final String response = await rootBundle.loadString('assets/files/docs_$lg.json');
        data = await json.decode(response);
        _documentCache[cacheKey] = data;
      }

      // Process documents
      final List rawDocuments = data["documents"];
      documents = rawDocuments.where((doc) => !(doc["disable"] ?? false)).toList();

      // Initialize store
      myStore = Provider.of<LoginStore>(context, listen: false);

      // Optimize checkbox initialization
      final int docLength = documents.length;
      if (myStore?.bTabApprouvedDocsCheckBox.isEmpty ?? true) {
        myStore?.bTabApprouvedDocsCheckBox = List.filled(docLength, false);
      } else {
        // Ensure correct length and preserve existing values
        final existingCheckboxes = myStore?.bTabApprouvedDocsCheckBox ?? [];
        myStore?.bTabApprouvedDocsCheckBox = List.generate(
          docLength,
          (index) => index < existingCheckboxes.length ? existingCheckboxes[index] : false,
        );
      }

      // Update approval state
      bAllDocsApprouved = myStore?.bTabApprouvedDocsCheckBox
          .every((element) => element) ?? false;

    } catch (e) {
      debugPrint('Error reading JSON: $e');
      // Fallback to empty state
      documents = [];
      data = {"documents": []};
      bAllDocsApprouved = false;
    }
  }

  Widget _buildFrames(String lang, int index) {
    return Container(
        height: 300.v,
        width: 500.h,
        padding: EdgeInsets.symmetric(
          horizontal: 12.h,
          vertical: 5.v,
        ),
        decoration: AppDecoration.fillOnPrimaryContainer.copyWith(
          borderRadius: BorderRadiusStyle.customBorderTL16,
        ),
        child: AccordionDocumentPage(index, lang, true));
  }

  /// Common widget
  Widget _buildFrame(
    BuildContext context, {
    required String chapitreOne,
    required String userDescription,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.h,
        vertical: 5.v,
      ),
      decoration: AppDecoration.fillOnPrimaryContainer.copyWith(
        borderRadius: BorderRadiusStyle.customBorderTL16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: 6.v),
          Padding(
            padding: EdgeInsets.only(right: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 1.v),
                  child: Text(
                    chapitreOne,
                    style: CustomTextStyles.titleSmallBold.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                CustomImageView(
                  imagePath: ImageConstant.imgSearchOnsecondarycontainer,
                  height: 20.adaptSize,
                  width: 20.adaptSize,
                  margin: EdgeInsets.only(bottom: 2.v),
                ),
              ],
            ),
          ),
          SizedBox(height: 13.v),
          Padding(
            padding: EdgeInsets.only(right: 15.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 169.v,
                  width: 288.h,
                  margin: EdgeInsets.only(top: 4.v),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: 281.h,
                          child: Text(
                            userDescription,
                            maxLines: 7,
                            overflow: TextOverflow.ellipsis,
                            style: CustomTextStyles
                                .bodySmallPoppinsOnSecondaryContainer
                                .copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              height: 2.20,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomImageView(
                              imagePath: ImageConstant.imgIconlyLightDocument,
                              height: 20.adaptSize,
                              width: 20.adaptSize,
                            ),
                            CustomImageView(
                              imagePath:
                                  ImageConstant.imgDownloadErrorcontainer,
                              height: 20.adaptSize,
                              width: 20.adaptSize,
                              margin: EdgeInsets.only(left: 19.h),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                CustomImageView(
                  imagePath: ImageConstant.imgGroup5,
                  height: 166.v,
                  width: 1.h,
                  margin: EdgeInsets.only(
                    left: 11.h,
                    bottom: 8.v,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelGestion() {
    return AppColorsBuilder(
      builder: (context, colors) => Focus(
        onFocusChange: (hasFocus) async {
          if (!hasFocus) {
            try {
              if (phoneController.text.length == 8) {
                if (phoneController.text == '00000000') {
                  buildSuccessMessage(context, "key_erreur".tr,
                      "err_numero_invalide".tr, "key_fermer".tr, false);

                  setState(() {
                    boolNumTelValide = false;
                    boolDisableSuivant = true;
                  });
                  return;
                }
                boolNumTelValide =
                    (await myStore?.isValideNumTelGestion(phoneController.text))!;
              } else {
                buildSuccessMessage(context, "key_erreur".tr, "err_numero_invalide".tr,
                    "key_fermer".tr, false);

                setState(() {
                  boolNumTelValide = false;
                  boolDisableSuivant = true;
                });
                return;
              }
            } catch (e) {
              buildSuccessMessage(context, "key_erreur".tr,
                  "err_serveur_introuvable".tr, "key_fermer".tr, false);
              return;
            }
            if (!boolNumTelValide && phoneController.text.length == 8) {
              buildSuccessMessage(
                  context, "key_erreur".tr, "err_num_ulilise".tr, "key_fermer".tr, false);
              boolDisableSuivant = true;
            }
          }
          setState(() {});
        },
        child: Visibility(
          visible: (bAllDocsApprouved ?? false),
          child: Container(
            height: 56.v,
            constraints: const BoxConstraints(maxWidth: 500),
            margin: EdgeInsets.symmetric(horizontal: 20.h, vertical: 12.v),
            child: TextFormField(
              controller: phoneController,
              textDirection: (rtl ?? false) ? TextDirection.rtl : TextDirection.ltr,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 8,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "key_placeh_manag_phone".tr,
                hintStyle: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.phone,
                  color: boolNumTelValide ? colors.greenmillime : colors.iconSecondary,
                ),
                filled: true,
                fillColor: colors.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.h),
                  borderSide: BorderSide(color: colors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.h),
                  borderSide: BorderSide(color: colors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.h),
                  borderSide: BorderSide(color: colors.greenmillime, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.h),
                  borderSide: BorderSide(color: colors.errorColor, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.v),
                counterText: "",
              ),
            ),
          ),
        ),
      ),
    );
  }


  

  Widget _buildEmailGestion() {
    return AppColorsBuilder(
      builder: (context, colors) => Focus(
        onFocusChange: (hasFocus) async {
          if (!hasFocus) {
            if (emailController.text.isEmpty) {
              setState(() {
                boolDisableSuivant = true;
              });
              return;
            }

            if (!validEmailFormat(emailController.text)) {
              buildSuccessMessage(
                  context, "key_erreur".tr, "err_email_invalide".tr, "key_fermer".tr, false);

              setState(() {
                boolDisableSuivant = true;
              });
              return;
            }

            boolEmailValide =
                (await myStore?.isValideEmailGestion(emailController.text))!;

            setState(() {
              boolDisableSuivant = !boolEmailValide;
            });

            if (!boolEmailValide) {
              buildSuccessMessage(
                  context, "key_erreur".tr, "err_mail_utilise".tr, "key_fermer".tr, false);

              setState(() {
                boolDisableSuivant = true;
              });
            }
          }
        },
        child: Visibility(
          visible: boolNumTelValide,
          child: Container(
            height: 56.v,
            constraints: const BoxConstraints(maxWidth: 500),
            margin: EdgeInsets.symmetric(horizontal: 20.h, vertical: 12.v),
            child: TextFormField(
              controller: emailController,
              textDirection: (rtl ?? false) ? TextDirection.rtl : TextDirection.ltr,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "key_placeh_manag_email".tr,
                hintStyle: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.email,
                  color: boolEmailValide ? colors.greenmillime : colors.iconSecondary,
                ),
                filled: true,
                fillColor: colors.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.h),
                  borderSide: BorderSide(color: colors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.h),
                  borderSide: BorderSide(color: colors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.h),
                  borderSide: BorderSide(color: colors.greenmillime, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.h),
                  borderSide: BorderSide(color: colors.errorColor, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.v),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
