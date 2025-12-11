import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:millime/conf/constants.dart';
import 'package:millime/conf/size_utils.dart';
import 'package:millime/core/utils/image_constant.dart';
import 'package:millime/localizationMillime/localization/app_localization.dart';
import 'package:millime/pages/face_page.dart';
import 'package:millime/theme/theme_helper.dart';
import 'package:millime/widgets/mwidgets.dart';

import 'package:path_provider/path_provider.dart';
import 'package:millime/common/functions.dart';

import 'package:millime/main.dart';
import 'package:millime/models/demOuvNewCompteNewMand.dart';
import 'package:millime/models/demandeouvcomptetmp.dart';
import 'package:millime/models/docIn.dart';
import 'package:millime/models/pesonnep.dart';
import 'package:millime/pages/figma_integration/color.dart';
import 'package:millime/theme/app_colors.dart';

import 'package:millime/pages/plugins/rightleft/right_left_face_view.dart';
import 'package:millime/pages/wallet1111_page.dart';
import 'package:millime/pages/wallet111_page.dart';
import 'package:millime/pages/clean_selfie_page.dart';

import 'package:provider/provider.dart';
import 'package:millime/stores/login_store.dart';
import 'package:millime/theme.dart';

import 'package:rflutter_alert/rflutter_alert.dart';

class DateMask {
  final TextEditingController textController = TextEditingController();
  final MaskTextInputFormatter formatter;
  final FormFieldValidator<String>? validator;
  final String hint;
  String? label;

  final TextInputType textInputType;

  DateMask(
      {required this.formatter,
      this.validator,
      required this.hint,
      this.label,

      required this.textInputType});
}

class UpperCaseTextFormatter implements TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}

/// Result class for image picking operations
class ImagePickResult {
  final bool success;
  final String? imagePath;
  final String? errorMessage;
  
  const ImagePickResult({
    required this.success,
    this.imagePath,
    this.errorMessage,
  });
  
  factory ImagePickResult.success(String imagePath) =>
      ImagePickResult(success: true, imagePath: imagePath);
  
  factory ImagePickResult.failure(String errorMessage) =>
      ImagePickResult(success: false, errorMessage: errorMessage);
}

class Wallet11Page extends StatefulWidget {
  // const Wallet11Page({Key? key}) : super(key: key);
  @override
  _Wallet11PageState createState() => _Wallet11PageState();
}

Future<RecognizedText> fcnTextRecognizer(String fileName) {
  TextRecognizer _textRecognizer = TextRecognizer();

  return _textRecognizer.processImage(InputImage.fromFilePath(fileName));
}

class _Wallet11PageState extends State<Wallet11Page> {
  //TextEditingController phoneController = TextEditingController();
  String? selectedValueNivCompte;
  String? selectedValueTypeP;
  String? selectedValueTypePiece;
  bool _isBusy = false;

  int _activeStepIndex = 0;
  bool _codeIsVisible = false;
  bool _bDisableStepNext = true;
  bool _pass1IsVisible = false;
  bool _pass2IsVisible = false;
  String? currentLg;
  String? currentDateFormat;
  bool _bAskForDocs = false;

  late int oneTimePass;

  // TextEditingController tel = TextEditingController();
  // TextEditingController code = TextEditingController();
  // TextEditingController pass1 = TextEditingController();
  // TextEditingController pass2 = TextEditingController();

