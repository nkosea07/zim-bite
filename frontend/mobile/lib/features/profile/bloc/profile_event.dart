import 'package:equatable/equatable.dart';
import '../data/models/profile_models.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String? email;

  const UpdateProfile({required this.name, this.email});

  @override
  List<Object?> get props => [name, email];
}

class LoadAddresses extends ProfileEvent {
  const LoadAddresses();
}

class AddAddress extends ProfileEvent {
  final CreateAddressRequest request;

  const AddAddress(this.request);

  @override
  List<Object?> get props => [request];
}
