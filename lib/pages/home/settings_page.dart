import 'package:flutter/material.dart';
import '../../utils/token_storage.dart';
import '../../apis/user_api.dart';
import '../../apis/api_client.dart';
import '../../utils/snack_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to get fresh data from server first
      try {
        final response = await UserApi.getUserInfo();
        if (response['success'] == true) {
          final user = response['data'] as Map<String, dynamic>;
          await TokenStorage.saveUser(user);
          setState(() {
            _userData = user;
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        // If server fails, fall back to local storage
        print('Failed to fetch from server, using local data: $e');
      }

      // Fallback to local storage
      final user = await TokenStorage.getUser();
      setState(() {
        _userData = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showErrorSnackTop(context, 'Failed to load user data');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUserData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3B82F6),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF3B82F6),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: _userData?['avatar'] != null
                                ? Image.network(
                                    _userData!['avatar'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFF3B82F6),
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: const Color(0xFF3B82F6),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userData?['username'] ?? 'User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userData?['email'] ?? 'email@example.com',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              if (_userData?['company'] != null &&
                                  _userData!['company'] != '-')
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.business,
                                        color: Colors.grey,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _userData!['company'],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF3B82F6),
                          ),
                          onPressed: () => _showEditProfileDialog(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // User Information Section
                  const Text(
                    'User Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoItem(
                    icon: Icons.person_outline,
                    title: 'Full Name',
                    value: _userData?['surName'] != null &&
                            _userData!['surName'] != '-'
                        ? _userData!['surName']
                        : 'Not set',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoItem(
                    icon: Icons.cake_outlined,
                    title: 'Birthday',
                    value: _userData?['birthday'] != null &&
                            _userData!['birthday'] != '-'
                        ? _userData!['birthday']
                        : 'Not set',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoItem(
                    icon: Icons.business_outlined,
                    title: 'Company',
                    value: _userData?['company'] != null &&
                            _userData!['company'] != '-'
                        ? _userData!['company']
                        : 'Not set',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Email Verified',
                    value: _userData?['isEmailVerified'] == true ? 'Yes' : 'No',
                    valueColor: _userData?['isEmailVerified'] == true
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFFF6B6B),
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
                    onTap: () => _showDeleteData(context),
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

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B82F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final usernameController = TextEditingController(
      text: (_userData?['username'] as String?) ?? '',
    );
    final surNameController = TextEditingController(
      text: (_userData?['surName'] as String?) != '-' 
          ? (_userData?['surName'] as String?) ?? '' 
          : '',
    );
    final birthdayController = TextEditingController(
      text: (_userData?['birthday'] as String?) != '-' 
          ? (_userData?['birthday'] as String?) ?? '' 
          : '',
    );
    final companyController = TextEditingController(
      text: (_userData?['company'] as String?) != '-' 
          ? (_userData?['company'] as String?) ?? '' 
          : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditField(
                controller: usernameController,
                label: 'Username',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildEditField(
                controller: surNameController,
                label: 'Full Name',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),
              _buildEditField(
                controller: birthdayController,
                label: 'Birthday (YYYY-MM-DD)',
                icon: Icons.cake_outlined,
                hint: '2000-01-01',
              ),
              const SizedBox(height: 16),
              _buildEditField(
                controller: companyController,
                label: 'Company',
                icon: Icons.business_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              usernameController.dispose();
              surNameController.dispose();
              birthdayController.dispose();
              companyController.dispose();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _updateUserInfo(
                username: usernameController.text.trim(),
                surName: surNameController.text.trim(),
                birthday: birthdayController.text.trim(),
                company: companyController.text.trim(),
              );
              usernameController.dispose();
              surNameController.dispose();
              birthdayController.dispose();
              companyController.dispose();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3B82F6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3B82F6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Future<void> _updateUserInfo({
    required String username,
    required String surName,
    required String birthday,
    required String company,
  }) async {
    try {
      final response = await UserApi.updateUserInfo(
        username: username.isNotEmpty ? username : null,
        surName: surName.isNotEmpty ? surName : null,
        birthday: birthday.isNotEmpty ? birthday : null,
        company: company.isNotEmpty ? company : null,
      );

      if (response['success'] == true) {
        // Update local user data
        final updatedUser = response['data'] as Map<String, dynamic>;
        await TokenStorage.saveUser(updatedUser);

        // Reload user data
        await _loadUserData();

        if (mounted) {
          showSuccessSnackTop(context, 'Profile updated successfully');
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceFirst('Exception: ', '');
        showErrorSnackTop(context, message);
      }
    }
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
                // Call logout API
                final refreshToken = await TokenStorage.getRefreshToken();
                if (refreshToken != null) {
                  await ApiClient.dio.post(
                    '/auth/logout',
                    data: {'refreshToken': refreshToken},
                  );
                }
              } catch (e) {
                // Continue with logout even if API call fails
                print('Logout API error: $e');
              } finally {
                // Clear local storage
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
              _buildContactItem(
                  'Trần Đại Vỉ', 'vitran6366@gmail.com', context),
              const SizedBox(height: 12),
              _buildContactItem(
                  'Trần Xuân Phát', 'phattran052004@gmail.com', context),
              const SizedBox(height: 12),
              _buildContactItem(
                  'Nguyễn Lưu Minh Khánh', 'khanhnlm2509@gmail.com', context),
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

  void _showDeleteData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Delete Data',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Delete All Data\n\n'
            'Warning: This action cannot be undone. All your data including:\n'
            '• Products and inventory\n'
            '• Transactions history\n'
            '• Team information\n'
            '• Settings and preferences\n\n'
            'will be permanently deleted from the application.\n\n'
            'If you are sure you want to proceed, please contact support to request data deletion. '
            'This is a security measure to prevent accidental data loss.\n\n'
            'To delete your data, please contact our support team through the Contact Support option.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
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
            onPressed: () {
              Navigator.of(context).pop();
              _showContactSupport(context);
            },
            child: const Text(
              'Contact Support',
              style: TextStyle(color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }
}
