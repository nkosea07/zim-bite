import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/zb_button.dart';
import '../../../../core/widgets/zb_empty_state.dart';
import '../../bloc/cart_bloc.dart';
import '../../bloc/cart_event.dart';
import '../../bloc/cart_state.dart';
import '../../data/models/cart_models.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const double _deliveryFee = 2.00;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: Text(
              state.isEmpty
                  ? 'Cart'
                  : 'Cart (${state.itemCount} item${state.itemCount == 1 ? '' : 's'})',
            ),
            elevation: 0,
            actions: [
              if (!state.isEmpty)
                TextButton(
                  onPressed: () => context.read<CartBloc>().add(const ClearCart()),
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
            ],
          ),
          body: state.isEmpty
              ? ZbEmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Your cart is empty',
                  subtitle: 'Browse restaurants to add items',
                  action: ElevatedButton(
                    onPressed: () => context.pushNamed(RouteNames.vendors),
                    child: const Text('Browse Restaurants'),
                  ),
                )
              : Column(
                  children: [
                    // Vendor banner
                    if (state.vendorId != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        color: AppColors.brandOrange.withValues(alpha: 0.08),
                        child: Row(
                          children: [
                            const Icon(Icons.restaurant,
                                size: 16, color: AppColors.brandOrange),
                            const SizedBox(width: 8),
                            Text(
                              state.items.first.vendorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandOrange,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Cart items
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return _CartItemCard(item: item);
                        },
                      ),
                    ),
                    // Order summary
                    _OrderSummary(
                      subtotal: state.subtotal,
                      deliveryFee: _deliveryFee,
                    ),
                  ],
                ),
          bottomNavigationBar: state.isEmpty
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: ZbButton(
                      label: 'Proceed to Checkout',
                      onPressed: () =>
                          context.pushNamed(RouteNames.checkout),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.menuItemId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          context.read<CartBloc>().add(RemoveFromCart(item.menuItemId)),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            // Item image placeholder
            Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warmGrey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fastfood,
                  color: AppColors.warmGrey300, size: 28),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item.price.toStringAsFixed(2)} each',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.warmGrey500),
                    ),
                  ],
                ),
              ),
            ),
            // Quantity stepper
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _QuantityStepper(item: item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final CartItem item;

  const _QuantityStepper({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon: Icons.remove,
          onPressed: () {
            if (item.quantity <= 1) {
              context
                  .read<CartBloc>()
                  .add(RemoveFromCart(item.menuItemId));
            } else {
              context
                  .read<CartBloc>()
                  .add(UpdateCartQuantity(item.menuItemId, item.quantity - 1));
            }
          },
        ),
        Container(
          width: 32,
          alignment: Alignment.center,
          child: Text(
            '${item.quantity}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        _StepBtn(
          icon: Icons.add,
          onPressed: () => context
              .read<CartBloc>()
              .add(UpdateCartQuantity(item.menuItemId, item.quantity + 1)),
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _StepBtn({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.warmGrey300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.warmGrey700),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;

  const _OrderSummary({required this.subtotal, required this.deliveryFee});

  @override
  Widget build(BuildContext context) {
    final total = subtotal + deliveryFee;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
              label: 'Subtotal', value: '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _SummaryRow(
              label: 'Delivery fee',
              value: '\$${deliveryFee.toStringAsFixed(2)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _SummaryRow(
            label: 'Total',
            value: '\$${total.toStringAsFixed(2)}',
            isBold: true,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: AppColors.warmGrey900)
        : Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.warmGrey700);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
