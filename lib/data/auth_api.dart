import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class AuthApi {
  Future<String?> login(String usuario, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');

    try {
      final body = jsonEncode({
  'usuario': usuario.trim(),
  'password': password.trim(),
});

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint('AuthApi.login url: $url');
      debugPrint('AuthApi.login statusCode: ${res.statusCode}');
      debugPrint('AuthApi.login response body: ${res.body}');

      if (res.statusCode < 200 || res.statusCode >= 300) {
        return null;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('AuthApi.login error: respuesta JSON inesperada.');
        return null;
      }

      final token = decoded['token'] ?? decoded['accessToken'];
      if (token is String && _isValidJwt(token)) {
        return token;
      }

      debugPrint('AuthApi.login error: no se encontro token JWT valido.');
      return null;
    } catch (e) {
      debugPrint('AuthApi.login error: $e');
      return null;
    }
  }

  bool _isValidJwt(String token) {
    return token.trim().isNotEmpty && token.split('.').length == 3;
  }
}
