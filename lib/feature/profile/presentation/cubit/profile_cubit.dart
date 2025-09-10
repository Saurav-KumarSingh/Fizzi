import 'dart:typed_data';
import 'package:fizzi/feature/profile/domain/entities/profile_user.dart';
import 'package:fizzi/feature/profile/presentation/cubit/profile_states.dart';
import 'package:fizzi/feature/storage/domain/storage_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/profile_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({required this.profileRepo, required this.storageRepo}) : super(ProfileInitial());

  // fetch user profile using repo -> usefull for loading single profile
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

  // fetch user profile using repo -> usefull for loading multiple profile for posts
  Future<ProfileUser?> getUserProfile(String uid) async {

      final user=await profileRepo.fetchUserProfile(uid);
      return user;

  }

  // update user profile

  Future<void> updateProfile(
      {required String uid,
        String? newBio,
        Uint8List? imageWebBytes,
        String? imageMobilePath,
      }) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user == null) {
        emit(ProfileError("Failed to fetch user profile for update"));
        return;
      }

      // profile pic update

      String? imageDownloadUrl;

      // ensure there is an img

      if(imageWebBytes !=null || imageMobilePath!=null){
        // for mobile

        if(imageMobilePath != null){
          imageDownloadUrl=await storageRepo.uploadPostImgMobile(imageMobilePath, uid);
        }else if(imageWebBytes != null){//for web
          imageDownloadUrl=await storageRepo.uploadPostImgWeb(imageWebBytes, uid);
        }

        if(imageDownloadUrl==null){
          emit(ProfileError("Failed to upload image"));
          return;
        }



      }

      // update new profile

      final updatedProfile=user.copyWith(
          newBio: newBio ?? user.bio,
        newProfileImageUrl: imageDownloadUrl?? user.profileImageUrl,
      );

      // update

      await profileRepo.updateUserProfile(updatedProfile);

      // re fetch user
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError("Error updating profile: ${e.toString()}"));
    }
  }
}
