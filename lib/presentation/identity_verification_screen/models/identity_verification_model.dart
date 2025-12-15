// ignore_for_file: must_be_immutable

// Constants for document management (temporary - will be moved to config later)
const String DEFAULT_ACCOUNT_LEVEL = 'Niveau1'; // Niveau1 or Niveau2
const bool DEFAULT_IS_PHYSICAL_PERSON = true; // true for physical person, false for legal entity
const bool DEFAULT_SIGNATAIRE_TITULAIRE = true; // true if signer and holder are the same person

class IdentityVerificationModel {
  IdentityVerificationModel({
    this.showCard = false,
    this.docManquants = const [],
    this.tituimages = const [],
    this.enableDocButton = const {},
    this.pieceIdVerifiee = false,
    this.cinr,
    this.disableCINR = true,
    this.disableCINV = true,
    this.disableSELFIE = true,
    this.disablePreuveDeVie = true,
    this.isProcessingImage = false,
    this.processingMessage = '',
    this.processingDocumentIndex = -1,
    this.accountLevel = DEFAULT_ACCOUNT_LEVEL,
    this.isPhysicalPerson = DEFAULT_IS_PHYSICAL_PERSON,
    this.signataireEtTitulaire = DEFAULT_SIGNATAIRE_TITULAIRE,
    this.tituImages,
    this.docManquantsTitu,
    this.enableDocButtonTitu,
    this.mandImages,
    this.docManquantsMand,
    this.enableDocButtonMand,
    this.backendError = false,
    this.backendErrorMessage = '',
    this.documentsRequis,
  }) {
    showCard = showCard ?? false;
    docManquants = docManquants ?? [];
    tituimages = tituimages ?? [];
    enableDocButton = enableDocButton ?? {};
    pieceIdVerifiee = pieceIdVerifiee ?? false;
    disableCINR = disableCINR ?? true;
    disableCINV = disableCINV ?? true;
    disableSELFIE = disableSELFIE ?? true;
    disablePreuveDeVie = disablePreuveDeVie ?? true;
    isProcessingImage = isProcessingImage ?? false;
    processingMessage = processingMessage ?? '';
    processingDocumentIndex = processingDocumentIndex ?? -1;
    accountLevel = accountLevel ?? DEFAULT_ACCOUNT_LEVEL;
    isPhysicalPerson = isPhysicalPerson ?? DEFAULT_IS_PHYSICAL_PERSON;
    signataireEtTitulaire = signataireEtTitulaire ?? DEFAULT_SIGNATAIRE_TITULAIRE;
    tituImages = tituImages ?? [];
    docManquantsTitu = docManquantsTitu ?? [];
    enableDocButtonTitu = enableDocButtonTitu ?? {};
    mandImages = mandImages ?? [];
    docManquantsMand = docManquantsMand ?? [];
    enableDocButtonMand = enableDocButtonMand ?? {};
    backendError = backendError ?? false;
    backendErrorMessage = backendErrorMessage ?? '';
    documentsRequis = documentsRequis ?? [];
  }

  bool? showCard;
  List<String>? docManquants;
  List<String?>? tituimages;
  Map<String, bool>? enableDocButton;
  bool? pieceIdVerifiee;
  String? cinr;
  bool? disableCINR;
  bool? disableCINV;
  bool? disableSELFIE;
  bool? disablePreuveDeVie;
  bool? isProcessingImage;
  String? processingMessage;
  int? processingDocumentIndex;

  // Enhanced document management fields (from wallet11_page.dart)
  String? accountLevel;
  bool? isPhysicalPerson;
  bool? signataireEtTitulaire;

  // Titular documents (main person)
  List<String?>? tituImages;
  List<String>? docManquantsTitu;
  Map<String, bool>? enableDocButtonTitu;

  // Mandatory documents (if different person)
  List<String?>? mandImages;
  List<String>? docManquantsMand;
  Map<String, bool>? enableDocButtonMand;

  // Backend connectivity status
  bool? backendError;
  String? backendErrorMessage;

  // Document management
  List<DocumentRequis>? documentsRequis;
}

// DocumentRequis model to represent required documents from backend
class DocumentRequis {
  final String? docInCode;
  final String? docInLibelle;
  final bool? obligatoire;
  final String? docInBoolTypePieceIdent;
  final PieceIdentite? pieceIdentite;

  DocumentRequis({
    this.docInCode,
    this.docInLibelle,
    this.obligatoire = false,
    this.docInBoolTypePieceIdent,
    this.pieceIdentite,
  });

  factory DocumentRequis.fromJson(Map<String, dynamic> json) {
    return DocumentRequis(
      docInCode: json['docInCode'] as String?,
      docInLibelle: json['docInLibelle'] as String?,
      obligatoire: json['obligatoire'] as bool? ?? false,
      docInBoolTypePieceIdent: json['docInBoolTypePieceIdent'] as String?,
      pieceIdentite: json['pieceIdentite'] != null ? PieceIdentite.fromJson(json['pieceIdentite']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docInCode': docInCode,
      'docInLibelle': docInLibelle,
      'obligatoire': obligatoire,
      'docInBoolTypePieceIdent': docInBoolTypePieceIdent,
      'pieceIdentite': pieceIdentite?.toJson(),
    };
  }

  @override
  String toString() {
    return 'DocumentRequis(docInCode: $docInCode, docInLibelle: $docInLibelle, obligatoire: $obligatoire, docInBoolTypePieceIdent: $docInBoolTypePieceIdent, pieceIdentite: $pieceIdentite)';
  }
}

// PieceIdentite model to represent identification piece information
class PieceIdentite {
  final String? pieceIdentiteCode;
  final String? pieceIdentiteLibelle;

  PieceIdentite({
    this.pieceIdentiteCode,
    this.pieceIdentiteLibelle,
  });

  factory PieceIdentite.fromJson(Map<String, dynamic> json) {
    return PieceIdentite(
      pieceIdentiteCode: json['pieceIdentiteCode'] as String?,
      pieceIdentiteLibelle: json['pieceIdentiteLibelle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pieceIdentiteCode': pieceIdentiteCode,
      'pieceIdentiteLibelle': pieceIdentiteLibelle,
    };
  }

  @override
  String toString() {
    return 'PieceIdentite(pieceIdentiteCode: $pieceIdentiteCode, pieceIdentiteLibelle: $pieceIdentiteLibelle)';
  }
}