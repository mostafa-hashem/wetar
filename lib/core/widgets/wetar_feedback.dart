import 'package:material_ui/material_ui.dart';

import '../../features/personalization/presentation/theme/wetar_tokens.dart';

/// Centralized UI feedback helper (enforces consistent tokenized toasts and undo actions).
class WetarFeedback {
  WetarFeedback._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showInfo(BuildContext context, String message) {
    _show(context, message: message, isError: false);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message: message, isError: false, isSuccess: true);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message: message, isError: true);
  }

  static void showUndo(
    BuildContext context, {
    required String message,
    required String undoLabel,
    required VoidCallback onUndo,
  }) {
    _show(
      context,
      message: message,
      isError: false,
      actionLabel: undoLabel,
      onAction: onUndo,
    );
  }

  static void showGlobalMessage(String message, {bool isError = false}) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required bool isError,
    bool isSuccess = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final tokens = context.wetarTokens;
    final messenger =
        ScaffoldMessenger.maybeOf(context) ?? messengerKey.currentState;
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    final Color border = isError
        ? tokens.danger
        : (isSuccess ? tokens.success : tokens.accentPrimary);
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: tokens.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusCard),
          side: BorderSide(color: border.withValues(alpha: 0.55)),
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: tokens.inkPrimary),
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: tokens.accentPrimary,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
