import 'package:cl_components/utils/models/pageaction.model.dart';

class BreadcrumbItem {
  final String name;
  final String path;
  final bool isModule;
  final bool isClickable;
  List<PageAction> pageActions = [];

  BreadcrumbItem({required this.name, required this.path, required this.isModule, this.isClickable = true});

  // Metodo per serializzare l'oggetto in JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'path': path, 'isModule': isModule, 'isClickable': isClickable};
  }

  // Metodo per creare un oggetto da una mappa JSON
  factory BreadcrumbItem.fromJson(Map<String, dynamic> json) {
    return BreadcrumbItem(
      name: json['name'],
      path: json['path'],
      isModule: json['isModule'],
      isClickable: json['isClickable'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BreadcrumbItem) return false;
    return other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}
