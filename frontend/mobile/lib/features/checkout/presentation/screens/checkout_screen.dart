import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/zb_button.dart';
import '../../../cart/bloc/cart_bloc.dart';
import '../../../cart/bloc/cart_event.dart';
import '../../../cart/bloc/cart_state.dart';
import '../../../profile/bloc/profile_bloc.dart';
import '../../../profile/bloc/profile_event.dart';
import '../../../profile/bloc/profile_state.dart';
import '../../../profile/data/models/profile_models.dart';
import '../../bloc/checkout_bloc.dart';
import '../../bloc/checkout_event.dart';
import '../../bloc/checkout_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const List<_PaymentOption> _paymentOptions = [
    _PaymentOption(method: 'ecocash',  label: 'EcoCash',  subtitle: 'Econet mobile money',   icon: Icons.phone_android),
    _PaymentOption(method: 'onemoney', label: 'OneMoney', subtitle: 'NetOne mobile money',    icon: Icons.phone_android),
    _PaymentOption(method: 'card',     label: 'Card',     subtitle: 'Visa / Mastercard',      icon: Icons.credit_card),
    _PaymentOption(method: 'cash',     label: 'Cash',     subtitle: 'Pay on delivery',        icon: Icons.money),
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          context.read<CartBloc>().add(const ClearCart());
          context.go('/orders/${state.orderId}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is CheckoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, checkoutState) {
          final formState = checkoutState is CheckoutFormState
              ? checkoutState
              : const CheckoutFormState();
          final isSubmitting = checkoutState is CheckoutSubmitting;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              title: const Text('Checkout'),
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery address
                  const _SectionHeader(
                    icon: Icons.location_on_outlined,
                    title: 'Delivery Address',
                  ),
                  const SizedBox(height: 10),
                  _AddressSelector(selectedId: formState.addressId),
                  const SizedBox(height: 24),

                  // Scheduled time
                  const _SectionHeader(
                    icon: Icons.access_time,
                    title: 'Delivery Time',
                  ),
                  const SizedBox(height: 10),
                  _TimeSlotSelector(selectedTime: formState.scheduledTime),
                  const SizedBox(height: 24),

                  // Payment method
                  const _SectionHeader(
                    icon: Icons.payment,
                    title: 'Payment Method',
                  ),
                  const SizedBox(height: 10),
                  ..._paymentOptions.map(
                    (opt) => _PaymentMethodCard(
                      option: opt,
                      selected: formState.paymentMethod == opt.method,
                      onSelected: () => context
                          .read<CheckoutBloc>()
                          .add(SetPaymentMethod(opt.method)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Order summary
                  const _SectionHeader(
                    icon: Icons.receipt_long_outlined,
                    title: 'Order Summary',
                  ),
                  const SizedBox(height: 10),
                  const _CheckoutOrderSummary(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ZbButton(
                  label: 'Place Order',
                  isLoading: isSubmitting,
                  onPressed: isSubmitting
                      ? null
                      : () => context
                          .read<CheckoutBloc>()
                          .add(const PlaceOrder()),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.brandOrange),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _AddressSelector extends StatelessWidget {
  final String? selectedId;

  const _AddressSelector({this.selectedId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded && state.addresses.isNotEmpty) {
          return Column(
            children: state.addresses.map((address) {
              final isSelected = address.id == selectedId;
              return GestureDetector(
                onTap: () => context
                    .read<CheckoutBloc>()
                    .add(SetDeliveryAddress(address.id)),
                child: _AddressCard(address: address, isSelected: isSelected),
              );
            }).toList(),
          );
        }

        return GestureDetector(
          onTap: () => context.pushNamed(RouteNames.addresses),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warmGrey100),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_location_outlined,
                    color: AppColors.brandOrange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state is ProfileLoading
                        ? 'Loading addresses...'
                        : 'Add delivery address',
                    style: const TextStyle(color: AppColors.warmGrey500),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.warmGrey300),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final bool isSelected;

  const _AddressCard({required this.address, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.brandOrange : AppColors.warmGrey100,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: isSelected ? AppColors.brandOrange : AppColors.warmGrey300,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(address.label,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (address.isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.brandOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.brandOrange,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${address.street}, ${address.city}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.warmGrey500),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle,
                color: AppColors.brandOrange, size: 20),
        ],
      ),
    );
  }
}

class _TimeSlotSelector extends StatelessWidget {
  final String? selectedTime;

  static const List<String> _slots = [
    '5:30', '6:00', '6:30', '7:00', '7:30',
    '8:00', '8:30', '9:00', '9:30',
  ];

  const _TimeSlotSelector({this.selectedTime});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _slots.map((slot) {
        final isSelected = slot == selectedTime;
        return GestureDetector(
          onTap: () =>
              context.read<CheckoutBloc>().add(SetScheduledTime(slot)),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brandOrange : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.brandOrange
                    : AppColors.warmGrey100,
              ),
            ),
            child: Text(
              slot,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.warmGrey700,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final _PaymentOption option;
  final bool selected;
  final VoidCallback onSelected;

  const _PaymentMethodCard({
    required this.option,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.brandOrange : AppColors.warmGrey100,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.brandOrange.withValues(alpha: 0.1)
                    : AppColors.warmGrey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                option.icon,
                color: selected ? AppColors.brandOrange : AppColors.warmGrey500,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(option.subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.warmGrey500)),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.brandOrange
                      : AppColors.warmGrey300,
                  width: 2,
                ),
                color: selected ? AppColors.brandOrange : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutOrderSummary extends StatelessWidget {
  static const double _deliveryFee = 1.50;

  const _CheckoutOrderSummary();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        final total = cartState.subtotal + _deliveryFee;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warmGrey100),
          ),
          child: Column(
            children: [
              ...cartState.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.name} × ${item.quantity}',
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.warmGrey700),
                        ),
                      ),
                      Text(
                        '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 16),
              _Row(
                  label: 'Subtotal',
                  value: '\$${cartState.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 4),
              _Row(
                  label: 'Delivery fee',
                  value: '\$${_deliveryFee.toStringAsFixed(2)}'),
              const Divider(height: 16),
              _Row(
                label: 'Total',
                value: '\$${total.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _Row({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)
        : const TextStyle(color: AppColors.warmGrey700, fontSize: 14);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}

class _PaymentOption {
  final String method;
  final String label;
  final String subtitle;
  final IconData icon;

  const _PaymentOption({
    required this.method,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}
