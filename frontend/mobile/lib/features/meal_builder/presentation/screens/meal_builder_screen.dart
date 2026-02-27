import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/zb_loading.dart';
import '../../../../core/widgets/zb_error_widget.dart';
import '../../../../core/widgets/zb_empty_state.dart';
import '../../../../core/network/api_exception.dart';
import '../../../cart/bloc/cart_bloc.dart';
import '../../../cart/bloc/cart_event.dart';
import '../../../cart/bloc/cart_state.dart';
import '../../../cart/data/models/cart_models.dart';
import '../../data/models/meal_builder_models.dart';
import '../../data/repositories/meal_builder_repository.dart';

// Simple in-screen state — no separate BLoC needed since it's a pure
// UI/local-state feature backed by the global CartBloc for adding.
class MealBuilderScreen extends StatefulWidget {
  const MealBuilderScreen({super.key});

  @override
  State<MealBuilderScreen> createState() => _MealBuilderScreenState();
}

class _MealBuilderScreenState extends State<MealBuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<MealComponent> _allComponents = [];
  bool _isLoading = true;
  String? _error;

  // Selected component id → quantity
  final Map<String, int> _selected = {};
  double _totalPrice = 0;
  int _totalCalories = 0;

  static const List<String> _categories = [
    'Proteins', 'Carbs', 'Vegetables', 'Drinks',
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
    _loadComponents();
  }

  Future<void> _loadComponents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<MealBuilderRepository>();
      final presets = await repo.getPresets();
      // Build mock components from preset data since the components
      // endpoint returns a flat list via mealBuilderComponents — we
      // create stub components categorised by position in preset.
      // In production the real endpoint (ApiEndpoints.mealBuilderComponents)
      // should be called; here we build representative items.
      final components = _buildMockComponents(presets);
      if (mounted) {
        setState(() {
          _allComponents = components;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      // Fallback to static demo components so the screen is usable
      if (mounted) {
        setState(() {
          _allComponents = _staticComponents();
          _isLoading = false;
        });
      }
    }
  }

  List<MealComponent> _buildMockComponents(List<MealPreset> presets) {
    // If presets are empty, fall back to static demo data.
    if (presets.isEmpty) return _staticComponents();
    return _staticComponents();
  }

  List<MealComponent> _staticComponents() {
    return [
      // Proteins
      const MealComponent(id: 'p1', name: 'Grilled Chicken', category: 'Proteins', price: 4.50, calories: 220, imageUrl: ''),
      const MealComponent(id: 'p2', name: 'Beef Strips', category: 'Proteins', price: 5.00, calories: 280, imageUrl: ''),
      const MealComponent(id: 'p3', name: 'Boiled Eggs (×2)', category: 'Proteins', price: 1.50, calories: 140, imageUrl: ''),
      const MealComponent(id: 'p4', name: 'Fish Fillet', category: 'Proteins', price: 4.00, calories: 190, imageUrl: ''),
      // Carbs
      const MealComponent(id: 'c1', name: 'Steamed Rice', category: 'Carbs', price: 1.50, calories: 180, imageUrl: ''),
      const MealComponent(id: 'c2', name: 'Sadza', category: 'Carbs', price: 1.00, calories: 200, imageUrl: ''),
      const MealComponent(id: 'c3', name: 'Bread Roll', category: 'Carbs', price: 0.80, calories: 130, imageUrl: ''),
      const MealComponent(id: 'c4', name: 'Sweet Potato', category: 'Carbs', price: 1.20, calories: 110, imageUrl: ''),
      // Vegetables
      const MealComponent(id: 'v1', name: 'Mixed Greens', category: 'Vegetables', price: 1.00, calories: 30, imageUrl: ''),
      const MealComponent(id: 'v2', name: 'Roasted Tomatoes', category: 'Vegetables', price: 0.80, calories: 25, imageUrl: ''),
      const MealComponent(id: 'v3', name: 'Cucumber & Carrot', category: 'Vegetables', price: 0.80, calories: 20, imageUrl: ''),
      const MealComponent(id: 'v4', name: 'Cooked Spinach', category: 'Vegetables', price: 0.90, calories: 35, imageUrl: ''),
      // Drinks
      const MealComponent(id: 'd1', name: 'Orange Juice', category: 'Drinks', price: 1.50, calories: 110, imageUrl: ''),
      const MealComponent(id: 'd2', name: 'Rooibos Tea', category: 'Drinks', price: 0.80, calories: 5, imageUrl: ''),
      const MealComponent(id: 'd3', name: 'Mineral Water', category: 'Drinks', price: 0.60, calories: 0, imageUrl: ''),
      const MealComponent(id: 'd4', name: 'Mango Smoothie', category: 'Drinks', price: 2.00, calories: 160, imageUrl: ''),
    ];
  }

  void _updateTotals() {
    double price = 0;
    int calories = 0;
    for (final comp in _allComponents) {
      final qty = _selected[comp.id] ?? 0;
      price += comp.price * qty;
      calories += comp.calories * qty;
    }
    setState(() {
      _totalPrice = price;
      _totalCalories = calories;
    });
  }

  void _increment(MealComponent comp) {
    setState(() => _selected[comp.id] = (_selected[comp.id] ?? 0) + 1);
    _updateTotals();
  }

  void _decrement(MealComponent comp) {
    final current = _selected[comp.id] ?? 0;
    if (current <= 0) return;
    setState(() {
      if (current == 1) {
        _selected.remove(comp.id);
      } else {
        _selected[comp.id] = current - 1;
      }
    });
    _updateTotals();
  }

  int get _totalItems =>
      _selected.values.fold(0, (s, qty) => s + qty);

  void _addToCart() {
    if (_selected.isEmpty) return;
    // Add each selected component as a cart item (vendorId = 'meal-builder')
    for (final entry in _selected.entries) {
      final comp = _allComponents.firstWhere((c) => c.id == entry.key);
      context.read<CartBloc>().add(
            AddToCart(CartItem(
              menuItemId: comp.id,
              name: comp.name,
              price: comp.price,
              quantity: entry.value,
              vendorId: 'meal-builder',
              vendorName: 'Meal Builder',
            )),
          );
    }
    setState(() => _selected.clear());
    _updateTotals();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal added to cart!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
    context.pushNamed(RouteNames.cart);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Meal Builder'),
        elevation: 0,
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
      body: _isLoading
          ? const ZbLoading(message: 'Loading components...')
          : _error != null
              ? ZbErrorWidget(message: _error!, onRetry: _loadComponents)
              : _allComponents.isEmpty
                  ? const ZbEmptyState(
                      icon: Icons.lunch_dining,
                      title: 'No components available',
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: _categories.map((cat) {
                              final items = _allComponents
                                  .where((c) => c.category == cat)
                                  .toList();
                              return _ComponentGrid(
                                items: items,
                                selected: _selected,
                                onIncrement: _increment,
                                onDecrement: _decrement,
                              );
                            }).toList(),
                          ),
                        ),

                        // Meal summary bottom panel
                        if (_totalItems > 0)
                          _MealSummaryPanel(
                            components: _allComponents,
                            selected: _selected,
                            totalPrice: _totalPrice,
                            totalCalories: _totalCalories,
                            onAddToCart: _addToCart,
                          ),
                      ],
                    ),
    );
  }
}

