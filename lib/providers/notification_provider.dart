import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool pushNotificationEnabled;
  final int minimumQuantityAlert;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationSettings({
    this.pushNotificationEnabled = true,
    this.minimumQuantityAlert = 15,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  NotificationSettings copyWith({
    bool? pushNotificationEnabled,
    int? minimumQuantityAlert,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      pushNotificationEnabled: pushNotificationEnabled ?? this.pushNotificationEnabled,
      minimumQuantityAlert: minimumQuantityAlert ?? this.minimumQuantityAlert,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushNotificationEnabled': pushNotificationEnabled,
      'minimumQuantityAlert': minimumQuantityAlert,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      pushNotificationEnabled: map['pushNotificationEnabled'] ?? true,
      minimumQuantityAlert: map['minimumQuantityAlert'] ?? 15,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _loadSettings();
  }

  static const String _prefsKey = 'notification_settings';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('${_prefsKey}_push') ?? true;
    final minQty = prefs.getInt('${_prefsKey}_min_qty') ?? 15;
    final sound = prefs.getBool('${_prefsKey}_sound') ?? true;
    final vibration = prefs.getBool('${_prefsKey}_vibration') ?? true;

    state = NotificationSettings(
      pushNotificationEnabled: enabled,
      minimumQuantityAlert: minQty,
      soundEnabled: sound,
      vibrationEnabled: vibration,
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefsKey}_push', state.pushNotificationEnabled);
    await prefs.setInt('${_prefsKey}_min_qty', state.minimumQuantityAlert);
    await prefs.setBool('${_prefsKey}_sound', state.soundEnabled);
    await prefs.setBool('${_prefsKey}_vibration', state.vibrationEnabled);
  }

  Future<void> togglePushNotification(bool enabled) async {
    state = state.copyWith(pushNotificationEnabled: enabled);
    await _saveSettings();
  }

  Future<void> setMinimumQuantityAlert(int quantity) async {
    state = state.copyWith(minimumQuantityAlert: quantity);
    await _saveSettings();
  }

  Future<void> toggleSound(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _saveSettings();
  }

  Future<void> toggleVibration(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    await _saveSettings();
  }
}
