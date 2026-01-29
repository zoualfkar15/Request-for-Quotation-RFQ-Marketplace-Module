import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs requests as a copy-pasteable `curl` command.
///
/// - Masks Authorization header by default.
class CurlLoggerInterceptor extends Interceptor {
  CurlLoggerInterceptor({
    this.printOnDebugOnly = true,
    this.maskAuthorization = true,
    this.logResponseBody = true,
    this.maxBodyChars = 2000,
  });

  final bool printOnDebugOnly;
  final bool maskAuthorization;
  final bool logResponseBody;
  final int maxBodyChars;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!printOnDebugOnly || kDebugMode) {
      debugPrint(_toCurl(options));
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!printOnDebugOnly || kDebugMode) {
      final code = response.statusCode;
      final method = response.requestOptions.method.toUpperCase();
      final url = response.requestOptions.uri.toString();
      debugPrint('⬅️  [$code] $method $url');
      if (logResponseBody) {
        final body = _safeString(response.data);
        if (body != null && body.isNotEmpty) {
          debugPrint(_trim(body, maxBodyChars));
        }
      }
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!printOnDebugOnly || kDebugMode) {
      final code = err.response?.statusCode;
      final method = err.requestOptions.method.toUpperCase();
      final url = err.requestOptions.uri.toString();
      debugPrint('❌  [$code] $method $url');
      debugPrint('Error: ${err.message}');
      if (logResponseBody && err.response != null) {
        final body = _safeString(err.response?.data);
        if (body != null && body.isNotEmpty) {
          debugPrint(_trim(body, maxBodyChars));
        }
      }
    }
    super.onError(err, handler);
  }

  String _toCurl(RequestOptions o) {
    final buffer = StringBuffer();

    final method = o.method.toUpperCase();
    final url = o.uri.toString();

    buffer.write("curl -i -X $method '$url'");

    final headers = Map<String, dynamic>.from(o.headers);
    if (maskAuthorization && headers.containsKey('Authorization')) {
      headers['Authorization'] = 'Bearer ***';
    }

    headers.forEach((key, value) {
      if (value == null) return;
      final v = value.toString().replaceAll("'", r"'\''");
      buffer.write(" \\\n  -H '$key: $v'");
    });

    final data = o.data;
    final body = _encodeBody(data);
    if (body != null && body.isNotEmpty) {
      final escaped = body.replaceAll("'", r"'\''");
      buffer.write(" \\\n  --data-raw '$escaped'");
    }

    return buffer.toString();
  }

  String? _encodeBody(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is FormData) {
      // Keep it simple for now.
      return null;
    }
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }

  String? _safeString(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }

  String _trim(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}\n... (trimmed ${s.length - max} chars)';
  }
}
