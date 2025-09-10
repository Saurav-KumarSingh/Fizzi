import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fizzi/feature/auth/domain/repositories/auth_repo.dart';

import '../domain/entities/app_user.dart';

class FirebaseAuthRepo implements AuthRepo {
  FirebaseAuth firebaseAuth=FirebaseAuth.instance;
  FirebaseFirestore firbaseFirestore=FirebaseFirestore.instance;
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password)async {
    // TODO: implement loginWithEmailPassword
    try{
      UserCredential userCredential=await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);


      // fetch user doc from firestore

      DocumentSnapshot userDoc=await firbaseFirestore.collection("users").doc(userCredential.user!.uid).get();

      // create user

      AppUser user=AppUser(uid: userCredential.user!.uid, email: email, name: userDoc['name']?? '');
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

      AppUser user=AppUser(uid: userCredential.user!.uid, email: email, name: name);
      // save user in db
      await firbaseFirestore.collection("users").doc(user.uid).set(user.toJson());

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

    // fetch user doc from firestore

    DocumentSnapshot userDoc=await firbaseFirestore.collection("users").doc(currentUser.uid).get();

    // check if user doc exists
    if(!userDoc.exists){
      return null;
    }


    return AppUser(uid: currentUser.uid, email: currentUser.email!, name: userDoc['name']);

  }
}