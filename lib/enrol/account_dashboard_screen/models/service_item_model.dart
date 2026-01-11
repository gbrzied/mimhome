/// This class is used for service items in the services section.

class ServiceItemModel {
  ServiceItemModel({
    this.icon,
    this.title,
    this.id,
  }) {
    icon = icon ?? "";
    title = title ?? "";
    id = id ?? "";
  }

  String? icon;
  String? title;
  String? id;
}
