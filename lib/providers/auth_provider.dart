import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// App-wide auth state. Wraps [AuthService] and exposes the current
/// [UserModel] profile (not just the raw FirebaseAuth user) so widgets
/// can read name/photo/rating directly via `context.watch`.
class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AppAuthProvider(this._authService) {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  AuthStatus status = AuthStatus.unknown;
  UserModel? profile;
  String? errorMessage;
  bool isLoading = false;

  Future<void> _onAuthChanged(fb.User? user) async {
    if (user == null) {
      status = AuthStatus.unauthenticated;
      profile = null;
      notifyListeners();
      return;
    }
    try {
      profile = await _authService.fetchProfile(user.uid);
      status = AuthStatus.authenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    return _guard(() async {
      profile = await _authService.login(email: email, password: password);
      status = AuthStatus.authenticated;
    });
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String studentId,
    required String university,
  }) async {
    return _guard(() async {
      profile = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        studentId: studentId,
        university: university,
      );
      status = AuthStatus.authenticated;
    });
  }

  Future<void> signOut() async {
    await _authService.signOut();
    profile = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> _guard(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Authentication failed';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
