import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/maps/app_map.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/zb_empty_state.dart';
import '../../../../core/widgets/zb_loading.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import '../../bloc/profile_state.dart';
import '../../data/models/profile_models.dart';

const MapCoordinate _harareCenter = MapCoordinate(
  latitude: -17.8292,
  longitude: 31.0522,
);

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const ZbLoading(message: 'Loading addresses...');
          }

          final addresses = state is ProfileLoaded ? state.addresses : <Address>[];

          if (addresses.isEmpty) {
            return const ZbEmptyState(
              icon: Icons.location_on_outlined,
              title: 'No addresses saved',
              subtitle: 'Tap + to add a delivery address',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return _AddressTile(address: addr);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brandOrange,
        onPressed: () => _showAddAddressSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: const _AddAddressSheet(),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final Address address;

  const _AddressTile({required this.address});

  IconData get _labelIcon {
    switch (address.label.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      case 'school':
        return Icons.school_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warmGrey100),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brandOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_labelIcon, color: AppColors.brandOrange, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.brandOrange,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${address.street}, ${address.city}',
                  style: const TextStyle(fontSize: 13, color: AppColors.warmGrey700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${address.latitude.toStringAsFixed(5)}, ${address.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: AppColors.warmGrey500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAddressSheet extends StatefulWidget {
  const _AddAddressSheet();

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
  MapCoordinate? _pin;
  String _label = 'Home';
  final _streetController = TextEditingController();
  final _cityController = TextEditingController(text: 'Harare');
  bool _geocoding = false;
  bool _gpsLoading = false;

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    setState(() => _geocoding = true);
    try {
      final dio = Dio();
      final res = await dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lng,
          'addressdetails': 1,
        },
        options: Options(headers: {
          'User-Agent': 'ZimBite/1.0 (co.zimbite.mobile)',
        }),
      );
      final data = res.data;
      if (data != null) {
        final addr = data['address'] as Map<String, dynamic>?;
        if (addr != null) {
          final houseNum = addr['house_number'] as String? ?? '';
          final road = addr['road'] as String? ?? addr['pedestrian'] as String? ?? '';
          final suburb = addr['suburb'] as String? ?? addr['neighbourhood'] as String? ?? '';
          final city = addr['city'] as String? ?? addr['town'] as String? ?? 'Harare';
          final street = [houseNum, road, suburb].where((s) => s.isNotEmpty).join(', ');
          if (street.isNotEmpty) _streetController.text = street;
          _cityController.text = city;
        }
      }
    } catch (_) {
      // Nominatim unavailable — leave fields for manual entry
    } finally {
      if (mounted) setState(() => _geocoding = false);
    }
  }

  Future<void> _useGps() async {
    setState(() => _gpsLoading = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final coord = MapCoordinate(latitude: pos.latitude, longitude: pos.longitude);
      setState(() => _pin = coord);
      _reverseGeocode(pos.latitude, pos.longitude);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location')),
        );
      }
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  void _onMapTap(MapCoordinate coord) {
    setState(() => _pin = coord);
    _reverseGeocode(coord.latitude, coord.longitude);
  }

  void _save() {
    if (_pin == null || _streetController.text.trim().isEmpty) return;
    final request = CreateAddressRequest(
      label: _label,
      street: _streetController.text.trim(),
      city: _cityController.text.trim().isEmpty ? 'Harare' : _cityController.text.trim(),
      latitude: _pin!.latitude,
      longitude: _pin!.longitude,
    );
    context.read<ProfileBloc>().add(AddAddress(request));
    Navigator.of(context).pop();
  }

  bool get _isValid => _pin != null && _streetController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.warmGrey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                'Add Delivery Address',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tap the map to pin your location, or use GPS.',
                style: TextStyle(fontSize: 13, color: AppColors.warmGrey500),
              ),
              const SizedBox(height: 16),

              // Map
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 220,
                  child: AppMap(
                    center: _pin ?? _harareCenter,
                    zoom: 13,
                    onTap: _onMapTap,
                    pins: _pin != null
                        ? [
                            MapPin(
                              id: 'selected',
                              position: _pin!,
                              color: AppColors.brandOrange,
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // GPS button
              OutlinedButton.icon(
                onPressed: _gpsLoading ? null : _useGps,
                icon: _gpsLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label: Text(_gpsLoading ? 'Getting location...' : 'Use my current location'),
              ),
              const SizedBox(height: 16),

              // Coordinates chip
              if (_pin != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warmGrey100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_pin!.latitude.toStringAsFixed(5)}, ${_pin!.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppColors.warmGrey500,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Label selector
              const Text(
                'Label',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Home', 'Work', 'School', 'Other'].map((lbl) {
                  final selected = _label == lbl;
                  return ChoiceChip(
                    label: Text(lbl),
                    selected: selected,
                    selectedColor: AppColors.brandOrange.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: selected ? AppColors.brandOrange : AppColors.warmGrey700,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    onSelected: (_) => setState(() => _label = lbl),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Street field
              TextField(
                controller: _streetController,
                decoration: InputDecoration(
                  labelText: 'Street address',
                  hintText: '12 Samora Machel Ave, Avondale',
                  border: const OutlineInputBorder(),
                  suffixIcon: _geocoding
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // City field
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Save button
              FilledButton(
                onPressed: _isValid ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandOrange,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Address',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
