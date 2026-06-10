import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_api.dart';

class AuthProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _loaded = false;
  bool _isAuth = false;
  bool get isAuth => _isAuth;

  final _api = AuthApi();

  Future<void> init() async {
    if (_loaded) return;
    _prefs = await SharedPreferences.getInstance();
    final token = _prefs?.getString('token');
    _isAuth = _isValidJwt(token);
    _loaded = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final token = await _api.login(email, password);

    if (!_isValidJwt(token)) {
      _isAuth = false;
      notifyListeners();
      return false;
    }

    final jwt = token!;
    await (_prefs ??= await SharedPreferences.getInstance())
        .setString('token', jwt);

    _isAuth = true;
    notifyListeners();
    return true;
  }

  Future<RegisterResult> register(String email, String password) {
    return _api.register(email, password);
  }

  Future<void> logout() async {
    _isAuth = false;
    notifyListeners();

    await (_prefs ??= await SharedPreferences.getInstance()).remove('token');
  }

  bool _isValidJwt(String? token) {
    if (token == null || token.trim().isEmpty) return false;

    final parts = token.split('.');
    if (parts.length != 3) return false;

    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      if (payload is! Map<String, dynamic>) return false;

      final exp = payload['exp'];
      if (exp is int) {
        final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        return expiresAt.isAfter(DateTime.now());
      }

      return true;
    } catch (_) {
      return false;
    }
  }
}
