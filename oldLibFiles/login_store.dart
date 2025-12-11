// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:convert';

//import 'dart:html';
//import 'dart:html';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:millime/Enrolement/authent.dart';
//import 'package:millime/Enrolement/home2_typeP_niv_page.dart';
import 'package:millime/Enrolement/initialinf_acctypepp_screen/initialinf_acctypepp_screen.dart';
import 'package:millime/build_info.dart';
import 'package:millime/common/functions.dart';
import 'package:millime/conf/constants.dart';
import 'package:millime/core/utils/date_time_utils.dart';
import 'package:millime/localizationMillime/localization/app_localization.dart';
import 'package:millime/models/favFactCritAgregateur.dart';
import 'package:millime/models/insFin.dart';
import 'package:millime/models/agence.dart';

import 'package:millime/models/reclam.dart';
import 'package:millime/models/virem.dart';
import 'package:millime/models/viremPerm.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:millime/localization/app_translations.dart';
import 'package:millime/models/NiveauCompte.dart';
import 'package:millime/models/demOuvNewCompteNewMand.dart';
import 'package:millime/models/demandeouvcomptetmp.dart';
import 'package:millime/models/demchangeInfosperso.dart';
import 'package:millime/models/devise.dart';
import 'package:millime/models/docIn.dart';
import 'package:millime/models/docInY.dart';
import 'package:millime/models/notif.dart';
import 'package:millime/models/pesonnep.dart';
import 'package:millime/models/serviceProvider.dart';
import 'package:millime/models/transaction.dart';
import 'package:millime/models/transaction_resume.dart';
import 'package:millime/models/wallet.dart';

import 'package:millime/pages/home_page.dart';
// import 'package:millime/pages/home_page.dart';
import 'package:millime/pages/login_page_3.dart';
import 'package:millime/pages/otp_page.dart';
import 'package:http/http.dart' as http;
import 'package:millime/pages/repository/authRepository.dart';
import 'package:millime/pages/resetpassword.dart';

import 'package:http_parser/http_parser.dart';

import '../conf/millimes_constantes.dart';
import '../models/demNewAdress.dart';

// import 'package:millime/pages/otp_page.dart';

part 'login_store.g.dart';

class LoginStore = LoginStoreBase with _$LoginStore;

abstract class LoginStoreBase with Store {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  @observable
  bool updateProfile = false;

  dynamic httpwrapper;

  dynamic authHttpClient;
  dynamic compteEx;

  String? authUsedMethod;

  @observable
  bool bCGUCheckBox = false;

  @observable
  String? currentTypeOperation;

  @observable
  bool bPCCheckBox = false;


  @observable
  bool bDefaultWalletchecked = false;
  

  @observable
  bool alignRight = false;

  @observable
  List<bool> bTabApprouvedDocsCheckBox = [];

  @observable
  int selfiecountdown = 5;

  @observable
  bool isRealDevice = false;
  // late String actualCode;

  @observable
  String userTel = "";
  int? howOldCINVis;

 @observable
  Uint8List? bytesSelfieUtilisateur;


  String? otp;
   String? imei;

  @observable
  String currentPassword = "";

  @observable
  String currentPin = "";

  @observable
  Rect? rect;

  @observable
  Rect? absoluterect;

  @observable
  String? barcode;

  @observable
  bool isLoginLoading = false;

  @observable
  bool showCameraScreen = false;

  bool refreshCompte=true;

  @observable
  bool isOtpLoading = false;

  @observable
  late int oneTimePass = 123;

  @observable
  bool isreset = false;

  @observable
  bool bMotPasseOublie = false;

  @observable
  bool bParsms = false;

  @observable
  bool bParmail = false;

  Wallet? walletMotPasseOublie;

  @observable
  PersonneP? pp;

  @observable
  List<String?> tituimages = [];

  @observable
  List<String?> mandimages = [];

  @observable
  List<String>? docManquantsTitu = [];

  @observable
  List<String>? docManquantsMand = [];

  @observable
  DemandeOuvCompteTmp? demande = DemandeOuvCompteTmp();

  String walletEmailGestion = '';
  String walletTelGestion = '';
  String phoneNo = '';
  String typePersonne = 'P';

  @observable
  String cinr = '';
  @observable
  String cinrmand = '';

  @observable
  DemOuvNewCompteNewMand dmd = DemOuvNewCompteNewMand();

  @observable
  DemNewAdr demNewAdr = DemNewAdr();

  @observable
  DemChangeInfosPerso dmdChgeInfosPerso = DemChangeInfosPerso();

  @observable
  GlobalKey<ScaffoldState> loginScaffoldKey = GlobalKey<ScaffoldState>();

  @observable
  GlobalKey<ScaffoldState> loginScaffoldKey1 = GlobalKey<ScaffoldState>();

  @observable
  GlobalKey<ScaffoldState> otpScaffoldKey = GlobalKey<ScaffoldState>();

  @observable
  GlobalKey<ScaffoldState> home2ScaffoldKey = GlobalKey<ScaffoldState>();

  @observable
  GlobalKey<ScaffoldState> confirmPassScaffoldKey = GlobalKey<ScaffoldState>();

  @observable
  GlobalKey<ScaffoldState> resetPassScaffoldKey = GlobalKey<ScaffoldState>();

  @observable
  GlobalKey<ScaffoldState> decouvrirScaffoldKey = GlobalKey<ScaffoldState>();

  @observable
  GlobalKey<ScaffoldState> decouvrir2ScaffoldKey = GlobalKey<ScaffoldState>();

  @observable
  GlobalKey<ScaffoldState> decouvrir3ScaffoldKey = GlobalKey<ScaffoldState>();

  @observable
  final GlobalKey<ScaffoldState> wallet1ScaffoldKey =
      GlobalKey<ScaffoldState>();

  @observable
  final GlobalKey<ScaffoldState> wallet11ScaffoldKey =
      GlobalKey<ScaffoldState>();

  @observable
  final GlobalKey<ScaffoldState> wallet12ScaffoldKey =
      GlobalKey<ScaffoldState>();

  @observable
  GlobalKey<ScaffoldState> wallet111ScaffoldKey = GlobalKey<ScaffoldState>();
  @observable
  GlobalKey<ScaffoldState> wallet1111ScaffoldKey = GlobalKey<ScaffoldState>();
  // @observable
  // FirebaseUser firebaseUser;

  @observable
  bool signataireEtTitulaire = false;

  int deviseNbrDec = 3;
  String? deviseCodeAlpha = 'TND';

  @observable
  Random rnd = Random();




  AppTranslations? translationsInstance;

  @action
  Future<bool> isAlreadyAuthenticated() async {
    // sleep(Duration(seconds: 5));
    return false;
  }


  
  // @observable
  // String backendServer = '192.168.1.13';  

 // @observable
  //String backendServer = '192.168.43.198';


  // String backendServer ='172.16.60.104';
  //String backendServer = '127.0.0.1';
  // @observable
  // String backendServer = '192.168.122.1';

  //String backendServer = '100.92.154.143';

  
  

  String? label;

  String CLIENT_ID = 'flutter-client';
  //String SSO_URL="http://"+backendServer+":8180/auth/realms/millime";
  //http://192.168.1.12:8180/auth/realms/millime

  getSSOURL() {
    return "http://${backendServer}:8080/realms/millime";
  }

  //var backendServer = '172.16.130.39';

  @action
  Future<void> sendOtp(String tel) async {
    int otpMax;
    int otpMin;
    otpMin = 100000;
    otpMax = 1000000;
    Notif notif = Notif();

    notif.methode = "SMS";
    oneTimePass = otpMin + Random().nextInt(otpMax - otpMin);
    notif.destinataire = tel;
    notif.message = oneTimePass.toString();




    ///use back end Api to notify the client
    print(oneTimePass);
  }

    @action
  Future<void> sendOtpOnSelectedCanals(String tel) async {
    int otpMax;
    int otpMin;
    otpMin = 100000;
    otpMax = 1000000;
    Notif notif = Notif();

    notif.methode = "SMS";
    oneTimePass = otpMin + Random().nextInt(otpMax - otpMin);
    notif.destinataire = tel;
    notif.message = oneTimePass.toString();

    ///use back end Api to notify the client
    print(oneTimePass);
  }


  Future<DemandeOuvCompteTmp?> updateDemandeTmp(DemandeOuvCompteTmp dmd) async {
//String dateSlug ="${today.year.toString()}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}";

// print ('http://${backendServer}:8081/demandeOuvCompteTmp/'+(demande?.demandeOuvCompteTmpId).toString());
// print( dmd.motDepasse.toString());
    String _telMobileRecup = '';
    if ((demande!.telMobileRecup) != null)
      _telMobileRecup = demande!.telMobileRecup!;

    final response = await http.put(
      Uri.parse('http://${backendServer}:8081/demandeOuvCompteTmp/' +
          (demande?.demandeOuvCompteTmpId).toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'motDepasse': dmd.motDepasse.toString(),
        'demandeOuvCompteTmpEmisDate':
            '2022-01-01', //dmd.demandeOuvCompteTmpEmisDate.toString(),
        'demandeOuvCompteTmpStatutDate':
            '2022-01-01', //dmd.demandeOuvCompteTmpStatutDate.toString(),
        'demandeOuvCompteTmpInitiateur':
            dmd.demandeOuvCompteTmpInitiateur.toString(),
        'statutdemandeOuvCompteTmp': dmd.statutdemandeOuvCompteTmp.toString(),
        'telMobile': dmd.telMobile.toString(),
        'telMobileRecup': _telMobileRecup,
        // 'mailRecup': dmd.mailRecup.toString(),

        'telMobileRecup': demande!.telMobileRecup!,
        // 'mailRecup': demande!.mailRecup!

        // 'demandeOuvCompteTmpId':null
      }),
    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      return DemandeOuvCompteTmp.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }




