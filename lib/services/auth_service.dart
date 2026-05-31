import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _keyLoggedIn = 'auth_logged_in';
  static const _keyUsername = 'auth_username';
  static const _keyUsers = 'auth_users';

  static const _defaultUsers = {
    'player': '123456',
    'admin': 'admin123',
  };

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final users = _loadUsers();
    var changed = false;
    for (final entry in _defaultUsers.entries) {
      if (!users.containsKey(entry.key)) {
        users[entry.key] = entry.value;
        changed = true;
      }
    }
    if (changed) {
      await _saveUsers(users);
    }
  }

  Map<String, String> _loadUsers() {
    final raw = _prefs?.getString(_keyUsers);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as String));
  }

  Future<void> _saveUsers(Map<String, String> users) async {
    await _prefs?.setString(_keyUsers, jsonEncode(users));
  }

  bool get isLoggedIn => _prefs?.getBool(_keyLoggedIn) ?? false;

  String? get currentUsername => _prefs?.getString(_keyUsername);

  Future<bool> login(String username, String password) async {
    final name = username.trim();
    if (name.isEmpty || password.isEmpty) return false;

    final users = _loadUsers();
    if (users[name] != password) return false;

    await _prefs?.setBool(_keyLoggedIn, true);
    await _prefs?.setString(_keyUsername, name);
    return true;
  }

  Future<String?> register(String username, String password) async {
    final name = username.trim();
    if (name.isEmpty || password.isEmpty) {
      return 'Vui lòng nhập đầy đủ thông tin';
    }
    if (name.length < 3) {
      return 'Tên đăng nhập phải có ít nhất 3 ký tự';
    }
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    final users = _loadUsers();
    if (users.containsKey(name)) {
      return 'Tên đăng nhập đã tồn tại';
    }

    users[name] = password;
    await _saveUsers(users);
    await _prefs?.setBool(_keyLoggedIn, true);
    await _prefs?.setString(_keyUsername, name);
    return null;
  }

  Future<void> logout() async {
    await _prefs?.setBool(_keyLoggedIn, false);
    await _prefs?.remove(_keyUsername);
  }
}
