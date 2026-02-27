import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/zb_loading.dart';
import '../../../../core/widgets/zb_error_widget.dart';
import '../../../../core/widgets/zb_empty_state.dart';
import '../../../cart/bloc/cart_bloc.dart';
import '../../../cart/bloc/cart_event.dart';
import '../../../cart/bloc/cart_state.dart';
import '../../../cart/data/models/cart_models.dart';
import '../../bloc/menu_bloc.dart';
import '../../bloc/menu_event.dart';
import '../../bloc/menu_state.dart';
import '../../data/models/menu_models.dart';

class MenuScreen extends StatefulWidget {
  final String vendorId;

  const MenuScreen({super.key, required this.vendorId});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    context.read<MenuBloc>().add(LoadMenu(widget.vendorId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        final categories =
            state is MenuLoaded ? state.categories : <MenuCategory>[];

        if (categories.length != _tabController.length) {
          final len = categories.isEmpty ? 1 : categories.length;
          _tabController.dispose();
          _tabController = TabController(length: len, vsync: this);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Menu'),
            backgroundColor: AppColors.background,
            elevation: 0,
            bottom: categories.isNotEmpty
                ? TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.brandOrange,
                    unselectedLabelColor: AppColors.warmGrey500,
                    indicatorColor: AppColors.brandOrange,
                    tabs: categories.map((c) => Tab(text: c.name)).toList(),
                    onTap: (i) => context
                        .read<MenuBloc>()
                        .add(SelectCategory(categories[i].name)),
                  )
                : null,
          ),
          body: _buildBody(state, categories),
          floatingActionButton: BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState.isEmpty) return const SizedBox.shrink();
              return FloatingActionButton.extended(
                backgroundColor: AppColors.brandOrange,
                onPressed: () => context.pushNamed(RouteNames.cart),
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  'Cart (${cartState.itemCount})  •  \$${cartState.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(MenuState state, List<MenuCategory> categories) {
    if (state is MenuLoading) {
      return const ZbLoading(message: 'Loading menu...');
    }

    if (state is MenuError) {
      return ZbErrorWidget(
        message: state.message,
        onRetry: () =>
            context.read<MenuBloc>().add(LoadMenu(widget.vendorId)),
      );
    }

    if (state is MenuLoaded && categories.isEmpty) {
      return const ZbEmptyState(
        icon: Icons.menu_book_outlined,
        title: 'Menu is empty',
        subtitle: 'No items available at the moment',
      );
    }

    if (categories.isNotEmpty) {
      return TabBarView(
        controller: _tabController,
        children: categories
            .map((cat) => _CategoryItemList(
                  category: cat,
                  vendorId: widget.vendorId,
                  vendorName: '',
                ))
            .toList(),
      );
    }

    return const ZbLoading();
  }
}

class _CategoryItemList extends StatelessWidget {
  final MenuCategory category;
  final String vendorId;
  final String vendorName;

  const _CategoryItemList({
    required this.category,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  Widget build(BuildContext context) {
    final items = category.items.where((i) => i.isAvailable).toList();

    if (items.isEmpty) {
      return const Center(
        child: Text('No items available in this category',
            style: TextStyle(color: AppColors.warmGrey500)),
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
      itemBuilder: (context, index) => _MenuItemGridCard(
        item: items[index],
        vendorId: vendorId,
        vendorName: vendorName,
      ),
    );
  }
}

class _MenuItemGridCard extends StatelessWidget {
  final MenuItem item;
  final String vendorId;
  final String vendorName;

  const _MenuItemGridCard({
    required this.item,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 110,
            color: AppColors.warmGrey50,
            child: const Center(
              child: Icon(Icons.fastfood, color: AppColors.warmGrey300, size: 40),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandOrange,
                          fontSize: 14,
                        ),
                      ),
                      BlocBuilder<CartBloc, CartState>(
                        builder: (context, cartState) {
                          final existing = cartState.items
                              .where((i) => i.menuItemId == item.id)
                              .firstOrNull;

                          if (existing != null) {
                            return _InlineQuantityStepper(
                              quantity: existing.quantity,
                              onDecrement: () {
                                if (existing.quantity <= 1) {
                                  context
                                      .read<CartBloc>()
                                      .add(RemoveFromCart(item.id));
                                } else {
                                  context.read<CartBloc>().add(
                                        UpdateCartQuantity(
                                            item.id, existing.quantity - 1),
                                      );
                                }
                              },
                              onIncrement: () {
                                context.read<CartBloc>().add(
                                      UpdateCartQuantity(
                                          item.id, existing.quantity + 1),
                                    );
                              },
                            );
                          }

                          return GestureDetector(
                            onTap: () {
                              context.read<CartBloc>().add(
                                    AddToCart(CartItem(
                                      menuItemId: item.id,
                                      name: item.name,
                                      price: item.price,
                                      quantity: 1,
                                      vendorId: vendorId,
                                      vendorName: vendorName,
                                    )),
                                  );
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: AppColors.brandOrange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 18),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineQuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _InlineQuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.brandOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.remove,
                color: AppColors.brandOrange, size: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '$quantity',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.brandOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 14),
          ),
        ),
      ],
    );
  }
}
