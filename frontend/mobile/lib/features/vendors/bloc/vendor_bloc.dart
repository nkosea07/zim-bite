import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../data/repositories/vendor_repository.dart';
import 'vendor_event.dart';
import 'vendor_state.dart';

class VendorBloc extends Bloc<VendorEvent, VendorState> {
  final VendorRepository _vendorRepository;

  VendorBloc(this._vendorRepository) : super(const VendorInitial()) {
    on<LoadVendors>(_onLoadVendors);
    on<SelectVendor>(_onSelectVendor);
  }

  Future<void> _onLoadVendors(
    LoadVendors event,
    Emitter<VendorState> emit,
  ) async {
    emit(const VendorLoading());
    try {
      final vendors = await _vendorRepository.getVendors();
      emit(VendorLoaded(vendors: vendors));
    } on ApiException catch (e) {
      emit(VendorError(e.message));
    } catch (e) {
      emit(VendorError(e.toString()));
    }
  }

  void _onSelectVendor(
    SelectVendor event,
    Emitter<VendorState> emit,
  ) {
    final current = state;
    if (current is VendorLoaded) {
      emit(current.copyWith(selectedVendorId: event.vendorId));
    }
  }
}
