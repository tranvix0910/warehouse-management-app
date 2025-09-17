import 'package:flutter/material.dart';
import '../../core/firebase_db_service.dart.dart';
import '../../utils/token_storage.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header
              _buildUserHeader(),
              const SizedBox(height: 30),

              // Stats Cards
              _buildStatsCards(),
              const SizedBox(height: 30),

              // Environment Panel (Temperature & Humidity)
              EnvironmentPanel(service: FirebaseEnvironmentService()),
              const SizedBox(height: 20),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 30),

              // Items Section
              _buildItemsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: TokenStorage.getUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final String displayName =
            (user != null && (user['username'] ?? '').toString().isNotEmpty)
            ? user['username'].toString()
            : 'Guest';
        final String? avatarURL = user?['avatar'];
        return Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF3B82F6),
              child: ClipOval(
                child: avatarURL != null && avatarURL.isNotEmpty
                    ? Image.network(
                        avatarURL,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      )
                    : Image.asset(
                        'https://res.cloudinary.com/djmeybzjk/image/upload/v1756449865/pngfind.com-placeholder-png-6104451_awuxxc.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Today',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Aug 28, 2025',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatItem('276', 'Total')),
              Expanded(child: _buildStatItem('374', 'Stock In')),
              Expanded(child: _buildStatItem('98', 'Stock Out')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.arrow_downward,
            label: 'Stock In',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.arrow_upward,
            label: 'Stock Out',
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.open_in_full, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Items',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                '+ Add item',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildItemsList(),
      ],
    );
  }

  Widget _buildItemsList() {
    final items = [
      {
        'name': 'Microsoft Surface 4',
        'sku': 'UEPYMGDO',
        'stock': '80',
        'min': '1000',
        'max': '1400',
        'image': 'assets/images/sign_in_up_page/1.png',
      },
      {
        'name': 'Acer Nitro 5',
        'sku': 'OMCZHYVIX',
        'stock': '75',
        'min': '1200',
        'max': '1500',
        'image': 'assets/images/sign_in_up_page/1.png',
      },
      {
        'name': 'Hp monoblock 12',
        'sku': 'IQHPVMSD',
        'stock': '15',
        'min': '650',
        'max': '800',
        'image': 'assets/images/sign_in_up_page/1.png',
      },
      {
        'name': 'Apple MacBook Pro 14',
        'sku': 'SMXAPGAID',
        'stock': '45',
        'min': '1800',
        'max': '2500',
        'image': 'assets/images/sign_in_up_page/1.png',
      },
      {
        'name': 'Lenovo ThinkPad',
        'sku': 'LNPHLUKGQL',
        'stock': '50',
        'min': '950',
        'max': '1200',
        'image': 'assets/images/sign_in_up_page/1.png',
      },
    ];

    return Column(
      children: items
          .map(
            (item) => _buildItemCard(
              name: item['name']!,
              sku: item['sku']!,
              stock: item['stock']!,
              min: item['min']!,
              max: item['max']!,
              imagePath: item['image']!,
            ),
          )
          .toList(),
    );
  }

  Widget _buildItemCard({
    required String name,
    required String sku,
    required String stock,
    required String min,
    required String max,
    required String imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.laptop,
                    color: Colors.white54,
                    size: 24,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: $sku',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      min,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      max,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            stock,
            style: const TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
