import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final class ApiLoggingConfig {
  const ApiLoggingConfig({
    required this.enabled,
    this.maxBodyLength = 2000,
  });

  final bool enabled;
  final int maxBodyLength;

  factory ApiLoggingConfig.fromEnvironment({
    bool fallbackEnabled = !kReleaseMode,
  }) {
    final enabledValue = _readEnv('API_LOGGING_ENABLED');
    final maxBodyLengthValue = _readEnv('API_LOGGING_MAX_BODY_LENGTH');

    return ApiLoggingConfig(
      enabled: _parseBool(enabledValue) ?? fallbackEnabled,
      maxBodyLength: _parseInt(maxBodyLengthValue) ?? 2000,
    );
  }
}

String? _readEnv(String key) {
  try {
    return dotenv.env[key];
  } catch (_) {
    return null;
  }
}

bool? _parseBool(String? value) {
  if (value == null) return null;
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return null;
}

int? _parseInt(String? value) {
  if (value == null) return null;
  final normalized = value.trim();
  if (normalized.isEmpty) return null;
  return int.tryParse(normalized);
}
