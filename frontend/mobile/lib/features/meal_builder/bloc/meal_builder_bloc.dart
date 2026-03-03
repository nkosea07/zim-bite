import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cart/bloc/cart_bloc.dart';
import '../../cart/bloc/cart_event.dart';
import '../../cart/data/models/cart_models.dart';
import '../data/models/meal_builder_models.dart';
import '../data/repositories/meal_builder_repository.dart';

// ── Constants ─────────────────────────────────────────

const int _maxMeals = 5;
const int _maxPerComponent = 10;
const int _maxItemsPerMeal = 15;

// ── Events ────────────────────────────────────────────

abstract class MealBuilderEvent extends Equatable {
  const MealBuilderEvent();

  @override
  List<Object?> get props => [];
}

class LoadComponents extends MealBuilderEvent {
  const LoadComponents();
}

class ToggleMode extends MealBuilderEvent {
  const ToggleMode();
}

class AddMeal extends MealBuilderEvent {
  const AddMeal();
}

class RemoveMeal extends MealBuilderEvent {
  final int index;
  const RemoveMeal(this.index);

  @override
  List<Object?> get props => [index];
}

class SwitchActiveMeal extends MealBuilderEvent {
  final int index;
  const SwitchActiveMeal(this.index);

  @override
  List<Object?> get props => [index];
}

class IncrementComponent extends MealBuilderEvent {
  final String componentId;
  const IncrementComponent(this.componentId);

  @override
  List<Object?> get props => [componentId];
}

class DecrementComponent extends MealBuilderEvent {
  final String componentId;
  const DecrementComponent(this.componentId);

  @override
  List<Object?> get props => [componentId];
}

class DropOnPlate extends MealBuilderEvent {
  final String componentId;
  final double plateX;
  final double plateY;
  const DropOnPlate(this.componentId, this.plateX, this.plateY);

  @override
  List<Object?> get props => [componentId, plateX, plateY];
}

class RemoveFromPlate extends MealBuilderEvent {
  final String componentId;
  const RemoveFromPlate(this.componentId);

  @override
  List<Object?> get props => [componentId];
}

class RenameMeal extends MealBuilderEvent {
  final int index;
  final String label;
  const RenameMeal(this.index, this.label);

  @override
  List<Object?> get props => [index, label];
}

class AddAllMealsToCart extends MealBuilderEvent {
  const AddAllMealsToCart();
}

// ── States ────────────────────────────────────────────

abstract class MealBuilderState extends Equatable {
  const MealBuilderState();

  @override
  List<Object?> get props => [];
}

class MealBuilderInitial extends MealBuilderState {
  const MealBuilderInitial();
}

class MealBuilderLoading extends MealBuilderState {
  const MealBuilderLoading();
}

class MealBuilderLoaded extends MealBuilderState {
  final List<MealComponent> catalog;
  final List<MealDraft> meals;
  final int activeMealIndex;
  final bool isDragMode;

  const MealBuilderLoaded({
    required this.catalog,
    required this.meals,
    required this.activeMealIndex,
    this.isDragMode = false,
  });

  MealDraft get activeMeal => meals[activeMealIndex];

  int get totalQty => activeMeal.ingredients.fold(0, (s, i) => s + i.quantity);

  MealBuilderLoaded copyWith({
    List<MealComponent>? catalog,
    List<MealDraft>? meals,
    int? activeMealIndex,
    bool? isDragMode,
  }) {
    return MealBuilderLoaded(
      catalog: catalog ?? this.catalog,
      meals: meals ?? this.meals,
      activeMealIndex: activeMealIndex ?? this.activeMealIndex,
      isDragMode: isDragMode ?? this.isDragMode,
    );
  }

  @override
  List<Object?> get props => [catalog, meals, activeMealIndex, isDragMode];
}

