import 'package:fizzi/feature/profile/presentation/cubit/profile_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/profile_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(ProfileInitial());

  // fetch user profile using repo
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError("User not found"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // update user profile

  Future<void> updateProfile({required String uid, String? newBio,}) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user == null) {
        emit(ProfileError("Failed to fetch user profile for update"));
        return;
      }

      // profile pic update


      // update profile

      final updatedProfile=user.copyWith(newBio: newBio ?? user.bio);

      // update

      await profileRepo.updateUserProfile(updatedProfile);

      // re fetch user

      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError("Error updating profile: $e.toString()"));
    }
  }
}
