import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../data/models/menu_models.dart';
import '../data/repositories/menu_repository.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository _menuRepository;

  MenuBloc(this._menuRepository) : super(const MenuInitial()) {
    on<LoadMenu>(_onLoadMenu);
    on<SelectCategory>(_onSelectCategory);
  }

  Future<void> _onLoadMenu(
    LoadMenu event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
    try {
      final items = await _menuRepository.getMenuItems(event.vendorId);

      // Group items by category
      final categoryMap = <String, List<MenuItem>>{};
      for (final item in items) {
        categoryMap.putIfAbsent(item.category, () => []).add(item);
      }

      final categories = categoryMap.entries
          .map((e) => MenuCategory(name: e.key, items: e.value))
          .toList();

      final firstCategory = categories.isNotEmpty ? categories.first.name : null;

      emit(MenuLoaded(categories: categories, selectedCategory: firstCategory));
    } on ApiException catch (e) {
      emit(MenuError(e.message));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  void _onSelectCategory(
    SelectCategory event,
    Emitter<MenuState> emit,
  ) {
    final current = state;
    if (current is MenuLoaded) {
      emit(current.copyWith(selectedCategory: event.category));
    }
  }
}