  @action
  Future<bool?> checkLogoAndFlag(String imagePath) async {
    bool found = false;
    var url = Uri.parse("http://${backendServer}:5000/");

    var request = http.MultipartRequest('POST', url);

    
    request.files.add(await http.MultipartFile.fromPath(
        'sampleImage', imagePath,
        contentType: MediaType('image', 'jpeg')));

    request.headers
        .addEntries(<String, String>{'enctype': 'multipart/form-data'}.entries);

    try {
      var sendRequest = await request.send();

      var response = await http.Response.fromStream(sendRequest);
      final responseData = json.decode(response.body);

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        var scannedObj = jsonDecode(response.body);
        if (scannedObj.length == 2) {
          found = true;
        }
      } else if (response.statusCode >= 400) {
        return Future.error('error on scannig flag and logo');
      }
      return found;
    } catch (e) {
      return Future.error('error on scannig flag and logo');
    }
  }

  uploadChgAdrFiles(images, titres) async {
    var url = Uri.parse("http://${backendServer}:8081/demNewAdrTitu/upload");
    var request = http.MultipartRequest("POST", url);

    for (var i = 0; i < titres.length; i++) {
      print(titres[i]);
      // request.fields['user'] = 'someone@somewhere.com';
      request.files.add(http.MultipartFile.fromBytes(
          'files', await File.fromUri(Uri.parse(images[i])).readAsBytes(),
          contentType: MediaType('image', 'jpeg'), filename: titres[i]));
    }
    await request.send().then((response) {
      if (response.statusCode == 200) print("Uploaded!");
    });
  }

  uploadFiles(images, titres) async {
  var url = Uri.parse("http://${backendServer}:8081/demOuvCompte/upload");
  var request = http.MultipartRequest("POST", url);

  for (var i = 0; i < titres.length; i++) {
    final fileBytes = await File.fromUri(Uri.parse(images[i])).readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'files', // 👈 must match Spring Boot's @RequestParam("files")
      fileBytes,
      filename: titres[i],
      contentType: MediaType('image', 'jpeg'), // or detect dynamically
    ));
  }


  var response = await request.send();
  if (response.statusCode == 200) {
    print("Uploaded!");
  } else {
    print("Upload failed with status ${response.statusCode}");
  }
}


  uploadFilesAndMandfiles(
      tituimages, titutitres, mandimages, mandtitres) async {
    var url = Uri.parse("http://${backendServer}:8081/demOuvCompte/upload");
    var request = http.MultipartRequest("POST", url);

    if (titutitres.length == tituimages.length)
      for (var i = 0; i < titutitres.length; i++) {
        print(titutitres[i]);
        // request.fields['user'] = 'someone@somewhere.com';
        request.files.add(http.MultipartFile.fromBytes(
            'files', await File.fromUri(Uri.parse(tituimages[i])).readAsBytes(),
            contentType: MediaType('image', 'jpeg'), filename: titutitres[i]));
      }

    if (mandimages.length == mandtitres.length)
      for (var i = 0; i < mandtitres.length; i++) {
        print(mandtitres[i]);
        // request.fields['user'] = 'someone@somewhere.com';
        request.files.add(http.MultipartFile.fromBytes('filesMandataire',
            await File.fromUri(Uri.parse(mandimages[i])).readAsBytes(),
            contentType: MediaType('image', 'jpeg'), filename: mandtitres[i]));
      }

    await request.send().then((response) {
      if (response.statusCode == 200) print("Titu and mand files Uploaded!");
    });
  }

  uploadMandfiles2NewMand(
      tituimages, titutitres, mandimages, mandtitres) async {
    var url = Uri.parse("http://${backendServer}:8081/demNewMand/upload");
    var request = http.MultipartRequest("POST", url);

    if (titutitres.length == tituimages.length)
      for (var i = 0; i < titutitres.length; i++) {
        print(titutitres[i]);
        // request.fields['user'] = 'someone@somewhere.com';
        request.files.add(http.MultipartFile.fromBytes(
            'files', await File.fromUri(Uri.parse(tituimages[i])).readAsBytes(),
            contentType: MediaType('image', 'jpeg'), filename: titutitres[i]));
      }

    if (mandimages.length == mandtitres.length)
      for (var i = 0; i < mandtitres.length; i++) {
        print(mandtitres[i]);
        // request.fields['user'] = 'someone@somewhere.com';
        request.files.add(http.MultipartFile.fromBytes('filesMandataire',
            await File.fromUri(Uri.parse(mandimages[i])).readAsBytes(),
            contentType: MediaType('image', 'jpeg'), filename: mandtitres[i]));
      }

    await request.send().then((response) {
      if (response.statusCode == 200) print("Titu and mand files Uploaded!");
    });
  }



  @action
  Future<dynamic?> updateDemNewMand(
      statutDemandeOuvCompteId,
      uniteGestionId,
      compteId,
      typePersonne,
      idFkTitu,
      ppIdFkOldMand,
      demOuvCompteMandId,
      dmd) async {
    final response = await http.put(
        Uri.parse('http://${backendServer}:8081/demNewMand/' +
            statutDemandeOuvCompteId +
            '/' +
            uniteGestionId +
            '/' +
            compteId +
            '/' +
            typePersonne +
            '/' +
            idFkTitu +
            '/' +
            ppIdFkOldMand +
            '/demNewMand/' +
            demOuvCompteMandId.toString()),
        //+ demOuvCompteMandId),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: dmd);

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      //return DemOuvNewCompteNewMand.fromJson(jsonDecode(response.body));
      return response.body;
    } else
      return response;
  }

  @action
  Future<DemOuvNewCompteNewMand?> updateDemOuvNewCompteNewMand(
      modeOuvCompteId,
      niveauCompteId,
      statutDemandeOuvCompteId,
      uniteGestionId,
      demOuvCompteMandId,
      dmd) async {
    final response = await http.put(
        Uri.parse('http://${backendServer}:8081/demOuvCompte/' +
            modeOuvCompteId +
            '/' +
            niveauCompteId +
            '/P/' +
            statutDemandeOuvCompteId +
            '/' +
            uniteGestionId +
            '/demOuvCompte/' +
            demOuvCompteMandId.toString()),
        //+ demOuvCompteMandId),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: dmd);

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      return DemOuvNewCompteNewMand.fromJson(jsonDecode(response.body));
    }
  }

  @action
  Future<DemOuvNewCompteNewMand?> createDemOuvNewCompteNewMand(
      DemOuvNewCompteNewMand dmd, images, titres) async {
    final respBlackListed = await isBlackListed(
            dmd.mandPpPieceIdentiteNo.toString(),
            dmd.mandPpPieceIdentiteCode.toString(),
            dmd.tituPmPieceIdentiteNo == null ? 'P' : 'M')
        .then((bres) {
      //return Future.value(bres.toString());
      print("La personne n'est pas listée");
    }).onError((error, stackTrace) {
      return Future.error(error.toString());
    });

    await uploadFiles(images, titres);
    final response = await http.post(
        Uri.parse('http://${backendServer}:8081/demOuvCompte/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'demOuvCompteMandBool': dmd.demOuvCompteMandBool.toString(),
          'demOuvCompteMandEmisDate':
              dmd.demOuvCompteMandEmisDate?.toIso8601String(),
          'mandPpNaissanceDate': dmd.mandPpNaissanceDate?.toIso8601String(),
          'mandPpNom': dmd.mandPpNom.toString(),
          'mandPpPieceIdentiteCode': dmd.mandPpPieceIdentiteCode.toString(),
          'mandPpPieceIdentiteNo': dmd.mandPpPieceIdentiteNo.toString(),
          'mandPpPrenom': dmd.mandPpPrenom.toString(),
          'tituPpPieceIdentiteCode': dmd.mandPpPieceIdentiteCode.toString(),
          'tituPpPieceIdentiteNo': dmd.mandPpPieceIdentiteNo.toString(),
          'tituPpEmail': dmd.tituPpEmail.toString(),
          'tituPpPrenom': dmd.tituPpPrenom.toString(),
          'tituPpNom': dmd.tituPpNom.toString(),
          'tituPpAdresse': dmd.tituPpAdresse.toString(),

          'mandPpAdresse': dmd.mandPpAdresse.toString(),

          'tituPpNaissanceDate': dmd.tituPpNaissanceDate?.toIso8601String(),
          'tituPpTelMobileNo': dmd.tituPpTelMobileNo.toString(),
          //  'telMobileRecup'                   : walletTelGestion,
          'mandPpTelMobileNo': dmd.mandPpTelMobileNo.toString(),
          'mandPpEmail': dmd.mandPpEmail.toString(),
          'walletNoTelGestion': dmd.walletNoTelGestion.toString(),
          'walletEmailGestion': dmd.walletEmailGestion.toString(),
          'tituPpBoolHandicap': dmd.tituPpBoolHandicap.toString(),
          'tituPpMotifHandicap': dmd.tituPpMotifHandicap.toString(),

          'tituPpBoolFatca': dmd.tituPpBoolFatca.toString(),
          'tituPpBoolVip': dmd.tituPpBoolVip.toString(),

          'tituPpBoolExemptRs': dmd.tituPpBoolExemptRS.toString(),
          'tituPpBoolExemptTva': dmd.tituPpBoolExemptTva.toString(),
          'tituPpBoolPep': dmd.tituPpBoolPep.toString(),

       


          'demNewCompteGesSecours':
              dmd.demNewCompteNewMandGesSecours.toString(),
          'demNewCompteEmailSecours':
              dmd.demNewCompteNewMandEmailSecours.toString(),
          'demNewCompteLang': 
              (AppLocalization.of().locale.languageCode).toString(),
          'params':dmd.params
        }));

    if (response.statusCode <= 206 && response.contentLength! > 0) {


      final response2 = await updateDemOuvNewCompteNewMand(
          '3',
          demande?.niveauCompte == 'Niveau1' ? '1' : '2',
          '1',
          '1',
          jsonDecode(response.body)['demOuvCompteMandId'],
          response.body);

      return response2;
    } else {
      return null;
    }
  }
//////////////////////////////////

  @action
  Future<dynamic?> createDemNewMand(DemOuvNewCompteNewMand dmd, images, titres,
      imagesmand, titresmand) async {
    await isBlackListed(dmd.mandPpPieceIdentiteNo.toString(),
            dmd.mandPpPieceIdentiteCode.toString(), 'P')
        .then((bres) {
      //return Future.value(bres.toString());
      print("La personne mand n'est pas listée");
    }).onError((error, stackTrace) {
      return Future.error(error.toString());
    });

    await uploadMandfiles2NewMand(
        tituimages, docManquantsTitu, imagesmand, titresmand);

    final response = await http.post(
        Uri.parse('http://${backendServer}:8081/demNewMand/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'demNewMandEmisDate': dmd.demOuvCompteMandEmisDate?.toIso8601String(),
          'newMandPpNaissanceDate': dmd.mandPpNaissanceDate?.toIso8601String(),
          'newMandPpNom': dmd.mandPpNom.toString(),
          'newMandPpPieceIdentiteCode': dmd.mandPpPieceIdentiteCode.toString(),
          'newMandPpPieceIdentiteNo': dmd.mandPpPieceIdentiteNo.toString(),
          'newMandPpPrenom': dmd.mandPpPrenom.toString(),
          'newMandPpTelMobileNo': dmd.mandPpTelMobileNo.toString(),
          'newMandPpEmail': dmd.mandPpEmail.toString(),
          'newMandPpAdresse': dmd.mandPpAdresse.toString(),
          'walletNoTelGestion': dmd.walletNoTelGestion.toString(),
          'walletEmailGestion': dmd.walletEmailGestion.toString(),
          'demNewCompteNewMandGesSecours':
              dmd.demNewCompteNewMandGesSecours.toString(),
          'demNewCompteNewMandEmailSecours':
              dmd.demNewCompteNewMandEmailSecours.toString()
        }));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      // DemNewAdr dem1=DemNewAdr.fromJson(jsonDecode(response.body));
      // String typePers=dmd.personnepTituId!=null ?"P":"M";
      int statutDemandeId = cteStatutDmdEnCoursId;
      int uniteGestionId = cteUniteGestionId;

      dynamic compteId = '2';
      dynamic typePersonne = 'P';
      dynamic idFkTitu = '1';
      dynamic ppIdFkOldMand = '1';

      if (compteEx['personnePTitu'] != null) {
        idFkTitu = compteEx['personnePTitu']['ppId'];
        typePersonne = 'P';
      } else {
        idFkTitu = compteEx['personneMTitu']['ppId'];
        ppIdFkOldMand = compteEx['personnePMand']['ppId'];
        typePersonne = 'M';
      }
      compteId = compteEx['compteId'];

      final response2 = await updateDemNewMand(
          statutDemandeId.toString(),
          uniteGestionId.toString(),
          compteId.toString(),
          typePersonne.toString(),
          idFkTitu.toString(),
          ppIdFkOldMand.toString(),
          jsonDecode(response.body)['demNewMandId'],
          response.body);

      if (!(response2 is String) && (response2.statusCode != null))
        throw Exception("Une demande existe déja pour ce compte ");

      return response2;
      // return DemOuvNewCompteNewMand.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

