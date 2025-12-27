// w_dem_ouv_compte_mand_id
// w_dem_ouv_compte_mand_bool
// w_dem_ouv_compte_mand_emis_date
// w_mand_pp_naissance_date
// w_mand_pp_nom
// w_mand_pp_piece_identite_code
// w_mand_pp_piece_identite_no
// w_mand_pp_prenom

import 'NiveauCompte.dart';

class DemOuvNewCompteNewMand {
  late int? demOuvCompteMandId;
  bool? demOuvCompteMandBool;
  DateTime? demOuvCompteMandEmisDate;
  String? demOuvCompteMandInfoLibre;

  String? tituPpPieceIdentiteCode;
  String? tituPpPieceIdentiteNo;
  DateTime? tituPpPieceIdentiteDelivDate;
  String? tituPpPieceIdentiteDelivLieu;
  DateTime? tituPpPieceIdentiteExpireDate;
  String? tituPpPieceIdentiteAutorite;

  String? tituPpNom;
  String? tituPpPrenom;
  String? tituPpAlias;
  DateTime? tituPpNaissanceDate;
  String? tituPpNaissanceLieu;
  String? tituPpNationaliteCodeNum;
  String? tituPpProfessionCode;
  String? tituPpGenre;
  String? tituPpAdresse;
  String? tituPpEmail;
  String? tituPpTelMobileNo;
  bool? tituPpBoolTun;
  bool? tituPpBoolResident;

  ////////////////08 juin 22
  ///17 avril 2024

  bool?   tituPpBoolFatca;
  bool?   tituPpBoolVip;

  bool?   tituPpBoolExemptRS;
  bool?   tituPpBoolExemptTva;
  bool?   tituPpBoolPep;

  bool? tituPpBoolHandicap;
  String? tituPpMotifHandicap;
  String? tituPpInfoLibre;

  String? tituPmPieceIdentiteCode;
  String? tituPmPieceIdentiteNo;
  DateTime? tituPmPieceIdentiteDelivDate;
  String? tituPmPieceIdentiteDelivLieu;
  String? tituPmPieceIdentiteAutorite;
  DateTime? tituPmPieceIdentiteExpireDate;
  String? tituPmRaisonSociale;
  String? tituPmSigle;
  DateTime? tituPmCreationDate;
  String? tituPmCreationLieu;
  String? tituPmNationaliteCodeNum;
  String? tituPmFormeJuridiqueCode;
  String? tituPmActiviteCode;
  String? tituPmSituationJudiciaireCode;
  String? tituPmAdresse;
  String? tituPmEmail;
  String? tituPmTelNo;
  bool? tituPmBoolTun;
  bool? tituPmBoolResident;
  String? tituPmInfoLibre;

  String? mandPpPieceIdentiteCode;
  String? mandPpPieceIdentiteNo;
  DateTime? mandPpPieceIdentiteDelivDate;
  String? mandPpPieceIdentiteDelivLieu;
  String? mandPpPieceIdentiteAutorite;
  DateTime? mandPpPieceIdentiteExpireDate;
  String? mandPpNom;
  String? mandPpPrenom;
  String? mandPpAlias;
  DateTime? mandPpNaissanceDate;
  String? mandPpNaissanceLieu;
  String? mandPpNationaliteCodeNum;
  String? mandPpTelMobileNo;
  String? mandPpProfessionCode;
  String? mandPpGenre;
  String? mandPpAdresse;
  String? mandPpEmail;
  bool? mandPpBoolTun;
  bool? mandPpBoolResiden;

  StatutDemande? statutDemandeOuvCompte;

  // statutDemandeOuvCompte: StatutDemandeOuvCompte
  // uniteGestion: UniteGestion
  // niveauCompte: NiveauCompte
  // modeOuvCompte: ModeOuvCompte
  NiveauCompte? niveauCompte;
  // String? telMobileRecup;

  String? walletNoTelGestion;
  String? walletEmailGestion;
  String? demNewCompteNewMandGesSecours;
  String? demNewCompteNewMandEmailSecours;
  String? params;


  // demOuvCompteMandDocs:      DemOuvCompteMandDoc[]
  // String? SysUser;
  // String? SysAction;
  // String? SysDate;

