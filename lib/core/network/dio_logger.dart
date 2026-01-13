import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioLoggerInterceptor extends Interceptor {
  DioLoggerInterceptor({bool enabled = kDebugMode}) : _enabled = enabled;

  final bool _enabled;

  static const int _maxBodyLength = 2000;
  static const List<String> _sensitiveKeys = [
    'authorization',
    'token',
    'refresh',
    'password',
    'secret',
    'clientid',
    'clientsecret',
  ];

  static int _sequence = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_enabled) {
      final requestId = (++_sequence).toString().padLeft(4, '0');
      options.extra['logId'] = requestId;
      options.extra['logStart'] = DateTime.now();

      final headers = _redactMap(options.headers);
      final query = _redactData(options.queryParameters);
      final body = _redactData(options.data);

      debugPrint('[HTTP][$requestId] --> ${options.method} ${options.uri}');
      if (headers.isNotEmpty) {
        debugPrint('[HTTP][$requestId] headers: $headers');
      }
      if (query is Map && query.isNotEmpty) {
        debugPrint('[HTTP][$requestId] query: ${_truncate(_stringify(query))}');
      }
      if (body != null) {
        debugPrint('[HTTP][$requestId] body: ${_truncate(_stringify(body))}');
      }
      debugPrint('[HTTP][$requestId] --> END');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_enabled) {
      final requestOptions = response.requestOptions;
      final requestId = requestOptions.extra['logId']?.toString() ?? '----';
      final duration = _durationMs(requestOptions);

      debugPrint(
        '[HTTP][$requestId] <-- ${response.statusCode} '
        '${requestOptions.method} ${requestOptions.uri} (${duration}ms)',
      );

      final data = _redactData(response.data);
      if (data != null) {
        debugPrint('[HTTP][$requestId] response: ${_truncate(_stringify(data))}');
      }
      debugPrint('[HTTP][$requestId] <-- END');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_enabled) {
      final requestOptions = err.requestOptions;
      final requestId = requestOptions.extra['logId']?.toString() ?? '----';
      final duration = _durationMs(requestOptions);

      debugPrint(
        '[HTTP][$requestId] <-- ERROR ${err.type} '
        '${requestOptions.method} ${requestOptions.uri} (${duration}ms)',
      );

      final response = err.response;
      if (response != null) {
        final data = _redactData(response.data);
        if (data != null) {
          debugPrint('[HTTP][$requestId] error: ${_truncate(_stringify(data))}');
        }
      } else {
        debugPrint('[HTTP][$requestId] error: ${err.message}');
      }

      debugPrint('[HTTP][$requestId] <-- END');
    }

    handler.next(err);
  }

  int _durationMs(RequestOptions options) {
    final startedAt = options.extra['logStart'];
    if (startedAt is DateTime) {
      return DateTime.now().difference(startedAt).inMilliseconds;
    }
    return 0;
  }

  Map<String, dynamic> _redactMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      final keyStr = key.toString();
      result[keyStr] =
          _isSensitiveKey(keyStr) ? '**REDACTED**' : _redactData(value);
    });
    return result;
  }

  dynamic _redactData(dynamic data) {
    if (data == null) return null;
    if (data is FormData) {
      final result = <String, dynamic>{};
      for (final field in data.fields) {
        result[field.key] = _isSensitiveKey(field.key)
            ? '**REDACTED**'
            : field.value;
      }
      if (data.files.isNotEmpty) {
        result['files'] = '[${data.files.length} files]';
      }
      return result;
    }
    if (data is Map) {
      final result = <String, dynamic>{};
      data.forEach((key, value) {
        final keyStr = key.toString();
        result[keyStr] =
            _isSensitiveKey(keyStr) ? '**REDACTED**' : _redactData(value);
      });
      return result;
    }
    if (data is Iterable) {
      return data.map(_redactData).toList();
    }
    return data;
  }

  bool _isSensitiveKey(String key) {
    final lower = key.toLowerCase();
    return _sensitiveKeys.any(lower.contains);
  }

  String _stringify(dynamic data) {
    if (data is String) return data;
    if (data is List<int>) return '<${data.length} bytes>';
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }

  String _truncate(String text) {
    if (text.length <= _maxBodyLength) return text;
    final remainder = text.length - _maxBodyLength;
    return '${text.substring(0, _maxBodyLength)}...($remainder more)';
  }
}
