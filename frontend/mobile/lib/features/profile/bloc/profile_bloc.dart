import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../data/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc(this._profileRepository) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<LoadAddresses>(_onLoadAddresses);
    on<AddAddress>(_onAddAddress);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      // Parallel load of profile and addresses
      final results = await Future.wait([
        _profileRepository.getProfile(),
        _profileRepository.getAddresses(),
      ]);

      emit(ProfileLoaded(
        profile: results[0] as dynamic,
        addresses: results[1] as dynamic,
      ));
    } on ApiException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(ProfileUpdating(
      profile: current.profile,
      addresses: current.addresses,
    ));

    try {
      final data = <String, dynamic>{'name': event.name};
      if (event.email != null) data['email'] = event.email;

      await _profileRepository.updateProfile(data);

      final updatedProfile = await _profileRepository.getProfile();
      emit(ProfileLoaded(
        profile: updatedProfile,
        addresses: current.addresses,
      ));
    } on ApiException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLoadAddresses(
    LoadAddresses event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    try {
      final addresses = await _profileRepository.getAddresses();
      emit(current.copyWith(addresses: addresses));
    } on ApiException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onAddAddress(
    AddAddress event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    try {
      await _profileRepository.addAddress(event.request);
      final addresses = await _profileRepository.getAddresses();
      emit(current.copyWith(addresses: addresses));
    } on ApiException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
