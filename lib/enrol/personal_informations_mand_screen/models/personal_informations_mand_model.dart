// ignore_for_file: must_be_immutable
class PersonalInformationsMandModel {
  PersonalInformationsMandModel({
    this.nom,
    this.prenom,
    this.dateNaissance,
    this.adresse,
    this.numeroTelephone,
    this.email,
    this.typePiece,
    this.numeroPiece,
    this.typeCompte,
    this.isPhysicalPerson,
  }) {
    nom = nom ?? '';
    prenom = prenom ?? '';
    dateNaissance = dateNaissance ?? '';
    adresse = adresse ?? '';
    numeroTelephone = numeroTelephone ?? '';
    email = email ?? '';
    typePiece = typePiece ?? '';
    numeroPiece = numeroPiece ?? '';
    typeCompte = typeCompte ?? AccountType.titulaireEtSignataire;
    isPhysicalPerson = isPhysicalPerson ?? true;
  }

  String? nom;
  String? prenom;
  String? dateNaissance;
  String? adresse;
  String? numeroTelephone;
  String? email;
  String? typePiece;
  String? numeroPiece;
  AccountType? typeCompte;
  bool? isPhysicalPerson;
}

enum AccountType {
  titulaire,
  titulaireEtSignataire,
}