////////////////////////////////////////////////

  @action
  Future<DemOuvNewCompteNewMand?> createDemOuvNewCompteNewMandSenario2(
      DemOuvNewCompteNewMand dmd,
      images,
      titres,
      imagesmand,
      titresmand) async {
    await isBlackListed(
            dmd.tituPpPieceIdentiteNo.toString(),
            dmd.tituPpPieceIdentiteCode.toString(),
            dmd.tituPmPieceIdentiteNo == null ? 'P' : 'M')
        .then((bres) {
      //return Future.value(bres.toString());
      print("La personne titu n'est pas listée");
    }).onError((error, stackTrace) {
      return Future.error(error.toString());
    });

    await isBlackListed(dmd.mandPpPieceIdentiteNo.toString(),
            dmd.mandPpPieceIdentiteCode.toString(), 'P')
        .then((bres) {
      //return Future.value(bres.toString());
      print("La personne mand n'est pas listée");
    }).onError((error, stackTrace) {
      return Future.error(error.toString());
    });

    await uploadFilesAndMandfiles(
        tituimages, docManquantsTitu, imagesmand, titresmand);

    final response = await http.post(
        Uri.parse('http://${backendServer}:8081/demOuvCompte/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'demOuvCompteMandBool': dmd.demOuvCompteMandBool.toString(),
          'demOuvCompteMandEmisDate':
              dmd.demOuvCompteMandEmisDate?.toIso8601String(),
          'mandPpNaissanceDate': dmd.mandPpNaissanceDate?.toIso8601String(),
          'mandPpNom': dmd.mandPpNom.toString(),
          'mandPpPieceIdentiteCode': dmd.mandPpPieceIdentiteCode.toString(),
          'mandPpPieceIdentiteNo': dmd.mandPpPieceIdentiteNo.toString(),
          'mandPpPrenom': dmd.mandPpPrenom.toString(),
          'mandPpTelMobileNo': dmd.mandPpTelMobileNo.toString(),
          'mandPpEmail': dmd.mandPpEmail.toString(),

          'tituPpAdresse': dmd.tituPpAdresse.toString(),

          'mandPpAdresse': dmd.mandPpAdresse.toString(),

          'tituPpPieceIdentiteCode': dmd.tituPpPieceIdentiteCode.toString(),
          // ignore: prefer_null_aware_operators
          'tituPpPieceIdentiteNo': dmd.tituPpPieceIdentiteNo == null
              ? null
              : dmd.tituPpPieceIdentiteNo.toString(),
          'tituPpEmail': dmd.tituPpEmail.toString(),
          'tituPpPrenom': dmd.tituPpPrenom.toString(),
          'tituPpNom': dmd.tituPpNom.toString(),
          'tituPpNaissanceDate': dmd.tituPpNaissanceDate?.toIso8601String(),
          'tituPpTelMobileNo': dmd.tituPpTelMobileNo.toString(),

          'walletNoTelGestion': dmd.walletNoTelGestion.toString(),
          'walletEmailGestion': dmd.walletEmailGestion.toString(),
         

          'tituPpBoolHandicap': dmd.tituPpBoolHandicap.toString(),
          'tituPpMotifHandicap': dmd.tituPpMotifHandicap.toString(),
          'demNewCompteGesSecours':
              dmd.demNewCompteNewMandGesSecours.toString(),
          'demNewCompteEmailSecours':
              dmd.demNewCompteNewMandEmailSecours.toString()
        }));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
  

      final response2 = await updateDemOuvNewCompteNewMand(
          '3',
          demande?.niveauCompte == 'Niveau1' ? '1' : '2',
          '1',
          '1',
          jsonDecode(response.body)['demOuvCompteMandId'],
          response.body);

      return response2;
      // return DemOuvNewCompteNewMand.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  @action
  Future<DemOuvNewCompteNewMand?> createDemOuvNewCompteNewMandSenario3(
      DemOuvNewCompteNewMand dmd,
      images,
      titres,
      imagesmand,
      titresmand) async {
    await isBlackListed(
            dmd.tituPpPieceIdentiteNo.toString(),
            dmd.tituPpPieceIdentiteCode.toString(),
            dmd.tituPmPieceIdentiteNo == null ? 'P' : 'M')
        .then((bres) {
      //return Future.value(bres.toString());
      print("La personne titu n'est pas listée");
    }).onError((error, stackTrace) {
      return Future.error(error.toString());
    });

    await isBlackListed(dmd.mandPpPieceIdentiteNo.toString(),
            dmd.mandPpPieceIdentiteCode.toString(), 'P')
        .then((bres) {
      //return Future.value(bres.toString());
      print("La personne mand n'est pas listée");
    }).onError((error, stackTrace) {
      return Future.error(error.toString());
    });

    await uploadFilesAndMandfiles(
        tituimages, docManquantsTitu, imagesmand, titresmand);

    final response = await http.post(
        Uri.parse('http://${backendServer}:8081/demOuvCompte/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'demOuvCompteMandBool': dmd.demOuvCompteMandBool.toString(),
          'demOuvCompteMandEmisDate':
              dmd.demOuvCompteMandEmisDate?.toIso8601String(),
          'mandPpNaissanceDate': dmd.mandPpNaissanceDate?.toIso8601String(),
          'mandPpNom': dmd.mandPpNom.toString(),
          'mandPpPieceIdentiteCode': dmd.mandPpPieceIdentiteCode.toString(),
          'mandPpPieceIdentiteNo': dmd.mandPpPieceIdentiteNo.toString(),
          'mandPpPrenom': dmd.mandPpPrenom.toString(),
          'mandPpEmail': dmd.mandPpEmail.toString(),
          'mandPpTelMobileNo': dmd.mandPpTelMobileNo.toString(),
          'mandPpAdresse': dmd.mandPpAdresse.toString(),
          'walletNoTelGestion': dmd.walletNoTelGestion.toString(),
          'walletEmailGestion': dmd.walletEmailGestion.toString(),
          'tituPmEmail': dmd.tituPmEmail.toString(),
          'tituPmCreationDate': dmd.tituPmCreationDate?.toIso8601String(),
          'tituPmRaisonSociale': dmd.tituPmRaisonSociale?.toString(),
          'tituPmTelNo': dmd.tituPmTelNo.toString(),
          'tituPmPieceIdentiteCode': dmd.tituPmPieceIdentiteCode.toString(),
          'tituPmPieceIdentiteNo': dmd.tituPmPieceIdentiteNo != null
              ? dmd.tituPmPieceIdentiteNo.toString()
              : null,
          'demNewCompteGesSecours':
              dmd.demNewCompteNewMandGesSecours.toString(),
          'demNewCompteEmailSecours':
              dmd.demNewCompteNewMandEmailSecours.toString()
        }));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      // updateDemOuvNewCompteNewMand( modeOuvCompteId,
      //                               niveauCompteId,
      //                               statutDemandeOuvCompteId,
      //                               uniteGestionId,
      //                               demOuvCompteMandId,response.body)

      final response2 = await updateDemOuvNewCompteNewMand(
          '3',
          demande?.niveauCompte == 'Niveau1' ? '1' : '2',
          '1',
          '1',
          jsonDecode(response.body)['demOuvCompteMandId'],
          response.body);

      //return DemOuvNewCompteNewMand.fromJson(jsonDecode(response.body));
      return response2;
    } else {
      return null;
    }
  }

  @action
  Future<DemandeOuvCompteTmp?> createDemandeTmp(DemandeOuvCompteTmp dmd) async {
//String dateSlug ="${today.year.toString()}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}";

    final response = await http.post(
      Uri.parse('http://${backendServer}:8081/demandeOuvCompteTmp/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'motDepasse': dmd.motDepasse.toString(),
        'demandeOuvCompteTmpEmisDate':
            '2022-01-01', //dmd.demandeOuvCompteTmpEmisDate.toString(),
        'demandeOuvCompteTmpStatutDate':
            '2022-01-01', //dmd.demandeOuvCompteTmpStatutDate.toString(),
        'demandeOuvCompteTmpInitiateur':
            dmd.demandeOuvCompteTmpInitiateur.toString(),
        'statutdemandeOuvCompteTmp': dmd.statutdemandeOuvCompteTmp.toString(),
        'telMobile': dmd.telMobile.toString(),
        'telMobileRecup': dmd.telMobileRecup.toString(),
        'mailRecup': dmd.mailRecup.toString()
        // 'demandeOuvCompteTmpId':null
      }),
    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      return DemandeOuvCompteTmp.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  @action
  Future<DemandeOuvCompteTmp?> fetchDemandeTmpByTel(
      BuildContext context, String tel) async {
    final response = await http.get(Uri.parse(
        'http://${backendServer}:8081/demandeOuvCompteTmp/byTel/${tel}'));

    DemandeOuvCompteTmp? dmdTemp;

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      dmdTemp = DemandeOuvCompteTmp.fromJson(jsonDecode(response.body));
    } else {
      dmdTemp = null;
    }
    return dmdTemp;
  }

