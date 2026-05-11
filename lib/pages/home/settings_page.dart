import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart' hide debugPrint;
import '../../services/role_service.dart';
import '../../services/offline_database.dart';
import '../../services/confirmation_service.dart';
import '../../services/batch_operations_service.dart';
import '../../apis/ai_api.dart';
import '../../apis/api_client.dart';
import '../../utils/snack_bar.dart';
import '../../utils/token_storage.dart';
import '../profile/profile_page.dart';
import '../activity/activity_log_page.dart';

Color _withOpacity(Color color, double opacity) {
  return color.withAlpha((opacity * 255).round());
}

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _notificationService = NotificationService();
  final _roleService = RoleService();
  final _offlineDb = OfflineDatabase();
  final _batchOps = BatchOperationsService();
  
  // Gemini API Key state
  bool _isGeminiConfigured = false;
  String? _maskedApiKey;
  DateTime? _geminiUpdatedAt;
  bool _isLoadingGemini = true;

  @override
  void initState() {
    super.initState();
    _loadGeminiSettings();
  }

  Future<void> _loadGeminiSettings() async {
    setState(() => _isLoadingGemini = true);
    try {
      final settings = await AIApi.getGeminiSettings();
      setState(() {
        _isGeminiConfigured = settings.isConfigured;
        _maskedApiKey = settings.apiKey;
        _geminiUpdatedAt = settings.updatedAt;
        _isLoadingGemini = false;
      });
    } catch (e) {
      setState(() => _isLoadingGemini = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final authState = ref.watch(authNotifierProvider);
    final localeState = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadGeminiSettings,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _roleService.getRoleColor(_roleService.currentRole),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        _roleService.getRoleIcon(_roleService.currentRole),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  authState.username ?? 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _withOpacity(_roleService.getRoleColor(_roleService.currentRole), 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _roleService.getRoleName(_roleService.currentRole),
                                  style: TextStyle(
                                    color: _roleService.getRoleColor(_roleService.currentRole),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authState.email ?? '',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Connection Status
            _buildConnectionStatus(),
            
            const SizedBox(height: 16),
            
            // Team Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _withOpacity(const Color(0xFF3B82F6), 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.groups,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Computer Stock Team',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Team ID: 1 Member',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Manage Team',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildSettingsItem(
              title: 'Team Name',
              value: 'Computer Stock Team',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Description',
              value: 'Central computer inventory',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Currency',
              value: 'USD',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Team Members',
              value: '1 member',
              onTap: () {},
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Attribute Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildSettingsItem(
              title: 'Categories',
              value: '4',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Attributes',
              value: '5',
              onTap: () {},
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Partner Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildSettingsItem(
              title: 'Suppliers',
              value: '4 suppliers',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Customers',
              value: '3 customers',
              onTap: () {},
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Low Stock Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _testNotification(notificationSettings),
                  icon: const Icon(Icons.notifications_active, size: 18),
                  label: const Text('Test'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications,
                        color: notificationSettings.pushNotificationEnabled 
                            ? const Color(0xFF3B82F6) 
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Push Notification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: notificationSettings.pushNotificationEnabled,
                    onChanged: (value) async {
                      await ref.read(notificationSettingsProvider.notifier).togglePushNotification(value);
                      if (mounted) {
                        showSuccessSnackTop(
                          context, 
                          value ? 'Push notifications enabled' : 'Push notifications disabled',
                        );
                      }
                    },
                    activeColor: const Color(0xFF3B82F6),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.volume_up,
                        color: notificationSettings.soundEnabled 
                            ? const Color(0xFF3B82F6) 
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Sound',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: notificationSettings.soundEnabled,
                    onChanged: (value) async {
                      await ref.read(notificationSettingsProvider.notifier).toggleSound(value);
                    },
                    activeColor: const Color(0xFF3B82F6),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.vibration,
                        color: notificationSettings.vibrationEnabled 
                            ? const Color(0xFF3B82F6) 
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Vibration',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: notificationSettings.vibrationEnabled,
                    onChanged: (value) async {
                      await ref.read(notificationSettingsProvider.notifier).toggleVibration(value);
                    },
                    activeColor: const Color(0xFF3B82F6),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            _buildMinQuantitySettingsItem(notificationSettings),
            
            const SizedBox(height: 8),
            
            GestureDetector(
              onTap: () => _checkLowStockNow(notificationSettings),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _withOpacity(const Color(0xFF3B82F6), 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Check Low Stock Now',
                      style: TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Language',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildLanguageSelector(localeState),
            
            const SizedBox(height: 24),
            
            const Text(
              'AI Features',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildGeminiApiKeySection(),
            
            const SizedBox(height: 24),
            
            const Text(
              'Data Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildSettingsItem(
              title: 'Activity Log',
              value: '',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActivityLogPage()),
              ),
              icon: Icons.history,
              iconColor: const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Import Products',
              value: '',
              onTap: () => _importProducts(),
              icon: Icons.upload_file,
              iconColor: const Color(0xFF10B981),
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Download Import Template',
              value: '',
              onTap: () => _downloadTemplate(),
              icon: Icons.download,
              iconColor: const Color(0xFF3B82F6),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildSettingsItem(
              title: 'About Application',
              value: '',
              onTap: () => _showAboutApplication(context),
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Contact Support',
              value: '',
              onTap: () => _showContactSupport(context),
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'FAQ',
              value: '',
              onTap: () => _showFAQ(context),
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Privacy Policy',
              value: '',
              onTap: () => _showPrivacyPolicy(context),
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Delete Data',
              value: '',
              onTap: () => _showDeleteDataDialog(),
              isDestructive: true,
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMinQuantitySettingsItem(NotificationSettings settings) {
    return GestureDetector(
      onTap: () => _showMinQuantityPicker(settings),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _withOpacity(Colors.black, 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  color: Color(0xFFFFD93D),
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Minimum Quantity Alert',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _withOpacity(const Color(0xFFFFD93D), 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${settings.minimumQuantityAlert} units',
                    style: const TextStyle(
                      color: Color(0xFFFFD93D),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMinQuantityPicker(NotificationSettings settings) {
    int selectedValue = settings.minimumQuantityAlert;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Minimum Quantity Alert',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get notified when stock falls below this level',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: selectedValue > 1 
                            ? () => setModalState(() => selectedValue--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 40,
                        color: const Color(0xFF3B82F6),
                        disabledColor: Colors.grey,
                      ),
                      const SizedBox(width: 24),
                      Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$selectedValue',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: selectedValue < 100 
                            ? () => setModalState(() => selectedValue++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 40,
                        color: const Color(0xFF3B82F6),
                        disabledColor: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [5, 10, 15, 20, 25, 50].map((value) {
                      final isSelected = selectedValue == value;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedValue = value),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected 
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF334155),
                            ),
                          ),
                          child: Text(
                            '$value',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await ref.read(notificationSettingsProvider.notifier)
                                .setMinimumQuantityAlert(selectedValue);
                            if (mounted) {
                              Navigator.pop(context);
                              showSuccessSnackTop(
                                context, 
                                'Alert threshold set to $selectedValue units',
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Save', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _testNotification(NotificationSettings settings) async {
    if (!settings.pushNotificationEnabled) {
      showErrorSnackTop(context, 'Please enable push notifications first');
      return;
    }

    await _notificationService.showLocalNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Warehouse Management App',
    );
    
    if (mounted) {
      showSuccessSnackTop(context, 'Test notification sent!');
    }
  }

  Future<void> _checkLowStockNow(NotificationSettings settings) async {
    if (!settings.pushNotificationEnabled) {
      showErrorSnackTop(context, 'Please enable push notifications first');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await _notificationService.checkLowStockAndNotify(
      minimumQuantity: settings.minimumQuantityAlert,
    );

    if (mounted) {
      Navigator.pop(context);
      showSuccessSnackTop(context, 'Stock check completed!');
    }
  }

  void _showDeleteDataDialog() async {
    final confirmed = await ConfirmationService.confirmDataClear(context);
    
    if (confirmed) {
      await _offlineDb.clearAllCache();
      if (mounted) {
        showSuccessSnackTop(context, 'Local data cleared successfully');
      }
    }
  }

  Widget _buildConnectionStatus() {
    return StreamBuilder<bool>(
      stream: _offlineDb.onConnectivityChanged,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _withOpacity(isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B), 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _withOpacity(isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B), 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? 'Online' : 'Offline Mode',
                      style: TextStyle(
                        color: isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isOnline ? 'Connected to server' : 'Using cached data',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (!isOnline)
                FutureBuilder<List>(
                  future: _offlineDb.getPendingActions(),
                  builder: (context, snapshot) {
                    final pendingCount = snapshot.data?.length ?? 0;
                    if (pendingCount > 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$pendingCount pending',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              if (isOnline)
                TextButton(
                  onPressed: () async {
                    final result = await _offlineDb.syncWithServer();
                    if (mounted) {
                      if (result.success) {
                        showSuccessSnackTop(context, result.message);
                      } else {
                        showErrorSnackTop(context, result.message);
                      }
                    }
                  },
                  child: const Text('Sync', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String value,
    required VoidCallback onTap,
    bool isDestructive = false,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _withOpacity(Colors.black, 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: iconColor ?? Colors.grey, size: 20),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: TextStyle(
                    color: isDestructive ? Colors.red : Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (value.isNotEmpty)
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: isDestructive ? Colors.red : Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(LocaleState localeState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.language,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Language',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLanguageOption(
                label: 'English',
                flag: '🇺🇸',
                isSelected: localeState.locale.languageCode == 'en',
                onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en', 'US')),
              ),
              const SizedBox(width: 12),
              _buildLanguageOption(
                label: 'Tiếng Việt',
                flag: '🇻🇳',
                isSelected: localeState.locale.languageCode == 'vi',
                onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('vi', 'VN')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _withOpacity(const Color(0xFF3B82F6), 0.2) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF334155),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF3B82F6) : Colors.grey,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _importProducts() async {
    try {
      final result = await _batchOps.pickImportFile();
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final products = await _batchOps.parseImportFile(file);
      
      if (mounted) Navigator.pop(context);

      if (products.isEmpty) {
        if (mounted) {
          showErrorSnackTop(context, 'No valid products found in file');
        }
        return;
      }

      final validCount = products.where((p) => p.isValid).length;
      final invalidCount = products.length - validCount;

      final shouldImport = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Import Products', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Found ${products.length} products in file:',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                  const SizedBox(width: 8),
                  Text('$validCount valid', style: const TextStyle(color: Colors.white)),
                ],
              ),
              if (invalidCount > 0) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.error, color: Color(0xFFEF4444), size: 16),
                    const SizedBox(width: 8),
                    Text('$invalidCount invalid', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
              child: Text('Import $validCount Products'),
            ),
          ],
        ),
      );

      if (shouldImport != true) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final importResult = await _batchOps.importProducts(products);
      
      if (mounted) {
        Navigator.pop(context);
        if (importResult.success) {
          showSuccessSnackTop(context, 'Successfully imported ${importResult.processedCount} products');
        } else {
          showErrorSnackTop(
            context, 
            'Imported ${importResult.processedCount}, failed ${importResult.failedCount}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showErrorSnackTop(context, 'Import failed: $e');
      }
    }
  }

  void _downloadTemplate() {
    final template = _batchOps.generateCsvTemplate();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('CSV Template', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Required columns:',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Product Name\n• SKU\n• Category\n• Cost\n• Price\n• Quantity',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 12),
              const Text(
                'Optional columns:',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• RAM\n• GPU\n• Color\n• Processor',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  template,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildGeminiApiKeySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: _withOpacity(_isGeminiConfigured 
                ? const Color(0xFF10B981) 
                : const Color(0xFFF59E0B), 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _withOpacity(_isGeminiConfigured 
                      ? const Color(0xFF10B981) 
                      : const Color(0xFFF59E0B), 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.key,
                  color: _isGeminiConfigured 
                      ? const Color(0xFF10B981) 
                      : const Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gemini API Key',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          _isGeminiConfigured ? Icons.check_circle : Icons.warning,
                          color: _isGeminiConfigured 
                              ? const Color(0xFF10B981) 
                              : const Color(0xFFF59E0B),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isLoadingGemini 
                              ? 'Checking...'
                              : _isGeminiConfigured 
                                  ? 'Configured'
                                  : 'Not configured',
                          style: TextStyle(
                            color: _isGeminiConfigured 
                                ? const Color(0xFF10B981) 
                                : const Color(0xFFF59E0B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showGeminiApiKeyDialog(),
                icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
              ),
            ],
          ),
          if (_isGeminiConfigured && _maskedApiKey != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.vpn_key, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _maskedApiKey!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  if (_geminiUpdatedAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Updated ${_formatDate(_geminiUpdatedAt!)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _launchUrl('https://aistudio.google.com/apikey'),
            child: const Row(
              children: [
                Icon(Icons.open_in_new, color: Color(0xFF3B82F6), size: 14),
                SizedBox(width: 6),
                Text(
                  'Get API Key from Google AI Studio',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showGeminiApiKeyDialog() {
    final controller = TextEditingController();
    bool isLoading = false;
    bool obscureText = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: Row(
              children: [
                const Icon(Icons.key, color: Color(0xFF3B82F6)),
                const SizedBox(width: 12),
                Text(
                  _isGeminiConfigured ? 'Update API Key' : 'Configure API Key',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your Gemini API Key to enable AI features.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  obscureText: obscureText,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: 'AIzaSy...',
                    hintStyle: TextStyle(color: Colors.grey[700]),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => setDialogState(() => obscureText = !obscureText),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _launchUrl('https://aistudio.google.com/apikey'),
                  child: const Row(
                    children: [
                      Icon(Icons.help_outline, color: Color(0xFF3B82F6), size: 14),
                      SizedBox(width: 6),
                      Text(
                        'How to get API Key?',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              if (_isGeminiConfigured)
                TextButton(
                  onPressed: isLoading ? null : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1E293B),
                        title: const Text('Remove API Key?', style: TextStyle(color: Colors.white)),
                        content: const Text(
                          'AI features will be disabled.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirmed == true) {
                      setDialogState(() => isLoading = true);
                      try {
                        await AIApi.deleteGeminiApiKey();
                        if (mounted) {
                          Navigator.pop(context);
                          await _loadGeminiSettings();
                          showSuccessSnackTop(context, 'API Key removed');
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (mounted) {
                          showErrorSnackTop(context, e.toString());
                        }
                      }
                    }
                  },
                  child: const Text('Remove', style: TextStyle(color: Colors.red)),
                ),
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isLoading || controller.text.isEmpty ? null : () async {
                  setDialogState(() => isLoading = true);
                  try {
                    await AIApi.saveGeminiApiKey(controller.text);
                    if (mounted) {
                      Navigator.pop(context);
                      await _loadGeminiSettings();
                      showSuccessSnackTop(context, 'API Key saved successfully');
                    }
                  } catch (e) {
                    setDialogState(() => isLoading = false);
                    if (mounted) {
                      showErrorSnackTop(context, e.toString().replaceAll('Exception: ', ''));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                final refreshToken = await TokenStorage.getRefreshToken();
                if (refreshToken != null) {
                  await ApiClient.dio.post(
                    '/auth/logout',
                    data: {'refreshToken': refreshToken},
                  );
                }
              } catch (e) {
                debugPrint('Logout API error: $e');
              } finally {
                await TokenStorage.clearTokens();
                await TokenStorage.clearUser();
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  showSuccessSnackTop(context, 'Logged out successfully');
                  Navigator.pushReplacementNamed(context, '/signin');
                }
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutApplication(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'About Application',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Warehouse Management Application\n\n'
            'Version: 1.0.0\n\n'
            'This application is designed to help manage warehouse inventory efficiently. '
            'It provides features for tracking stock levels, managing suppliers and customers, '
            'and monitoring inventory movements.\n\n'
            'Developed with Flutter for cross-platform compatibility.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Contact Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'For support, please contact:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildContactItem('Trần Đại Vỉ', 'vitran6366@gmail.com', context),
              const SizedBox(height: 12),
              _buildContactItem('Trần Xuân Phát', 'phattran052004@gmail.com', context),
              const SizedBox(height: 12),
              _buildContactItem('Nguyễn Lưu Minh Khánh', 'khanhnlm2509@gmail.com', context),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String name, String email, BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email: $email'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.email, color: Color(0xFF3B82F6), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFAQ(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Q: How do I add a new product?\n'
            'A: Navigate to the Products section and tap the add button to create a new product entry.\n\n'
            'Q: How do I update stock levels?\n'
            'A: Use the Stock In or Stock Out features in the Transactions section to update inventory levels.\n\n'
            'Q: Can I export my data?\n'
            'A: Yes, you can export your data through the Settings menu under Data Management.\n\n'
            'Q: How do I add team members?\n'
            'A: Go to Settings > Manage Team > Team Members to add or manage team members.\n\n'
            'Q: What should I do if I encounter an error?\n'
            'A: Please contact our support team through the Contact Support option in Settings.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy\n\n'
            'Last Updated: 2024\n\n'
            '1. Information We Collect\n'
            'We collect information that you provide directly to us, including inventory data, '
            'team information, and transaction records.\n\n'
            '2. How We Use Your Information\n'
            'We use the information to provide and improve our warehouse management services, '
            'process transactions, and communicate with you.\n\n'
            '3. Data Security\n'
            'We implement appropriate security measures to protect your data against unauthorized '
            'access, alteration, disclosure, or destruction.\n\n'
            '4. Data Retention\n'
            'We retain your data for as long as necessary to provide our services and comply '
            'with legal obligations.\n\n'
            '5. Your Rights\n'
            'You have the right to access, update, or delete your personal information at any time '
            'through the application settings.\n\n'
            '6. Contact Us\n'
            'If you have questions about this Privacy Policy, please contact us through the '
            'Contact Support option in Settings.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }
}

