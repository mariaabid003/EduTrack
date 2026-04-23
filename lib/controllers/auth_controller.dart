// lib/controllers/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../enums/app_enums.dart';

class AuthController extends ChangeNotifier {
  AuthState _state = AuthState.idle;
  String? _errorMessage;
  UserModel? _currentUser;
  bool _rememberMe = false;

  // Registration form state
  Gender? _selectedGender;
  bool _registerPasswordVisible = false;
  bool _registerConfirmPasswordVisible = false;

  // Login form state
  bool _loginPasswordVisible = false;

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get rememberMe => _rememberMe;
  Gender? get selectedGender => _selectedGender;
  bool get registerPasswordVisible => _registerPasswordVisible;
  bool get registerConfirmPasswordVisible => _registerConfirmPasswordVisible;
  bool get loginPasswordVisible => _loginPasswordVisible;

  // Keys for SharedPreferences
  static const String _keyRememberMe = 'remember_me';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_full_name';
  static const String _keyUserGender = 'user_gender';
  static const String _keyUserPassword = 'user_password';
  static const String _keyIsLoggedIn = 'is_logged_in';

  AuthController() {
    _loadRememberMe();
  }

  // ──────────────── REGISTRATION ────────────────

  void setGender(Gender? gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void toggleRegisterPasswordVisibility() {
    _registerPasswordVisible = !_registerPasswordVisible;
    notifyListeners();
  }

  void toggleRegisterConfirmPasswordVisibility() {
    _registerConfirmPasswordVisible = !_registerConfirmPasswordVisible;
    notifyListeners();
  }

  Future<bool> register(UserModel user) async {
    _setState(AuthState.loading);
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserEmail, user.email);
      await prefs.setString(_keyUserName, user.fullName);
      await prefs.setString(_keyUserGender, user.gender.name);
      await prefs.setString(_keyUserPassword, user.password);

      _setState(AuthState.success);
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      _setState(AuthState.failure);
      return false;
    }
  }

  // ──────────────── LOGIN ────────────────

  void toggleLoginPasswordVisibility() {
    _loginPasswordVisible = !_loginPasswordVisible;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString(_keyUserEmail) ?? '';
      final storedPassword = prefs.getString(_keyUserPassword) ?? '';

      if (email.trim() == storedEmail && password == storedPassword) {
        _currentUser = UserModel(
          fullName: prefs.getString(_keyUserName) ?? '',
          email: storedEmail,
          password: storedPassword,
          gender: Gender.values.firstWhere(
            (g) => g.name == prefs.getString(_keyUserGender),
            orElse: () => Gender.preferNotToSay,
          ),
        );

        if (_rememberMe) {
          await prefs.setBool(_keyRememberMe, true);
          await prefs.setBool(_keyIsLoggedIn, true);
        } else {
          await prefs.setBool(_keyRememberMe, false);
          await prefs.setBool(_keyIsLoggedIn, false);
        }

        _setState(AuthState.success);
        return true;
      } else {
        _errorMessage = 'Invalid email or password. Please try again.';
        _setState(AuthState.failure);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      _setState(AuthState.failure);
      return false;
    }
  }

  Future<bool> checkAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

      if (rememberMe && isLoggedIn) {
        _currentUser = UserModel(
          fullName: prefs.getString(_keyUserName) ?? '',
          email: prefs.getString(_keyUserEmail) ?? '',
          password: prefs.getString(_keyUserPassword) ?? '',
          gender: Gender.values.firstWhere(
            (g) => g.name == prefs.getString(_keyUserGender),
            orElse: () => Gender.preferNotToSay,
          ),
        );
        _rememberMe = true;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    _currentUser = null;
    _rememberMe = false;
    _loginPasswordVisible = false;
    _setState(AuthState.idle);
  }

  // ──────────────── HELPERS ────────────────

  void resetState() {
    _state = AuthState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> _loadRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _rememberMe = prefs.getBool(_keyRememberMe) ?? false;
      notifyListeners();
    } catch (_) {}
  }
}