//return this.http.get(`${this.uri}/${cin}/cin`)

  @action
  Future<String?> findFirstDmd(
      String cin, String codePiece, String typePersonne) async {
    final response = await http.get(Uri.parse(
        'http://${backendServer}:8081/demOuvCompte/byNoPieceIdentite/' +
            cin +
            '/' +
            codePiece +
            '/' +
            typePersonne));

    dynamic dmd;
    if (response.statusCode == 200 && response.contentLength! > 0) {
      dmd = jsonDecode(response.body);

      if (dmd?["statutDemandeOuvCompte"]["statutDemandeOuvCompteCode"] ==
          "EN COURS") {
        return "Une demande existe déja";
      } else {
        return null;
      }
    } else if (response.statusCode == 406 && response.contentLength! > 0) {
      return response.body;
    }
  }

  @action
  Future<String?> getWalletByCin(String cin) async {
    final response = await http
        .get(Uri.parse('http://${backendServer}:8081/wallet/' + cin + '/cin'));

    dynamic wallet;
    if (response.statusCode == 200 && response.contentLength! > 0) {
      wallet = jsonDecode(response.body);
      if (wallet?["statutWallet"]["statutWalletCode"] == "ACTIF") {
        return "Vous avez déja un compte Actif";
      } else if (wallet["statutWallet"]["statutWalletCode"] == "BLOQUE_D") {
        return "Bloqué pour cause de Décés";
      } else if (wallet["statutWallet"]["statutWalletCode"] == "SUSP") {
        return "Compte Suspendu";
      } else if (wallet["statutWallet"]["statutWalletCode"] == "OPPO") {
        return "Compte en Opposition";
      } else {
        return null;
      }
    }
  }

  @action
  Future<String?> getCompteByCin(String cin) async {
    final response = await http
        .get(Uri.parse('http://${backendServer}:8081/compte/' + cin + '/cin'));

    dynamic wallet;
    if (response.statusCode == 200 && response.contentLength! > 0) {
      wallet = jsonDecode(response.body);
      if (wallet?["statutCompte"]["statutCompteCode"] == "ACTIF") {
        return "Vous avez déja un compte Actif";
      } else if (wallet["statutCompte"]["statutCompteCode"] == "BLOQUE_D") {
        return "Bloqué pour cause de Décés";
      } else {
        return null;
      }
    }
  }

//     "http://localhost:8081/docInY",
//  findFirstByNoPieceIdentite(       numPiece: string,
//                                     codePiece: string,
//                                     typePersonne: string,
//                                     codeDocinX: string          ): Observable<any> {

// return this.http.get(`${this.uri}/byNoPieceIdentite/`+ numPiece + '/' + codePiece + '/' + typePersonne + '/' + codeDocinX);
// }

  @action
  Future<DocInY?> fetchDocInYByNoPieceIdentite(String numPiece,
      String codePiece, String typePersonne, String codeDocinX) async {
    final response = await httpwrapper.get(Uri.parse(
        'http://${backendServer}:8081/docInY/byNoPieceIdentite/' +
            numPiece +
            '/' +
            codePiece +
            '/' +
            typePersonne +
            '/' +
            codeDocinX));
    DocInY? dociny;

    if (response.statusCode == 200 && response.contentLength! > 0) {
      dociny = DocInY.fromJson(jsonDecode(response.body));
    } else {
      dociny = null;
    }

    return dociny;
  }

  @action
  Future<PersonneP?> fetchPersonnePbyPieceIdentite(
      String codePiece, String numPiece) async {
    isOtpLoading = true;

    if (numPiece.isEmpty) return null;
    final response = await http
        .get(Uri.parse('http://${backendServer}:8081/pp/' + numPiece + '/pp'));

    PersonneP? pp;
    if (response.statusCode == 200 && response.contentLength! > 0) {
      pp = PersonneP.fromJson(jsonDecode(response.body));
      print(pp.ppId);
    } else {
      // return Future.error(response.body);
      return null;
    }

    return pp;
  }

  @action
  Future<PersonneP?> fetchPersonnePbyTel(
      BuildContext context, String tel) async {
    isOtpLoading = true;

    final response = await http
        .get(Uri.parse('http://${backendServer}:8081/pp/' + tel + '/ppTel'));

    PersonneP? pp;
    if (response.statusCode == 200 && response.contentLength! > 0) {
      pp = PersonneP.fromJson(jsonDecode(response.body));
      print('ppid ==' + pp.ppId.toString());
    } else {
      pp = null;
    }
    //sleep(Duration(seconds:3));
    isOtpLoading = false;
    currentPhone = tel;
    sendOtp(tel);

    return pp;
  }

  @action
  Future<bool?> isValideEmailGestion(String email) async {
    if (email.isEmpty) return false;

    final res = email.split("@");
    if (res.length != 2) return false;

    final user = res[0];
    final res1 = res[1].split(".");

    if (res1.length != 2) return false;

    final domaine = res1[0];
    final suffixe = res1[1];

    var queryParameters = {
      'user': user,
      'domaine': domaine,
      'suffixe': suffixe
    };

    var uri = Uri.http(
        // ignore: unnecessary_brace_in_string_interps
        '${backendServer}:8081',
        '/wallet/email',
        queryParameters);

    var response = await http.get(uri, headers: {
      HttpHeaders.contentTypeHeader: 'text/plain; charset=utf-8',
    });

    // final response = await http.get(uri);

//  const headers = new HttpHeaders().set('Content-Type', 'text/plain; charset=utf-8');

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @action
  Future<bool?> isValideNumTelGestion(String numTel) async {
    try {
      final response = await http.get(
          Uri.parse('http://${backendServer}:8081/wallet/public/' + numTel + '/tel'));

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        return Future.value(false);
      } else if (response.statusCode <= 206) {
        return Future.value(true);
      } else {
        return Future.error('Pb de connection');
      }
    } catch (ex) {
      return Future.error('Pb de connection');
    }
  }

