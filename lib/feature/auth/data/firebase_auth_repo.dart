import 'package:firebase_auth/firebase_auth.dart';
import 'package:fizzi/feature/auth/domain/repositories/auth_repo.dart';

import '../domain/entities/app_user.dart';

class FirebaseAuthRepo implements AuthRepo {
  FirebaseAuth firebaseAuth=FirebaseAuth.instance;
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password)async {
    // TODO: implement loginWithEmailPassword
    try{
      UserCredential userCredential=await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      // create user

      AppUser user=AppUser(uid: userCredential.user!.uid, email: email, name: '');
      // return user

      return user;
    }catch (e){
      throw Exception('Login Failed: $e');

    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password)async {
    // TODO: implement registerWithEmailPassword
    try{
      UserCredential userCredential=await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      // create user

      AppUser user=AppUser(uid: userCredential.user!.uid, email: email, name: '');
      // return user

      return user;
    }catch (e){
      throw Exception('Registration Failed: $e');

    }
  }

  @override
  Future<void> logout()async {
    // TODO: implement logout

    firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser()async {
    // TODO: implement getCurrentUser
    // get current user data from firebase
    final currentUser=await firebaseAuth.currentUser;

    if(currentUser==null){
      return null;
    }

    return AppUser(uid: currentUser.uid, email: currentUser.email!, name: '');

  }
}