class MealBuilderError extends MealBuilderState {
  final String message;
  const MealBuilderError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────

class MealBuilderBloc extends Bloc<MealBuilderEvent, MealBuilderState> {
  final MealBuilderRepository _repository;
  final CartBloc _cartBloc;
  int _mealCounter = 0;

  MealBuilderBloc({
    required MealBuilderRepository repository,
    required CartBloc cartBloc,
  })  : _repository = repository,
        _cartBloc = cartBloc,
        super(const MealBuilderInitial()) {
    on<LoadComponents>(_onLoadComponents);
    on<ToggleMode>(_onToggleMode);
    on<AddMeal>(_onAddMeal);
    on<RemoveMeal>(_onRemoveMeal);
    on<SwitchActiveMeal>(_onSwitchActiveMeal);
    on<IncrementComponent>(_onIncrement);
    on<DecrementComponent>(_onDecrement);
    on<DropOnPlate>(_onDropOnPlate);
    on<RemoveFromPlate>(_onRemoveFromPlate);
    on<RenameMeal>(_onRenameMeal);
    on<AddAllMealsToCart>(_onAddAllMealsToCart);
  }

  MealDraft _createEmptyMeal() {
    _mealCounter++;
    return MealDraft(
      id: 'meal-${DateTime.now().millisecondsSinceEpoch}-$_mealCounter',
      label: 'Meal $_mealCounter',
    );
  }

  MealDraft _recalcMeal(MealDraft meal) {
    double price = 0;
    int calories = 0;
    int totalQty = 0;
    for (final ing in meal.ingredients) {
      price += ing.price * ing.quantity;
      calories += ing.calories * ing.quantity;
      totalQty += ing.quantity;
    }
    return meal.copyWith(
      totalPrice: double.parse(price.toStringAsFixed(2)),
      totalCalories: calories,
      available: totalQty <= _maxItemsPerMeal,
    );
  }

  /// Golden-angle placement to avoid overlap
  ({double x, double y}) _platePosition(int index, int total) {
    if (total == 1) return (x: 0.5, y: 0.5);
    const goldenAngle = 137.508 * pi / 180;
    final angle = index * goldenAngle;
    final r = sqrt((index + 1) / (total + 1)) * 0.32;
    return (x: 0.5 + r * cos(angle), y: 0.5 + r * sin(angle));
  }

  Future<void> _onLoadComponents(
    LoadComponents event,
    Emitter<MealBuilderState> emit,
  ) async {
    emit(const MealBuilderLoading());
    try {
      // Try loading from API; fall back to static data
      List<MealComponent> catalog;
      try {
        await _repository.getPresets();
        catalog = _staticCatalog();
      } catch (_) {
        catalog = _staticCatalog();
      }
      emit(MealBuilderLoaded(
        catalog: catalog,
        meals: [_createEmptyMeal()],
        activeMealIndex: 0,
      ));
    } catch (e) {
      emit(MealBuilderError(e.toString()));
    }
  }

  void _onToggleMode(ToggleMode event, Emitter<MealBuilderState> emit) {
    final s = state;
    if (s is! MealBuilderLoaded) return;
    emit(s.copyWith(isDragMode: !s.isDragMode));
  }

  void _onAddMeal(AddMeal event, Emitter<MealBuilderState> emit) {
    final s = state;
    if (s is! MealBuilderLoaded) return;
    if (s.meals.length >= _maxMeals) return;
    final newMeals = [...s.meals, _createEmptyMeal()];
    emit(s.copyWith(meals: newMeals, activeMealIndex: newMeals.length - 1));
  }

  void _onRemoveMeal(RemoveMeal event, Emitter<MealBuilderState> emit) {
    final s = state;
    if (s is! MealBuilderLoaded) return;
    if (s.meals.length <= 1) return;
    final newMeals = [...s.meals]..removeAt(event.index);
    int newIndex = s.activeMealIndex;
    if (newIndex >= event.index && newIndex > 0) newIndex--;
    emit(s.copyWith(meals: newMeals, activeMealIndex: newIndex));
  }

