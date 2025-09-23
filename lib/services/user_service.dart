import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Saves NON-SENSITIVE user profile data to Firestore.
  // Passwords are handled exclusively by Firebase Authentication.
  Future<void> saveUserToFirestore(User firebaseUser, {required String name, required String userType}) async {
    final docSnapshot = await _usersCollection.doc(firebaseUser.uid).get();

    if (!docSnapshot.exists) {
      // Create a new user document with public profile data only.
      // The password is securely stored in Firebase Auth, not here.
      UserModel newAppUser = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: name,
        createdAt: DateTime.now(),
      );
      await _usersCollection.doc(firebaseUser.uid).set(newAppUser.toMap());
    }
  }
  // ... rest of the code ...
}