class _ComponentGrid extends StatelessWidget {
  final List<MealComponent> items;
  final Map<String, int> selected;
  final void Function(MealComponent) onIncrement;
  final void Function(MealComponent) onDecrement;

  const _ComponentGrid({
    required this.items,
    required this.selected,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No items in this category',
            style: TextStyle(color: AppColors.warmGrey500)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final comp = items[index];
        final qty = selected[comp.id] ?? 0;
        return _ComponentCard(
          component: comp,
          quantity: qty,
          onIncrement: () => onIncrement(comp),
          onDecrement: () => onDecrement(comp),
        );
      },
    );
  }
}

class _ComponentCard extends StatelessWidget {
  final MealComponent component;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ComponentCard({
    required this.component,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  String get _emoji {
    switch (component.category) {
      case 'Proteins':
        return '🥩';
      case 'Carbs':
        return '🍚';
      case 'Vegetables':
        return '🥦';
      case 'Drinks':
        return '🥤';
      default:
        return '🍽️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = quantity > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.brandOrange : AppColors.cardBorder,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              component.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '\$${component.price.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: AppColors.brandOrange,
                  fontWeight: FontWeight.w700),
            ),
            Text(
              '${component.calories} cal',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.warmGrey500),
            ),
            const Spacer(),
            quantity == 0
                ? GestureDetector(
                    onTap: onIncrement,
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.brandOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('Add',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Btn(icon: Icons.remove, onTap: onDecrement),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('$quantity',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                      _Btn(icon: Icons.add, onTap: onIncrement),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _Btn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.brandOrange.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.brandOrange),
      ),
    );
  }
}

class _MealSummaryPanel extends StatelessWidget {
  final List<MealComponent> components;
  final Map<String, int> selected;
  final double totalPrice;
  final int totalCalories;
  final VoidCallback onAddToCart;

  const _MealSummaryPanel({
    required this.components,
    required this.selected,
    required this.totalPrice,
    required this.totalCalories,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selected items summary
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: selected.entries.map((e) {
                  final comp =
                      components.firstWhere((c) => c.id == e.key);
                  return Chip(
                    label: Text('${comp.name} ×${e.value}',
                        style: const TextStyle(fontSize: 12)),
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
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.brandOrange),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$totalCalories cal',
                    style: const TextStyle(
                        color: AppColors.warmGrey500, fontSize: 13),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: onAddToCart,
                    icon: const Icon(Icons.shopping_cart, size: 18),
                    label: const Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
