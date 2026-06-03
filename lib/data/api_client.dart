import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class ApiClient {
  ApiClient() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['Content-Type'] = 'application/json';

          if (!_isAuthEndpoint(options.path)) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('token');

            if (token != null && token.trim().isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
      ),
    );
  }

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      validateStatus: (_) => true,
    ),
  );

  bool _isAuthEndpoint(String path) {
    return path.contains('/api/auth/login') ||
        path.contains('/api/auth/register');
  }
}
