import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fizzi/feature/profile/domain/entities/profile_user.dart';
import 'package:fizzi/feature/profile/domain/repositories/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      final doc = await firebaseFirestore.collection("users").doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final userData = doc.data()!;
        // return ProfileUser.fromJson(userData);
        return ProfileUser(
            uid: uid,
            email: userData['email'],
            name: userData['name'],
            bio: userData['bio'] ?? ' ',
            profileImageUrl: userData['profileImageUrl'].toString()
        );
      } else {
        return null;
      }
    } catch (e) {
      throw Exception("Failed to fetch user profile: $e");
    }
  }

  @override
  Future<void> updateUserProfile(ProfileUser updatedProfile) async {
    try {
      await firebaseFirestore
          .collection("users")
          .doc(updatedProfile.uid)
          .update(updatedProfile.toJson());
    } catch (e) {
      throw Exception("Failed to update user profile: $e");
    }
  }
}
