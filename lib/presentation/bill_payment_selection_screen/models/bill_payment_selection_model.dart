/// This class is used in the [BillPaymentSelectionScreen] screen.

// ignore_for_file: must_be_immutable
class BillPaymentSelectionModel {
  BillPaymentSelectionModel({this.billOptions}) {
    billOptions = billOptions ?? [];
  }

  List<BillOptionModel>? billOptions;
}

// ignore_for_file: must_be_immutable
class BillOptionModel {
  BillOptionModel({
    this.type,
    this.title,
    this.description,
    this.icon,
    this.iconWidth,
    this.iconHeight,
  }) {
    type = type ?? "";
    title = title ?? "";
    description = description ?? "";
    icon = icon ?? "";
    iconWidth = iconWidth ?? 0;
    iconHeight = iconHeight ?? 0;
  }

  String? type;
  String? title;
  String? description;
  String? icon;
  int? iconWidth;
  int? iconHeight;
}
