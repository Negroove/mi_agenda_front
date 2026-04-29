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

  Future<bool> login(String usuario, String password) async {
    final token = await _api.login(usuario, password);

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

  Future<void> logout() async {
    _isAuth = false;
    notifyListeners();

    await (_prefs ??= await SharedPreferences.getInstance()).remove('token');
  }

  bool _isValidJwt(String? token) {
    return token != null &&
        token.trim().isNotEmpty &&
        token.split('.').length == 3;
  }
}
