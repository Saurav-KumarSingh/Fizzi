import 'package:fizzi/feature/profile/domain/entities/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser?> fetchUserProfile(String uid);
  Future<void> updateUserProfile(ProfileUser updatedProfile);
}
