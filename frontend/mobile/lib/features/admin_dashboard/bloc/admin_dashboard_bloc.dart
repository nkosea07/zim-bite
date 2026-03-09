import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/admin_dashboard_repository.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadAdminDashboard extends AdminDashboardEvent {}

class RefreshAdminDashboard extends AdminDashboardEvent {}

// ── States ───────────────────────────────────────────────────────────────────

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();
  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final Map<String, dynamic> overview;
  final List<Map<String, dynamic>> vendors;
  final List<Map<String, dynamic>> revenue;
  const AdminDashboardLoaded({
    required this.overview,
    required this.vendors,
    required this.revenue,
  });
  @override
  List<Object?> get props => [overview, vendors, revenue];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;
  const AdminDashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final AdminDashboardRepository _repository;

  AdminDashboardBloc(this._repository) : super(AdminDashboardInitial()) {
    on<LoadAdminDashboard>(_onLoad);
    on<RefreshAdminDashboard>(_onRefresh);
  }

  Future<void> _onLoad(
      LoadAdminDashboard event, Emitter<AdminDashboardState> emit) async {
    emit(AdminDashboardLoading());
    await _fetchAll(emit);
  }

  Future<void> _onRefresh(
      RefreshAdminDashboard event, Emitter<AdminDashboardState> emit) async {
    await _fetchAll(emit);
  }

  Future<void> _fetchAll(Emitter<AdminDashboardState> emit) async {
    try {
      final results = await Future.wait([
        _repository.getOverview(),
        _repository.getVendors(),
        _repository.getRevenueTrends(),
      ]);
      emit(AdminDashboardLoaded(
        overview: results[0] as Map<String, dynamic>,
        vendors: results[1] as List<Map<String, dynamic>>,
        revenue: results[2] as List<Map<String, dynamic>>,
      ));
    } catch (e) {
      emit(AdminDashboardError(e.toString()));
    }
  }
}
