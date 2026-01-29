import 'dart:convert';

import 'package:dio/dio.dart';

import '../../error/api_exception.dart';
import '../../service/storage/local_storage_service.dart';

class ApiClient {
  ApiClient({required this.dio, required this.storage}) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = storage.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          final status = e.response?.statusCode ?? 0;
          final isAuthCall =
              (e.requestOptions.path.contains('api/auth/login') ||
                  e.requestOptions.path.contains('api/auth/register') ||
                  e.requestOptions.path.contains('api/auth/refresh') ||
                  e.requestOptions.path.contains('api/auth/logout'));
          final alreadyRetried = e.requestOptions.extra['retried'] == true;

          if (status == 401 && !isAuthCall && !alreadyRetried) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              final ro = e.requestOptions;
              ro.extra['retried'] = true;
              ro.headers['Authorization'] = 'Bearer ${storage.accessToken}';
              try {
                final clone = await dio.fetch(ro);
                return handler.resolve(clone);
              } catch (e2) {
                return handler.reject(e2 as DioException);
              }
            }
          }

          handler.next(e);
        },
      ),
    );
  }

  final Dio dio;
  final LocalStorageService storage;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await dio.get(path, queryParameters: query);
      return _decode(res);
    } on DioException catch (e) {
      if (e.response != null) return _decode(e.response!);
      throw ApiException(message: e.message ?? 'Network error', statusCode: 0);
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final res = await dio.post(path, data: data);
      return _decode(res);
    } on DioException catch (e) {
      if (e.response != null) return _decode(e.response!);
      throw ApiException(message: e.message ?? 'Network error', statusCode: 0);
    }
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      final res = await dio.patch(path, data: data);
      return _decode(res);
    } on DioException catch (e) {
      if (e.response != null) return _decode(e.response!);
      throw ApiException(message: e.message ?? 'Network error', statusCode: 0);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final res = await dio.delete(path);
      return _decode(res);
    } on DioException catch (e) {
      if (e.response != null) return _decode(e.response!);
      throw ApiException(message: e.message ?? 'Network error', statusCode: 0);
    }
  }

  dynamic _decode(Response res) {
    final status = res.statusCode ?? 0;
    final body = res.data;

    // Yii2 may return Map/List directly or a JSON string depending on response type.
    dynamic decoded = body;
    if (body is String && body.isNotEmpty) {
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = body;
      }
    }

    if (status >= 200 && status < 300) {
      return decoded;
    }

    // Try to extract message
    String message = 'Request failed';
    if (decoded is Map && decoded['message'] is String) {
      message = decoded['message'];
    } else if (decoded is String && decoded.isNotEmpty) {
      message = decoded;
    }

    throw ApiException(message: message, statusCode: status);
  }

  Future<bool> _tryRefreshToken() async {
    final refresh = storage.refreshToken;
    if (refresh == null || refresh.isEmpty) return false;

    // Use a "clean" Dio instance to avoid recursive interceptor calls.
    final tmp = Dio(
      BaseOptions(
        baseUrl: dio.options.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    try {
      final res =
          await tmp.post('api/auth/refresh', data: {'refresh_token': refresh});
      final decoded = _decode(res);
      if (decoded is! Map<String, dynamic>) return false;

      final accessToken = decoded['access_token'] as String?;
      final newRefresh = decoded['refresh_token'] as String?;
      final user = decoded['user'] as Map<String, dynamic>?;
      if (accessToken == null || newRefresh == null || user == null)
        return false;

      await storage.setAuth(
        accessToken: accessToken,
        refreshToken: newRefresh,
        role: (user['role'] ?? '') as String,
        userId: (user['id'] as num).toInt(),
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      tmp.close(force: true);
    }
  }
}
