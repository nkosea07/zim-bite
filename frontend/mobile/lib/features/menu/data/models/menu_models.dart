import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_models.freezed.dart';
part 'menu_models.g.dart';

@freezed
class MenuItem with _$MenuItem {
  const factory MenuItem({
    required String id,
    required String vendorId,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String category,
    int? calories,
    @Default(true) bool isAvailable,
  }) = _MenuItem;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
}

@freezed
class MenuCategory with _$MenuCategory {
  const factory MenuCategory({
    required String name,
    required List<MenuItem> items,
  }) = _MenuCategory;

  factory MenuCategory.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoryFromJson(json);
}
