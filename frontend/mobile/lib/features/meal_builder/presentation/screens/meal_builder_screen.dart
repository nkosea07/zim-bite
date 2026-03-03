import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/zb_loading.dart';
import '../../../../core/widgets/zb_error_widget.dart';
import '../../../../core/widgets/zb_empty_state.dart';
import '../../../cart/bloc/cart_bloc.dart';
import '../../bloc/meal_builder_bloc.dart';
import '../../data/models/meal_builder_models.dart';
import '../../data/repositories/meal_builder_repository.dart';
import '../widgets/meal_plate_widget.dart';
import '../widgets/draggable_component_card.dart';
import '../widgets/meal_tabs_widget.dart';

class MealBuilderScreen extends StatelessWidget {
  const MealBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MealBuilderBloc(
        repository: context.read<MealBuilderRepository>(),
        cartBloc: context.read<CartBloc>(),
      )..add(const LoadComponents()),
      child: const _MealBuilderView(),
    );
  }
}

class _MealBuilderView extends StatefulWidget {
  const _MealBuilderView();

  @override
  State<_MealBuilderView> createState() => _MealBuilderViewState();
}

class _MealBuilderViewState extends State<_MealBuilderView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _categories = [
    'Proteins',
    'Carbs',
    'Vegetables',
    'Drinks',
  ];

  static const Map<String, String> _categoryEmoji = {
    'Proteins': '🥩',
    'Carbs': '🍚',
    'Vegetables': '🥦',
    'Drinks': '🥤',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MealBuilderBloc, MealBuilderState>(
      listenWhen: (prev, curr) {
        // Navigate to cart after adding all meals
        if (prev is MealBuilderLoaded && curr is MealBuilderLoaded) {
          return false;
        }
        return false;
      },
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: const Text('Meal Builder'),
            elevation: 0,
            actions: [
              if (state is MealBuilderLoaded)
                IconButton(
                  onPressed: () =>
                      context.read<MealBuilderBloc>().add(const ToggleMode()),
                  icon: Icon(
                    state.isDragMode ? Icons.grid_view : Icons.pan_tool_alt,
                    color: AppColors.brandOrange,
                  ),
                  tooltip: state.isDragMode
                      ? 'Switch to Classic'
                      : 'Switch to Drag Mode',
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.brandOrange,
              unselectedLabelColor: AppColors.warmGrey500,
              indicatorColor: AppColors.brandOrange,
              tabs: _categories
                  .map((c) => Tab(text: '${_categoryEmoji[c]} $c'))
                  .toList(),
            ),
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(MealBuilderState state) {
    if (state is MealBuilderLoading || state is MealBuilderInitial) {
      return const ZbLoading(message: 'Loading components...');
    }
    if (state is MealBuilderError) {
      return ZbErrorWidget(
        message: state.message,
        onRetry: () =>
            context.read<MealBuilderBloc>().add(const LoadComponents()),
      );
    }
    if (state is! MealBuilderLoaded) {
      return const ZbEmptyState(
        icon: Icons.lunch_dining,
        title: 'No components available',
      );
    }

    final bloc = context.read<MealBuilderBloc>();
    final activeMeal = state.activeMeal;

    // Build qty map for active meal
    final qtyMap = <String, int>{};
    for (final ing in activeMeal.ingredients) {
      qtyMap[ing.componentId] = ing.quantity;
    }

    return Column(
      children: [
        // Meal tabs
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: MealTabsWidget(
            meals: state.meals,
            activeIndex: state.activeMealIndex,
            onSelect: (i) => bloc.add(SwitchActiveMeal(i)),
            onAdd: () => bloc.add(const AddMeal()),
            onRemove: (i) => bloc.add(RemoveMeal(i)),
            onRename: (i, label) => bloc.add(RenameMeal(i, label)),
          ),
        ),

        // Plate (drag mode only)
        if (state.isDragMode) ...[
          const SizedBox(height: 12),
          MealPlateWidget(
            ingredients: activeMeal.ingredients,
            onRemove: (id) => bloc.add(RemoveFromPlate(id)),
            onAccept: (comp) =>
                bloc.add(DropOnPlate(comp.id, 0.5, 0.5)),
          ),
          const SizedBox(height: 8),
        ],

        // Category grid
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _categories.map((cat) {
              final items =
                  state.catalog.where((c) => c.category == cat).toList();
              return _ComponentGrid(
                items: items,
                qtyMap: qtyMap,
                isDragMode: state.isDragMode,
                onIncrement: (comp) =>
                    bloc.add(IncrementComponent(comp.id)),
                onDecrement: (comp) =>
                    bloc.add(DecrementComponent(comp.id)),
              );
            }).toList(),
          ),
        ),

        // Summary panel
        if (activeMeal.ingredients.isNotEmpty)
          _MealSummaryPanel(
            meals: state.meals,
            activeMeal: activeMeal,
            onAddToCart: () {
              bloc.add(const AddAllMealsToCart());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meals added to cart!'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 2),
                ),
              );
              context.pushNamed(RouteNames.cart);
            },
          ),
      ],
    );
  }
}

class _ComponentGrid extends StatelessWidget {
  final List<MealComponent> items;
  final Map<String, int> qtyMap;
  final bool isDragMode;
  final void Function(MealComponent) onIncrement;
  final void Function(MealComponent) onDecrement;

  const _ComponentGrid({
    required this.items,
    required this.qtyMap,
    required this.isDragMode,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No items in this category',
          style: TextStyle(color: AppColors.warmGrey500),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final comp = items[index];
        final qty = qtyMap[comp.id] ?? 0;
        return DraggableComponentCard(
          component: comp,
          quantity: qty,
          isDragMode: isDragMode,
          onIncrement: () => onIncrement(comp),
          onDecrement: () => onDecrement(comp),
        );
      },
    );
  }
}

class _MealSummaryPanel extends StatelessWidget {
  final List<MealDraft> meals;
  final MealDraft activeMeal;
  final VoidCallback onAddToCart;

  const _MealSummaryPanel({
    required this.meals,
    required this.activeMeal,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final nonEmptyCount =
        meals.where((m) => m.ingredients.isNotEmpty).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected items summary
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: activeMeal.ingredients.map((ing) {
              return Chip(
                label: Text(
                  '${ing.name} x${ing.quantity}',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor:
                    AppColors.brandOrange.withValues(alpha: 0.08),
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '\$${activeMeal.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.brandOrange,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${activeMeal.totalCalories} cal',
                style: const TextStyle(
                  color: AppColors.warmGrey500,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onAddToCart,
                icon: const Icon(Icons.shopping_cart, size: 18),
                label: Text(
                  nonEmptyCount > 1
                      ? 'Add $nonEmptyCount Meals'
                      : 'Add to Cart',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