  void _onSwitchActiveMeal(
    SwitchActiveMeal event,
    Emitter<MealBuilderState> emit,
  ) {
    final s = state;
    if (s is! MealBuilderLoaded) return;
    if (event.index < 0 || event.index >= s.meals.length) return;
    emit(s.copyWith(activeMealIndex: event.index));
  }

  void _onIncrement(
    IncrementComponent event,
    Emitter<MealBuilderState> emit,
  ) {
    final s = state;
    if (s is! MealBuilderLoaded) return;
    final meal = s.activeMeal;
    final ings = List<PlateIngredient>.from(meal.ingredients);
    final idx = ings.indexWhere((i) => i.componentId == event.componentId);

    if (idx >= 0) {
      if (ings[idx].quantity >= _maxPerComponent) return;
      ings[idx] = ings[idx].copyWith(quantity: ings[idx].quantity + 1);
    } else {
      final comp = s.catalog.firstWhere((c) => c.id == event.componentId);
      final pos = _platePosition(ings.length, ings.length + 1);
      ings.add(PlateIngredient(
        componentId: comp.id,
        name: comp.name,
        category: comp.category,
        price: comp.price,
        calories: comp.calories,
        quantity: 1,
        plateX: pos.x,
        plateY: pos.y,
      ));
    }

    final updatedMeal = _recalcMeal(meal.copyWith(ingredients: ings));
    final newMeals = List<MealDraft>.from(s.meals);
    newMeals[s.activeMealIndex] = updatedMeal;
    emit(s.copyWith(meals: newMeals));
  }

  void _onDecrement(
    DecrementComponent event,
    Emitter<MealBuilderState> emit,
  ) {
    final s = state;
    if (s is! MealBuilderLoaded) return;
    final meal = s.activeMeal;
    final ings = List<PlateIngredient>.from(meal.ingredients);
    final idx = ings.indexWhere((i) => i.componentId == event.componentId);
    if (idx < 0) return;

    if (ings[idx].quantity <= 1) {
      ings.removeAt(idx);
    } else {
      ings[idx] = ings[idx].copyWith(quantity: ings[idx].quantity - 1);
    }

    final updatedMeal = _recalcMeal(meal.copyWith(ingredients: ings));
    final newMeals = List<MealDraft>.from(s.meals);
    newMeals[s.activeMealIndex] = updatedMeal;
    emit(s.copyWith(meals: newMeals));
  }

  void _onDropOnPlate(DropOnPlate event, Emitter<MealBuilderState> emit) {
    final s = state;
    if (s is! MealBuilderLoaded) return;
    final meal = s.activeMeal;
    final ings = List<PlateIngredient>.from(meal.ingredients);
    final idx = ings.indexWhere((i) => i.componentId == event.componentId);

    if (idx >= 0) {
      if (ings[idx].quantity >= _maxPerComponent) return;
      ings[idx] = ings[idx].copyWith(
        quantity: ings[idx].quantity + 1,
        plateX: event.plateX,
        plateY: event.plateY,
      );
    } else {
      final comp = s.catalog.firstWhere((c) => c.id == event.componentId);
      ings.add(PlateIngredient(
        componentId: comp.id,
        name: comp.name,
        category: comp.category,
        price: comp.price,
        calories: comp.calories,
        quantity: 1,
        plateX: event.plateX,
        plateY: event.plateY,
      ));
    }

    final updatedMeal = _recalcMeal(meal.copyWith(ingredients: ings));
    final newMeals = List<MealDraft>.from(s.meals);
    newMeals[s.activeMealIndex] = updatedMeal;
    emit(s.copyWith(meals: newMeals));
  }

