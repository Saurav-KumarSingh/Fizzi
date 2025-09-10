import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fizzi/feature/profile/domain/entities/profile_user.dart';
import 'package:fizzi/feature/profile/domain/repositories/profile_repo.dart';
import 'package:fizzi/feature/profile/presentation/cubit/profile_states.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      final doc = await firebaseFirestore.collection("users").doc(uid).get();

      if (doc.exists && doc.data() != null) {

        //fetch followers and following


        final userData = doc.data()!;


        final followers=List<String>.from(userData['followers'] ?? []);
        final following=List<String>.from(userData['following'] ?? []);
        // return ProfileUser.fromJson(userData);
        return ProfileUser(
            uid: uid,
            email: userData['email'],
            name: userData['name'],
            bio: userData['bio'] ?? ' ',
            profileImageUrl: userData['profileImageUrl'].toString(),
            followers: followers,
            following: following,
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

  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      final currentUserDoc =
      await firebaseFirestore.collection('users').doc(currentUid).get();
      final targetUserDoc =
      await firebaseFirestore.collection('users').doc(targetUid).get();

      if (currentUserDoc.exists && targetUserDoc.exists) {
        final currentUserData = currentUserDoc.data();

        if (currentUserData != null) {
          final List<String> currentFollowing =
          List<String>.from(currentUserData['following'] ?? []);

          if (currentFollowing.contains(targetUid)) {
            // 🔹 Unfollow
            await firebaseFirestore.collection("users").doc(currentUid).update({
              'following': FieldValue.arrayRemove([targetUid]),
            });

            await firebaseFirestore.collection("users").doc(targetUid).update({
              'followers': FieldValue.arrayRemove([currentUid]),
            });
          } else {
            // 🔹 Follow
            await firebaseFirestore.collection("users").doc(currentUid).update({
              'following': FieldValue.arrayUnion([targetUid]),
            });

            await firebaseFirestore.collection("users").doc(targetUid).update({
              'followers': FieldValue.arrayUnion([currentUid]),
            });
          }
        }
      }
    } catch (e, stack) {
      throw Exception("Error in toggleFollow: $e\n$stack");
    }
  }


}
