import 'package:flutter/material.dart';
import 'package:mohaeng_app_service/core/utils/user_friendly_message.dart';

void showAppSnackBar(
  BuildContext context, {
  String? message,
  required String fallbackMessage,
}) {
  final resolvedMessage = toUserFriendlyMessage(
    message,
    fallbackMessage: fallbackMessage,
  );

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      content: Text(resolvedMessage),
    ),
  );
}