// /byNoPieceIdentite/{numPiece}/{codePiece}/{typePersonne}
  @action
  Future<String?> isBlackListed(
      //BuildContext context,
      String numPiece,
      String codePiece,
      String typePersonne) async {
    isOtpLoading = true;

    final response = await http.get(Uri.parse(
        'http://${backendServer}:8081/demOuvCompte/byNoPieceIdentite/' +
            numPiece +
            '/' +
            codePiece +
            '/' +
            typePersonne));

    if (response.statusCode <= 206) {
      //&& response.contentLength! > 0) {
      return Future.value("OK");
    } else {
      return Future.error(response.body);
    }
  }

  @action
  Future<List<dynamic>?> chargerListePiece(bool physique) async {
    List<dynamic>? listePieces = [];

    final response = await http
        .get(Uri.parse('http://${backendServer}:8081/pieceIdentite/'));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      listePieces = jsonDecode(response.body);
      //DocInNiveauCompte docInNivCompte = DocInNiveauCompte.fromJson(docInNivComptes?[0]);
      List<dynamic>? filtrelistePieces = [];
      if (physique) {
        filtrelistePieces =
            listePieces?.where((e) => !e['pieceIdentiteBoolPmTun']).toList();
      } else {
        filtrelistePieces =
            listePieces?.where((e) => e['pieceIdentiteBoolPmTun']).toList();
      }
      return filtrelistePieces;
    }
  }

  @action
  Future<List<String>?> chargerDocRequis(
      bool signatireEtTitutaire, String? niveau, bool? pp) async {
    List<dynamic>? docInNivComptes = [];
    final response = await http
        .get(Uri.parse('http://${backendServer}:8081/docInNiveauCompte/'));
    if (response.statusCode <= 206 && response.contentLength! > 0) {
      docInNivComptes = jsonDecode(response.body);
      //DocInNiveauCompte docInNivCompte = DocInNiveauCompte.fromJson(docInNivComptes?[0]);
      List<dynamic>? filtredDocInNivComptes = [];

      if (signatireEtTitutaire) {
        filtredDocInNivComptes = docInNivComptes
            ?.where((e) =>
                e['niveauCompte']['niveauCompteDsg'] == niveau &&
                e['docIn']['docInBoolLignePpTituSign'] != 'N')
            .toList();
      } else if (!pp!) {
        filtredDocInNivComptes = docInNivComptes
            ?.where((e) =>
                e['niveauCompte']['niveauCompteDsg'] == niveau &&
                e['docIn']['docInBoolLignePmTitu'] != 'N')
            .toList();
      } else {
        filtredDocInNivComptes = docInNivComptes
            ?.where((e) =>
                e['niveauCompte']['niveauCompteDsg'] == niveau &&
                e['docIn']['docInBoolLignePpMand'] != 'N')
            .toList();
      }

      List<String>? docsRequis = List.generate(filtredDocInNivComptes!.length,
          (i) => (filtredDocInNivComptes![i]['docIn']['docInCode']));

      return docsRequis;
    }

    return ['CINR', 'CINV', 'SELFIE'];
  }

  @action
  Future<List<DocIn?>?> chargerDocInRequisNvCompte(
      bool signatireEtTitutaire, String? niveau, bool? pp) async {
    List<dynamic>? docInNivComptes = [];

    try {
      final response = await http
          .get(Uri.parse('http://${backendServer}:8081/docInNiveauCompte/'));
      if (response.statusCode <= 206 && response.contentLength! > 0) {
        docInNivComptes = jsonDecode(response.body);

        // selfiecountdown
        //DocInNiveauCompte docInNivCompte = DocInNiveauCompte.fromJson(docInNivComptes?[0]);
        List<dynamic>? filtredDocInNivComptes = [];
        if (signatireEtTitutaire) {
          filtredDocInNivComptes = docInNivComptes
              ?.where((e) =>
                  e['niveauCompte']['niveauCompteDsg'] == niveau &&
                  e['docIn']['docInBoolLignePpTituSign'] != 'N' &&
                  e['operation']['operationCode'] == codeNVCOMPTE)
              .toList();
        } else if (!pp!) {
          filtredDocInNivComptes = docInNivComptes
              ?.where((e) =>
                  e['niveauCompte']['niveauCompteDsg'] == niveau &&
                  e['docIn']['docInBoolLignePmTitu'] != 'N' &&
                  e['operation']['operationCode'] == codeNVCOMPTE)
              .toList();
        } else {
          filtredDocInNivComptes = docInNivComptes
              ?.where((e) =>
                  e['niveauCompte']['niveauCompteDsg'] == niveau &&
                  e['docIn']['docInBoolLignePpMand'] != 'N' &&
                  e['operation']['operationCode'] == codeNVCOMPTE)
              .toList();
        }

        // List<String>? docsRequis = List.generate(filtredDocInNivComptes!.length,
        //     (i) => (filtredDocInNivComptes![i]['docIn']['docInCode']));

        List<DocIn?>? docsRequis = List.generate(filtredDocInNivComptes!.length,
            (i) => (DocIn.fromJson(filtredDocInNivComptes![i]['docIn'])));

        //DocIn? docinSign=
        docsRequis.removeWhere((e) => e?.docInCode == 'SIGN');
        // if (docinSign !=  null){

        //     docsRequis.removeWhere((element) => false)

        // }
        if (signatireEtTitutaire && tituimages.isEmpty) {
          for (int k = 0; k < docsRequis.length; k++) {
            tituimages.add(null);
          }
        } else if (!signatireEtTitutaire && mandimages.isEmpty) {
          for (int k = 0; k < docsRequis.length; k++) {
            mandimages.add(null);
          }
        }

        return docsRequis;
      } else {
        return List.empty();
      }
    } catch (e) {
      return List.empty();
    }
  }

  @action
  Future<List<DocIn?>?> chargerDocInRequisMandNvCompte(String? niveau) async {
    List<dynamic>? docInNivComptes = [];

    String? operation = codeNVCOMPTE;
    if (currentTypeOperation != null) operation = currentTypeOperation;

    try {
      final response = await http
          .get(Uri.parse('http://${backendServer}:8081/docInNiveauCompte/'));
      if (response.statusCode <= 206 && response.contentLength! > 0) {
        docInNivComptes = jsonDecode(response.body);

        List<dynamic>? filtredDocInNivComptes = [];

        filtredDocInNivComptes = docInNivComptes
            ?.where((e) =>
                e['niveauCompte']['niveauCompteDsg'] == niveau &&
                e['docIn']['docInBoolLignePpMand'] != 'N' &&
                e['operation']['operationCode'] == operation)
            .toList();

        List<DocIn?>? docsRequis = List.generate(filtredDocInNivComptes!.length,
            (i) => (DocIn.fromJson(filtredDocInNivComptes![i]['docIn'])));
        docsRequis.removeWhere((e) => e?.docInCode == 'SIGN');
        if (mandimages.isEmpty) {
          for (int k = 0; k < docsRequis.length; k++) {
            mandimages.add(null);
          }
        }

        return docsRequis;
      } else {
        return List.empty();
      }
    } catch (e) {
      return List.empty();
    }
  }

  @action
  Future<void> getCodeWithPhoneNumber(
      BuildContext context, String phoneNumber) async {
    isLoginLoading = true;

    onAuthenticationSuccessful(context);
  }

  // void scaffymsg(BuildContext context, String text,
  //     {bool greenred = true, int duration = 5}) {
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     action: SnackBarAction(
  //       label: 'fermer',
  //       onPressed: () {
  //         snackclosed = true;
  //         ScaffoldMessenger.of(context).hideCurrentSnackBar();

  //         Navigator.of(context).pushAndRemoveUntil(
  //             //MaterialPageRoute(builder: (_) => const ConfirmPassPage()),
  //             MaterialPageRoute(builder: (_) => Authent()),
  //             (Route<dynamic> route) => false);
  //       },
  //     ),
  //     duration: Duration(seconds: duration),
  //     behavior: SnackBarBehavior.floating,
  //     backgroundColor: greenred ? Colors.green[200] : Colors.red[200],
  //     content: Text(
  //       text,
  //       // ignore: prefer_const_constructors
  //       style: TextStyle(color: Colors.black),
  //     ),
  //   ));
  // }

  bool snackclosed = false;
  @action
  Future<bool> validateOtpAndLogin(BuildContext context, String smsCode) async {
    if (smsCode == oneTimePass.toString()) {
      if (bMotPasseOublie) {
        snackclosed = false;

        if (walletMotPasseOublie?.walletNoTelGestion != null)
          dynamic token = await AuthRepository.updatePassword(
              backendServer, walletMotPasseOublie?.walletNoTelGestion, ' ', '',
              temporaire: true, notifBySMS: bParsms, notifByMAIL: bParmail);

      } else {
        Navigator.of(context).push(
          
      MaterialPageRoute(builder: (_) =>    Home2TypePNivPage()) )  ;       ///const Home2Page()),                 
           // (Route<dynamic> route) => false);
      }
      isreset = false;
      return true;
    } else {
   
        buildSuccessMessage(
                                            context,
                                            "key_erreur".tr,
                                            "key_code_errone".tr,
                                            "key_fermer".tr,
                                            false);
    }

    return false;
  }

  Future<void> onAuthenticationSuccessful(BuildContext context) async {
    isLoginLoading = true;
    isOtpLoading = true;

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (Route<dynamic> route) => false);

    isLoginLoading = false;
    isOtpLoading = false;
  }

  @action
  Future<void> signOut(BuildContext context) async {
    // await _auth.signOut();
    pp = null;
    demande?.motDepasse = null;
    dmd = DemOuvNewCompteNewMand();
    compteEx=null;
    for (int i = 0; i < bTabApprouvedDocsCheckBox.length; i++)
      bTabApprouvedDocsCheckBox[i] = false;
    
    bDefaultWalletchecked=false;

    await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => Authent()),
        (Route<dynamic> route) => false);
  }

  @action
  Future<void> login(BuildContext context) async {
    // await _auth.signOut();
    pp = null;
    demande?.motDepasse = null;
    await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage3()),
        (Route<dynamic> route) => false);
  }

  String currentPhone = '';
  String currentToken = '';

  @action
  Future<void> resetPass(BuildContext context, String tel) async {
    // final response = await http
    //     .get(Uri.parse('http://${backendServer}:8081/pp/' + tel + '/ppTel'));

    print(demande.toString());

    currentPhone = tel;
    sendOtp(tel);

    return;
  }

  @action
  Future<Uint8List?> getContract(
      BuildContext context, String code, String num, String rib) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    final response = await http.get(Uri.parse(
        'http://${backendServer}:8081/demOuvCompte/contract/' +
            code +
            '/' +
            num +
            '/' +
            rib));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      String p = "/storage/emulated/0/Download";

      File file = File(p + '/' + 'contrat.pdf');

      // Uint8List bytes = base64.decode((doc?.docInYImageScan).toString());

      File f = await file.writeAsBytes(response.bodyBytes, flush: true);

      print(f.path);

      return response.bodyBytes;
    }
  }

  @action
  Future<Uint8List?> getContract2privatedir(
      BuildContext context, String code, String num, String rib) async {
    final response = await http.get(Uri.parse(
        'http://${backendServer}:8081/demOuvCompte/contract/' +
            code +
            '/' +
            num +
            '/' +
            rib));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      final directory = await getExternalStorageDirectory();

      print(directory!.path);

      String? p = directory.path;

      File file = File(p + '/' + 'contrat.pdf');
      File f = await file.writeAsBytes(response.bodyBytes, flush: true);

      print(f.path);

      return response.bodyBytes; //Uint8List(10);
    }
  }

  @action
  Future<List<NiveauCompte>> getNiveauOld(BuildContext context) async {
    List<dynamic> listeNiveau = [];
    try {
      final response = await http
          .get(Uri.parse('http://${backendServer}:8081/niveauCompte/'));

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        listeNiveau = jsonDecode(response.body);
        List<NiveauCompte> filtrelisteNiveau = [];

        filtrelisteNiveau = listeNiveau
            .where((e) => e['niveauPossibleMob'])
            .map((e) => NiveauCompte.fromJson(e))
            .toList();

        if (filtrelisteNiveau != null)
          return filtrelisteNiveau;
        else
          return List.empty();
      }
      return List.empty();
    } catch (e) {
      return List.empty();
    }
  }

  @action
  Future<List<NiveauCompte>> getNiveauFromIndicateurs(
      BuildContext context) async {
    List<dynamic> listeNiveau = [];
    try {
      final response = await http.get(
          Uri.parse('http://${backendServer}:8081/niveauCompteIndicCompte'));

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        listeNiveau = jsonDecode(response.body);
        List<NiveauCompte> filtrelisteNiveau = [];

        filtrelisteNiveau =
            listeNiveau.map((e) => NiveauCompte.fromJson(e)).toList();

        if (filtrelisteNiveau != null)
          return filtrelisteNiveau;
        else
          return List.empty();
      }
      return List.empty();
    } catch (e) {
      return List.empty();
    }
  }

  @action
  Future<List<NiveauCompte>> getNiveau(BuildContext context) async {
    List<dynamic> listeNiveau = [];
    try {
      final response = await http.get(Uri.parse(
          'http://${backendServer}:8081/modeOuvCloCompte/niveau/MOBILE'));

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        listeNiveau = jsonDecode(response.body);
        List<NiveauCompte> filtrelisteNiveau = [];

        filtrelisteNiveau =
            listeNiveau.map((e) => NiveauCompte.fromJson(e)).toList();

        if (filtrelisteNiveau != null)
          return filtrelisteNiveau;
        else
          return List.empty();
      }
      return List.empty();
    } catch (e) {
      return List.empty();
    }
  }

  @action
  Future<dynamic> getCompteByTelGestion(String tel) async {
    dynamic compte;
    try {
     // final response = await httpwrapper.get(Uri.parse(
      final response = await http.get(Uri.parse(

          'http://${backendServer}:8081/compte/telgestion/' + tel + '/'));

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        compte = jsonDecode(response.body);

        return compte;
      }
      return null;
    } catch (e) {
      return null;
    }
  }


  @action
  Future<dynamic> getCompteByTelGestionPlus(String tel) async {
    dynamic compte;
    try {
      final response = await http.get(Uri.parse(
          'http://${backendServer}:8081/compte/telgestplus/' + tel + '/'));

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        compte = jsonDecode(response.body);

        return compte;
      }    else if (response.statusCode == 422) {
            return Future.error(response);
       
      } 

      return null;
    } catch (e) {
      return null;
    }
  }








  @action
  Future<dynamic> getCompteByNumTelTitu(String tel) async {
    dynamic compte;
    try {
      final response = await http.get(Uri.parse(
          'http://${backendServer}:8081/compte/telTitu/' + tel + '/'));

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        compte = jsonDecode(response.body);

        return compte;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @action
  Future<dynamic> getWalletByNoTelGestion(String numTel) async {
    dynamic wallet;

    try {
      final response = await http.get(Uri.parse(
          'http://${backendServer}:8081/wallet/' + numTel + '/wallet'));

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        wallet = jsonDecode(response.body);

        return wallet;
      } else if (response.statusCode <= 206) {
        return null;
      } else {
        return Future.error('Pb de connection');
      }
    } catch (ex) {
      return Future.error('Pb de connection');
    }
  }

  @action
  Future<dynamic> resetUserPass(String email, String verif) async {
//String dateSlug ="${today.year.toString()}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}";

    final response = await http.post(
      Uri.parse('http://${backendServer}:8081/user/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'verif': verif,
        'mailRecup': email
        // 'demandeOuvCompteTmpId':null
      }),
    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      return true;
    } else {
      return false;
    }
  }

