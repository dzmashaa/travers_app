import 'package:flutter/material.dart';

class SnackbarUtils {
  static void show(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    _buildAndShow(
      ScaffoldMessenger.of(context),
      Theme.of(context).primaryColor,
      message,
      isError,
    );
  }

  static void showLoading(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.blueGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(days: 1),
      ),
    );
  }

  static void hideSafe(ScaffoldMessengerState messenger) {
    messenger.clearSnackBars();
  }

  static void showSafe({
    required ScaffoldMessengerState messenger,
    required String message,
    required Color primaryColor,
    bool isError = true,
  }) {
    _buildAndShow(messenger, primaryColor, message, isError);
  }

  static void _buildAndShow(
    ScaffoldMessengerState messenger,
    Color primaryColor,
    String message,
    bool isError,
  ) {
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
