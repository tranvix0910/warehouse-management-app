import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_provider.dart';
import 'transaction_provider.dart';
import 'report_provider.dart';
import 'notification_provider.dart';
import 'auth_provider.dart';

export 'product_provider.dart';
export 'transaction_provider.dart';
export 'report_provider.dart';
export 'notification_provider.dart';
export 'auth_provider.dart';

final productNotifierProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier();
});

final transactionNotifierProvider = StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier();
});

final reportNotifierProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier();
});

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