  DemOuvNewCompteNewMand(
      {this.niveauCompte,
      this.statutDemandeOuvCompte,
      this.demOuvCompteMandId,
      this.demOuvCompteMandBool,
      this.demOuvCompteMandEmisDate,
      this.demOuvCompteMandInfoLibre,
      this.tituPpPieceIdentiteCode,
      this.tituPpPieceIdentiteNo,
      this.tituPpPieceIdentiteDelivDate,
      this.tituPpPieceIdentiteDelivLieu,
      this.tituPpPieceIdentiteExpireDate,
      this.tituPpPieceIdentiteAutorite,
      this.tituPpNom,
      this.tituPpPrenom,
      this.tituPpAlias,
      this.tituPpNaissanceDate,
      this.tituPpNaissanceLieu,
      this.tituPpNationaliteCodeNum,
      this.tituPpProfessionCode,
      this.tituPpGenre,
      this.tituPpAdresse,
      this.tituPpEmail,
      this.tituPpTelMobileNo,
      this.tituPpBoolTun,
      this.tituPpBoolResident,
      this.tituPpBoolVip,
      this.tituPpBoolFatca,

      this.tituPpBoolExemptRS,
      this.tituPpBoolExemptTva,
      this.tituPpBoolPep,

      this.tituPpBoolHandicap,
      this.tituPpMotifHandicap,
      this.tituPpInfoLibre,
      this.tituPmPieceIdentiteCode,
      this.tituPmPieceIdentiteNo,
      this.tituPmPieceIdentiteDelivDate,
      this.tituPmPieceIdentiteDelivLieu,
      this.tituPmPieceIdentiteAutorite,
      this.tituPmPieceIdentiteExpireDate,
      this.tituPmRaisonSociale,
      this.tituPmSigle,
      this.tituPmCreationDate,
      this.tituPmCreationLieu,
      this.tituPmNationaliteCodeNum,
      this.tituPmFormeJuridiqueCode,
      this.tituPmActiviteCode,
      this.tituPmSituationJudiciaireCode,
      this.tituPmAdresse,
      this.tituPmEmail,
      this.tituPmTelNo,
      this.tituPmBoolTun,
      this.tituPmBoolResident,
      this.tituPmInfoLibre,
      this.mandPpPieceIdentiteCode,
      this.mandPpPieceIdentiteNo,
      this.mandPpPieceIdentiteDelivDate,
      this.mandPpPieceIdentiteDelivLieu,
      this.mandPpPieceIdentiteAutorite,
      this.mandPpPieceIdentiteExpireDate,
      this.mandPpNom,
      this.mandPpPrenom,
      this.mandPpAlias,
      this.mandPpNaissanceDate,
      this.mandPpNaissanceLieu,
      this.mandPpNationaliteCodeNum,
      this.mandPpTelMobileNo,
      this.mandPpProfessionCode,
      this.mandPpGenre,
      this.mandPpAdresse,
      this.mandPpEmail,
      this.mandPpBoolTun,
      this.mandPpBoolResiden,
      this.walletNoTelGestion,
      this.walletEmailGestion,
      this.demNewCompteNewMandGesSecours,
      this.demNewCompteNewMandEmailSecours,
      this.params


      });

