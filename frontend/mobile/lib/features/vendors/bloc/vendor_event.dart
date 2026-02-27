import 'package:equatable/equatable.dart';

abstract class VendorEvent extends Equatable {
  const VendorEvent();

  @override
  List<Object?> get props => [];
}

class LoadVendors extends VendorEvent {
  const LoadVendors();
}

class SelectVendor extends VendorEvent {
  final String vendorId;

  const SelectVendor(this.vendorId);

  @override
  List<Object?> get props => [vendorId];
}
