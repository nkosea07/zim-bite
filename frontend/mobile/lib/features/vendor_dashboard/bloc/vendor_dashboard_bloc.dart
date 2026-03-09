import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../menu/data/models/menu_models.dart';
import '../data/repositories/vendor_dashboard_repository.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class VendorDashboardEvent extends Equatable {
  const VendorDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadVendorDashboard extends VendorDashboardEvent {
  final String vendorId;
  const LoadVendorDashboard(this.vendorId);
  @override
  List<Object?> get props => [vendorId];
}

class RefreshVendorDashboard extends VendorDashboardEvent {
  final String vendorId;
  const RefreshVendorDashboard(this.vendorId);
  @override
  List<Object?> get props => [vendorId];
}

class ToggleMenuItemAvailability extends VendorDashboardEvent {
  final String vendorId;
  final String itemId;
  final bool available;
  const ToggleMenuItemAvailability({
    required this.vendorId,
    required this.itemId,
    required this.available,
  });
  @override
  List<Object?> get props => [vendorId, itemId, available];
}

class AddMenuItem extends VendorDashboardEvent {
  final String vendorId;
  final String name;
  final String category;
  final double price;
  const AddMenuItem({
    required this.vendorId,
    required this.name,
    required this.category,
    required this.price,
  });
  @override
  List<Object?> get props => [vendorId, name, category, price];
}

class CreateVendorProfile extends VendorDashboardEvent {
  final String ownerUserId;
  final String name;
  final String phoneNumber;
  final String? description;
  final String city;
  final double latitude;
  final double longitude;
  const CreateVendorProfile({
    required this.ownerUserId,
    required this.name,
    required this.phoneNumber,
    this.description,
    required this.city,
    required this.latitude,
    required this.longitude,
  });
  @override
  List<Object?> get props =>
      [ownerUserId, name, phoneNumber, description, city, latitude, longitude];
}

// ── States ───────────────────────────────────────────────────────────────────

abstract class VendorDashboardState extends Equatable {
  const VendorDashboardState();
  @override
  List<Object?> get props => [];
}

class VendorDashboardInitial extends VendorDashboardState {}

class VendorDashboardLoading extends VendorDashboardState {}

class VendorDashboardLoaded extends VendorDashboardState {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> orders;
  final List<MenuItem> menuItems;
  const VendorDashboardLoaded({
    required this.stats,
    required this.orders,
    required this.menuItems,
  });
  @override
  List<Object?> get props => [stats, orders, menuItems];
}

class VendorCreated extends VendorDashboardState {
  final String vendorId;
  const VendorCreated(this.vendorId);
  @override
  List<Object?> get props => [vendorId];
}

class VendorDashboardError extends VendorDashboardState {
  final String message;
  const VendorDashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class VendorDashboardBloc
    extends Bloc<VendorDashboardEvent, VendorDashboardState> {
  final VendorDashboardRepository _repository;

  VendorDashboardBloc(this._repository)
      : super(VendorDashboardInitial()) {
    on<LoadVendorDashboard>(_onLoad);
    on<RefreshVendorDashboard>(_onRefresh);
    on<ToggleMenuItemAvailability>(_onToggle);
    on<AddMenuItem>(_onAddItem);
    on<CreateVendorProfile>(_onCreateVendor);
  }

  Future<void> _onLoad(
      LoadVendorDashboard event, Emitter<VendorDashboardState> emit) async {
    emit(VendorDashboardLoading());
    await _fetchAll(event.vendorId, emit);
  }

  Future<void> _onRefresh(
      RefreshVendorDashboard event, Emitter<VendorDashboardState> emit) async {
    await _fetchAll(event.vendorId, emit);
  }

  Future<void> _onToggle(ToggleMenuItemAvailability event,
      Emitter<VendorDashboardState> emit) async {
    try {
      await _repository.toggleMenuItemAvailability(
          event.itemId, event.available);
      await _fetchAll(event.vendorId, emit);
    } catch (e) {
      emit(VendorDashboardError(e.toString()));
    }
  }

  Future<void> _onAddItem(
      AddMenuItem event, Emitter<VendorDashboardState> emit) async {
    try {
      await _repository.createMenuItem(event.vendorId, {
        'name': event.name,
        'category': event.category,
        'basePrice': event.price,
        'currency': 'USD',
        'available': true,
      });
      await _fetchAll(event.vendorId, emit);
    } catch (e) {
      emit(VendorDashboardError(e.toString()));
    }
  }

  Future<void> _onCreateVendor(
      CreateVendorProfile event, Emitter<VendorDashboardState> emit) async {
    emit(VendorDashboardLoading());
    try {
      final result = await _repository.createVendor(
        ownerUserId: event.ownerUserId,
        name: event.name,
        phoneNumber: event.phoneNumber,
        description: event.description,
        city: event.city,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(VendorCreated(result['id'] as String));
    } catch (e) {
      emit(VendorDashboardError(e.toString()));
    }
  }

  Future<void> _fetchAll(
      String vendorId, Emitter<VendorDashboardState> emit) async {
    try {
      final results = await Future.wait([
        _repository.getVendorStats(vendorId),
        _repository.getOrders(),
        _repository.getMenuItems(vendorId),
      ]);
      emit(VendorDashboardLoaded(
        stats: results[0] as Map<String, dynamic>,
        orders: results[1] as List<Map<String, dynamic>>,
        menuItems: results[2] as List<MenuItem>,
      ));
    } catch (e) {
      emit(VendorDashboardError(e.toString()));
    }
  }
}