///////

  @action
  Future<DemNewAdr?> updateDemNewAdr(niveauCompteId, typePersonne, tituId,
      mandId, statutDemandeId, uniteGestionId, demNewAdrTituId, dmd) async {
    // this.httpClient.put( environment.API_URL_DEM_NEW_ADR_TITU  + '/'
    //                                                               + this.demandeService.intNiveauCompte + '/'
    //                                                               + typePersonne  + '/'
    //                                                               + tituId        + '/'
    //                                                               + mandId        + '/'
    //                                                               + demande.statutDemande.statutDemandeId   + '/'
    //                                                               + demande.uniteGestion.uniteGestionId     + '/demNewAdrTitu/'
    //                                                               + dem.demNewAdrTituId, dem

    //                                                               )

    final response = await http.put(
        Uri.parse('http://${backendServer}:8081/demNewAdrTitu/' +
            niveauCompteId +
            '/' +
            typePersonne +
            '/' +
            tituId +
            '/' +
            mandId +
            '/' +
            statutDemandeId +
            '/' +
            uniteGestionId +
            '/demNewAdrTitu/' +
            demNewAdrTituId),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: dmd);

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      return DemNewAdr.fromJson(jsonDecode(response.body));
    } else
      return null;
  }

  Future<dynamic?> updateInfosPerso(DemNewAdr dmd) async {
   
   
    if (tituimages.isNotEmpty &&
        docManquantsTitu != null &&
        docManquantsTitu!.isNotEmpty)
      await uploadChgAdrFiles(tituimages, docManquantsTitu);

    final response = await http.post(
      Uri.parse('http://${backendServer}:8081/demNewAdrTitu'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'demNewAdrTituEmisDate': dmd.demNewAdrTituEmisDate?.toIso8601String(),
        'demNewAdrTituNewAdr': dmd.demNewAdrTituNewAdr.toString(),
        'demNewAdrTituInfoLibre': dmd.demNewAdrTituInfoLibre.toString(),
      }),
    );
    DemNewAdr dem1 = DemNewAdr.fromJson(jsonDecode(response.body));
    String typePers = dmd.personnepTituId != null ? "P" : "M";
    int statutDemandeId = 1;
    int uniteGestionId = 1;
    int? tituId = dmd.personnepTituId ?? dmd.personnepTituId ?? -1;
    int mandId = dmd.personnepMandId ?? dmd.personnepTituId ?? -1;
    int niveauCompteId = this.dmdChgeInfosPerso.niveauCompte!;
    int demNewAdrTituId = dem1.demNewAdrTituId ?? -1;

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      return await updateDemNewAdr(
          niveauCompteId.toString(),
          typePers,
          tituId.toString(),
          mandId.toString(),
          statutDemandeId.toString(),
          uniteGestionId.toString(),
          demNewAdrTituId.toString(),
          response.body);

      //return DemNewAdr.fromJson(jsonDecode(response.body));
    } else {
      //throw Exception();
      return null;
    }
  }

  Future<Map<String,dynamic>?> updateInfosPersoV2(Map <String,dynamic> params) async {
   
      // await uploadChgAdrFiles(tituimages, docManquantsTitu);


    final response = await http.post(
      Uri.parse('http://${backendServer}:8081/compte/persoInfos'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(params ),
    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      return      jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      //throw Exception();
      return null;
    }
  }

  Future<dynamic> payerCommercant(Transaction tr) async {
    final response = await httpwrapper.post(
      Uri.parse('http://${backendServer}:8081/transfererFond/process'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        
        'telDonneur': tr.telDonneur?.toString(),
        'telBeneficiaire': tr.telBeneficiaire?.toString(),

        'institutionBenificiaire': tr.institutionBenificiaire.toString(),
        'institutionEmetteur': tr.institutionEmetteur.toString(),
        'montant': tr.montant.toString(),
        'tva': tr.tva.toString(),
        'commHT': tr.commHT.toString(),
        'codeOperation': tr.codeOperation.toString(),
        'transInfoLibre': tr.transInfoLibre.toString(),
        'canal': tr.canal.toString(),
        'qrCode': tr.qrCode.toString()

      }),
    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      Transaction tr2 = Transaction.fromJson(jsonDecode(response.body));

      return tr2;
    } else {
      return response.bodyBytes;
      //return null;
      //return response.body;
    }
  }




  Future<dynamic> payerFacture(Transaction tr) async {
    final response = await httpwrapper.post(
      Uri.parse('http://${backendServer}:8081/transfererFond/process'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        
 'facturierCode':  tr.facturierCode?.toString(),
 'transAgregateurId':  tr.transAgregateurId?.toString(),
 'critereCode':  tr.critereCode?.toString(),
 'transFacturierCritereValue': tr.transFacturierCritereValue?.toString(),
 'transTypeOpRef': tr.transTypeOpRef?.toString(),

        'telDonneur': tr.telDonneur?.toString(),
        'telBeneficiaire': tr.telBeneficiaire?.toString(),
        'institutionBenificiaire': tr.institutionBenificiaire.toString(),
        'institutionEmetteur': tr.institutionEmetteur.toString(),
        'montant': tr.montant.toString(),
        'tva': tr.tva.toString(),
        'commHT': tr.commHT.toString(),
        'codeOperation': tr.codeOperation.toString(),
        'transInfoLibre': tr.transInfoLibre.toString(),
        'canal': tr.canal.toString()
      }),
    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      Transaction tr2 = Transaction.fromJson(jsonDecode(response.body));

      return tr2;
    } else {
      return response.bodyBytes;
      //return null;
      //return response.body;
    }
  }



  Future<dynamic> transfererFond(Transaction tr) async {
    
    final response = await httpwrapper.post(
      Uri.parse('http://${backendServer}:8081/transfererFond/process'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'telDonneur': tr.telDonneur?.toString(),
        'telBeneficiaire': tr.telBeneficiaire?.toString(),
        'institutionBenificiaire': tr.institutionBenificiaire.toString(),
        'institutionEmetteur': tr.institutionEmetteur.toString(),
        'montant': tr.montant.toString(),
        'tva': tr.tva.toString(),
        'commHT': tr.commHT.toString(),
        'codeOperation': tr.codeOperation.toString(),
        'transInfoLibre': tr.transInfoLibre.toString(),
        'canal': tr.canal.toString()
      }),
    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      Transaction tr2 = Transaction.fromJson(jsonDecode(response.body));

      return tr2;
    } else {
      return response.bodyBytes;
      //return null;
      //return response.body;
    }
  }



//   Future<void> transferFunds(String token) async {
//   final url = Uri.parse('http://192.168.1.13:8081/transfererFond/evaluate');
//   final response = await http.post(
//     url,
//     headers: {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     },
//     body: '{"amount":100}',
//   );

