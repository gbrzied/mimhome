// ignore_for_file: must_be_immutable
class IdentityVerificationModel {
  IdentityVerificationModel({
    this.showCard = false,
  }) {
    showCard = showCard ?? false;
  }

  bool? showCard;
}