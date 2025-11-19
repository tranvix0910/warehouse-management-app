import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/firebase_db_service.dart.dart';

class FirebaseDebugPage extends StatefulWidget {
  const FirebaseDebugPage({Key? key}) : super(key: key);

  @override
  State<FirebaseDebugPage> createState() => _FirebaseDebugPageState();
}

class _FirebaseDebugPageState extends State<FirebaseDebugPage> {
  final FirebaseEnvironmentService _service = FirebaseEnvironmentService();
  String _status = 'Chưa kiểm tra';
  String _details = '';
  bool _isLoading = false;
  Color _statusColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Firebase Debug',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              _buildStatusCard(),
              const SizedBox(height: 20),

              // Test Buttons
              _buildTestButton(
                icon: Icons.wifi_tethering,
                label: 'Test Connection',
                color: const Color(0xFF3B82F6),
                onPressed: _testConnection,
              ),
              const SizedBox(height: 12),
              _buildTestButton(
                icon: Icons.refresh,
                label: 'Read Data',
                color: const Color(0xFF10B981),
                onPressed: _readData,
              ),
              const SizedBox(height: 12),
              _buildTestButton(
                icon: Icons.edit,
                label: 'Write Normal Data (25°C, 60%)',
                color: const Color(0xFF10B981),
                onPressed: _writeTestData,
              ),
              const SizedBox(height: 12),
              _buildTestButton(
                icon: Icons.warning,
                label: 'Test Warning (45°C, 75%) 🟡',
                color: const Color(0xFFF59E0B),
                onPressed: _writeWarningData,
              ),
              const SizedBox(height: 12),
              _buildTestButton(
                icon: Icons.dangerous,
                label: 'Test Critical Both (65°C, 85%) 🔴🔴',
                color: const Color(0xFFEF4444),
                onPressed: _writeCriticalData,
              ),
              const SizedBox(height: 12),
              _buildTestButton(
                icon: Icons.water,
                label: 'Test Only Humidity (30°C, 90%) 🔵🔴',
                color: const Color(0xFF3B82F6),
                onPressed: _writeHumidityOnlyWarning,
              ),
              const SizedBox(height: 12),
              _buildTestButton(
                icon: Icons.credit_card,
                label: 'Write Test RFID',
                color: const Color(0xFF8B5CF6),
                onPressed: _writeTestRFID,
              ),
              const SizedBox(height: 12),
              _buildTestButton(
                icon: Icons.qr_code,
                label: 'Write Test QR Code',
                color: const Color(0xFF8B5CF6),
                onPressed: _writeTestQRCode,
              ),
              const SizedBox(height: 12),
              _buildTestButton(
                icon: Icons.delete_outline,
                label: 'Clear Data',
                color: const Color(0xFF64748B),
                onPressed: _clearData,
              ),
              const SizedBox(height: 30),

              // Details Card
              if (_details.isNotEmpty) _buildDetailsCard(),

              const SizedBox(height: 30),

              // Live Stream
              _buildLiveStreamCard(),

              const SizedBox(height: 30),