//   if (response.statusCode == 200) {
//     print('Transfer successful: ${response.body}');
//   } else {
//     print('Failed to transfer: ${response.statusCode} ${response.body}');
//   }
// }

  Future<dynamic> EvaluerTransfererFond(Transaction tr) async {

   // var  token= await AuthRepository.authenticate('98123456', '12345aA@');


    final response = await httpwrapper.post(
         // final response = await http.post(

      Uri.parse('http://${backendServer}:8081/transfererFond/evaluate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'telDonneur': tr.telDonneur?.toString(),
        'telBeneficiaire': tr.telBeneficiaire?.toString(),
        'institutionBenificiaire': tr.institutionBenificiaire.toString(),
        'institutionEmetteur': tr.institutionEmetteur.toString(),
        'codeOperation': tr.codeOperation.toString(),
        'montant': tr.montant.toString(),
        'tva': tr.tva.toString(),
        'commHT': tr.commHT.toString(),
        'transInfoLibre': tr.transInfoLibre.toString(),
        'canal': tr.canal.toString()
      }),
    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      Transaction tr2 = Transaction.fromJson(jsonDecode(response.body));

      return tr2;
    } else { return response.bodyBytes;  }
  }

  Future<dynamic> EvaluerPayerFacture(Transaction tr) async {
    final response = await httpwrapper.post(
      Uri.parse('http://${backendServer}:8081/transfererFond/evaluate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{

 'facturierCode':  tr.facturierCode?.toString(),
 'transAgregateurId':  tr.transAgregateurId?.toString(),
 'critereCode':  tr.critereCode?.toString(),
 'transFacturierCritereValue': tr.transFacturierCritereValue?.toString(),
'transTypeOpRef': tr.transTypeOpRef?.toString(),

        'telDonneur': tr.telDonneur?.toString(),
        'telBeneficiaire': tr.telBeneficiaire?.toString(),
        'institutionBenificiaire': tr.institutionBenificiaire.toString(),
        'institutionEmetteur': tr.institutionEmetteur.toString(),
        'codeOperation': tr.codeOperation.toString(),
        'montant': tr.montant.toString(),
        'tva': tr.tva.toString(),
        'commHT': tr.commHT.toString(),
        'transInfoLibre': tr.transInfoLibre.toString(),
        'canal': tr.canal.toString()
      }),
    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      Transaction tr2 = Transaction.fromJson(jsonDecode(response.body));

      return tr2;
    } else { return response.bodyBytes;  }
  }


  Map <String,String>? institutions;
  @action
  Future<List<ServiceProvider>> getServiceProviders() async {
    List<dynamic> listeProviders = [];
    final response = await http.get(
        Uri.parse('http://${backendServer}:3000/switch/api/ServiceProviders'));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      //listeProviders = ServiceProvider.fromJson(jsonDecode(response.body));
      listeProviders = jsonDecode(response.body);
    } else {
      listeProviders = List.empty();
    }
    List<ServiceProvider> serviceProvider = [];

    serviceProvider =
        listeProviders.map((e) => ServiceProvider.fromJson(e)).toList();
    return serviceProvider;
  }

    Future<List<InsFin>> getInsFins() async {
    List<dynamic> listeProviders = [];
    final response = await httpwrapper.get(
        Uri.parse('http://${backendServer}:8081/insFin/'));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      //listeProviders = ServiceProvider.fromJson(jsonDecode(response.body));
      listeProviders = jsonDecode(response.body);
    } else {
      listeProviders = List.empty();
    }
    List<InsFin> serviceProvider = [];

    serviceProvider =
        listeProviders.map((e) => InsFin.fromJson(e)).toList();
    return serviceProvider;
  }

  Future<List<Agence>> getAgences() async {
    List<dynamic> listeProviders = [];
    final response = await httpwrapper.get(
        Uri.parse('http://${backendServer}:8081/agence/'));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      //listeProviders = ServiceProvider.fromJson(jsonDecode(response.body));
      listeProviders = jsonDecode(response.body);
    } else {
      listeProviders = List.empty();
    }
    List<Agence> serviceProvider = [];

    serviceProvider =
        listeProviders.map((e) => Agence.fromJson(e)).toList();
    return serviceProvider;
  }

  
  /////////////////////////////
  @action
  Future<dynamic> getOtpByNoTelGestion(String noTelGest, String montant) async {    
    dynamic otp;
    try {
      if (noTelGest == null )
        return Future.error('Num de Tél non fournie');
      String strMontant;
      if (montant != null && '0'.allMatches(montant).length!=2  )
        strMontant= '&montant=' + montant;
      else
        strMontant="";


      final response = await http.get(Uri.parse(
          'http://${backendServer}:8081/otp/generate?noTelGest=' +
              noTelGest + strMontant
             ));

      dynamic otp;
      if (response.statusCode <= 206 && response.contentLength! > 0) {
        otp = jsonDecode(response.body);    

        return otp;
      } else if (response.statusCode <= 206) {
        return null;

       } else if (response.statusCode == 422) {
       return response;
      } else {
        return Future.error('Pb de connection');
      }
    } catch (ex) {
      return Future.error('Pb de connection');
    }
  }

   @action
  Future<dynamic> getOtpNominatifByNoTelGestion(String noTelGest, String montant,
  String code,String numId, String nom,String prenom) async {    
    dynamic otp;
    try {
      if (noTelGest == null )
        return Future.error('Num de Tél non fournie');
      String strMontant;
      if (montant != null && '0'.allMatches(montant).length!=2  )
        strMontant= '&montant=' + montant;
      else
        strMontant="";


      // final response = await http.get(Uri.parse(
      //     'http://${backendServer}:8081/otp/generate?noTelGest=' +
      //         noTelGest + strMontant
      //        ));



    final response = await httpwrapper.post(
      Uri.parse('http://${backendServer}:8081/otp/generate'),
      // headers: <String, String>{
      //   'Content-Type': 'application/json; charset=UTF-8',
      // },
      body: //jsonEncode(<String, dynamic>
      {
                    'userTel':userTel ,
                    'noTelGest':noTelGest, 
                    'montant':montant,
                    'codeId':code, 
                    'numId':numId,
                    'nom':nom,
                    'prenom':prenom             
      }
  
    );

      dynamic otp;
      if (response.statusCode <= 206 && response.contentLength! > 0) {
        otp = jsonDecode(response.body);    

        return otp;
      } else if (response.statusCode <= 206) {
        return null;

       } else if (response.statusCode == 422) {
       return response;
      } else {
        return Future.error('Pb de connection');
      }
    } catch (ex) {
      return Future.error('Pb de connection');
    }
  }



  List<entryTitleValue> transactionStatus = [];
  List<entryTitleValue> transactionResumeHisto = [];

  final api_user_trans="user";
  final api_user_trans_otp_reclam="transOtpAndReclams";


  Future<List<Transaction>? > getTransByUser(String? don, String? ben) async {
    try {
      if (don == null || ben == null)
        return Future.error('Num de Tél non fournie');


      final response = await httpwrapper.get(Uri.parse(
          'http://${backendServer}:8081/transaction/transOtpAndReclams?don=' +
              don +
              '&ben=' +
              ben));

      List<dynamic> transactions;
      if (response.statusCode <= 206 && response.contentLength! > 0) {
        // transactions = jsonDecode(response.body);
         transactions = jsonDecode(utf8.decode(response.bodyBytes));


        List<Transaction> transs = transactions
            .map<Transaction>((t) => Transaction.fromJson(t))
            .toList();

        return transs;
      } else if (response.statusCode <= 206) {
        return null;
      } else {
        return Future.error('Pb de connection');
      }
    } catch (ex) {
      return Future.error('Pb de connection');
    }
  }



  Future<List<Transaction>? > getTransByUserByMonths(String? don, String? ben) async {
    try {
      if (don == null || ben == null)
        return Future.error('Num de Tél non fournie');

      final response = await httpwrapper.get(Uri.parse(
          'http://${backendServer}:8081/transaction/userbymonths?don=' +
              don +
              '&ben=' +
              ben));

      List<dynamic> transactions;
      if (response.statusCode <= 206 && response.contentLength! > 0) {
        transactions = jsonDecode(response.body);

        List<Transaction> transs = transactions
            .map<Transaction>((t) => Transaction.fromJson(t))
            .toList();

        return transs;
      } else if (response.statusCode <= 206) {
        return null;
      } else {
        return Future.error('Pb de connection');
      }
    } catch (ex) {
      return Future.error('Pb de connection');
    }
  }


   Devise? currentDevise;
   Future<List<Devise>? > getDevises() async {
    try {

      final response = await http.get(Uri.parse(
          'http://${backendServer}:8081/devise/'   ));

      List<dynamic> devs;
      if (response.statusCode <= 206 && response.contentLength! > 0) {
        devs = jsonDecode(utf8.decode(response.bodyBytes));


        List<Devise> devises = devs
            .map<Devise>((t) => Devise.fromJson(t))
            .toList();

        return devises;
      } else if (response.statusCode <= 206) {
        return null;
      } else {
        return Future.error('Pb de connection');
      }
    } catch (ex) {
      return Future.error('Pb de connection');
    }
  }

  @action
  Future<Uint8List?> getRIB(
      BuildContext context) async {
String? telGestion=userTel;
String? codeLang;
codeLang = AppLocalization.of().locale.languageCode;

    if ( telGestion==null)
      return null;
    final response = await http.get(Uri.parse(
        'http://${backendServer}:8081/compte/doc/rib/' + telGestion +  '/' + (codeLang ?? "fr")));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
     
   
      return response.bodyBytes;
    }
  }




  @action
  Future<Uint8List?> getReleve(
      BuildContext context) async {
String? telGestion=userTel;
String? codeLang;
codeLang = AppLocalization.of().locale.languageCode;

    // var status = await Permission.storage.status;
    // if (!status.isGranted) {
    //   await Permission.storage.request();
    // }
    if ( telGestion==null)
      return null;
    final response = await httpwrapper.get(Uri.parse(
        'http://${backendServer}:8081/compte/doc/releve/' + telGestion +  '/' + (codeLang ?? "fr")));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
     
      // String p = "/storage/emulated/0/Download";
      // File file = File(p + '/' + 'rib.pdf');
      // Uint8List bytes = base64.decode((doc?.docInYImageScan).toString());
    ///  File f = await file.writeAsBytes(response.bodyBytes, flush: true);
    //  print(f.path);

      return response.bodyBytes;
    }
  }






  Future<dynamic> initSetDefaultWallet() async {
    final response = await httpwrapper.post(
      Uri.parse('http://${backendServer}:8081/wallet/initdefault'),
      // headers: <String, String>{
      //   'Content-Type': 'application/json; charset=UTF-8',
      // },
      body: //jsonEncode(<String, dynamic>
      {
                  'userTel':userTel              
      }
  
    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
     // final jsonResponse =jsonDecode(response.body);

      return response.body;
    } else {
      return response.body;
      //return null;
      //return response.body;
    }
  }


  Future<dynamic> confirmSetDefaultWallet(String otp) async {
    final response = await httpwrapper.post(
      Uri.parse('http://${backendServer}:8081/wallet/confirmdefault'),
      body: 
      {           
        'otp':otp,              
        'userTel':userTel              
      });

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      return response.body;
    } else {
      return response.body;
    }
  } 

  @action
  Future<bool?> getIsDefaultWallet() async {
    String? telGestion=userTel;
    final queryParameters = {
      'telGestion': telGestion,
    };

    // var status = await Permission.storage.status;
    // if (!status.isGranted) {
    //   await Permission.storage.request();
    // }
    if ( telGestion==null)
      return null;    

 final response = await httpwrapper.get(
          Uri.parse('http://${backendServer}:8081/wallet/getisdefault/' + telGestion));

    if (response.statusCode <= 206 && response.contentLength! > 0) {

      final swresp=jsonDecode(response.body);

      if (swresp["resultCode"]=="1")    
        return true;
      else
        return false;
    }

    return null;
  }



    @action
  Future<String?> getStatus({String? telBeneficiaire}) async {
String? telGestion=  telBeneficiaire ??  userTel;
    final queryParameters = {
  'telGestion': telGestion,
};

    // var status = await Permission.storage.status;
    // if (!status.isGranted) {
    //   await Permission.storage.request();
    // }
    if ( telGestion==null)
      return null;    

 final response = await httpwrapper.get(
          Uri.parse('http://${backendServer}:8081/wallet/getStatus/${telGestion}' ));

    if (response.statusCode <= 206 && response.contentLength! > 0) {

      final swresp=jsonDecode(response.body);

      if (swresp["resultCode"]=="00")    
        return swresp["status"];
      else
        return swresp["resultCode"];
    }

    return null;
  }


List<dynamic> mapIndicsNiv2Niveaux(List<dynamic> list) {
  // Use a set to ensure uniqueness based on niveauCompteId
  final uniqueSet = <int, dynamic>{};

  for (var indicNiv in list) {
    final niveauCompte = indicNiv['niveauCompte'];
    if (niveauCompte != null) {
      uniqueSet[niveauCompte['niveauCompteId']] = niveauCompte;
    }
  }

  return uniqueSet.values.toList();
}

