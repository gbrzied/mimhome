class NiveauCompte {
  NiveauCompte(
      {this.niveauCompteId,
      this.niveauCompteCode,
      this.niveauCompteDsg,
      this.niveauComptePlafondSolde,
      this.niveauComptePlafondSortie,
      this.niveauCompteInfoLibre,
//     this.niveauPossibleMob
      });

  int? niveauCompteId;
  String? niveauCompteCode;
  String? niveauCompteDsg;
  double? niveauComptePlafondSolde;
  double? niveauComptePlafondSortie;
  String? niveauCompteInfoLibre;
//  bool? niveauPossibleMob;

  factory NiveauCompte.fromJson(Map<String, dynamic> json) => NiveauCompte(
        niveauCompteId: json["niveauCompteId"] == null ? null : json["niveauCompteId"],
        niveauCompteCode: json["niveauCompteCode"] == null ? null : json["niveauCompteCode"],
        niveauCompteDsg: json["niveauCompteDsg"] == null ? null : json["niveauCompteDsg"],
        niveauComptePlafondSolde: json["niveauComptePlafondSolde"] == null ? null : json["niveauComptePlafondSolde"],
        niveauComptePlafondSortie: json["niveauComptePlafondSortie"] == null ? null : json["niveauComptePlafondSortie"],
        niveauCompteInfoLibre: json["niveauCompteInfoLibre"] == null ? null : json["niveauCompteInfoLibre"],
    //    niveauPossibleMob: json["niveauPossibleMob"] == null ? null : json["niveauPossibleMob"],
      );

  Map<String, dynamic> toJson() => {
        "niveauCompteId": niveauCompteId == null ? null : niveauCompteId,
        "niveauCompteCode": niveauCompteCode == null ? null : niveauCompteCode,
        "niveauCompteDsg": niveauCompteDsg == null ? null : niveauCompteDsg,
        "niveauComptePlafondSolde": niveauComptePlafondSolde == null ? null : niveauComptePlafondSolde,
        "niveauComptePlafondSortie": niveauComptePlafondSortie == null ? null : niveauComptePlafondSortie,
        "niveauCompteInfoLibre": niveauCompteInfoLibre == null ? null : niveauCompteInfoLibre,
     //   "niveauPossibleMob": niveauPossibleMob == null ? null : niveauPossibleMob,
      };
}