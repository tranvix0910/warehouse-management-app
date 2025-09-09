// lib/utils/app_snackbar.dart
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

/// Hiển thị snackbar success ở top
void showSuccessSnackTop(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  showTopSnackBar(
    overlay,
    CustomSnackBar.success(message: message),
    displayDuration: const Duration(milliseconds: 1500), // thời gian hiển thị
  );
}

/// Hiển thị snackbar error ở top
void showErrorSnackTop(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  showTopSnackBar(
    overlay,
    CustomSnackBar.error(message: message),
    displayDuration: const Duration(milliseconds: 1500),
  );
}

/// Hiển thị snackbar info ở top
void showInfoSnackTop(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  showTopSnackBar(
    overlay,
    CustomSnackBar.info(message: message),
    displayDuration: const Duration(milliseconds: 1500),
  );
}