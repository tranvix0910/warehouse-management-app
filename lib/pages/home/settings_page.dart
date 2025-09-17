import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isPushNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team Info Section
            Container(
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
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.computer,
                      color: Colors.white,
                      size: 24,
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ID: 1352781',
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
            
            const SizedBox(height: 16),
            
            // Create New Team Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Color(0xFF3B82F6),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Create New Team',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Manage Team Section
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
            
            // Attribute Settings Section
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
            
            // Partner Settings Section
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
            
            // Low Stock Alert Section
            const Text(
              'Low Stock Alert',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                  const Text(
                    'Push Notification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Switch(
                    value: isPushNotificationEnabled,
                    onChanged: (value) {
                      setState(() {
                        isPushNotificationEnabled = value;
                      });
                    },
                    activeThumbColor: const Color(0xFF3B82F6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Minimum Quantity Alert',
              value: '15 units',
              onTap: () {},
            ),
            
            const SizedBox(height: 24),
            
            // Information Section
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
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Contact Support',
              value: '',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'FAQ',
              value: '',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Privacy Policy',
              value: '',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              title: 'Delete Data',
              value: '',
              onTap: () {},
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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
}