              // Database Info
              _buildDatabaseInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Icon(
            _isLoading ? Icons.hourglass_empty : _getStatusIcon(),
            size: 48,
            color: _statusColor,
          ),
          const SizedBox(height: 12),
          Text(
            _status,
            style: TextStyle(
              color: _statusColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTestButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 20),
              SizedBox(width: 8),
              Text(
                'Chi Tiết',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              _details,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStreamCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stream, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 8),
              Text(
                'Live Stream',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<EnvironmentReading>(
            stream: _service.streamReading(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white70,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F1D1D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(
                      color: Color(0xFFFECACA),
                      fontSize: 12,
                    ),
                  ),
                );
              }

              final reading = snapshot.data ??
                  const EnvironmentReading(
                    temperatureCelsius: 0,
                    humidityPercent: 0,
                  );

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildMetricRow(
                      '🌡️ Nhiệt độ',
                      '${reading.temperatureCelsius.toStringAsFixed(1)}°C',
                    ),
                    const Divider(color: Color(0xFF334155), height: 20),
                    _buildMetricRow(
                      '💧 Độ ẩm',
                      '${reading.humidityPercent.toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDatabaseInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.storage, color: Color(0xFFF59E0B), size: 20),
              SizedBox(width: 8),
              Text(
                'Database Info',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Database URL', 
              'mobile-app-development-1a585-default-rtdb.asia-southeast1.firebasedatabase.app'),
          const SizedBox(height: 8),
          _buildInfoRow('Path', 'sensors'),
          const SizedBox(height: 8),
          _buildInfoRow('Region', 'asia-southeast1 (Singapore)'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon() {
    if (_status.contains('Thành công')) return Icons.check_circle;
    if (_status.contains('Lỗi')) return Icons.error;
    return Icons.help_outline;
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Đang kiểm tra...';
      _details = '';
      _statusColor = Colors.orange;
    });

    try {
      final isConnected = await _service.testConnection();
      setState(() {
        _isLoading = false;
        if (isConnected) {
          _status = '✅ Kết nối thành công!';
          _statusColor = const Color(0xFF10B981);
          _details = 'Firebase Realtime Database đang hoạt động tốt.\n'
              'Dữ liệu đã được tìm thấy tại path "sensors".';
        } else {
          _status = '⚠️ Không có dữ liệu';
          _statusColor = Colors.orange;
          _details = 'Kết nối thành công nhưng không tìm thấy dữ liệu.\n'
              'Vui lòng thêm dữ liệu vào path "sensors".';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Lỗi kết nối';
        _statusColor = const Color(0xFFEF4444);
        _details = 'Error: $e\n\n'
            'Kiểm tra:\n'
            '1. Firebase Rules (cho phép đọc dữ liệu)\n'
            '2. Internet connection\n'
            '3. Firebase configuration';
      });
    }
  }

  Future<void> _readData() async {
    setState(() {
      _isLoading = true;
      _status = 'Đang đọc dữ liệu...';
      _details = '';
      _statusColor = Colors.orange;
    });

    try {
      final ref = FirebaseDatabase.instance.ref('sensors');
      final snapshot = await ref.get();

      setState(() {
        _isLoading = false;
        if (snapshot.exists) {
          _status = '✅ Đọc dữ liệu thành công!';
          _statusColor = const Color(0xFF10B981);
          _details = 'Data:\n${snapshot.value}\n\n'
              'Type: ${snapshot.value.runtimeType}';
        } else {
          _status = '⚠️ Không có dữ liệu';
          _statusColor = Colors.orange;
          _details = 'Path "sensors" không có dữ liệu.\n'
              'Click "Write Test Data" để tạo dữ liệu mẫu.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Lỗi đọc dữ liệu';
        _statusColor = const Color(0xFFEF4444);
        _details = 'Error: $e';
      });
    }
  }

  Future<void> _writeTestData() async {
    setState(() {
      _isLoading = true;
      _status = 'Đang ghi dữ liệu...';
      _details = '';
      _statusColor = Colors.orange;
    });

    try {
      final ref = FirebaseDatabase.instance.ref('sensors');
      await ref.set({
        'temperature': 25.5,
        'humidity': 60,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      setState(() {
        _isLoading = false;
        _status = '✅ Ghi dữ liệu thành công!';
        _statusColor = const Color(0xFF10B981);
        _details = 'Test data đã được ghi vào path "sensors":\n'
            '{\n'
            '  "temperature": 25.5,\n'
            '  "humidity": 60,\n'
            '  "timestamp": ${DateTime.now().millisecondsSinceEpoch}\n'
            '}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Lỗi ghi dữ liệu';
        _statusColor = const Color(0xFFEF4444);
        _details = 'Error: $e\n\n'
            'Kiểm tra Firebase Rules:\n'
            'Rules phải cho phép write permission.';
      });
    }
  }
  
  Future<void> _writeWarningData() async {
    setState(() {
      _isLoading = true;
      _status = 'Đang ghi dữ liệu cảnh báo...';
      _details = '';
      _statusColor = Colors.orange;
    });

    try {
      final ref = FirebaseDatabase.instance.ref('sensors');
      await ref.set({
        'temperature': 45.0, // Warning level
        'humidity': 75.0,    // Warning level
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      setState(() {
        _isLoading = false;
        _status = '⚠️ Ghi dữ liệu warning thành công!';
        _statusColor = const Color(0xFFF59E0B);
        _details = 'Warning data (màu vàng):\n'
            '{\n'
            '  "temperature": 45.0°C,\n'
            '  "humidity": 75%\n'
            '}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Lỗi ghi dữ liệu';
        _statusColor = const Color(0xFFEF4444);
        _details = 'Error: $e';
      });
    }
  }
  
  Future<void> _writeCriticalData() async {
    setState(() {
      _isLoading = true;
      _status = 'Đang ghi dữ liệu nguy hiểm...';
      _details = '';
      _statusColor = Colors.orange;
    });

    try {
      final ref = FirebaseDatabase.instance.ref('sensors');
      await ref.set({
        'temperature': 65.0, // Critical level
        'humidity': 85.0,    // Critical level
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      setState(() {
        _isLoading = false;
        _status = '🚨 Ghi dữ liệu critical thành công!';
        _statusColor = const Color(0xFFEF4444);
        _details = 'Critical data (cả 2 đỏ + thông báo):\n'
            '{\n'
            '  "temperature": 65.0°C,\n'
            '  "humidity": 85%\n'
            '}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Lỗi ghi dữ liệu';
        _statusColor = const Color(0xFFEF4444);
        _details = 'Error: $e';
      });
    }
  }
  
  Future<void> _writeHumidityOnlyWarning() async {
    setState(() {
      _isLoading = true;
      _status = 'Đang ghi test...';
      _details = '';
      _statusColor = Colors.orange;
    });

    try {
      final ref = FirebaseDatabase.instance.ref('sensors');
      await ref.set({
        'temperature': 30.0, // Normal
        'humidity': 90.0,    // Critical - chỉ độ ẩm đỏ
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      setState(() {
        _isLoading = false;
        _status = '✅ Test: Chỉ độ ẩm cảnh báo!';
        _statusColor = const Color(0xFF3B82F6);
        _details = 'Nhiệt độ bình thường, độ ẩm cao:\n'
            '{\n'
            '  "temperature": 30.0°C (bình thường),\n'
            '  "humidity": 90% (ĐỎ!)\n'
            '}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Lỗi ghi dữ liệu';
        _statusColor = const Color(0xFFEF4444);
        _details = 'Error: $e';
      });
    }
  }

  Future<void> _writeTestRFID() async {
    setState(() {
      _isLoading = true;
      _status = 'Đang ghi RFID test...';
      _details = '';
      _statusColor = Colors.orange;
    });

    try {
      // Generate test RFID UUID
      final random = DateTime.now().millisecondsSinceEpoch;
      final part1 = (random % 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
      final part2 = ((random ~/ 1000) % 0xFFFF).toRadixString(16).padLeft(4, '0');
      final part3 = ((random ~/ 10000) % 0xFFFF).toRadixString(16).padLeft(4, '0');
      final part4 = ((random ~/ 100000) % 0xFFFF).toRadixString(16).padLeft(4, '0');
      final part5 = ((random ~/ 1000000) % 0xFFFFFFFFFFFF).toRadixString(16).padLeft(12, '0');
      final testRFID = '${part1}-${part2}-${part3}-${part4}-${part5}'.toUpperCase();
      
      final ref = FirebaseDatabase.instance.ref('sensors');
      await ref.update({
        'rfid_uid': testRFID,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      setState(() {
        _isLoading = false;
        _status = '✅ Ghi RFID test thành công!';
        _statusColor = const Color(0xFF8B5CF6);
        _details = 'Test RFID UUID:\n$testRFID\n\n'
            'Bây giờ có thể scan RFID trong Add Item page!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Lỗi ghi RFID';
        _statusColor = const Color(0xFFEF4444);
        _details = 'Error: $e';
      });
    }
  }
  
  Future<void> _writeTestQRCode() async {
    setState(() {
      _isLoading = true;
      _status = 'Đang ghi QR test...';
      _details = '';
      _statusColor = Colors.orange;
    });

    try {
      // Generate test QR data
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testQR = 'QR-${timestamp.toString().substring(7)}';
      
      final ref = FirebaseDatabase.instance.ref('sensors');
      await ref.update({
        'qr_data': testQR,
        'check_qr': false,
        'timestamp': timestamp,
      });

      setState(() {
        _isLoading = false;
        _status = '✅ Ghi QR test thành công!';
        _statusColor = const Color(0xFF8B5CF6);
        _details = 'Test QR Code:\n$testQR\n\n'
            'Bây giờ có thể scan QR trong Add Item page!\n\n'
            'Note: check_qr = false';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Lỗi ghi QR';
        _statusColor = const Color(0xFFEF4444);
        _details = 'Error: $e';
      });
    }
  }
  
  Future<void> _clearData() async {
    setState(() {
      _isLoading = true;
      _status = 'Đang xóa dữ liệu...';
      _details = '';
      _statusColor = Colors.orange;
    });

    try {
      final ref = FirebaseDatabase.instance.ref('sensors');
      await ref.remove();

      setState(() {
        _isLoading = false;
        _status = '✅ Xóa dữ liệu thành công!';
        _statusColor = const Color(0xFF10B981);
        _details = 'Tất cả dữ liệu tại path "sensors" đã được xóa.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Lỗi xóa dữ liệu';
        _statusColor = const Color(0xFFEF4444);
        _details = 'Error: $e';
      });
    }
  }
}

