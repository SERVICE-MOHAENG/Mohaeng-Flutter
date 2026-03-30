String toUserFriendlyMessage(
  String? rawMessage, {
  required String fallbackMessage,
}) {
  final message = _stripFrameworkPrefixes(rawMessage?.trim() ?? '');
  if (message.isEmpty) {
    return fallbackMessage;
  }

  final mappedMessage = _mapTechnicalMessage(message, fallbackMessage);
  if (mappedMessage != null) {
    return mappedMessage;
  }

  if (_looksTechnical(message)) {
    return fallbackMessage;
  }

  return message;
}

String _stripFrameworkPrefixes(String message) {
  var value = message.trim();

  while (true) {
    final next = value
        .replaceFirst(RegExp(r'^(Exception|FormatException):\s*'), '')
        .replaceFirst(
          RegExp(r'^ApiError\([^)]+\)(?:\s*\(status:\s*\d+\))?:\s*'),
          '',
        )
        .replaceFirst(RegExp(r'^DioException(?:\s*\[[^\]]+\])?:\s*'), '')
        .trim();

    if (next == value) {
      return value;
    }

    value = next;
  }
}

String? _mapTechnicalMessage(String message, String fallbackMessage) {
  final lower = message.toLowerCase();
  final statusCode = _extractStatusCode(message);

  if (_looksLikeHtml(message) ||
      lower.contains('base_url is not set') ||
      lower.contains('baseurl is empty') ||
      lower.contains('jobid is missing') ||
      lower.contains('surveyid is missing') ||
      lower.contains('응답 형식이 올바르지 않습니다') ||
      lower.contains('response format') ||
      lower.contains('null check operator used on a null value') ||
      lower.contains('type \'')) {
    return fallbackMessage;
  }

  if (statusCode != null) {
    return switch (statusCode) {
      400 => '입력한 내용을 다시 확인해주세요.',
      401 => '인증 정보를 다시 확인해주세요.',
      403 => '접근 권한이 없어요.',
      404 => '요청한 정보를 찾지 못했어요.',
      409 => '이미 처리 중인 요청이에요. 잠시만 기다려주세요.',
      final code when code >= 500 => '서버 오류가 발생했어요. 잠시 후 다시 시도해주세요.',
      _ => null,
    };
  }

  if (lower.contains('네트워크 오류') ||
      lower.contains('network') ||
      lower.contains('connection error') ||
      lower.contains('socketexception')) {
    return '네트워크 연결을 확인해주세요.';
  }

  if (lower.contains('timeout') || lower.contains('시간이 초과')) {
    return '응답이 지연되고 있어요. 잠시 후 다시 시도해주세요.';
  }

  if (lower.contains('already processing') ||
      lower.contains('already in progress') ||
      lower.contains('already running')) {
    return '이미 처리 중인 요청이에요. 잠시만 기다려주세요.';
  }

  if (lower.contains('cancelled') || lower.contains('취소')) {
    return '요청이 취소되었어요.';
  }

  return null;
}

int? _extractStatusCode(String message) {
  final match = RegExp(r'\b([45]\d{2})\b').firstMatch(message);
  return match == null ? null : int.tryParse(match.group(1)!);
}

bool _looksTechnical(String message) {
  final lower = message.toLowerCase();
  return lower.contains('exception') ||
      lower.contains('formatexception') ||
      lower.contains('nosuchmethoderror') ||
      lower.contains('stack trace') ||
      lower.contains('dart');
}

bool _looksLikeHtml(String value) {
  final lower = value.toLowerCase();
  return lower.contains('<!doctype') ||
      lower.contains('<html') ||
      lower.contains('<head') ||
      lower.contains('<body');
}
