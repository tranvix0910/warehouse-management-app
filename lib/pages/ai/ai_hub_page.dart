import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../apis/ai_api.dart';
import 'ai_chatbot_page.dart';
import 'ai_report_page.dart';

class AIHubPage extends ConsumerStatefulWidget {
  const AIHubPage({super.key});

  @override
  ConsumerState<AIHubPage> createState() => _AIHubPageState();
}

class _AIHubPageState extends ConsumerState<AIHubPage> {
  bool _isApiKeyConfigured = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkApiKeyStatus();
  }

  Future<void> _checkApiKeyStatus() async {
    try {
      final settings = await AIApi.getGeminiSettings();
      if (mounted) {
        setState(() {
          _isApiKeyConfigured = settings.isConfigured;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'AI Assistant',
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
          if (_isApiKeyConfigured)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
                  SizedBox(width: 4),
                  Text(
                    'API Ready',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isApiKeyConfigured) _buildApiKeyWarning(),
                  
                  const SizedBox(height: 8),
                  
                  // AI Features Header
                  const Text(
                    'AI Features',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Powered by Google Gemini AI',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // AI Chatbot Card
                  _buildFeatureCard(
                    icon: Icons.smart_toy,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'AI Chatbot',
                    subtitle: 'Ask questions about your warehouse',
                    description: 'Get instant answers about inventory, transactions, stock levels, and more using natural language.',
                    features: [
                      'Natural language queries',
                      'Real-time warehouse data',
                      'Smart recommendations',
                    ],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AIChatbotPage()),
                    ),
                    enabled: _isApiKeyConfigured,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // AI Report Card
                  _buildFeatureCard(
                    icon: Icons.analytics,
                    iconColor: const Color(0xFF10B981),
                    title: 'AI Report',
                    subtitle: 'Generate intelligent reports',
                    description: 'Create comprehensive weekly or monthly reports with AI-powered insights and analysis.',
                    features: [
                      'Weekly & monthly reports',
                      'Financial analysis',
                      'Inventory insights',
                    ],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AIReportPage()),
                    ),
                    enabled: _isApiKeyConfigured,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Stats
                  if (_isApiKeyConfigured) ...[
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.inventory_2,
                            label: 'Stock Status',
                            onTap: () => _navigateToChatWithQuestion('Tình trạng tồn kho hiện tại?'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.warning_amber,
                            label: 'Low Stock',
                            onTap: () => _navigateToChatWithQuestion('Sản phẩm nào sắp hết hàng?'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.trending_up,
                            label: 'Top Products',
                            onTap: () => _navigateToChatWithQuestion('Top 5 sản phẩm bán chạy nhất?'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.attach_money,
                            label: 'Revenue',
                            onTap: () => _navigateToChatWithQuestion('Tổng doanh thu tháng này?'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildApiKeyWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withAlpha(77),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF59E0B),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'API Key Required',
                  style: TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Please configure your Gemini API Key in Settings to use AI features.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Go to Settings > AI Features to configure API Key'),
                        backgroundColor: Color(0xFF3B82F6),
                      ),
                    );
                  },
                  child: const Text(
                    'Go to Settings →',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String description,
    required List<String> features,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled 
                ? iconColor.withAlpha(77) 
                : Colors.grey.withAlpha(51),
          ),
        ),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: enabled ? iconColor : Colors.grey,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features.map((feature) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: iconColor,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        feature,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              if (!enabled) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, color: Colors.grey, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Configure API Key to unlock',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF334155),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF3B82F6), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChatWithQuestion(String question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIChatbotPage(initialQuestion: question),
      ),
    );
  }
}
