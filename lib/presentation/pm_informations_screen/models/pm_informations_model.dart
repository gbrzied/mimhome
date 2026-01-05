// ignore_for_file: must_be_immutable
class PmInformationsModel {
  PmInformationsModel({
    this.raisonSociale,
    //this.prenom,
    this.dateCreation,
    this.adresse,
    this.numeroTelephone,
    this.email,
    this.typePiece,
    this.numeroPiece,
    //this.typeCompte,
    this.isPhysicalPerson,
  }) {
    raisonSociale = raisonSociale ?? '';
   // prenom = prenom ?? '';
    dateCreation = dateCreation ?? '';
    adresse = adresse ?? '';
    numeroTelephone = numeroTelephone ?? '';
    email = email ?? '';
    typePiece = typePiece ?? '';
    numeroPiece = numeroPiece ?? '';
   // typeCompte = typeCompte ?? AccountType.titulaireEtSignataire;
    isPhysicalPerson = isPhysicalPerson ?? true;
  }

  String? raisonSociale;
 // String? prenom;
  String? dateCreation;
  String? adresse;
  String? numeroTelephone;
  String? email;
  String? typePiece;
  String? numeroPiece;
  //AccountType? typeCompte;
  bool? isPhysicalPerson;
}

// enum AccountType {
//   titulaire,
//   titulaireEtSignataire,
// }