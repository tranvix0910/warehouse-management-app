import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/nav_bar.dart';
import '../providers/providers.dart';
import '../services/notification_service.dart';
import 'home/dashboard_page.dart';
import 'home/items_page.dart';
import 'home/transactions_page.dart';
import 'home/report_page.dart';
import 'ai/ai_hub_page.dart';
import 'home/settings_page.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ItemsPage(),
    const TransactionsPage(),
    const ReportPage(),
    const AIHubPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkLowStockOnStartup();
  }

  Future<void> _checkLowStockOnStartup() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final notificationSettings = ref.read(notificationSettingsProvider);
    if (notificationSettings.pushNotificationEnabled) {
      await NotificationService().checkLowStockAndNotify(
        minimumQuantity: notificationSettings.minimumQuantityAlert,
      );
    }
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