  TextEditingController telController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  DateMask dateMask = DateMask(
      formatter: MaskTextInputFormatter(mask: "##-##-####"),
      hint: "JJ-MM-AAAA",
      textInputType: TextInputType.datetime,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        final components = value.split("-");

        if (components.length == 3) {
          final day = int.tryParse(components[0]);
          final month = int.tryParse(components[1]);
          final year = int.tryParse(components[2]);
          if (day != null && month != null && year != null) {
            final date = DateTime(year, month, day);
            if (date.year == year && date.month == month && date.day == day) {
              final difference = DateTime.now().difference(date).inDays;
              if (difference / 365 < 18) {
                return "Age illégal";
              }

              return null;
            }
          }
        }
        // DateTime dateNaiss = intl.DateFormat('', currentLg).parse(dateNaissance.text);
        //intl.DateFormat
        return "Entrer une date";
      });

  // final _formStep1Key = GlobalKey<FormState>();
  // final _formStep2Key = GlobalKey<FormState>();

  late Future futurePersonne;

  bool bObscure = true;

  late PersonneP? personneP = null;

  late Future<DemandeOuvCompteTmp?> futuredemande;

  late String? errorPass1Msg = null;

  TextEditingController dateNaissance = TextEditingController();

  TextEditingController ppNomfr = TextEditingController();
  TextEditingController ppPrenomfr = TextEditingController();
  TextEditingController ppAdresse = TextEditingController();
  TextEditingController numPiece = TextEditingController();
  TextEditingController motifController = TextEditingController();

  // TextEditingController agentPaiCodeRegulateur = TextEditingController();
  // TextEditingController agentPaiCodeEtabPai = TextEditingController();
  // TextEditingController agentPaiDateDebRelation = TextEditingController();

  bool isAgent = false;

  String? selectedValueTypeAgent;

  bool bTypePersSelected = false;

  bool bTypePieceIsSelected = false;

  bool bNumPieceIsSelected = false;

  final formKeyPhone1 = GlobalKey<FormState>();
  static final GlobalKey<FormState> formKey = GlobalKey();

  bool validPhone = false;
  bool validNumPiece = false;

  String strMsg = "";

  bool codePinErrone = false;

  final ScrollController listImages = ScrollController();

  bool signataireEtTitulaire = true;

  bool deposee = false;

  bool booldmdEnvoyee = false;

  bool handicape = false;

  bool boolpersonneFound = false;

  bool barcodeVerified = true;

  bool disableCINR = true;
  bool disableCINV = true;
  bool disablePASS = true;

  bool disableSELFIE = true;
  bool disablePreuveDeVie = true;

  bool pieceIdVerifiee = false;

  String? cinr;

  bool bNeedTogetallDocs = false;

  bool booldmdfound = false;

  bool boolCompteExiste = false;

  bool showDocs = false;

  bool booldecesTitulaire = false;

  bool bFormChanged = false;

  bool bFormTelAndemailVerified = false;

  late int remains;

  bool fatca = false;
  bool vip = false;

  bool pep = false;
  bool rs = false;
  bool tva = false;
  String? selectedLevel;

  final int tncinLength = 8;
  final int tnpassLength = 7;

  final bool isExtendedProperties = false;

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Niveau1"), value: '1'),
      DropdownMenuItem(child: Text("Niveau2"), value: '2')
    ];
    return menuItems;
  }

  // final keyz = GlobalKey<FormState>();
  // final k3 = GlobalKey();
  // var appBarMaxHeight=Scaffold().appBar!.preferredSize.height;

  List<String> docManquants = []; // ['CINV', 'CINR', 'SELFIE'];

  List<CustomCard> docManquantss = [];
  List<dynamic> piecesitems = [];

  @override
  void initState() {
    super.initState();

    LoginStore myStore;

    List<dynamic>? pieces;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      myStore = Provider.of<LoginStore>(context, listen: false);
      timerStarted = false;
      remains = (myStore.selfiecountdown);
      pieces = await myStore.chargerListePiece(true).then((values) {
        piecesitems = List.generate(
            values!.length,
            (i) => (DropdownMenuItem(
                child: Text(
                    //values[i]['pieceIdentiteCode']
                    codePieceToLabelMapper[AppLocalization.of()
                            .locale
                            .languageCode]?[values[i]['pieceIdentiteCode']] ??
                        values[i]['pieceIdentiteCode']),
                value: values[i]['pieceIdentiteCode'])));
        setState(() {});
      });

      currentLg = AppLocalization.of().locale.languageCode;
      print("----------------------");
      print(currentLg);

      currentDateFormat = 'key_current_format'.tr;
      ppNomfr.text = myStore.dmd.tituPpNom ?? '';
      ppPrenomfr.text = myStore.dmd.tituPpPrenom ?? '';
      ppAdresse.text = myStore.dmd.tituPpAdresse ?? '';

      numPiece.text = myStore.dmd.tituPpPieceIdentiteNo ?? '';
      //selectedValueTypePiece = myStore.dmd.tituPpPieceIdentiteCode ?? '';
    });
  }

  Widget buildDateField(DateMask example) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          TextFormField(
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              labelText: "key_date_naissance".tr, //'Date de naissance  *',
              hintText: "key_entrer_date_naissance"
                  .tr, //'Entrez la date de naissance',
              prefixIcon: Icon(Icons.calendar_today,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : context.appColors.textPrimary,
                  size: 18),
              labelStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : context.appColors.textPrimary),
              hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[600]
                      : context.appColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(const Radius.circular(20)),
              ),
            ),
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : context.appColors.textPrimary),
            onTap: () async {
              DateTime? date;
              DateTime today = DateTime.now();

              if (example.textController.text.isNotEmpty) {
                try {
                  date = intl.DateFormat(currentDateFormat, currentLg)
                      .parse(example.textController.text);
                } catch (e) {
                  debugPrint('Erreur de parsing de date: $e');
                  date = null;
                }
              }

              // Fermer le clavier avant d'afficher le picker
              FocusScope.of(context).unfocus();
              
              // Utiliser le DatePicker natif de Flutter qui est plus fiable
              DateTime? pickedDate1 = await showDatePicker(
                context: context,
                initialDate: (date ?? pickedDate) ??
                    DateTime(today.year - 20, today.month, today.day),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                locale: Locale('fr', 'FR'),
                helpText: "key_selection_date".tr,
                confirmText: "key_confirmer".tr,
                cancelText: "key_annuler".tr,
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).brightness == Brightness.light
                          ? ColorScheme.light(
                              primary: context.appColors.greenmillime,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                            )
                          : ColorScheme.dark(
                              primary: context.appColors.greenmillime,
                              onPrimary: Colors.white,
                              surface: Colors.grey[900]!,
                              onSurface: Colors.white,
                            ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: context.appColors.greenmillime,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate1 != null) {
                try {
                  String formattedDate =
                      intl.DateFormat(currentDateFormat, currentLg)
                          .format(pickedDate1);
                  setState(() {
                    pickedDate = pickedDate1;
                    example.textController.text = formattedDate;
                    dateNaissance.text = example.textController.text;
                  });
                  // Valider le formulaire après sélection de date
                  final FormState? formState = formKey.currentState;
                  formState?.validate();
                } catch (e) {
                  debugPrint('Erreur de formatage de date: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors du formatage de la date'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                debugPrint("Aucune date sélectionnée");
              }
            },
            controller: example.textController,
            inputFormatters: [
              const UpperCaseTextFormatter(),
              example.formatter
            ],
            autocorrect: false,
            readOnly: true, // Prevents manual input
            keyboardType: example.textInputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (str) {
              String? error = example.validator!(str);
              if (error != null) {
                _bDisableStepNext = true;
                showDocs = false;
              }

              return error;
            },
            // decoration: InputDecoration(
            //   hintText: example.hint,
            //   hintStyle: const TextStyle(color: Colors.grey),
            //   fillColor: Colors.white,
            //   filled: true,
            //   focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
            //   enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            //   errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            //   border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
            //   errorMaxLines: 1
            // )
          ),
          Positioned(
            right: 0,
            top: 0,
            child: SizedBox(
                width: 48,
                height: 48,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      child: Icon(
                        Icons.clear,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[600]
                            : context.appColors.textSecondary,
                        size: 24,
                      ),
                      onTap: () {
                        example.textController.clear();
                        setState(() {
                          pickedDate = null;
                          dateNaissance.text = '';
                        });
                        // Valider le formulaire après suppression
                        final FormState? formState = formKey.currentState;
                        formState?.validate();
                      }),
                )),
          )
        ],
      ),
    );
  }

  Timer? _timer;
  bool timerStarted = false;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (mounted) {
          if (remains == 0) {
            setState(() {
              timer.cancel();
            });
          } else {
            setState(() {
              remains--;
            });
          }
        } else
          return;
      },
    );
  }

  void startTimer2() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (!timerStarted) if (remains == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            remains--;
          });
        }
        setState(() {
          timerStarted = true;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  Widget _buildList(BuildContext context, loginStore) {
    loginStore.rect = null;

    //  docManquants.sort((b, a) => a.length.compareTo(b.length));
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int i) {
        String item = docManquants[i];
        switch (item) {
          case 'CINR':
            item = 'CIN Recto';

            break;

          case 'CINV':
            item = 'CIN Verso';
            break;

          case 'PREUVEIE':
            item = 'Preuve de vie';
            break;
          default:
        }
        return Container(
          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 50),
          margin: EdgeInsets.only(bottom: 10),
          child: ListTile(
            subtitle: Row(
              //  fit: StackFit.loose,
              children: [
                if (item == 'SELFIE')
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 150, maxHeight: 60),
                      height: 60,
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.greenmillime,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                        child: Text(item,
                            style: theme.textTheme.titleSmall!
                                .copyWith(color: Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : context.appColors.textPrimary)),
                        onPressed: (disableSELFIE &&
                                !(pieceIdVerifiee && cinr == numPiece.text) &&
                                !(enableDocButton[docManquants[i]] ?? false))
                            ? null
                            : () async {
                                // Navigate to CleanSelfiePage
                                final File? capturedImage = await Navigator.of(context).push<File>(
                                  MaterialPageRoute(
                                    builder: (context) => CleanSelfiePage(
                                      title: 'Take Selfie',
                                      onImageCaptured: (File imageFile) {
                                        // This callback is optional since we handle the result via Navigator.pop
                                        debugPrint('Selfie captured: ${imageFile.path}');
                                      },
                                    ),
                                  ),
                                );

                                if (capturedImage != null) {
                                  // Handle the returned image
                                  var index = i;
                                  var imagePath = capturedImage.path;
                                  
                                  if (index < loginStore.tituimages!.length) {
                                    loginStore.tituimages![index] = imagePath;
                                  } else {
                                    num n = index - loginStore.tituimages!.length + 1;
                                    for (int j = 0; j < n; j++) {
                                      loginStore.tituimages!.add('');
                                    }
                                    loginStore.tituimages![index] = imagePath;
                                  }

                                  setState(() {
                                    // Enable next document button if available
                                    if (i + 1 < docManquants.length) {
                                      enableDocButton[docManquants[i + 1]] = true;
                                    }
                                    // Update UI to reflect the captured image
                                  });
                                  
                                  debugPrint('✅ Selfie integrated successfully at index $index: $imagePath');
                                } else {
                                  debugPrint('❌ No selfie captured or user cancelled');
                                }
                              },
                      ),
                    ),
                  )
                else if (item == 'CIN Recto' &&
                    (enableDocButton[docManquants[i]] ?? false))
                  Expanded(
                      child: Container(
                    constraints:
                        const BoxConstraints(maxWidth: 150, maxHeight: 60),
                    height: 60,
                    width: 150,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.greenmillime,
                          // primary: const Color.fromARGB(
                          //     255, 68, 175, 104),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                        child: Text(item,
                            style: theme.textTheme.titleSmall!
                                .copyWith(color: Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : context.appColors.textPrimary)),
                        onPressed: disableCINR
                            ? null
                            : () async {
                                bool res = await getImage(i, loginStore);
                                if (!res) {
                                  loginStore.tituimages![i] = null;
                                } else if (item == 'CIN Recto' &&
                                    !loginStore.tituimages.isEmpty &&
                                    i < loginStore.tituimages.length &&
                                    loginStore.tituimages![i] != null &&
                                    loginStore.tituimages![i] != '') {
                                  setState(() {
                                    _inProcess = true;
                                  });
                                  try {
                                    final TextRecognizer _textRecognizer =
                                        TextRecognizer();
                                    final recognizedTextFuture = _textRecognizer
                                        .processImage(InputImage.fromFilePath(
                                            loginStore.tituimages![i]));
                                    Future<bool?> checkLogoAndFlagFuture =
                                        loginStore.checkLogoAndFlag(
                                            loginStore.tituimages![i]);
                    
                                    // final recognizedTextFuture =  compute(
                                    //                               _textRecognizer.processImage,
                                    //                               InputImage.fromFilePath(loginStore.tituimages![i]));
                                    //  final resultsFuture=Future.wait([
                                    //                           compute ( fcnTextRecognizer,loginStore.tituimages![i] as String) ,
                                    //                           loginStore.checkLogoAndFlag(loginStore.tituimages![i]) as Future<bool?>
                                    //                                 ]);
                    
                                    final resultsFuture =
                                        Future.wait([recognizedTextFuture]);
                    
                                    final resultsFuture2 =
                                        Future.wait([checkLogoAndFlagFuture]);
                    
                                    final results = await resultsFuture;
                                    final results2 = await resultsFuture2;
                                    final bCheckLogoAndFalg =
                                        results2[0] as bool?;
                                    final recognizedText =
                                        results[0] as RecognizedText;
                    
                                    setState(() {
                                      _inProcess = false;
                                    });
                    
                                    if ((bCheckLogoAndFalg ?? false) &&
                                        (recognizedText.blocks.isNotEmpty &&
                                            recognizedText.text.length >= 8)) {
                                      for (var k = 0;
                                          k < recognizedText.blocks.length;
                                          k++) {
                                        if (recognizedText
                                                .blocks[k].text.length ==
                                            8) {
                                          setState(() {
                                            cinr = recognizedText.text
                                                .substring(0, 8);
                                            if (i + 1 < docManquants.length)
                                              enableDocButton[
                                                  docManquants[i + 1]] = true;
                    
                                            disableCINV = false;
                                          });
                                        }
                                        break;
                                      }
                                    } else {
                                      loginStore.cinr = '';
                                      setState(() {
                                        disableCINV = true;
                                        cinr = '';
                                      });
                    
                                      buildSuccessMessage(
                                          context,
                                          "key_erreur".tr,
                                          "err_refaire_op".tr,
                                          "key_fermer".tr,
                                          false);
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _inProcess = false;
                                      disableCINV = true;
                                    });
                                    // scaffymsg("err_refaire_op".tr, context,
                                    //     color: Colors.red[200]);
                    
                                    buildSuccessMessage(
                                        context,
                                        "key_erreur".tr,
                                        "err_refaire_op".tr,
                                        "key_fermer".tr,
                                        false);
                                  }
                                }
                              }),
                  ))
                else if (item == 'CIN Verso' &&
                    (enableDocButton[docManquants[i]] ?? false))
                  Expanded(
                    child: Container(
                      constraints:
                          const BoxConstraints(maxWidth: 150, maxHeight: 60),
                 
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.greenmillime,
                          // primary: const Color.fromARGB(
                          //     255, 68, 175, 104),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                        child: Text(item,
                            style: theme.textTheme.titleSmall!
                                .copyWith(color: Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : context.appColors.textPrimary)),
                        onPressed: disableCINV
                            ? null
                            : () async {
                                try {
                                  // Set processing state
                                  setState(() {
                                    _inProcess = true;
                                  });

                                  bool imageResult = await getImage(i, loginStore);
                                  
                                  if (!imageResult) {
                                    setState(() {
                                      _inProcess = false;
                                    });
                                    return;
                                  }

                                  if (item == 'CIN Verso' &&
                                      !loginStore.tituimages.isEmpty &&
                                      i < loginStore.tituimages.length &&
                                      loginStore.tituimages![i] != null &&
                                      loginStore.tituimages![i] != '') {
                                    
                                    try {
                                      final BarcodeScanner _barcodeScanner = BarcodeScanner();
                                      
                                      // Validate file exists before processing
                                      final File imageFile = File(loginStore.tituimages![i]!);
                                      if (!await imageFile.exists()) {
                                        throw Exception('Image file not found');
                                      }

                                      final List<Barcode> barcodes = await _barcodeScanner
                                          .processImage(InputImage.fromFilePath(loginStore.tituimages![i]!))
                                          .timeout(
                                            const Duration(seconds: 30),
                                            onTimeout: () => throw TimeoutException('Barcode scanning timed out'),
                                          );

                                      if (barcodes.isNotEmpty && barcodes.first.displayValue != null) {
                                        final String? codeAbar = barcodes.first.displayValue;
                                        debugPrint('Barcode detected: $codeAbar');
                                        
                                        if (codeAbar != null && codeAbar.length >= 8) {
                                          final String? cin = codeAbar.substring(0, 8);
                                          final DateTime theDate = extractDate(codeAbar);
                                          loginStore.howOldCINVis = oldInYears(theDate);

                                          if (cin == cinr) {
                                            if (numPiece.text == cin) {
                                              setState(() {
                                                disableSELFIE = false;
                                                pieceIdVerifiee = true;
                                                disablePreuveDeVie = false;
                                                if (i + 1 < docManquants.length)
                                                  enableDocButton[docManquants[i + 1]] = true;
                                              });
                                            } else {
                                              buildSuccessMessage(
                                                  context,
                                                  "key_erreur".tr,
                                                  "err_verif_saisie_num_cin".tr,
                                                  "key_fermer".tr,
                                                  false);
                                              setState(() {
                                                disableSELFIE = true;
                                                disablePreuveDeVie = true;
                                                pieceIdVerifiee = true;
                                              });
                                            }
                                          } else {
                                            buildSuccessMessage(
                                                context,
                                                "key_erreur".tr,
                                                "err_doc_cin_non_conforme".tr,
                                                "key_fermer".tr,
                                                false);
                                            setState(() {
                                              disableSELFIE = true;
                                              disablePreuveDeVie = true;
                                              pieceIdVerifiee = false;
                                            });
                                          }
                                        } else {
                                          throw Exception('Invalid barcode format');
                                        }
                                      } else {
                                        buildSuccessMessage(
                                            context,
                                            "key_erreur".tr,
                                            "err_doc_cinv_non_conforme".tr,
                                            "key_fermer".tr,
                                            false);
                                        setState(() {
                                          disableSELFIE = true;
                                          disablePreuveDeVie = true;
                                          pieceIdVerifiee = false;
                                        });
                                      }
                                    } catch (e) {
                                      debugPrint('$_logTag: Error during barcode scanning: $e');
                                      buildSuccessMessage(
                                          context,
                                          "key_erreur".tr,
                                          "err_refaire_op".tr,
                                          "key_fermer".tr,
                                          false);
                                      setState(() {
                                        disableSELFIE = true;
                                        disablePreuveDeVie = true;
                                        pieceIdVerifiee = false;
                                      });
                                    }
                                  }
                                } catch (e) {
                                  debugPrint('$_logTag: Error in CIN Verso processing: $e');
                                  if (mounted) {
                                    buildSuccessMessage(
                                        context,
                                        "key_erreur".tr,
                                        "err_refaire_op".tr,
                                        "key_fermer".tr,
                                        false);
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _inProcess = false;
                                    });
                                  }
                                }
                              },
                      ),
                    ),
                  )
                else if (item == 'Preuve de vie' &&
                    (enableDocButton[docManquants[i]] ?? false))
                  Expanded(
                    child: CustomCard2(
                      item,
                      RightLeftFaceDetectorView(
                        onAcceptedImage: (imagepath) async {
                          // print(imagepath);

                          // var index = i, imagePath = filePath + '/' + fileName;
                          var index = i, imagePath = imagepath;
                          if (index < loginStore.tituimages!.length) {
                            loginStore.tituimages![index] = imagePath;
                          } else {
                            num n = index - loginStore.tituimages!.length + 1;
                            for (int j = 0; j < n; j++) {
                              loginStore.tituimages!.add('');
                            }
                            loginStore.tituimages![index] = imagePath;
                          }
                          // }

                          if (i + 1 < docManquants.length)
                            enableDocButton[docManquants[i + 1]] = true;

                          setState(() {
                            // disableCINR = false;
                          });
                        },
                      ),
                      featuredisabled: disablePreuveDeVie &&
                          !(pieceIdVerifiee && cinr == numPiece.text),
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      constraints:
                          const BoxConstraints(maxWidth: 300, maxHeight: 170),
                      height: 60,
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.greenmillime,
                          //Color.fromARGB(255, 68, 175, 104)
                          // primary: const Color.fromARGB(
                          //     255, 68, 175, 104),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                        child: Text(item,
                            style: theme.textTheme.titleSmall!
                                .copyWith(color: Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : context.appColors.textPrimary)),
                        onPressed: enableDocButton[docManquants[i]] ?? false
                            ? () async {
                                //print (images);
                                await getImage(i, loginStore);
                                //print (images);
                                setState(() {
                                  if (i + 1 < docManquants.length)
                                    enableDocButton[docManquants[i + 1]] = true;
                                });
                              }
                            : null,
                      ),
                    ),
                  ),
                if (!loginStore.tituimages.isEmpty &&
                        i < loginStore.tituimages.length &&
                        loginStore.tituimages![i] != null &&
                        loginStore.tituimages![i] != ''
                    )
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        //padding: EdgeInsets.only(left: 150, bottom: 30),
                        // margin: EdgeInsets.only(left: 150, bottom: 86),
                        constraints:
                            const BoxConstraints(maxWidth: 300, maxHeight: 50),
                        child: Center(
                          child: loginStore.tituimages!.length > i &&
                                  loginStore.tituimages![i] != null &&
                                  loginStore.tituimages![i] != '' &&
                                  !loginStore.tituimages![i]
                                      .toString()
                                      .contains('zip')
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.file(
                                    File(loginStore.tituimages![i]!),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      debugPrint('Error loading image at index $i: $error');
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: context.appColors.greenmillime.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Icon(
                                          Icons.image,
                                          color: context.appColors.greenmillime,
                                          size: 24,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : (loginStore.tituimages![i] != null &&
                                      loginStore.tituimages![i]
                                          .toString()
                                          .contains('zip')
                                  ? Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: context.appColors.greenmillime.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Icon(
                                        Icons.folder,
                                        color: context.appColors.greenmillime,
                                        size: 24,
                                      ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: context.appColors.greenmillime.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Image.asset(
                                        (loginStore.alignRight ?? false)
                                            ? ImageConstant.imgMillimeArlogo
                                            : ImageConstant.imgMillimelogo,
                                        width: 30,
                                        height: 30,
                                      ),
                                    )),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // subtitle: (loginStore.tituimages.length > i &&
            //         loginStore.tituimages[i] != null &&
            //         loginStore.tituimages[i] != '')
            //     ? (Image.file(File(loginStore.tituimages[i])))
            //     : Image.asset('assets/img/logoMillimes.png'),

            //subtitle:Image.asset('assets/img/logoMillimes.png'),
            // onTap: () {
            //   //print (images);
            //   boolpersonneFound ? null : getImage(i, loginStore);
            //   //print (images);

            //   setState(() {
            //     // items.removeAt(i);
            //     // items!.add( i.toString());
            //   });
            // },
          ),
        );
        //    } else {
        //   return Container();
        // }
      },
      itemCount: docManquants.length,
    );
  }

  bool init = false;
  List<DocIn?>? docss;
  List<DocIn?>? docssALL;

  DateTime? pickedDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.watchAppColors;
    return Consumer<LoginStore>(
      builder: (_, loginStore, __) {
        // loginStore.chargerDocInRequisNvCompte(true, loginStore.demande?.niveauCompte, true).then((value) => docss = value);
        //if (docManquantss.isEmpty && (docss?.isNotEmpty ?? false)) {
        if (docManquantss.isEmpty) {
          loginStore
              .chargerDocInRequisNvCompte(
                  true, loginStore.demande?.niveauCompte, true)
              .then((docs) {
            docManquantss = List.generate(
                docs!.length,
                (i) => CustomCard(
                    docs[i]!.docInCode!, 'assets/img/logoMillimes.png'));

            docManquants =
                List.generate(docs.length, (i) => docs[i]!.docInCode!);
            loginStore.selfiecountdown = 5;

            for (var e in docManquants) {
              enableDocButton[e] = false;
            }
            docss = docs;
            docssALL = docs;
            enableDocButton[docManquants[0]] = true;
          });
        }

        selectedLevel = loginStore.demande?.niveauCompte;

        if (!init) {
          selectedValueTypePiece = loginStore.dmd.tituPpPieceIdentiteCode;
          currentLg = AppLocalization.of().locale.languageCode;
          if (loginStore.dmd.tituPpNaissanceDate != null) {
            //  DateTime dateNaiss = intl.DateFormat('yyyy-MM-dd', currentLg).parse((loginStore.dmd.tituPpNaissanceDate).toString());
            DateTime dateNaiss = intl.DateFormat(currentDateFormat, currentLg)
                .parse((loginStore.dmd.tituPpNaissanceDate).toString());
            dateNaissance.text =
                intl.DateFormat(currentDateFormat, currentLg).format(dateNaiss);
            //dateNaissance.text = intl.DateFormat( currentLg).format(dateNaiss);
          }
          if (boolpersonneFound) {
            disableCINR = true;
          }

          if (loginStore.dmd.tituPpPieceIdentiteCode != null)
            _bDisableStepNext = false;
          // setState(() {});
          init = true;
        }

        return Directionality(
          textDirection:
              (loginStore.alignRight) ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            appBar: millimeAppBar(
                onTapfn: () {
                  Navigator.pushNamed(context, '/auth');
                },
                getContext: () {
                  return context;
                },
                opencloseDrawer: () {}),

            backgroundColor: colors.white,
            //  key: loginStore.wallet11ScaffoldKey,
            body: SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            const SizedBox(
                              height: 16,
                            ),
                            Container(
                              alignment: Alignment.center,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "key_id_titu".tr,

                                    //  'Identité Titulaire:',
                                    style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.light
                                            ? Colors.black
                                            : colors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  SizedBox(width: 80.h),
                                  Text(
                                      "PP-" +
                                          (selectedLevel == "Niveau1"
                                              ? "N1"
                                              : (selectedLevel == "Niveau2")
                                                  ? "N2"
                                                  : ""),
                                      style: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.light
                                              ? Colors.black
                                              : colors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Center(
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 300),
                                child: Focus(
                                  onFocusChange: (focus) {
                                    // if (!focus) {
                                    final FormState? formState =
                                        formKey.currentState;

                                    bool validForm = false;
                                    if (!numPiece.text.isEmpty &&
                                        bTypePieceIsSelected &&
                                        !ppNomfr.text.isEmpty &&
                                        !ppPrenomfr.text.isEmpty &&
                                        !ppAdresse.text.isEmpty &&
                                        // !dateNaissance.text.isEmpty &&
                                        dateMask
                                            .textController.text.isNotEmpty &&
                                        !emailController.text.isEmpty &&
                                        !boolCompteExiste &&
                                        !booldecesTitulaire) {
                                      validForm = (formState?.validate())!;

                                      if (telController.text !=
                                              loginStore.phoneNo ||
                                          emailController.text.trim() !=
                                              loginStore.walletEmailGestion) {
                                        setState(() {
                                          bFormChanged = false;
                                          _bDisableStepNext = true;
                                          showDocs = false;
                                          _bAskForDocs = false;
                                        });
                                        return;
                                      }

                                      //  e['docIn']['docInBoolTypePieceIdent'] != 'N' &&

                                      setState(() {
                                        docss = docssALL
                                            ?.where((doc) =>
                                                doc != null &&
                                                ((doc.docInBoolTypePieceIdent ==
                                                            'O' &&
                                                        doc.pieceIdentite !=
                                                            null &&
                                                        doc.pieceIdentite
                                                                ?.pieceIdentiteCode ==
                                                            selectedValueTypePiece) ||
                                                    doc.pieceIdentite == null))
                                            .toList();

                                        docManquants = List.generate(
                                            docss!.length,
                                            (i) => docss![i]!.docInCode!);

                                        loginStore.tituimages = [];
                                        if (loginStore.tituimages.isEmpty)
                                          for (int k = 0;
                                              k < docManquants.length;
                                              k++) {
                                            loginStore.tituimages.add(null);
                                          }

                                        enableDocButton = {};
                                        for (var e in docManquants) {
                                          enableDocButton[e] = false;
                                        }

                                        enableDocButton[docManquants[0]] = true;

                                        _bDisableStepNext = !validForm;
                                        // showDocs=validForm;
                                        if (validForm ||
                                            boolpersonneFound ||
                                            pieceIdVerifiee) {
                                          showDocs = validForm;
                                          disableCINR = false;
                                          disableCINV = false;
                                          disableSELFIE = false;
                                          disablePreuveDeVie = false;
                                        }
                                        if (!boolpersonneFound && validForm) {
                                          showDocs = validForm;
                                          disableCINR = false;
                                          disableCINV = true;
                                          disableSELFIE = true;
                                          disablePreuveDeVie = true;
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        //bDisableStepNext = !validForm;
                                        boolCompteExiste = false;
                                      });
                                    }
                                    //}
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      DropdownButtonFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: (dynamic? value) {
                                          if (value == null || value.isEmpty) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              setState(() {
                                                _bDisableStepNext = true;
                                                showDocs = false;
                                                _bAskForDocs = false;
                                              });
                                            });

                                            return "err_champ_requis".tr;
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10.0,
                                                  horizontal: 10.0),
                                          prefixIcon: Icon(
                                              Icons.credit_card_sharp,
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.black
                                                  : context.appColors.textPrimary,
                                              size: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    const Radius.circular(20)),
                                          ),
                                          labelStyle: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.black
                                                  : context.appColors.textPrimary),
                                          hintStyle: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.grey[600]
                                                  : context.appColors.textSecondary),
                                          labelText: "key_type_piece".tr,
                                          // 'Type de pièce  *',
                                          hintText: "msg_type_piece".tr,
                                          // 'Entrez le type de la pièce d\'identité ',
                                        ),
                                        value: selectedValueTypePiece,
                                        onChanged: boolpersonneFound
                                            ? null
                                            : (dynamic? newValue) {
                                                //formKey.currentState?.validate();

                                                setState(() {
                                                  selectedValueTypePiece =
                                                      newValue!;
                                                  bTypePieceIsSelected = true;
                                                });
                                              },
                                        items: piecesitems
                                            .map((e) => e as DropdownMenuItem)
                                            .toList(),
                                      ),

                                      const SizedBox(
                                        height: 8,
                                      ),

                                      Focus(
                                        onFocusChange: (hasfocus) async {
                                          if (!hasfocus) {
                                            erasefiledsTitu();
                                            if (numPiece.text.length == 8) {
                                              await loginStore
                                                  .findFirstDmd(
                                                      numPiece.text,
                                                      selectedValueTypePiece
                                                          .toString(),
                                                      'P')
                                                  .then((dmd) async {
                                                if (dmd != null) {
                                                  setState(() {
                                                    booldmdfound = true;
                                                  });

                                                  buildSuccessMessage(
                                                      context,
                                                      "key_erreur".tr,
                                                      dmd.toString().tr,
                                                      "key_fermer".tr,
                                                      false);

                                                  return;
                                                } else {
                                                  setState(() {
                                                    booldmdfound = false;
                                                  });

                                                  await loginStore
                                                      .fetchPersonnePbyPieceIdentite(
                                                          selectedValueTypePiece
                                                              .toString(),
                                                          numPiece.text)
                                                      .then((pp) async {
                                                    if (pp != null) {
                                                      setState(() {
                                                        boolpersonneFound =
                                                            true;
                                                      });

                                                      ppNomfr.text =
                                                          (pp.ppNomFr)
                                                              .toString();
                                                      ppPrenomfr.text =
                                                          (pp.ppPrenomFr)
                                                              .toString();
                                                      ppAdresse.text =
                                                          (pp.ppAdresse)
                                                              .toString();

                                                      // DateTime dateNaiss = intl.DateFormat(currentDateFormat, currentLg)
                                                      //     .parse((pp.ppDateNaissance).toString());

                                                      // dateNaissance.text = intl.DateFormat(currentDateFormat, currentLg)
                                                      //     .format(dateNaiss);

                                                      DateTime? dateNaiss =
                                                          pp.ppDateNaissance;
                                                      //intl.DateFormat(currentDateFormat, currentLg).parse((pp.ppDateNaissance).toString());
                                                      dateNaissance
                                                          .text = dateNaiss ==
                                                              null
                                                          ? ""
                                                          : intl.DateFormat(
                                                                  currentDateFormat,
                                                                  currentLg)
                                                              .format(
                                                                  dateNaiss!);
                                                      dateMask.textController
                                                              .text =
                                                          dateNaissance.text;

                                                      //  intl.DateFormat().

                                                      selectedValueTypePiece =
                                                          (pp.pieceIdentite
                                                              ?.pieceIdentiteCode
                                                              .toString());

                                                      if (pp.ppDateDeces !=
                                                          null) {
                                                        buildSuccessMessage(
                                                            context,
                                                            "key_erreur".tr,
                                                            "err_titulaire_non_autorise"
                                                                .tr,
                                                            "key_fermer".tr,
                                                            false);

                                                        setState(() {
                                                          booldecesTitulaire =
                                                              true;
                                                          _bDisableStepNext =
                                                              true;
                                                          showDocs = false;
                                                        });
                                                        return;
                                                      } else {
                                                        setState(() {
                                                          booldecesTitulaire =
                                                              false;
                                                          _bDisableStepNext =
                                                              false;
                                                          // showDocs=true;
                                                        });
                                                      }

                                                      await loginStore
                                                          .getWalletByCin(
                                                              numPiece.text)
                                                          .then((wallet) {
                                                        if (wallet != null) {
                                                          setState(() {
                                                            disableCINR = true;
                                                            _bDisableStepNext =
                                                                true;
                                                            showDocs = false;
                                                            boolCompteExiste =
                                                                true;
                                                          });

                                                          buildSuccessMessage(
                                                              context,
                                                              "key_erreur".tr,
                                                              wallet
                                                                  .toString()
                                                                  .tr,
                                                              "key_fermer".tr,
                                                              false);
                                                        } else {
                                                          loadDocsOfPp2(
                                                              loginStore);

                                                          setState(() {
                                                            if (pp.ppDateDeces !=
                                                                null)
                                                              _bDisableStepNext =
                                                                  true;

                                                            boolCompteExiste =
                                                                false;
                                                          });
                                                        }
                                                        ;

                                                        return;
                                                      });
                                                    } else //pp==null
                                                    {
                                                      for (var e
                                                          in docManquants) {
                                                        enableDocButton[e] =
                                                            false;
                                                      }
                                                      enableDocButton[
                                                              docManquants[0]] =
                                                          true;

                                                      for (int k = 0;
                                                          k <
                                                              loginStore
                                                                  .tituimages
                                                                  .length;
                                                          k++)
                                                        loginStore
                                                                .tituimages[k] =
                                                            null;

                                                      setState(() {
                                                        pieceIdVerifiee = false;
                                                        booldecesTitulaire =
                                                            false;
                                                        cinr = null;
                                                        disableSELFIE = true;
                                                        disablePreuveDeVie =
                                                            true;
                                                        boolpersonneFound =
                                                            false;
                                                      });
                                                    }
                                                  }).onError(
                                                          (error, stackTrace) {
                                                    print(error);
                                                  });
                                                }
                                              }).onError((error, stackTrace) {
                                                print(error);
                                              });
                                            }

                                            // setState(() {});
                                          }
                                        },
                                        child: Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 300),
                                          child: TextFormField(
                                            //: !boolpersonneFound,
                                            maxLength:
                                                (selectedValueTypePiece ==
                                                        "TNCIN")
                                                    ? tncinLength
                                                    : tnpassLength,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            controller: numPiece,
                                            decoration: InputDecoration(
                                              counterText: '',
                                              labelText: "label_n_piece"
                                                  .tr, //'N° Pièce  *',
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15.0,
                                                      horizontal: 10.0),
                                              hintText: "hint_n_piece"
                                                  .tr, //'Num. Pièce',
                                              prefixIcon: Icon(
                                                  Icons.perm_identity,
                                                  color: Theme.of(context).brightness == Brightness.light
                                                      ? Colors.black
                                                      : context.appColors.textPrimary,
                                                  size: 20),
                                              labelStyle: TextStyle(
                                                  color: Theme.of(context).brightness == Brightness.light
                                                      ? Colors.black
                                                      : context.appColors.textPrimary),
                                              hintStyle: TextStyle(
                                                  color: Theme.of(context).brightness == Brightness.light
                                                      ? Colors.grey[600]
                                                      : context.appColors.textSecondary),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context).brightness == Brightness.light
                                                        ? Colors.black
                                                        : colors.borderColor,
                                                    width: 2.0,
                                                    style: BorderStyle.solid),
                                                borderRadius: const BorderRadius
                                                    .all(
                                                    const Radius.circular(20)),
                                              ),
                                              // icon:
                                              //     Icon(Icons.smartphone, color: Colors.blue, size: 20)
                                            ),
                                            style: TextStyle(
                                                color: Theme.of(context).brightness == Brightness.light
                                                    ? Colors.black
                                                    : context.appColors.textPrimary),
                                            // inputFormatters: [FilteringTextInputFormatter.allow( regexMap [selectedValueTypePiece??"TNCIN"]!.regEx )],
                                            validator: (String? value) {
                                              //if (!_bDisableStepNext)
                                              if (value!.isEmpty) {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  setState(() {
                                                    _bDisableStepNext = true;
                                                    showDocs = false;
                                                  });
                                                });
                                                return "err_champ_requis".tr;
                                              } else if (value
                                                      .toString()
                                                      .length !=
                                                  ((selectedValueTypePiece ==
                                                          "TNCIN")
                                                      ? tncinLength
                                                      : tnpassLength)) {
                                                return "err_longueur_incorrecte"
                                                    .tr;
                                              } else if (value == '00000000') {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  setState(() {
                                                    _bDisableStepNext = true;
                                                    showDocs = false;
                                                  });
                                                });
                                                return "err_numero_invalide".tr;
                                              }
                                              ValidationResult vr =
                                                  doesValueMatchRegex(
                                                      selectedValueTypePiece ??
                                                          "TNCIN",
                                                      value);
                                              return vr.errorMessage?.tr;
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),

                                      Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 300),
                                        child: TextFormField(
                                          enabled: !boolpersonneFound ||
                                              !booldmdfound,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          controller: ppNomfr,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 15.0,
                                                    horizontal: 10.0),
                                            labelText: "key_nom".tr, //'Nom  *',
                                            hintText: "key_enter_name"
                                                .tr, //'Entrez votre Nom',
                                            prefixIcon: Icon(
                                                Icons.perm_identity,
                                                color: Theme.of(context).brightness == Brightness.light
                                                    ? Colors.black
                                                    : context.appColors.textPrimary,
                                                size: 20),
                                            labelStyle: TextStyle(
                                                color: Theme.of(context).brightness == Brightness.light
                                                    ? Colors.black
                                                    : context.appColors.textPrimary),
                                            hintStyle: TextStyle(
                                                color: Theme.of(context).brightness == Brightness.light
                                                    ? Colors.grey[600]
                                                    : context.appColors.textSecondary),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context).brightness == Brightness.light
                                                      ? Colors.black
                                                      : colors.borderColor,
                                                  width: 2.0,
                                                  style: BorderStyle.solid),
                                              borderRadius: const BorderRadius
                                                  .all(
                                                  const Radius.circular(20)),
                                            ),
                                            // icon:
                                            //     Icon(Icons.smartphone, color: Colors.blue, size: 20)
                                          ),
                                          style: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.black
                                                  : context.appColors.textPrimary),
                                          validator: (String? value) {
                                            //if (!_bDisableStepNext)
                                            if (value!.isEmpty) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                setState(() {
                                                  _bDisableStepNext = true;
                                                  showDocs = false;
                                                });
                                              });

                                              return "err_nom_requis".tr;
                                            } else if (value.length == 1)
                                              return "err_min_carac".tr;

                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      //Container(
                                      // constraints:
                                      //   const BoxConstraints(maxWidth: 300,maxHeight:50),
                                      // child:
                                      TextFormField(
                                        enabled:
                                            !boolpersonneFound || !booldmdfound,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        controller: ppPrenomfr,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 15.0,
                                                  horizontal: 10.0),
                                          labelText:
                                              "key_prenom".tr, // 'Prénom  *',
                                          hintText: "key_enter_prenom"
                                              .tr, // 'Entrez votre prénom',
                                          prefixIcon: Icon(Icons.perm_identity,
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.black
                                                  : context.appColors.textPrimary,
                                              size: 20),
                                          labelStyle: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.black
                                                  : context.appColors.textPrimary),
                                          hintStyle: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.grey[600]
                                                  : context.appColors.textSecondary),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    const Radius.circular(20)),
                                          ),
                                          // icon:
                                          //     Icon(Icons.smartphone, color: Colors.blue, size: 20)
                                        ),
                                        style: TextStyle(
                                            color: Theme.of(context).brightness == Brightness.light
                                                ? Colors.black
                                                : context.appColors.textPrimary),
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              setState(() {
                                                _bDisableStepNext = true;
                                                showDocs = false;
                                              });
                                            });

                                            return "err_prenom_requis".tr;
                                          } else if (value.length == 1)
                                            return "err_min_carac".tr;
                                          return null;
                                        },
                                      ),
                                      //),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      buildDateField(dateMask),

                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                        enabled:
                                            !boolpersonneFound || !booldmdfound,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        controller: ppAdresse,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 15.0,
                                                  horizontal: 10.0),
                                          labelText:
                                              "key_adresse".tr, //'Adresse  *',
                                          hintText: "key_entrer_adresse"
                                              .tr, //'Entrez votre adresse',
                                          prefixIcon: Icon(Icons.perm_identity,
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.black
                                                  : context.appColors.textPrimary,
                                              size: 20),
                                          labelStyle: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.black
                                                  : context.appColors.textPrimary),
                                          hintStyle: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.grey[600]
                                                  : context.appColors.textSecondary),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    const Radius.circular(20)),
                                          ),
                                          // icon:
                                          //     Icon(Icons.smartphone, color: Colors.blue, size: 20)
                                        ),
                                        style: TextStyle(
                                            color: Theme.of(context).brightness == Brightness.light
                                                ? Colors.black
                                                : context.appColors.textPrimary),
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              setState(() {
                                                _bDisableStepNext = true;
                                                showDocs = false;
                                              });
                                            });

                                            return "err_champ_requis".tr;
                                          } else if (value.length == 1)
                                            return "err_min_carac".tr;
                                          return null;
                                        },
                                      ),

                                      const SizedBox(
                                        height: 8,
                                      ),

                                      Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 300),
                                        child: TextFormField(
                                          onChanged: (value) {
                                            setState(() {
                                              bFormTelAndemailVerified = false;
                                            });
                                          },
                                          enabled: !boolpersonneFound ||
                                              !booldmdfound,
                                          maxLength: 8,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          controller: telController,
                                          decoration: InputDecoration(
                                            counterText: '',
                                            labelText: "key_num_tel"
                                                .tr, //'Num. Tel  *',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 15.0,
                                                    horizontal: 10.0),
                                            hintText: "key_entrer_num_tel"
                                                .tr, // 'Num. Tel',
                                            prefixIcon: Icon(Icons.smartphone,
                                                color: Theme.of(context).brightness == Brightness.light
                                                    ? Colors.black
                                                    : context.appColors.textPrimary,
                                                size: 20),
                                            labelStyle: TextStyle(
                                                color: Theme.of(context).brightness == Brightness.light
                                                    ? Colors.black
                                                    : context.appColors.textPrimary),
                                            hintStyle: TextStyle(
                                                color: Theme.of(context).brightness == Brightness.light
                                                    ? Colors.grey[600]
                                                    : context.appColors.textSecondary),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context).brightness == Brightness.light
                                                      ? Colors.black
                                                      : colors.borderColor,
                                                  width: 2.0,
                                                  style: BorderStyle.solid),
                                              borderRadius: const BorderRadius
                                                  .all(
                                                  const Radius.circular(20)),
                                            ),
                                            // icon:
                                            //     Icon(Icons.smartphone, color: Colors.blue, size: 20)
                                          ),
                                          style: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.black
                                                  : context.appColors.textPrimary),
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          validator: (String? value) {
                                            if (value!.isEmpty) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                setState(() {
                                                  _bDisableStepNext = true;
                                                  showDocs = false;
                                                });
                                              });
                                              return "err_champ_requis".tr;
                                            } else if (value.length != 8) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                setState(() {
                                                  _bDisableStepNext = true;
                                                  showDocs = false;
                                                });
                                              });
                                              return "err_longueur_incorrecte"
                                                  .tr;
                                            } else if (value == '00000000') {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                setState(() {
                                                  _bDisableStepNext = true;
                                                  showDocs = false;
                                                });
                                              });
                                              return "err_numero_invalide".tr;
                                            } else if (value !=
                                                loginStore.phoneNo) {
                                              return "err_numero_different".tr;
                                            }

                                            return null;
                                          },
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 8,
                                      ),

                                      Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 300),
                                        child: TextFormField(
                                          enabled: !boolpersonneFound ||
                                              !booldmdfound,
                                          //   initialValue: '',
                                          // loginStore.dmd.tituPpEmail ?? '',
                                          // maxLength: 8,
                                          onChanged: (value) {
                                            setState(() {
                                              bFormTelAndemailVerified = false;
                                            });
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          controller: emailController,
                                          decoration: InputDecoration(
                                            counterText: '',
                                            labelText: "key_email_star"
                                                .tr, //'Email  *',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 15.0,
                                                    horizontal: 10.0),
                                            hintText: "key_entrer_email"
                                                .tr, //'Email',

                                            prefixIcon: Icon(
                                                Icons.email_outlined,
                                                color: Theme.of(context).brightness == Brightness.light
                                                    ? Colors.black
                                                    : context.appColors.textPrimary,
                                                size: 20),
                                            labelStyle: TextStyle(
                                                color: Theme.of(context).brightness == Brightness.light
                                                    ? Colors.black
                                                    : context.appColors.textPrimary),
                                            hintStyle: TextStyle(
                                                color: Theme.of(context).brightness == Brightness.light
                                                    ? Colors.grey[600]
                                                    : context.appColors.textSecondary),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context).brightness == Brightness.light
                                                      ? Colors.black
                                                      : colors.borderColor,
                                                  width: 2.0,
                                                  style: BorderStyle.solid),
                                              borderRadius: const BorderRadius
                                                  .all(
                                                  const Radius.circular(20)),
                                            ),
                                            // icon:
                                            //     Icon(Icons.smartphone, color: Colors.blue, size: 20)
                                          ),
                                          style: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.black
                                                  : context.appColors.textPrimary),
                                          // inputFormatters: [
                                          //   FilteringTextInputFormatter.digitsOnly
                                          // ],
                                          validator: (String? value) {
                                            if (value!.isEmpty) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                setState(() {
                                                  _bDisableStepNext = true;
                                                  showDocs = false;
                                                });
                                              });
                                              return "err_champ_requis".tr;
                                            } else {
                                              // bool emailValid = RegExp(
                                              //         r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                              //     .hasMatch(value);
                                              value = value.trim();
                                              bool emailValid =
                                                  validEmailFormat(value);
                                              if (!emailValid)
                                                return "err_email_invalide".tr;
                                            }
                                            if (value !=
                                                loginStore.walletEmailGestion) {
                                              return "err_email_different".tr;
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      // if (false)
                                      // Column(
                                      //                                 children: [
                                      //                                   Row(
                                      //                                     children: [
                                      //                                       Flexible(
                                      //                                         child: Row(
                                      //                                           children: [
                                      //                                             Checkbox(
                                      //                                               value: this.tva,
                                      //                                               onChanged: (bool? value) {
                                      //                                                 setState(() {
                                      //                                                   tva = value!;
                                      //                                                 });
                                      //                                               },
                                      //                                             ),
                                      //                                             Flexible(
                                      //                                               child: Text("key_tva".tr,
                                      //                                                        //  style: TextStyle(fontSize: 12.fSize),
                                      //                                                 style: theme.textTheme.titleSmall!.copyWith(fontSize: 12.fSize),

                                      //                                               ),
                                      //                                             )
                                      //                                           ],
                                      //                                         ),
                                      //                                       ),
                                      //                                       Flexible(
                                      //                                         child: Row(
                                      //                                           children: [
                                      //                                             Checkbox(
                                      //                                               value: this.rs,
                                      //                                               onChanged: (bool? value) {
                                      //                                                 setState(() {
                                      //                                                   rs = value!;
                                      //                                                 });
                                      //                                               },
                                      //                                             ),
                                      //                                             Flexible(
                                      //                                               child: Text("key_rs".tr,
                                      //                                                 style: theme.textTheme.titleSmall!.copyWith(fontSize: 12.fSize),
                                      //                                               ),
                                      //                                             )
                                      //                                           ],
                                      //                                         ),
                                      //                                       ),
                                      //                                           Flexible(
                                      //                                         child: Row(
                                      //                                           children: [
                                      //                                             Checkbox(
                                      //                                               value: this.fatca,
                                      //                                               onChanged: (bool? value) {
                                      //                                                 setState(() {
                                      //                                                   fatca = value!;
                                      //                                                 });
                                      //                                               },
                                      //                                             ),
                                      //                                             Flexible(
                                      //                                               child: Text("key_fatca".tr,
                                      //                                                 style: theme.textTheme.titleSmall!.copyWith(fontSize: 12.fSize),
                                      //                                               ),
                                      //                                             )
                                      //                                           ],
                                      //                                         ),
                                      //                                       ),
                                      //                                     ],
                                      //                                   ),

                                      //                                                                   Row(
                                      //                                     children: [
                                      //                                       Flexible(
                                      //                                         child: Row(
                                      //                                           children: [
                                      //                                             Checkbox(
                                      //                                               value: this.vip,
                                      //                                               onChanged: (bool? value) {
                                      //                                                 setState(() {
                                      //                                                   vip = value!;
                                      //                                                 });
                                      //                                               },
                                      //                                             ),
                                      //                                             Flexible(
                                      //                                               child: Text("key_vip".tr,
                                      //                                                 style: theme.textTheme.titleSmall!.copyWith(fontSize: 12.fSize),
                                      //                                               ),
                                      //                                             )
                                      //                                           ],
                                      //                                         ),
                                      //                                       ),
                                      //                                       Flexible(
                                      //                                         child: Row(
                                      //                                           children: [
                                      //                                             Checkbox(
                                      //                                               value: this.pep,
                                      //                                               onChanged: (bool? value) {
                                      //                                                 setState(() {
                                      //                                                   pep = value!;
                                      //                                                 });
                                      //                                               },
                                      //                                             ),
                                      //                                             Flexible(
                                      //                                               child: Text("key_pep".tr,
                                      //                                                 style: theme.textTheme.titleSmall!.copyWith(fontSize: 12.fSize),
                                      //                                               ),
                                      //                                             )
                                      //                                           ],
                                      //                                         ),
                                      //                                       ),
                                      //                                     ],
                                      //                                   ),

                                      //                                   Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                      //                                     Expanded(
                                      //                                       child: Row(
                                      //                                         children: [
                                      //                                           Checkbox(
                                      //                                             value: this.handicape,
                                      //                                             onChanged: (bool? value) {
                                      //                                               setState(() {
                                      //                                                 handicape = value!;
                                      //                                               });
                                      //                                             },
                                      //                                           ),
                                      //                                           Expanded(
                                      //                                             child:
                                      //                                                 Text("key_handicap_signataire".tr,
                                      //                                                   style: theme.textTheme.titleSmall!.copyWith(fontSize: 12.fSize),
                                      //                                                 ),
                                      //                                           )
                                      //                                         ],
                                      //                                       ),
                                      //                                       flex: 1,
                                      //                                     ),
                                      //                                     Visibility(
                                      //                                       visible: handicape,
                                      //                                       child: Expanded(
                                      //                                         child: TextFormField(
                                      //                                           enabled: !boolpersonneFound,
                                      //                                           maxLength: 8,
                                      //                                           autovalidateMode: AutovalidateMode.onUserInteraction,
                                      //                                           controller: motifController,
                                      //                                           decoration: InputDecoration(
                                      //                                             counterText: '',
                                      //                                             labelText: "key_motif_handicap".tr,
                                      //                                             contentPadding:
                                      //                                                 const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                      //                                           //  hintText: "key_motif_handicap".tr,
                                      //                                            // hintStyle: theme.textTheme.titleSmall!.copyWith(fontSize: 12.fSize),

                                      //                                             border: OutlineInputBorder(
                                      //                                               borderSide: BorderSide(
                                      //                                                   color: Colors.black, width: 2.0, style: BorderStyle.solid),
                                      //                                               borderRadius: const BorderRadius.all(const Radius.circular(20)),
                                      //                                             ),
                                      //                                             // icon:
                                      //                                             //     Icon(Icons.smartphone, color: Colors.blue, size: 20)
                                      //                                           ),
                                      //                                           validator: (String? value) {
                                      //                                             if (value!.isEmpty) {
                                      //                                               WidgetsBinding.instance.addPostFrameCallback((_) {
                                      //                                                 setState(() {
                                      //                                                   _bDisableStepNext = true;
                                      //                                                   showDocs = false;
                                      //                                                 });
                                      //                                               });
                                      //                                               return "err_champ_requis".tr;
                                      //                                             }

                                      //                                             return null;
                                      //                                           },
                                      //                                         ),
                                      //                                       ),
                                      //                                     )
                                      //                                   ]),
                                      //                                 ],
                                      //                               ),
                                      //                            //   CheckboxList(),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Radio(
                                                    value: false,
                                                    groupValue:
                                                        signataireEtTitulaire,
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        signataireEtTitulaire =
                                                            value!;
                                                      });
                                                    }),
                                                Expanded(
                                                  child: Text(
                                                    "key_Titulaire_uniquement"
                                                        .tr,
                                                    style: theme
                                                        .textTheme.titleSmall!
                                                        .copyWith(
                                                            fontSize: 12.fSize),
                                                  ),
                                                )
                                              ],
                                            ),
                                            flex: 1,
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Radio(
                                                    value: true,
                                                    groupValue:
                                                        signataireEtTitulaire,
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        signataireEtTitulaire =
                                                            value!;
                                                      });
                                                    }),
                                                Expanded(
                                                    child: Text(
                                                  "key_Titulaire_Signataire".tr,
                                                  style: theme
                                                      .textTheme.titleSmall!
                                                      .copyWith(
                                                          fontSize: 12.fSize),
                                                ))
                                              ],
                                            ),
                                            flex: 1,
                                          )
                                        ],
                                      ),

                                      //                 Image.file(File(_imagePath==null?'assets/img/logoMillimes.png':_imagePath!)),

                                      //                 Visibility(
                                      //   visible: _imagePath != null,
                                      //   child: Padding(
                                      //     padding: const EdgeInsets.all(8.0),
                                      //     child: Image.file(
                                      //       File(_imagePath ?? ''),
                                      //     ),
                                      //   ),
                                      // ),

                                      // Text(items!.length.toString()),
                                      if (showDocs)
                                        Container(
                                            constraints: const BoxConstraints(
                                                maxWidth: 300, maxHeight: 150),
                                            child: _buildList(
                                                context, loginStore)),
                                      const SizedBox(
                                        height: 8,
                                      ),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.4, // 40% of screen width
                                              height: 50, // Fixed height instead of responsive
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                //primary: Colors.grey[300],
                                                //Color.fromARGB(255, 68, 175, 104)
                                                backgroundColor: context.appColors.greenmillime,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              onPressed: () {
                                                loginStore.docManquantsMand = [];
                                                loginStore.docManquantsTitu = [];
                                                loginStore.tituimages = [];
                                                loginStore.mandimages = [];
                                                loginStore.dmd =
                                                    new DemOuvNewCompteNewMand();
                                                Navigator.of(context).pop();
                                                //  MaterialPageRoute(builder: (_) => const Wallet1Page()),
                                                // (Route<dynamic> route) =>
                                                //     false
                                                //  );
                                              },
                                            
                                              //onPressed:()async {imagePath = (await EdgeDetection.detectEdge); } ,
                                            
                                              child: Text("key_precedent".tr),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),

                                          SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.4, // 40% of screen width
                                              height: 50, // Fixed height instead of responsive
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                //primary: Colors.grey[300],
                                                //Color.fromARGB(255, 68, 175, 104)
                                                backgroundColor: context.appColors.greenmillime,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              onPressed: (booldmdEnvoyee ||
                                                      _bDisableStepNext)
                                                  ? null
                                                  : () async {
                                                      final FormState? formState =
                                                          formKey.currentState;
                                            
                                                      bool? validForm =
                                                          formState?.validate();
                                            
                                                      if (validForm!) {
                                                        print('form is valid');
                                            
                                                        _bDisableStepNext = false;
                                                        DateTime dateNaiss = intl
                                                                .DateFormat(
                                                                    currentDateFormat,
                                                                    currentLg)
                                                            .parse(dateMask
                                                                .textController
                                                                .text);
                                                        final difference =
                                                            DateTime.now()
                                                                .difference(
                                                                    dateNaiss)
                                                                .inDays;
                                                        if (difference / 365 <
                                                            18) {
                                                          // ScaffoldMessenger.of(context).showSnackBar(
                                                          //   SnackBar(
                                                          //     behavior: SnackBarBehavior.floating,
                                                          //     backgroundColor: Colors.red[200],
                                                          //     content: Text(
                                                          //      "err_age_sup".tr,
                                                          //       // error.toString(),
                                                          //       style: TextStyle(color: Colors.black),
                                                          //     ),
                                                          //   ),
                                            
                                                          buildSuccessMessage(
                                                              context,
                                                              "key_erreur".tr,
                                                              "err_age_sup".tr,
                                                              "key_fermer".tr,
                                                              false);
                                                          // );
                                                          return;
                                                        }
                                                      } else {
                                                        return;
                                                      }
                                            
                                                      loginStore.dmd =
                                                          DemOuvNewCompteNewMand(
                                                              tituPpBoolVip: vip,
                                                              tituPpBoolFatca:
                                                                  fatca,
                                                              tituPpBoolExemptRS:
                                                                  rs,
                                                              tituPpBoolExemptTva:
                                                                  tva,
                                                              tituPpBoolPep: pep,
                                                              tituPpBoolHandicap:
                                                                  handicape,
                                                              tituPpMotifHandicap:
                                                                  motifController
                                                                      .text,
                                                              // demOuvCompteMandId: 1,
                                                              demOuvCompteMandBool:
                                                                  false,
                                                              demOuvCompteMandEmisDate:
                                                                  DateTime.now(),
                                                              //  demOuvCompteMandEmisDate       :intl.DateFormat('dd-MM-yyyy').format(DateTime.now()),
                                                              //  mandPpNaissanceDate            :intl.DateFormat('dd-MM-yyyy').format(DateTime.now()),
                                                              tituPpEmail:
                                                                  emailController
                                                                      .text
                                                                      .trim(),
                                                              tituPpNaissanceDate:
                                                                  intl.DateFormat(currentDateFormat, currentLg)
                                                                      .parse(dateMask
                                                                          .textController
                                                                          .text),
                                                              // DateTime.parse(
                                                              //     dateNaissance
                                                              //         .text),
                                                              tituPpNom:
                                                                  ppNomfr.text,
                                                              tituPpTelMobileNo:
                                                                  telController
                                                                      .text,
                                                              //loginStore.phoneNo,
                                                              tituPpPieceIdentiteCode:
                                                                  selectedValueTypePiece,
                                                              tituPpPieceIdentiteNo:
                                                                  numPiece.text,
                                                              tituPpPrenom:
                                                                  ppPrenomfr.text,
                                                              tituPpAdresse: ppAdresse.text,
                                            
                                                              // mandPpNaissanceDate: intl.DateFormat('dd-MM-yyyy', 'fr').parse(dateNaissance.text),
                                                              // mandPpNom: ppNomfr.text,
                                                              // mandPpPieceIdentiteCode: selectedValueTypePiece,
                                                              // mandPpPieceIdentiteNo: numPiece.text,
                                                              // mandPpPrenom: ppPrenomfr.text,
                                                              walletNoTelGestion: loginStore.phoneNo,
                                                              //walletTelGestion,
                                                              walletEmailGestion: loginStore.walletEmailGestion, //,
                                                              //  niveauCompte                   : NiveauCompte.fromJson({'niveauCompteId':1,
                                                              //                                        'niveauCompteCode':'N1',
                                                              //                                        'niveauCompteDsg':'Niveau1',
                                                              //                                        'niveauComptePlafondSolde':500,
                                                              //                                        'niveauComptePlafondSortie':500,
                                                              //                                        'niveauCompteInfoLibre' :'Infos'
                                                              //  })
                                                              params: jsonEncode({"howOldCINVis": loginStore.howOldCINVis}));
                                                      loginStore
                                                              .docManquantsTitu =
                                                          docManquants;
                                                      loginStore
                                                              .signataireEtTitulaire =
                                                          signataireEtTitulaire;
                                            
                                                      print(loginStore.dmd
                                                          .mandPpPieceIdentiteNo);
                                                      // if (docManquants.length != loginStore.tituimages.length ||
                                                      //     loginStore.tituimages.contains(null)) {
                                                      //   ///element
                                            
                                                      int i = loginStore
                                                          .tituimages
                                                          .indexOf(null);
                                                      bool booldocmanquant =
                                                              false,
                                                          booldocOptionnel =
                                                              false;
                                                      while (i > -1 &&
                                                          !booldocmanquant &&
                                                          i <
                                                              loginStore
                                                                  .tituimages
                                                                  .length) {
                                                        if (!loginStore
                                                                .signataireEtTitulaire &&
                                                            docss![i]!
                                                                    .docInCode !=
                                                                'SIGN') {
                                                          if (docss![i]!
                                                                  .docInBoolLignePpTituOnly ==
                                                              "O") {
                                                            booldocmanquant =
                                                                true;
                                                            break;
                                                          } else if (docss![i]!
                                                                  .docInBoolLignePpTituOnly ==
                                                              "P") {
                                                            booldocmanquant =
                                                                false;
                                                            booldocOptionnel =
                                                                true;
                                                            break;
                                                          }
                                                        } else if (docss![i]!
                                                                    .docInBoolLignePpTituSign ==
                                                                "O" &&
                                                            docss![i]!
                                                                    .docInCode !=
                                                                'SIGN') {
                                                          booldocmanquant = true;
                                                          break;
                                                        } else {
                                                          i = loginStore
                                                              .tituimages
                                                              .indexOf(
                                                                  null, i + 1);
                                                        }
                                                      }
                                            
                                                      ///end while
                                                      if (!booldocmanquant &&
                                                          !signataireEtTitulaire) {
                                                        if (booldocOptionnel) {
                                                          showAlertDialog(
                                                              context,
                                                              docss![i]!
                                                                  .docInDsg!);
                                                        } else {
                                                          // if (  loginStore.dmd.mandPpPieceIdentiteNo== loginStore.dmd.tituPpPieceIdentiteNo)
                                                          //       loginStore.dmd.mandPpPieceIdentiteNo=null;
                                            
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      Wallet111Page()));
                                                        }
                                                      } else if (signataireEtTitulaire &&
                                                          !booldocmanquant) {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    Wallet1111Page()));
                                                      } else if (booldocOptionnel &&
                                                          !booldocmanquant) {
                                                        showAlertDialog(context,
                                                            docss![i]!.docInDsg!);
                                                      } else {
                                                        //afficher il vous manque un doc
                                            
                                                        buildSuccessMessage(
                                                            context,
                                                            "key_erreur".tr,
                                                            "key_document_manquant"
                                                                .tr,
                                                            "key_fermer".tr,
                                                            false);
                                                      }
                                                      // } else if (booldocmanquant && signataireEtTitulaire) {
                                                      //   loginStore.signataireEtTitulaire = true;
                                                      //   Navigator.of(context).push(
                                                      //     MaterialPageRoute(builder: (_) => const Wallet1111Page()),
                                                      //      }
                                            
                                                      // else {
                                                      //   loginStore
                                                      //           .signataireEtTitulaire =
                                                      //       false;
                                                      //   Navigator.of(context)
                                                      //       .push(
                                                      //     MaterialPageRoute(
                                                      //         builder: (_) =>
                                                      //             const Wallet111Page()),
                                                      //   );
                                                      // }
                                                      // }
                                                    },
                                              child: Text("key_suivant".tr),
                                            ),
                                          )

                                          //  child: Text(signataireEtTitulaire ? 'Enregistrer' : '  Suivant  '))
                                          // child: Text('Enregistrer'))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    (_inProcess)
                        ? Container(
                            color: colors.white.withOpacity(0.95),
                            height: MediaQuery.of(context).size.height * 0.95,
                            child: Center(
                              // child: CircularProgressIndicator(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: context.appColors.greenmillime,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                      alignment: Alignment.center,
                                      width: 300,
                                      child:
                                          Text("key_traitement_en_cours".tr)),
                                ],
                              ),
                            ),
                          )
                        : Center()
                  ],
                ),
              ),
            ),
          ),
        );

        //);
      },
    );
  }

  // Improved image picker variables with better naming
  XFile? _pickedFile;
  CroppedFile? _croppedFile;
  bool _inProcess = false;
  static const String _logTag = 'Wallet11Page';

  /// Improved image picking and cropping method with comprehensive error handling
  Future<bool> getImage(int index, loginStore) async {
    // Input validation
    if (index < 0) {
      debugPrint('$_logTag: Invalid index provided: $index');
      _showErrorMessage('Invalid image index');
      return false;
    }

    if (loginStore?.tituimages == null) {
      debugPrint('$_logTag: Login store or tituimages is null');
      _showErrorMessage('Storage not available');
      return false;
    }

    // Check if widget is still mounted before starting
    if (!mounted) return false;

    // Set processing state safely
    _setProcessingState(true);

    try {
      // Step 1: Pick image from camera
      final ImagePickResult result = await _pickAndCropImage();

      // Check if widget is still mounted after async operation
      if (!mounted) return false;

      if (!result.success) {
        _showErrorMessage(result.errorMessage ?? 'Failed to process image');
        return false;
      }

      // Step 2: Store image path in login store
      final bool stored = _storeImagePath(
        imagePath: result.imagePath!,
        index: index,
        loginStore: loginStore,
      );

      if (stored) {
        debugPrint('$_logTag: Image successfully stored at index $index');
      } else {
        _showErrorMessage('Failed to save image');
      }

      return stored;

    } catch (e) {
      debugPrint('$_logTag: Unexpected error in getImage: $e');
      if (mounted) {
        _showErrorMessage('An unexpected error occurred');
      }
      return false;
    } finally {
      // Always reset processing state
      if (mounted) {
        _setProcessingState(false);
      }
    }
  }

  /// Crash-resistant image picking with timeout and retry mechanism
  Future<ImagePickResult> _pickAndCropImage() async {
    try {
      // Step 1: Pick image with timeout
      _pickedFile = await ImagePicker()
          .pickImage(source: ImageSource.camera)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Image picking timed out'),
          );
      
      if (_pickedFile == null) {
        return ImagePickResult.failure('No image selected');
      }

      // Step 2: Validate file exists and is readable
      final File imageFile = File(_pickedFile!.path);
      if (!await imageFile.exists()) {
        return ImagePickResult.failure('Selected image file not found');
      }

      // Step 3: Crop image with enhanced error handling
      _croppedFile = await _cropImageSafely(_pickedFile!.path);

      if (_croppedFile == null || _croppedFile!.path.isEmpty) {
        return ImagePickResult.failure('Image cropping cancelled or failed');
      }

      return ImagePickResult.success(_croppedFile!.path);
      
    } on TimeoutException catch (e) {
      debugPrint('$_logTag: Timeout during image picking: $e');
      return ImagePickResult.failure('Operation timed out. Please try again.');
      
    } on PlatformException catch (e) {
      debugPrint('$_logTag: Platform exception: ${e.message}');
      
      // Handle specific platform errors
      if (e.code == 'camera_access_denied') {
        return ImagePickResult.failure('Camera access denied. Please enable camera permissions.');
      } else if (e.code == 'photo_access_denied') {
        return ImagePickResult.failure('Photo access denied. Please enable photo permissions.');
      } else if (e.message?.contains('UCropActivity') == true) {
        return ImagePickResult.failure('Image cropper not properly configured. Please contact support.');
      }
      
      return ImagePickResult.failure('Camera or cropper error. Please try again.');
      
    } catch (e) {
      debugPrint('$_logTag: Unexpected error during image picking: $e');
      return ImagePickResult.failure('An unexpected error occurred. Please try again.');
    }
  }

  /// Safe image cropping with retry mechanism
  Future<CroppedFile?> _cropImageSafely(String imagePath) async {
    int retryCount = 0;
    const int maxRetries = 2;
    
    while (retryCount < maxRetries) {
      try {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: imagePath,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 85,
          maxWidth: 1024,
          maxHeight: 1024,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: "key_cropper".tr,
              toolbarColor: context.appColors.greenmillime,
              activeControlsWidgetColor: context.appColors.greenmillime,
              toolbarWidgetColor: context.appColors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              hideBottomControls: false,
              showCropGrid: true,
              // Add these to prevent crashes
              statusBarColor: context.appColors.greenmillime,
              backgroundColor: Colors.black,
            ),
            IOSUiSettings(
              title: "key_cropper".tr,
              doneButtonTitle: 'Done',
              cancelButtonTitle: 'Cancel',
              // Add these for better iOS handling
              minimumAspectRatio: 0.5,
              aspectRatioLockDimensionSwapEnabled: false,
              aspectRatioLockEnabled: false,
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );
        
        return croppedFile;
        
      } catch (e) {
        retryCount++;
        debugPrint('$_logTag: Crop attempt $retryCount failed: $e');
        
        if (retryCount >= maxRetries) {
          debugPrint('$_logTag: Max retries reached for image cropping');
          return null;
        }
        
        // Wait before retry
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
      }
    }
    
    return null;
  }

  /// Optimized method to store image path in the correct index
  bool _storeImagePath({
    required String imagePath,
    required int index,
    required dynamic loginStore,
  }) {
    try {
      final List<String?> images = loginStore.tituimages! as List<String?>;
      
      // Expand array if necessary using a more efficient approach
      if (index >= images.length) {
        final int elementsToAdd = index - images.length + 1;
        images.addAll(List.filled(elementsToAdd, ''));
      }
      
      // Store the image path
      images[index] = imagePath;
      
      debugPrint('$_logTag: Image stored at index $index: $imagePath');
      return true;
      
    } catch (e) {
      debugPrint('$_logTag: Error storing image path: $e');
      return false;
    }
  }

  /// Helper method to safely update processing state
  void _setProcessingState(bool processing) {
    if (mounted) {
      setState(() {
        _inProcess = processing;
      });
    }
  }

  /// Helper method to show error messages to user
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Alternative method for picking from gallery (bonus feature)
  Future<bool> getImageFromGallery(int index, dynamic loginStore) async {
    if (!mounted) return false;
    
    _setProcessingState(true);
    
    try {
      _pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      
      if (_pickedFile == null) {
        _showErrorMessage('No image selected from gallery');
        return false;
      }

      final ImagePickResult result = await _cropSelectedImage(_pickedFile!.path);

      if (!mounted) return false;

      if (!result.success) {
        _showErrorMessage(result.errorMessage ?? 'Failed to process gallery image');
        return false;
      }

      final bool stored = _storeImagePath(
        imagePath: result.imagePath!,
        index: index,
        loginStore: loginStore,
      );

      if (stored) {
        debugPrint('$_logTag: Gallery image saved successfully');
      }

      return stored;
    } catch (e) {
      debugPrint('$_logTag: Error in getImageFromGallery: $e');
      if (mounted) {
        _showErrorMessage('Failed to process gallery image');
      }
      return false;
    } finally {
      if (mounted) {
        _setProcessingState(false);
      }
    }
  }

  /// Helper method to crop an already selected image
  Future<ImagePickResult> _cropSelectedImage(String imagePath) async {
    try {
      _croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "key_cropper".tr,
            toolbarColor: context.appColors.greenmillime,
            activeControlsWidgetColor: context.appColors.greenmillime,
            toolbarWidgetColor: context.appColors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            showCropGrid: true,
          ),
          IOSUiSettings(
            title: "key_cropper".tr,
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );

      if (_croppedFile == null || _croppedFile!.path.isEmpty) {
        return ImagePickResult.failure('Image cropping cancelled or failed');
      }

      return ImagePickResult.success(_croppedFile!.path);
    } catch (e) {
      debugPrint('$_logTag: Error during image cropping: $e');
      return ImagePickResult.failure('Image cropping failed');
    }
  }

  loadDocsOfPp(loginStore) async {
    for (var i = 0; i < docManquants.length; i++) {
      if (bNeedTogetallDocs) {
        setState(() {
          disableCINR = false;
          disableCINV = true;
          disableSELFIE = true;
        });

        break;
      }

      await loginStore
          .fetchDocInYByNoPieceIdentite(numPiece.text,
              selectedValueTypePiece.toString(), 'P', docManquants[i])
          .then((doc) async {
        print(doc?.docinx?.docInCode);
        if (doc != null) {
          String dir = (await getApplicationDocumentsDirectory()).path;
          File file =
              File(dir + '/' + (doc?.docinx?.docInCode).toString() + '.png');
          Uint8List bytes = base64.decode((doc?.docInYImageScan).toString());
          File f = await file.writeAsBytes(bytes, flush: true);

          loginStore.tituimages[i] =
              dir + '/' + (doc?.docinx?.docInCode).toString() + '.png';
          if (['CINR', 'CINV', 'SELFIE'].contains(doc?.docinx?.docInCode)) {
            switch (
                ['CINR', 'CINV', 'SELFIE'].indexOf(doc?.docinx?.docInCode)) {
              case 0:
                disableCINR = false;
                break;
              case 1:
                disableCINV = false;
                break;
              case 2:
                disableSELFIE = false;
                //loginStore.selfiecountdown=doc?.docinx?.docInParam;
                break;
            }
          }
        } else {
          //doc==null

          switch (['CINR', 'CINV', 'SELFIE'].indexOf(docManquants[i])) {
            case 0:
              disableCINR = false;
              bNeedTogetallDocs = true;
              break;
            case 1:
              disableCINV = false;
              break;
            case 2:
              setState(() {
                disableSELFIE = false;
                // loginStore.selfiecountdown=doc?.docinx?.docInParam;
              });
              break;
          }
        }
        setState(() {});
      });
    }
  }

  Map<String, bool> enableDocButton = {};

  loadDocsOfPp2(loginStore) async {
    for (var i = 0; i < docManquants.length; i++) {
      if (bNeedTogetallDocs) {
        setState(() {
          disableCINR = false;
          disableCINV = false;
          disableSELFIE = false;
          disablePreuveDeVie = false;
        });

        break;
      }

      await loginStore
          .fetchDocInYByNoPieceIdentite(numPiece.text,
              selectedValueTypePiece.toString(), 'P', docManquants[i])
          .then((doc) async {
        print(doc?.docinx?.docInCode);
        if (doc != null) {
          enableDocButton[docManquants[i]] = false;
          String dir = (await getApplicationDocumentsDirectory()).path;
          File file =
              File(dir + '/' + (doc?.docinx?.docInCode).toString() + '.png');
          Uint8List bytes = base64.decode((doc?.docInYImageScan).toString());
          File f = await file.writeAsBytes(bytes, flush: true);

          loginStore.tituimages[i] =
              dir + '/' + (doc?.docinx?.docInCode).toString() + '.png';
          if (['CINR', 'CINV', 'PASSPORT', 'SELFIE', 'PREUVEIE']
              .contains(doc?.docinx?.docInCode)) {
            switch (['CINR', 'CINV', 'PASSPORT', 'SELFIE', 'PREUVEIE']
                .indexOf(doc?.docinx?.docInCode)) {
              case 0:
                disableCINR = false;
                break;
              case 1:
                disableCINV = false;
                break;
              case 2:
                disablePASS = false;
                break;

              case 3:
                setState(() {
                  disableSELFIE = false;
                  enableDocButton[docManquants[i]] = true;
                  loginStore.tituimages[i] = null;
                });
                break;
              case 4:
                setState(() {
                  disablePreuveDeVie = false;
                  enableDocButton[docManquants[i]] = true;
                  loginStore.tituimages[i] = null;
                });
                break;
            }
          }
        } else {
          //doc==null
          enableDocButton[docManquants[i]] = true;
          switch (['CINR', 'CINV', 'PASSPORT', 'SELFIE', 'PREUVEIE']
              .indexOf(docManquants[i])) {
            case 0:
              disableCINR = false;
              //    bNeedTogetallDocs = true;
              break;
            case 1:
              disableCINV = false;
              break;
            case 2:
              disablePASS = false;
              break;
            case 3:
              setState(() {
                disableSELFIE = false;
                enableDocButton[docManquants[i]] = true;
              });
              break;
            case 4:
              setState(() {
                disablePreuveDeVie = false;
                enableDocButton[docManquants[i]] = true;
              });
              break;
          }
        }
        setState(() {});
      });
    }
  }

  erasefiledsTitu() {
    handicape = false;
    motifController.text = "";
    ppNomfr.text = "";
    ppPrenomfr.text = "";
    ppAdresse.text = "";
    dateNaissance.text = "";
  }

  showAlertDialog(BuildContext context, String dsg) {
    // set up the buttons

    // // set up the AlertDialog
    // AlertDialog alert = AlertDialog(
    //   title: Text("Information"),
    //   content: Text("Continuer sans le selfie du titulaire ?"),
    //   actions: [
    //     cancelButton,
    //     continueButton,
    //   ],
    // );

    // // show the dialog
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return alert;
    //   },
    // );

    Alert(
      context: context,
      type: AlertType.warning,
      desc: "key_continuer_sans".tr + ' ' + dsg + "?",
      buttons: [
        DialogButton(
          child: Text(
            "key_refaire_doc".tr + ' ' + dsg,
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          color: Color.fromARGB(255, 225, 50, 2),
        ),
        DialogButton(
          child: Text(
            "key_continuer_sans".tr + ' ' + dsg,
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => Wallet111Page()));
          }
          // Navigator.of(context).pop(),
          //  Navigator.of(context).push(MaterialPageRoute(builder: (_) => Wallet111Page()))
          ,
          gradient: LinearGradient(
              colors: [context.appColors.greenmillime, Color.fromRGBO(52, 138, 199, 1.0)]),
        )
      ],
    ).show();
  }
}

