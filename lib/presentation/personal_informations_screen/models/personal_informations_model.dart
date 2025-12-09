// ignore_for_file: must_be_immutable
class PersonalInformationsModel {
  PersonalInformationsModel({
    this.nom,
    this.prenom,
    this.dateNaissance,
    this.adresse,
    this.numeroTelephone,
    this.email,
    this.typeCompte,
  }) {
    nom = nom ?? '';
    prenom = prenom ?? '';
    dateNaissance = dateNaissance ?? '';
    adresse = adresse ?? '';
    numeroTelephone = numeroTelephone ?? '';
    email = email ?? '';
    typeCompte = typeCompte ?? AccountType.titulaireEtSignataire;
  }

  String? nom;
  String? prenom;
  String? dateNaissance;
  String? adresse;
  String? numeroTelephone;
  String? email;
  AccountType? typeCompte;
}

enum AccountType {
  titulaire,
  titulaireEtSignataire,
}