Map<String, List<dynamic>> transformListToMap(List<dynamic> list) {
  Map<String, List<dynamic>> resultMap = {};

  for (dynamic c in list) {
    if (resultMap.containsKey(c['niveauCompte']['niveauCompteDsg'])) {
      c['indicCompte']['maxvalue']=c['niveauIndicAutoValeur'];
      resultMap[c['niveauCompte']['niveauCompteDsg']]!.add(c['indicCompte']);

    } else {
      c['indicCompte']['maxvalue']=c['niveauIndicAutoValeur'];
      resultMap[c['niveauCompte']['niveauCompteDsg']] = [c['indicCompte']];
    }
  } //niveauCompteIndicCompteMaxVal ---->         niveauIndicAutoValeur

  return resultMap;
}

  @action
 // Future<Map<String,List<dynamic>>> getNivCptIndicCpt(BuildContext context) async {
  Future <List<dynamic>> getNivCptIndicCpt(BuildContext context) async {
    List<dynamic> listeNiveauCptIndicCpt = [];
    try {
      final response = await http.get(Uri.parse(
          'http://${backendServer}:8081/modeOuvCloCompte/niveauCompteIndicCompte/MOBILE'));

      if (response.statusCode <= 206 && response.contentLength! > 0) {
        listeNiveauCptIndicCpt = jsonDecode(response.body);                       
      }
    } catch (e) {
      print ("Error in getNivCptIndicCpt ");
    }
    return listeNiveauCptIndicCpt ;

  }


  List<dynamic> listeNotifs = [];
  List<Notif>  typedlisteNotifs = [];


  @action
  Future<List<Notif>> getUserNotifs () async {   // (String userTel) async {
    try {
      final response = await httpwrapper.get(
          Uri.parse('http://${backendServer}:8081/notification'));
      listeNotifs=[];
      if (response.statusCode <= 206 && response.contentLength! > 0) {
        listeNotifs = jsonDecode( utf8.decode( response.bodyBytes ));
        List<Notif> filtrelisteNotifs = [];

        filtrelisteNotifs =
            listeNotifs.map((e) => Notif.fromJson(e)).toList();
        filtrelisteNotifs.removeWhere((n) => n.destinataire!=userTel)   ;        
        typedlisteNotifs=filtrelisteNotifs;
          return filtrelisteNotifs;
       
      }
      return List.empty();
    } catch (e) {
      return List.empty();
    }
  }



  Future<Notif?> updateNotif(Notif notif) async {

    refreshCompte=true;
    String _telMobileRecup = '';
    if ((demande!.telMobileRecup) != null)
      _telMobileRecup = demande!.telMobileRecup!;

    final response = await httpwrapper.patch(
      Uri.parse('http://${backendServer}:8081/notification/' +
          (notif.notifId).toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
       'lue': true.toString(),     
      }),
    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      return Notif.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<bool> postNotification(Notif n) async {
  try {
    final response = await http.post(
      Uri.parse('http://$backendServer:8081/notification'), // Replace with your backend URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
        body: jsonEncode(<String, String>{
        'message':n.message.toString(), 
        'destinataire':n.destinataire.toString(),
        'source':n.source.toString(), 
        'subject':n.subject.toString(), 
        'methode':n.methode.toString(),
        'notifDate':n.notifDate?.toIso8601String() ??"",
        'lue':false.toString()
   }),
      
    );

    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print('Error posting notification: $e');
    return false;
  }
}

ConnectivityResult? connectivityResult;
 Future<ConnectivityResult?> checkInternetConnection() async {

    connectivityResult = await Connectivity().checkConnectivity();
     return connectivityResult;
    // if (connectivityResult == ConnectivityResult.none) {
    //  retrun "Pas de connexion Internet");
    // } else if (connectivityResult == ConnectivityResult.wifi) {
    //   print("Connexion Wi-Fi disponible");
    // } else if (connectivityResult == ConnectivityResult.mobile) {
    //   print("Connexion mobile disponible");
    // }
  }

    @action
  Future<List<DocInY>> fetchDocInYByRib(String rib) async {
    final response = await httpwrapper.get(Uri.parse(
        'http://${backendServer}:8081/docInY/compte/' + rib));

    List<dynamic> elements = [];
    if (response.statusCode == 200 && response.contentLength! > 0) {
        elements = jsonDecode(response.body );
        List<DocInY> DocInYList = elements.map((jsonObject) {
    return DocInY.fromJson(jsonObject);
  }).toList();

      return DocInYList;
    } else {
      return [];
    }

  }

  Future<dynamic> reclam (Reclam rec) async {
  intl.DateFormat? defaultFormatter;
          
  String defaultDateTimeFormat = 'key_default_date_time_format'.tr;
            
  defaultFormatter = intl.DateFormat(defaultDateTimeFormat, 'fr');
  
    final response = await httpwrapper.post(
      Uri.parse('http://${backendServer}:8081/reclam'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(rec.toMap(defaultFormatter) ),
     // body: rec 

    );

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      return true;

    } else {
      //throw Exception();
      return false;
    }
  }


  Future< dynamic > chargerListeTypeReclam(String codeOp) async {
    List<dynamic>? typesReclams = [];

    final response = await httpwrapper
        .get(Uri.parse('http://${backendServer}:8081/typeReclam/'));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      typesReclams = jsonDecode(response.body);
      List<dynamic>? filtretypesReclams = [];

      bool conditionOnCodeOp= codeOp == "";
      dynamic typeReclam;
        filtretypesReclams = 
            typesReclams?.where((e) => e['typeOp']!=null && ((e['typeOp']['operationCode']==codeOp) ||conditionOnCodeOp) ).toList();
      if ((filtretypesReclams?.isNotEmpty ?? false)){
           typeReclam= filtretypesReclams![0];
      }
      return typeReclam;
    }
  }

  Future< dynamic > getReclamsByTel (String tel) async {
  List<dynamic>? reclams = [];

    final response = await httpwrapper
        .get(Uri.parse('http://${backendServer}:8081/reclam/byTel/'+tel));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
               reclams = jsonDecode(utf8.decode(response.bodyBytes));



      return reclams;
    }
    else return [];
  }




  // Future< dynamic > extractInvoices (String biller, String objectReference) async {
  // List<dynamic>? reclams = [];

  //   final response = await http
  //       .get(Uri.parse('http://${backendServer}:8081/reclam/byTel/'+tel));

  //   if (response.statusCode <= 206 && response.contentLength! > 0) {
  //     reclams = jsonDecode(response.body);


  //     return reclams;
  //   }
  //   else return [];
  // }


  Future<List<dynamic>> extractInvoices(String biller, String critere, String ref) async {
    
    if (biller.isEmpty || critere.isEmpty || ref.isEmpty) return [];
    
   // var queryParameters = { 'biller': biller, 'objectReference': ref };

   var param;
   if (facturierCodeToCritereType[biller]!=null && facturierCodeToCritereType[biller]?.length==1){
      String? firstKey = facturierCodeToCritereType[biller]?.keys.firstOrNull; 
      param=facturierCodeToCritereType[biller]?[firstKey];

   }else
     param=facturierCodeToCritereType[biller]?[critere];

    final queryParams = {
      'biller': biller,
      if (param?.param == 'objectReference') 'objectReference': ref,
      if (param?.param  == 'clientCode') 'clientCode': ref,
      'critereType': param?.url,
      'paramName': param?.param ,
    };





    var uri = Uri.http('${backendServer}:8081','/facturier/extract', queryParams);
    
    final finalUri = uri.replace(queryParameters: queryParams); 

    var response = await httpwrapper.get(finalUri);
    List<dynamic> listeInvoices = [];
    if (response.statusCode <= 206 && response.contentLength! > 0) {
            listeInvoices = jsonDecode(utf8.decode(response.bodyBytes));

      return listeInvoices;
    } else {
      return [];
    }
  }

    //orderInvoice(String id, String paymentMean, String addedAmount ){

    Future<dynamic> orderInvoice(String id, String paymentMean,String addedAmount,String critereType) async {
    if (id.isEmpty || paymentMean.isEmpty || addedAmount.isEmpty) return [];
    
    var queryParameters = { 'paymentMean': paymentMean, 'addedAmount': addedAmount,'critereType':critereType };

    var uri = Uri.http('${backendServer}:8081','/facturier/order/'+id, queryParameters);
    
    final finalUri = uri.replace(queryParameters: queryParameters); 

    var response = await httpwrapper.get(finalUri);
    dynamic invoice;
    if (response.statusCode <= 206 && response.contentLength! > 0) {
            invoice = jsonDecode(response.body);

      return invoice;
    } else {
      return {};
    }
  }



  @action
  Future<List<dynamic>> chargeCritere (String codeFacturier)  async {
    List<dynamic> listeCriteres = [];

    final response = await httpwrapper
        .get(Uri.parse('http://${backendServer}:8081/facturierCritere/'));

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      listeCriteres = jsonDecode(utf8.decode(response.bodyBytes));
      // devs = jsonDecode(utf8.decode(response.bodyBytes));


      List<dynamic> filtrelisteCriteres = [];
      filtrelisteCriteres =
            listeCriteres.where((e) => e['facturier']['facturierAgregateurCode']==codeFacturier).toList();
      
      return filtrelisteCriteres;
    }else return [];

  }

  Future<List<Favori>> addFavoriRefCritere (String nomFav, String ref, int critereId, String rib)  async {
      List<dynamic> listeCriteres = [];

          final response = await httpwrapper.post(
      Uri.parse('http://${backendServer}:8081/favori/create'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'favoriNom': nomFav,
        'favoriReference': ref,
        'facturierCritere':   {'facturierCritereId': critereId },
        'compte': {'compteRib' : rib}
      }),
    );
    List<dynamic> favs = [];

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      favs = jsonDecode(utf8.decode (response.bodyBytes) );

              List<Favori> Favoris = favs.map((jsonObject) {
    return Favori.fromJson(jsonObject);
  }).toList();
      return Favoris;
    } else {
      throw Exception("");
    }
  }

    Future<List<Favori>> deleteFavori ( int favoriId)  async {
      List<dynamic> listeCriteres = [];

          final response = await httpwrapper.delete(
      Uri.parse('http://${backendServer}:8081/favori/$favoriId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // body: jsonEncode(<String, dynamic>{
      //   'favoriNom': nomFav,
      //   'favoriReference': ref,
      //   'facturierCritere':   {'facturierCritereId': critereId },
      //   'compte': {'compteRib' : rib}
      // }),
    );
    List<dynamic> favs = [];

    if (response.statusCode <= 206 && response.contentLength! > 0) {
      favs = jsonDecode(utf8.decode (response.bodyBytes) );

              List<Favori> Favoris = favs.map((jsonObject) {
    return Favori.fromJson(jsonObject);
  }).toList();
      return Favoris;
    } else {
      throw Exception("");
    }
  }


  @action
  Future<List<Favori>> fetchFavorisByRibAndFacturier(String rib, String facturier) async {

 
    var queryParameters = { 'rib': rib, 'facturier': facturier };

    var uri = Uri.http('${backendServer}:8081','/favori/byrib/', queryParameters);
    
    final finalUri = uri.replace(queryParameters: queryParameters); 

    var response = await httpwrapper.get(finalUri);
    // , headers: {
    //  // HttpHeaders.contentTypeHeader: 'text/plain; charset=utf-8',
    // //  HttpHeaders.contentTypeHeader: 'application/json',
    // });

    List<dynamic> favs = [];
    if (response.statusCode == 200 && response.contentLength! > 0) {
        favs = jsonDecode(response.body );
        List<Favori> favoris = favs.map((jsonObject) {
    return Favori.fromJson(jsonObject);
  }).toList();

      return favoris;
    } else {
      return [];
    }

  }

// compte:
// facturierCritere:
            // favoriId:
// favoriNom:
// favoriReference:


Future<dynamic> createVirem(Virem virem, String doRib) async {

  var url ='http://${backendServer}:8081/virem/create';

  final headers = {'Content-Type': 'application/json'};

   Map<String, dynamic> mapVirem = virem.toJson();
   mapVirem.addAll({'viremDoRib':doRib,'viremCanal':CODE_CANAL_MOBIL});
  try {
    final response = await httpwrapper.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(  mapVirem),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
      return Virem.fromJson(jsonResponse);
    } else {
        print('Failed to insert virement entity: ${response.statusCode}');
      return null;
    }
  } catch (e) {
      print('Error during API call: $e');
    return null;
  }

}


Future<dynamic> createViremPerm(ViremPerm viremPerm, String doRib) async {

  var url ='http://${backendServer}:8081/virem/perm/create';

  final headers = {'Content-Type': 'application/json'};

   Map<String, dynamic> mapVirem = viremPerm.toJson();
   mapVirem.addAll({'viremPermDoRib':doRib,'viremPermCanal':CODE_CANAL_MOBIL});
  try {
    final response = await httpwrapper.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(  mapVirem),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
      return Virem.fromJson(jsonResponse);
    } else {
        print('Failed to insert virement entity: ${response.statusCode}');
      return null;
    }
  } catch (e) {
      print('Error during API call: $e');
    return null;
  }

}


}
