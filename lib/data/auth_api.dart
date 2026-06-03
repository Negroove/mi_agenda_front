import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<bool> register(String usuario, String password) async {
    try {
      final res = await _client.dio.post(
        '/api/auth/register',
        data: {
          'usuario': usuario.trim(),
          'password': password.trim(),
        },
      );

      debugPrint('AuthApi.register statusCode: ${res.statusCode}');
      debugPrint('AuthApi.register response body: ${res.data}');

      return _isSuccess(res.statusCode);
    } on DioException catch (e) {
      debugPrint('AuthApi.register error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('AuthApi.register error: $e');
      return false;
    }
  }

  Future<String?> login(String usuario, String password) async {
    try {
      final res = await _client.dio.post(
        '/api/auth/login',
        data: {
          'usuario': usuario.trim(),
          'password': password.trim(),
        },
      );

      debugPrint('AuthApi.login statusCode: ${res.statusCode}');
      debugPrint('AuthApi.login response body: ${res.data}');

      if (!_isSuccess(res.statusCode)) {
        return null;
      }

      final decoded = _responseAsMap(res.data);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('AuthApi.login error: respuesta JSON inesperada.');
        return null;
      }

      final token = decoded['token'] ?? decoded['accessToken'];
      if (token is String && _isValidJwt(token)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return token;
      }

      debugPrint('AuthApi.login error: no se encontro token JWT valido.');
      return null;
    } on DioException catch (e) {
      debugPrint('AuthApi.login error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('AuthApi.login error: $e');
      return null;
    }
  }

  bool _isSuccess(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  Map<String, dynamic>? _responseAsMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    return null;
  }

  bool _isValidJwt(String token) {
    if (token.trim().isEmpty) return false;

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
