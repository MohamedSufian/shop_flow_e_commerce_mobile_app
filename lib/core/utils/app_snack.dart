import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

void showAppSnack(
  BuildContext context,
  String message, {
  IconData icon = Icons.info_outline_rounded,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(context.tr(message))),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(label: context.tr(actionLabel), textColor: const Color(0xFFFFB199), onPressed: onAction ?? () {}),
      ),
    );
}
