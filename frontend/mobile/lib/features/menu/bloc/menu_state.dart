import 'package:equatable/equatable.dart';
import '../data/models/menu_models.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {
  const MenuInitial();
}

class MenuLoading extends MenuState {
  const MenuLoading();
}

class MenuLoaded extends MenuState {
  final List<MenuCategory> categories;
  final String? selectedCategory;

  const MenuLoaded({
    required this.categories,
    this.selectedCategory,
  });

  MenuLoaded copyWith({
    List<MenuCategory>? categories,
    String? selectedCategory,
  }) {
    return MenuLoaded(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [categories, selectedCategory];
}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}
