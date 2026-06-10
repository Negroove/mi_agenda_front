import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class RegisterResult {
  const RegisterResult({
    required this.success,
    this.statusCode,
    this.message,
  });

  final bool success;
  final int? statusCode;
  final String? message;

  bool get alreadyExists => statusCode == 409;
}

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<RegisterResult> register(String email, String password) async {
    try {
      final res = await _client.dio.post(
        '/api/auth/register',
        data: {
          'email': email.trim(),
          'password': password.trim(),
        },
      );

      debugPrint('AuthApi.register statusCode: ${res.statusCode}');
      debugPrint('AuthApi.register response body: ${res.data}');

      return RegisterResult(
        success: _isSuccess(res.statusCode),
        statusCode: res.statusCode,
        message: _responseMessage(res.data),
      );
    } on DioException catch (e) {
      debugPrint('AuthApi.register error: ${e.message}');
      return RegisterResult(
        success: false,
        statusCode: e.response?.statusCode,
        message: _responseMessage(e.response?.data),
      );
    } catch (e) {
      debugPrint('AuthApi.register error: $e');
      return const RegisterResult(success: false);
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final res = await _client.dio.post(
        '/api/auth/login',
        data: {
          'email': email.trim(),
          'password': password.trim(),
        },
      );

      debugPrint('AuthApi.login statusCode: ${res.statusCode}');

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

  String? _responseMessage(dynamic data) {
    final decoded = _tryResponseAsMap(data);
    final message = decoded?['mensaje'] ?? decoded?['message'];
    return message is String ? message : null;
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

  Map<String, dynamic>? _tryResponseAsMap(dynamic data) {
    try {
      return _responseAsMap(data);
    } catch (_) {
      return null;
    }
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
