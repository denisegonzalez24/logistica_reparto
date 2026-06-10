import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AuthProvider(this.repository);

  bool isLoading = false;
  String? errorMessage;

  Stream<bool> get sessionChanges =>
      repository.authStateChanges().map((user) => user != null);

  bool get isLoggedIn => repository.currentUser != null;

  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      await repository.signIn(email, password);

      return true;
    } on Exception catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await repository.signOut();
  }
}
