import 'package:flutter/material.dart';

/// A non-blocking banner for a failed API call (e.g. a refresh that
/// couldn't reach the backend) — shown without hiding whatever data is
/// already on screen, which is the whole point of it being a banner and
/// not a full-screen error state.
void showErrorBanner(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentMaterialBanner()
    ..showMaterialBanner(
      MaterialBanner(
        content: Text(message),
        leading: const Icon(Icons.error_outline),
        actions: [
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
}
