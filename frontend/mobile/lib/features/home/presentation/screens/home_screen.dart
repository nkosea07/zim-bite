import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../vendors/bloc/vendor_bloc.dart';
import '../../../vendors/bloc/vendor_event.dart';
import '../../../vendors/bloc/vendor_state.dart';
import '../../../vendors/data/models/vendor_models.dart';
import '../../../cart/bloc/cart_bloc.dart';
import '../../../cart/bloc/cart_state.dart';
import '../../../orders/bloc/orders_bloc.dart';
import '../../../orders/bloc/orders_event.dart';
import '../../../orders/bloc/orders_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VendorBloc>().add(const LoadVendors());
    context.read<OrdersBloc>().add(const LoadOrders());
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  bool get _isDeliveryWindowOpen {
    final hour = DateTime.now().hour;
    return hour >= 5 && hour < 10;
  }

  String _deliveryWindowStatus() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 5) {
      final opens = DateTime(now.year, now.month, now.day, 5, 0);
      final diff = opens.difference(now);
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      return 'Window opens in ${h}h ${m}m';
    } else if (hour < 10) {
      final closes = DateTime(now.year, now.month, now.day, 10, 0);
      final diff = closes.difference(now);
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      return 'Closes in ${h}h ${m}m';
    } else {
      return 'Next window: Tomorrow 5:00 AM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'ZimBite',
          style: TextStyle(
            color: AppColors.brandOrange,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.pushNamed(RouteNames.cart),
                  ),
                  if (cartState.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.brandOrange,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cartState.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.pushNamed(RouteNames.notifications),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.brandOrange,
        onRefresh: () async {
          context.read<VendorBloc>().add(const LoadVendors());
          context.read<OrdersBloc>().add(const LoadOrders());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting header
              Text(
                '${_greeting()}!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'What would you like for breakfast?',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.warmGrey500),
              ),
              const SizedBox(height: 16),

              // Delivery window banner
              _DeliveryWindowBanner(
                isOpen: _isDeliveryWindowOpen,
                statusText: _deliveryWindowStatus(),
              ),
              const SizedBox(height: 24),

              // Search bar
              GestureDetector(
                onTap: () => context.pushNamed(RouteNames.vendors),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warmGrey100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: AppColors.warmGrey500),
                      SizedBox(width: 12),
                      Text(
                        'Search restaurants...',
                        style: TextStyle(
                            color: AppColors.warmGrey500, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick actions
              Text('Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  _QuickAction(
                    icon: Icons.restaurant_menu,
                    label: 'Restaurants',
                    onTap: () => context.pushNamed(RouteNames.vendors),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    icon: Icons.lunch_dining,
                    label: 'Meal Builder',
                    onTap: () => context.pushNamed(RouteNames.mealBuilder),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    icon: Icons.repeat,
                    label: 'Subscribe',
                    onTap: () => context.pushNamed(RouteNames.subscriptions),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Cart',
                    onTap: () => context.pushNamed(RouteNames.cart),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Vendor carousel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Popular Near You',
                      style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () => context.pushNamed(RouteNames.vendors),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BlocBuilder<VendorBloc, VendorState>(
                builder: (context, state) {
                  if (state is VendorLoading) {
                    return _ShimmerCarousel();
                  }
                  if (state is VendorLoaded && state.vendors.isNotEmpty) {
                    return _VendorCarousel(vendors: state.vendors);
                  }
                  if (state is VendorError) {
                    return _CarouselError(
                      message: state.message,
                      onRetry: () =>
                          context.read<VendorBloc>().add(const LoadVendors()),
                    );
                  }
                  // Initial or empty
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text('No restaurants available',
                          style: TextStyle(color: AppColors.warmGrey500)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Recent orders shortcut
              BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoaded && state.orders.isNotEmpty) {
                    final latest = state.orders.first;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recent Order',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        _RecentOrderCard(
                          vendorName: latest.vendorName,
                          status: latest.status,
                          totalAmount: latest.totalAmount,
                          orderId: latest.id,
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryWindowBanner extends StatelessWidget {
  final bool isOpen;
  final String statusText;

  const _DeliveryWindowBanner({
    required this.isOpen,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOpen
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warmGrey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isOpen ? AppColors.success.withValues(alpha: 0.3) : AppColors.warmGrey100,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOpen ? Icons.check_circle_outline : Icons.access_time,
            color: isOpen ? AppColors.success : AppColors.warmGrey500,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'Delivery window is open' : 'Delivery window closed',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isOpen ? AppColors.success : AppColors.warmGrey700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.warmGrey500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '5AM–10AM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isOpen ? AppColors.success : AppColors.warmGrey500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.brandOrange, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorCarousel extends StatelessWidget {
  final List<Vendor> vendors;

  const _VendorCarousel({required this.vendors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vendors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return _VendorCard(vendor: vendor);
        },
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final Vendor vendor;

  const _VendorCard({required this.vendor});

  static const List<List<Color>> _gradients = [
    [Color(0xFFD24D29), Color(0xFFE8734F)],
    [Color(0xFF1976D2), Color(0xFF42A5F5)],
    [Color(0xFF2E7D32), Color(0xFF66BB6A)],
    [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
    [Color(0xFFF57F17), Color(0xFFFFCA28)],
  ];

  @override
  Widget build(BuildContext context) {
    final gradientIndex = vendor.name.hashCode.abs() % _gradients.length;
    final gradient = _gradients[gradientIndex];

    return GestureDetector(
      onTap: () => context.pushNamed(
        RouteNames.vendorDetail,
        pathParameters: {'vendorId': vendor.id},
      ),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 40,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: vendor.isOpen
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.warmGrey100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          vendor.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: vendor.isOpen
                                ? AppColors.success
                                : AppColors.warmGrey500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vendor.city,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.warmGrey500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        vendor.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        ' (${vendor.reviewCount})',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.warmGrey500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: AppColors.warmGrey100,
            highlightColor: AppColors.warmGrey50,
            child: Container(
              width: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CarouselError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CarouselError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                style: const TextStyle(color: AppColors.warmGrey500),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  final String vendorName;
  final String status;
  final double totalAmount;
  final String orderId;

  const _RecentOrderCard({
    required this.vendorName,
    required this.status,
    required this.totalAmount,
    required this.orderId,
  });

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppColors.success;
      case 'out_for_delivery':
      case 'out for delivery':
        return AppColors.info;
      case 'preparing':
      case 'confirmed':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warmGrey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        RouteNames.orderDetail,
        pathParameters: {'orderId': orderId},
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: _statusColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vendorName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                const Text('View',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.brandOrange)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