// class ListViewHomeLayout extends StatefulWidget {
// @override
//       ListViewHome createState() {
//         return new ListViewHome();
//       }
// }
// class ListViewHome extends State<ListViewHomeLayout> {
//   List<String> docManquants = ["List 1", "List 2", "List 3"];
//   final docManquants = [
//     "Here is list 1 subtitle",
//     "Here is list 2 subtitle",
//     "Here is list 3 subtitle"
//   ];
//   final icons = [Icons.ac_unit, Icons.access_alarm, Icons.access_time];
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//         itemCount: docManquants.length,
//         itemBuilder: (context, index) {
//           return Card(
//               child: ListTile(
//                   onTap: () {
//                   setState(() {
//                     docManquants.add('List' + (docManquants.length+1).toString());
//                     subtitles.add('Here is list' + (docManquants.length+1).toString() + ' subtitle');
//                     icons.add(Icons.zoom_out_sharp);
//                   });
//                     Scaffold.of(context).showSnackBar(SnackBar(
//                       content: Text(docManquants[index] + ' pressed!'),
//                     ));
//                   },
//                   title: Text(docManquants[index]),
//                   subtitle: Text(subtitles[index]),
//                   leading: CircleAvatar(
//                       backgroundImage: NetworkImage(
//                           "https://images.unsplash.com/photo-1547721064-da6cfb341d50")),
//                   trailing: Icon(icons[index])));
//         });
//   }
// }

