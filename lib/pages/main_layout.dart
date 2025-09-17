import 'package:flutter/material.dart';
import '../common/nav_bar.dart';
import 'home/dashboard_page.dart';
import 'home/items_page.dart';
import 'home/transactions_page.dart';
import 'home/report_page.dart';
import 'home/settings_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ItemsPage(),
    const TransactionsPage(),
    const ReportPage(),
    const SettingsPage(),
  ];

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
