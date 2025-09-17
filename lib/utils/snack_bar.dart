// lib/utils/app_snackbar.dart
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

void showSuccessSnackTop(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  showTopSnackBar(
    overlay,
    CustomSnackBar.success(message: message),
    displayDuration: const Duration(milliseconds: 1500),
  );
}

void showErrorSnackTop(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  showTopSnackBar(
    overlay,
    CustomSnackBar.error(message: message),
    displayDuration: const Duration(milliseconds: 1500),
  );
}

void showInfoSnackTop(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  showTopSnackBar(
    overlay,
    CustomSnackBar.info(message: message),
    displayDuration: const Duration(milliseconds: 1500),
  );
}