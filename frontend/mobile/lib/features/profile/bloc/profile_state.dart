import 'package:equatable/equatable.dart';
import '../data/models/profile_models.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final List<Address> addresses;

  const ProfileLoaded({
    required this.profile,
    required this.addresses,
  });

  ProfileLoaded copyWith({
    UserProfile? profile,
    List<Address>? addresses,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      addresses: addresses ?? this.addresses,
    );
  }

  @override
  List<Object?> get props => [profile, addresses];
}

class ProfileUpdating extends ProfileState {
  final UserProfile profile;
  final List<Address> addresses;

  const ProfileUpdating({
    required this.profile,
    required this.addresses,
  });

  @override
  List<Object?> get props => [profile, addresses];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