  factory DemOuvNewCompteNewMand.fromJson(Map<String, dynamic> json) {
    return DemOuvNewCompteNewMand(
      statutDemandeOuvCompte:
          json["statutDemandeOuvCompte"] == null ? null : StatutDemande.fromJson(json["statutDemandeOuvCompte"]),
      niveauCompte: json["niveauCompte"] == null ? null : NiveauCompte.fromJson(json["niveauCompte"]),
      demOuvCompteMandId: json['demOuvCompteMandId'],
      demOuvCompteMandBool: json['demOuvCompteMandBool'],
      demOuvCompteMandEmisDate: DateTime.parse(json['demOuvCompteMandEmisDate']),
      demOuvCompteMandInfoLibre: json['demOuvCompteMandInfoLibre'],
      tituPpPieceIdentiteCode: json['tituPpPieceIdentiteCode'],
      tituPpPieceIdentiteNo: json['tituPpPieceIdentiteNo'],
      tituPpPieceIdentiteDelivDate:
          (json['tituPpPieceIdentiteDelivDate'] == null) ? null : DateTime.parse(json['tituPpPieceIdentiteDelivDate']),
      tituPpPieceIdentiteDelivLieu: json['tituPpPieceIdentiteDelivLieu'],
      tituPpPieceIdentiteExpireDate:
          (json['tituPpPieceIdentiteExpireDate'] == null) ? null : DateTime.parse(json['tituPpPieceIdentiteExpireDate']),
      tituPpPieceIdentiteAutorite: json['tituPpPieceIdentiteAutorite'],
      tituPpNom: json['tituPpNom'],
      tituPpPrenom: json['tituPpPrenom'],
      tituPpAlias: json['tituPpAlias'],
      tituPpNaissanceDate: (json['tituPpNaissanceDate'] == null) ? null : DateTime.parse(json['tituPpNaissanceDate']),
      tituPpNaissanceLieu: json['tituPpNaissanceLieu'],
      tituPpNationaliteCodeNum: json['tituPpNationaliteCodeNum'],
      tituPpProfessionCode: json['tituPpProfessionCode'],
      tituPpGenre: json['tituPpGenre'],
      tituPpAdresse: json['tituPpAdresse'],
      tituPpEmail: json['tituPpEmail'],
      tituPpTelMobileNo: json['tituPpTelMobileNo'],
      tituPpBoolTun: json['tituPpBoolTun'],
      tituPpBoolResident: json['tituPpBoolResident'],
      tituPpBoolHandicap: json['tituPpBoolHandicap'],
      tituPpMotifHandicap: json['tituPpMotifHandicap'],
      tituPpInfoLibre: json['tituPpInfoLibre'],
      tituPmPieceIdentiteCode: json['tituPmPieceIdentiteCode'],
      tituPmPieceIdentiteNo: json['tituPmPieceIdentiteNo'],
      tituPmPieceIdentiteDelivDate:
          (json['tituPmPieceIdentiteDelivDate'] == null) ? null : DateTime.parse(json['tituPmPieceIdentiteDelivDate']),
      tituPmPieceIdentiteDelivLieu: json['tituPmPieceIdentiteDelivLieu'],
      tituPmPieceIdentiteAutorite: json['tituPmPieceIdentiteAutorite'],
      tituPmPieceIdentiteExpireDate:
          (json['tituPmPieceIdentiteExpireDate'] == null) ? null : DateTime.parse(json['tituPmPieceIdentiteExpireDate']),
      tituPmRaisonSociale: json['tituPmRaisonSociale'],
      tituPmSigle: json['tituPmSigle'],
      tituPmCreationDate: (json['tituPmCreationDate'] == null) ? null : DateTime.parse(json['tituPmCreationDate']),
      tituPmCreationLieu: json['tituPmCreationLieu'],
      tituPmNationaliteCodeNum: json['tituPmNationaliteCodeNum'],
      tituPmFormeJuridiqueCode: json['tituPmFormeJuridiqueCode'],
      tituPmActiviteCode: json['tituPmActiviteCode'],
      tituPmSituationJudiciaireCode: json['tituPmSituationJudiciaireCode'],
      tituPmAdresse: json['tituPmAdresse'],
      tituPmEmail: json['tituPmEmail'],
      tituPmTelNo: json['tituPmTelNo'],
      tituPmBoolTun: json['tituPmBoolTun'],
      tituPmBoolResident: json['tituPmBoolResident'],
      tituPmInfoLibre: json['tituPmInfoLibre'],
      mandPpPieceIdentiteCode: json['mandPpPieceIdentiteCode'],
      mandPpPieceIdentiteNo: json['mandPpPieceIdentiteNo'],
      mandPpPieceIdentiteDelivDate:
          (json['mandPpPieceIdentiteDelivDate'] == null) ? null : DateTime.parse(json['mandPpPieceIdentiteDelivDate']),
      mandPpPieceIdentiteDelivLieu: json['mandPpPieceIdentiteDelivLieu'],
      mandPpPieceIdentiteAutorite: json['mandPpPieceIdentiteAutorite'],
      mandPpPieceIdentiteExpireDate:
          (json['mandPpPieceIdentiteExpireDate'] == null) ? null : DateTime.parse(json['mandPpPieceIdentiteExpireDate']),
      mandPpNom: json['mandPpNom'],
      mandPpPrenom: json['mandPpPrenom'],
      mandPpAlias: json['mandPpAlias'],
      mandPpNaissanceDate: (json['mandPpNaissanceDate'] == null) ? null : DateTime.parse(json['mandPpNaissanceDate']),
      mandPpNaissanceLieu: json['mandPpNaissanceLieu'],
      mandPpNationaliteCodeNum: json['mandPpNationaliteCodeNum'],
      mandPpTelMobileNo: json['mandPpTelMobileNo'],
      mandPpProfessionCode: json['mandPpProfessionCode'],
      mandPpGenre: json['mandPpGenre'],
      mandPpAdresse: json['mandPpAdresse'],
      mandPpEmail: json['mandPpEmail'],
      mandPpBoolTun: json['mandPpBoolTun'],
      mandPpBoolResiden: json['mandPpBoolResiden'],
      walletNoTelGestion: json['walletNoTelGestion'],
      walletEmailGestion: json['walletEmailGestion'],
      demNewCompteNewMandGesSecours: json['demNewCompteNewMandGesSecours'],
      demNewCompteNewMandEmailSecours: json['demNewCompteNewMandEmailSecours'],
      params: json['params'],

    );
  }
}

class StatutDemande {
  StatutDemande({
    this.statutDemandeId,
    this.statutDemandeCode,
    this.statutDemandeDsg,
  });

  int? statutDemandeId;
  String? statutDemandeCode;
  String? statutDemandeDsg;
  factory StatutDemande.fromJson(Map<String, dynamic> json) => StatutDemande(
        statutDemandeId: json["statutDemandeId"] == null ? null : json["statutDemandeId"],
        statutDemandeCode: json["statutDemandeCode"] == null ? null : json["statutDemandeCode"],
        statutDemandeDsg: json["statutDemandeDsg"] == null ? null : json["statutDemandeDsg"],
      );

  Map<String, dynamic> toJson() => {
        "statutDemandeId": statutDemandeId == null ? null : statutDemandeId,
        "statutDemandeCode": statutDemandeCode == null ? null : statutDemandeCode,
        "statutDemandeDsg": statutDemandeDsg == null ? null : statutDemandeDsg,
      };
}