  void _onRemoveFromPlate(
    RemoveFromPlate event,
    Emitter<MealBuilderState> emit,
  ) {
    final s = state;
    if (s is! MealBuilderLoaded) return;
    final meal = s.activeMeal;
    final ings = meal.ingredients
        .where((i) => i.componentId != event.componentId)
        .toList();

    final updatedMeal = _recalcMeal(meal.copyWith(ingredients: ings));
    final newMeals = List<MealDraft>.from(s.meals);
    newMeals[s.activeMealIndex] = updatedMeal;
    emit(s.copyWith(meals: newMeals));
  }

  void _onRenameMeal(RenameMeal event, Emitter<MealBuilderState> emit) {
    final s = state;
    if (s is! MealBuilderLoaded) return;
    final newMeals = List<MealDraft>.from(s.meals);
    newMeals[event.index] = newMeals[event.index].copyWith(label: event.label);
    emit(s.copyWith(meals: newMeals));
  }

  void _onAddAllMealsToCart(
    AddAllMealsToCart event,
    Emitter<MealBuilderState> emit,
  ) {
    final s = state;
    if (s is! MealBuilderLoaded) return;

    for (final meal in s.meals) {
      if (meal.ingredients.isEmpty) continue;
      final names = meal.ingredients.map((i) => i.name).join(', ');
      _cartBloc.add(AddToCart(CartItem(
        menuItemId: 'custom-${meal.id}',
        name: '${meal.label} ($names)',
        price: meal.totalPrice,
        quantity: 1,
        vendorId: 'meal-builder',
        vendorName: 'Meal Builder',
      )));
    }
  }

  List<MealComponent> _staticCatalog() {
    return const [
      MealComponent(id: 'p1', name: 'Grilled Chicken', category: 'Proteins', price: 4.50, calories: 220, imageUrl: ''),
      MealComponent(id: 'p2', name: 'Beef Strips', category: 'Proteins', price: 5.00, calories: 280, imageUrl: ''),
      MealComponent(id: 'p3', name: 'Boiled Eggs (x2)', category: 'Proteins', price: 1.50, calories: 140, imageUrl: ''),
      MealComponent(id: 'p4', name: 'Fish Fillet', category: 'Proteins', price: 4.00, calories: 190, imageUrl: ''),
      MealComponent(id: 'c1', name: 'Steamed Rice', category: 'Carbs', price: 1.50, calories: 180, imageUrl: ''),
      MealComponent(id: 'c2', name: 'Sadza', category: 'Carbs', price: 1.00, calories: 200, imageUrl: ''),
      MealComponent(id: 'c3', name: 'Bread Roll', category: 'Carbs', price: 0.80, calories: 130, imageUrl: ''),
      MealComponent(id: 'c4', name: 'Sweet Potato', category: 'Carbs', price: 1.20, calories: 110, imageUrl: ''),
      MealComponent(id: 'v1', name: 'Mixed Greens', category: 'Vegetables', price: 1.00, calories: 30, imageUrl: ''),
      MealComponent(id: 'v2', name: 'Roasted Tomatoes', category: 'Vegetables', price: 0.80, calories: 25, imageUrl: ''),
      MealComponent(id: 'v3', name: 'Cucumber & Carrot', category: 'Vegetables', price: 0.80, calories: 20, imageUrl: ''),
      MealComponent(id: 'v4', name: 'Cooked Spinach', category: 'Vegetables', price: 0.90, calories: 35, imageUrl: ''),
      MealComponent(id: 'd1', name: 'Orange Juice', category: 'Drinks', price: 1.50, calories: 110, imageUrl: ''),
      MealComponent(id: 'd2', name: 'Rooibos Tea', category: 'Drinks', price: 0.80, calories: 5, imageUrl: ''),
      MealComponent(id: 'd3', name: 'Mineral Water', category: 'Drinks', price: 0.60, calories: 0, imageUrl: ''),
      MealComponent(id: 'd4', name: 'Mango Smoothie', category: 'Drinks', price: 2.00, calories: 160, imageUrl: ''),
    ];
  }
}