class CustomCard extends StatelessWidget {
  String titre;
  String? imagePath;

  CustomCard(String this.titre, String this.imagePath);
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //   ElevatedButton(
            //onPressed: () {print (imagePath!);},
            //      child:
            // Container(
            //   height: 120,
            //   //child: Image.asset(imagePath! ),
            //   //child: Image.file(File(imagePath! )),
            //   child: Text(imagePath!),
            // ),

            //    ),
            Container(
              height: 30,
              child: Padding(
                padding: new EdgeInsets.all(7.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //  new Padding(
                    //   //  padding: new EdgeInsets.all(7.0),
                    //   //  child: new Icon(Icons.thumb_up),
                    //  ),
                    new Text(
                      titre,
                      style: new TextStyle(fontSize: 16.0),
                    ),
                    //  new Padding(
                    //    padding: new EdgeInsets.all(7.0),
                    //    child: new Icon(Icons.comment),
                    //  ),
                    //  new Padding(
                    //    padding: new EdgeInsets.all(7.0),
                    //    child: new Text('Comments',style: new TextStyle(fontSize: 18.0)),
                    //  )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
// class Document{
//   String imagePath;
//   String titre;
// }

class CheckboxList extends StatefulWidget {
  @override
  _CheckboxListState createState() => _CheckboxListState();
}

class _CheckboxListState extends State<CheckboxList> {
  List<bool> _checkboxValues =
      List.generate(1, (index) => false); // Example list of checkbox values

  @override
  Widget build(BuildContext context) {
    // return ListView.builder(
    //   itemCount: _checkboxValues.length,
    //   itemBuilder: (context, index) {

    return CheckboxListItem(
      title: 'Title ',
      value: _checkboxValues[0],
      onChanged: (bool? newValue) {
        setState(() {
          _checkboxValues[0] = newValue ?? false;
        });
      },
    );

    //   },
    // );
  }
}

class CheckboxListItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  CheckboxListItem({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

