import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    if (kDebugMode) {
      print("Firebase initialized successfully");
      print("Note: AppCheck is not configured - this is fine for development");
    }
  }
}
