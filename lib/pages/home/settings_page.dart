import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _teamNameController = TextEditingController(text: 'Computer Stock Team');
  final TextEditingController _descriptionController = TextEditingController(text: 'Central computer inventory');
  final TextEditingController _teamMembersController = TextEditingController(text: '1 member');
  String? _editingField; // Track which field is being edited
  
  @override
  void initState() {
    super.initState();
    // Listen to team name changes to update the Team Info section
    _teamNameController.addListener(() {
      setState(() {});
    });
  }
  
  @override
  void dispose() {
    _teamNameController.dispose();
    _descriptionController.dispose();
    _teamMembersController.dispose();
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _teamNameController.text.isEmpty 
                              ? 'Computer Stock Team' 
                              : _teamNameController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'ID: 1352781',
                          style: TextStyle(
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
            
            _buildEditableItem(
              title: 'Team Name',
              controller: _teamNameController,
              fieldKey: 'teamName',
              isEditing: _editingField == 'teamName',
              onTap: () {
                setState(() {
                  _editingField = 'teamName';
                });
              },
              onEditingComplete: () {
                setState(() {
                  _editingField = null;
                });
              },
            ),
            const SizedBox(height: 8),
            _buildEditableItem(
              title: 'Description',
              controller: _descriptionController,
              fieldKey: 'description',
              isEditing: _editingField == 'description',
              onTap: () {
                setState(() {
                  _editingField = 'description';
                });
              },
              onEditingComplete: () {
                setState(() {
                  _editingField = null;
                });
              },
            ),
            const SizedBox(height: 8),
            _buildEditableItem(
              title: 'Team Members',
              controller: _teamMembersController,
              fieldKey: 'teamMembers',
              isEditing: _editingField == 'teamMembers',
              onTap: () {
                setState(() {
                  _editingField = 'teamMembers';
                });
              },
              onEditingComplete: () {
                setState(() {
                  _editingField = null;
                });
              },
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

  Widget _buildEditableItem({
    required String title,
    required TextEditingController controller,
    required String fieldKey,
    required bool isEditing,
    required VoidCallback onTap,
    required VoidCallback onEditingComplete,
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
      child: isEditing
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onEditingComplete: onEditingComplete,
                  onSubmitted: (_) => onEditingComplete(),
                ),
              ],
            )
          : InkWell(
              onTap: onTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.text.isEmpty ? 'Tap to edit' : controller.text,
                          style: TextStyle(
                            color: controller.text.isEmpty ? Colors.grey : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
        // Copy email to clipboard or open email client
        // For now, just show a snackbar
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
