import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/zb_loading.dart';
import '../../../../core/widgets/zb_error_widget.dart';
import '../../../../core/network/api_exception.dart';
import '../../../cart/bloc/cart_bloc.dart';
import '../../../cart/bloc/cart_state.dart';
import '../../../menu/bloc/menu_bloc.dart';
import '../../../menu/bloc/menu_event.dart';
import '../../../menu/bloc/menu_state.dart';
import '../../../menu/data/models/menu_models.dart';
import '../../../cart/bloc/cart_event.dart';
import '../../../cart/data/models/cart_models.dart';
import '../../data/models/vendor_models.dart';
import '../../data/repositories/vendor_repository.dart';

class VendorDetailScreen extends StatefulWidget {
  final String vendorId;

  const VendorDetailScreen({super.key, required this.vendorId});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VendorDetail? _vendor;
  bool _isLoadingVendor = true;
  String? _vendorError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadVendor();
    context.read<MenuBloc>().add(LoadMenu(widget.vendorId));
  }

  Future<void> _loadVendor() async {
    try {
      final repo = context.read<VendorRepository>();
      final vendor = await repo.getVendor(widget.vendorId);
      if (mounted) {
        setState(() {
          _vendor = vendor;
          _isLoadingVendor = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _vendorError = e.message;
          _isLoadingVendor = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _vendorError = e.toString();
          _isLoadingVendor = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const List<List<Color>> _gradients = [
    [Color(0xFFD24D29), Color(0xFFE8734F)],
    [Color(0xFF1976D2), Color(0xFF42A5F5)],
    [Color(0xFF2E7D32), Color(0xFF66BB6A)],
    [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
    [Color(0xFFF57F17), Color(0xFFFFCA28)],
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, menuState) {
        final categories = menuState is MenuLoaded ? menuState.categories : <MenuCategory>[];

        if (categories.length != _tabController.length) {
          final newLength = categories.isEmpty ? 1 : categories.length;
          _tabController.dispose();
          _tabController = TabController(length: newLength, vsync: this);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.brandOrange,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Builder(builder: (ctx) {
                    if (_isLoadingVendor) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.brandOrange, AppColors.brandOrangeLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    }
                    final name = _vendor?.name ?? widget.vendorId;
                    final gradIdx = name.hashCode.abs() % _gradients.length;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _gradients[gradIdx],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  if (_vendor != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _vendor!.isOpen
                                            ? Colors.white.withValues(alpha: 0.2)
                                            : Colors.black.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _vendor!.isOpen ? 'Open' : 'Closed',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (_vendor != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_vendor!.rating.toStringAsFixed(1)} (${_vendor!.reviewCount} reviews)',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.location_on,
                                        color: Colors.white70, size: 14),
                                    const SizedBox(width: 2),
                                    Text(
                                      _vendor!.city,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                bottom: categories.isNotEmpty
                    ? TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white60,
                        indicatorColor: Colors.white,
                        tabs: categories
                            .map((c) => Tab(text: c.name))
                            .toList(),
                        onTap: (i) => context
                            .read<MenuBloc>()
                            .add(SelectCategory(categories[i].name)),
                      )
                    : null,
              ),
            ],
            body: _buildBody(context, menuState, categories),
          ),
          floatingActionButton: BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState.isEmpty) return const SizedBox.shrink();
              return FloatingActionButton.extended(
                backgroundColor: AppColors.brandOrange,
                onPressed: () => context.pushNamed(RouteNames.cart),
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  'Cart (${cartState.itemCount})',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    MenuState menuState,
    List<MenuCategory> categories,
  ) {
    // Vendor info panel
    if (_vendorError != null) {
      return ZbErrorWidget(
        message: _vendorError!,
        onRetry: () {
          setState(() {
            _isLoadingVendor = true;
            _vendorError = null;
          });
          _loadVendor();
        },
      );
    }

    if (menuState is MenuLoading) {
      return const ZbLoading(message: 'Loading menu...');
    }

    if (menuState is MenuError) {
      return ZbErrorWidget(
        message: menuState.message,
        onRetry: () =>
            context.read<MenuBloc>().add(LoadMenu(widget.vendorId)),
      );
    }

    if (categories.isEmpty) {
      return _buildVendorInfo();
    }

    return Column(
      children: [
        if (_vendor != null) _buildInfoBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: categories
                .map((cat) => _MenuCategoryTab(
                      category: cat,
                      vendorId: widget.vendorId,
                      vendorName: _vendor?.name ?? '',
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBar() {
    final v = _vendor!;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _InfoChip(
            icon: Icons.local_shipping_outlined,
            label: '\$${v.deliveryFee.toStringAsFixed(2)} delivery',
          ),
          const SizedBox(width: 12),
          _InfoChip(
            icon: Icons.shopping_bag_outlined,
            label: 'Min \$${v.minimumOrder.toStringAsFixed(0)}',
          ),
          const SizedBox(width: 12),
          _InfoChip(
            icon: Icons.access_time,
            label: '${v.estimatedDeliveryMinutes} min',
          ),
        ],
      ),
    );
  }

  Widget _buildVendorInfo() {
    if (_isLoadingVendor) return const ZbLoading();
    if (_vendor == null) return const SizedBox.shrink();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_vendor!.description,
              style: const TextStyle(
                  color: AppColors.warmGrey700, fontSize: 15, height: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pushNamed(
                RouteNames.menu,
                pathParameters: {'vendorId': widget.vendorId},
              ),
              child: const Text('View Full Menu'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.warmGrey500),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.warmGrey500)),
      ],
    );
  }
}

class _MenuCategoryTab extends StatelessWidget {
  final MenuCategory category;
  final String vendorId;
  final String vendorName;

  const _MenuCategoryTab({
    required this.category,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  Widget build(BuildContext context) {
    final available =
        category.items.where((i) => i.isAvailable).toList();

    if (available.isEmpty) {
      return const Center(
        child: Text('No items in this category',
            style: TextStyle(color: AppColors.warmGrey500)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: available.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _MenuItemCard(
        item: available[index],
        vendorId: vendorId,
        vendorName: vendorName,
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final String vendorId;
  final String vendorName;

  const _MenuItemCard({
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
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warmGrey50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fastfood, color: AppColors.warmGrey300),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.warmGrey500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandOrange,
                          fontSize: 15,
                        ),
                      ),
                      if (item.calories != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${item.calories} cal',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.warmGrey500),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _AddButton(
                item: item, vendorId: vendorId, vendorName: vendorName),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final MenuItem item;
  final String vendorId;
  final String vendorName;

  const _AddButton({
    required this.item,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        final existingItem = cartState.items
            .where((i) => i.menuItemId == item.id)
            .firstOrNull;

        if (existingItem != null) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepperButton(
                icon: Icons.remove,
                onPressed: () {
                  if (existingItem.quantity <= 1) {
                    context
                        .read<CartBloc>()
                        .add(RemoveFromCart(item.id));
                  } else {
                    context.read<CartBloc>().add(
                          UpdateCartQuantity(
                              item.id, existingItem.quantity - 1),
                        );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${existingItem.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              _StepperButton(
                icon: Icons.add,
                onPressed: () {
                  context.read<CartBloc>().add(
                        UpdateCartQuantity(
                            item.id, existingItem.quantity + 1),
                      );
                },
              ),
            ],
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
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.brandOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        );
      },
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _StepperButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.brandOrange.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.brandOrange, size: 16),
      ),
    );
  }
}
