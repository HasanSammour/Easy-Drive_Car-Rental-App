import 'package:flutter/foundation.dart';
import 'package:easydrive/services/auth_service.dart';
import 'package:easydrive/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    _authService.user.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      UserModel? user = await _authService.signUpWithEmail(email, password, name);
      _isLoading = false;
      
      if (user != null) {
        _user = user;
        notifyListeners();
        return true;
      } else {
        _error = "Failed to create account";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      UserModel? user = await _authService.signInWithEmail(email, password);
      _isLoading = false;
      
      if (user != null) {
        _user = user;
        notifyListeners();
        return true;
      } else {
        _error = "Invalid email or password";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}