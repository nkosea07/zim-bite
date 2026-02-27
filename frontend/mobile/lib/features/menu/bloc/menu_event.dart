import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenu extends MenuEvent {
  final String vendorId;

  const LoadMenu(this.vendorId);

  @override
  List<Object?> get props => [vendorId];
}

class SelectCategory extends MenuEvent {
  final String? category;

  const SelectCategory(this.category);

  @override
  List<Object?> get props => [category];
}
