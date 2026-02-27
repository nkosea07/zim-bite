import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/zb_loading.dart';
import '../../../../core/widgets/zb_error_widget.dart';
import '../../../../core/widgets/zb_empty_state.dart';
import '../../bloc/vendor_bloc.dart';
import '../../bloc/vendor_event.dart';
import '../../bloc/vendor_state.dart';
import '../../data/models/vendor_models.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key});

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  final _searchController = TextEditingController();
  bool _filterOpenNow = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<VendorBloc>().add(const LoadVendors());
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Vendor> _applyFilters(List<Vendor> vendors) {
    var filtered = vendors;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((v) =>
              v.name.toLowerCase().contains(_searchQuery) ||
              v.city.toLowerCase().contains(_searchQuery) ||
              v.categories.any((c) => c.toLowerCase().contains(_searchQuery)))
          .toList();
    }

    if (_filterOpenNow) {
      filtered = filtered.where((v) => v.isOpen).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Restaurants'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search + filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search restaurants, categories...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.warmGrey100),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.warmGrey100),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _FilterChip(
                      label: 'Open Now',
                      icon: Icons.access_time,
                      selected: _filterOpenNow,
                      onSelected: (val) =>
                          setState(() => _filterOpenNow = val),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Vendor list
          Expanded(
            child: BlocBuilder<VendorBloc, VendorState>(
              builder: (context, state) {
                if (state is VendorLoading) {
                  return const ZbLoading(message: 'Loading restaurants...');
                }

                if (state is VendorError) {
                  return ZbErrorWidget(
                    message: state.message,
                    onRetry: () =>
                        context.read<VendorBloc>().add(const LoadVendors()),
                  );
                }

                if (state is VendorLoaded) {
                  final vendors = _applyFilters(state.vendors);

                  if (vendors.isEmpty) {
                    return ZbEmptyState(
                      icon: Icons.restaurant_outlined,
                      title: _searchQuery.isNotEmpty || _filterOpenNow
                          ? 'No restaurants match your filters'
                          : 'No restaurants available',
                      subtitle: _searchQuery.isNotEmpty || _filterOpenNow
                          ? 'Try adjusting your search or filters'
                          : 'Check back later',
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.brandOrange,
                    onRefresh: () async =>
                        context.read<VendorBloc>().add(const LoadVendors()),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: vendors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _VendorListCard(vendor: vendors[index]),
                    ),
                  );
                }

                return const ZbLoading();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: selected ? Colors.white : AppColors.warmGrey700,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.brandOrange,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.warmGrey700,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(
        color: selected ? AppColors.brandOrange : AppColors.warmGrey300,
      ),
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class _VendorListCard extends StatelessWidget {
  final Vendor vendor;

  static const List<List<Color>> _gradients = [
    [Color(0xFFD24D29), Color(0xFFE8734F)],
    [Color(0xFF1976D2), Color(0xFF42A5F5)],
    [Color(0xFF2E7D32), Color(0xFF66BB6A)],
    [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
    [Color(0xFFF57F17), Color(0xFFFFCA28)],
  ];

  const _VendorListCard({required this.vendor});

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Colored gradient side
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.restaurant, color: Colors.white, size: 36),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vendor.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: vendor.isOpen
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.warmGrey100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            vendor.isOpen ? 'Open' : 'Closed',
                            style: TextStyle(
                              fontSize: 11,
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
                          fontSize: 13, color: AppColors.warmGrey500),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.amber, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          vendor.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          ' (${vendor.reviewCount})',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.warmGrey500),
                        ),
                        const Spacer(),
                        if (vendor.categories.isNotEmpty)
                          Text(
                            vendor.categories.first,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.warmGrey500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: AppColors.warmGrey300),
            ),
          ],
        ),
      ),
    );
  }
}
