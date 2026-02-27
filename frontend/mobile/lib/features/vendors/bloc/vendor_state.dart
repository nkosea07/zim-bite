import 'package:equatable/equatable.dart';
import '../data/models/vendor_models.dart';

abstract class VendorState extends Equatable {
  const VendorState();

  @override
  List<Object?> get props => [];
}

class VendorInitial extends VendorState {
  const VendorInitial();
}

class VendorLoading extends VendorState {
  const VendorLoading();
}

class VendorLoaded extends VendorState {
  final List<Vendor> vendors;
  final String? selectedVendorId;

  const VendorLoaded({
    required this.vendors,
    this.selectedVendorId,
  });

  VendorLoaded copyWith({
    List<Vendor>? vendors,
    String? selectedVendorId,
  }) {
    return VendorLoaded(
      vendors: vendors ?? this.vendors,
      selectedVendorId: selectedVendorId ?? this.selectedVendorId,
    );
  }

  @override
  List<Object?> get props => [vendors, selectedVendorId];
}

class VendorError extends VendorState {
  final String message;

  const VendorError(this.message);

  @override
  List<Object?> get props => [message];
}
