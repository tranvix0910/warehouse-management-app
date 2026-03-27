import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EnvironmentReading {
  final double temperatureCelsius;
  final double humidityPercent;

  const EnvironmentReading({
    required this.temperatureCelsius,
    required this.humidityPercent,
  });

  factory EnvironmentReading.fromMap(Map<dynamic, dynamic> data) {
    final temp = data['temperature'];
    final hum = data['humidity'];
    double parseNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return EnvironmentReading(
      temperatureCelsius: parseNum(temp),
      humidityPercent: parseNum(hum),
    );
  }
}

class FirebaseEnvironmentService {
  final FirebaseDatabase _database;
  final String path;

  FirebaseEnvironmentService({
    FirebaseDatabase? database,
    this.path = 'sensors',
  }) : _database = database ?? FirebaseDatabase.instance;

  Stream<EnvironmentReading> streamReading() {
    final ref = _database.ref(path);
    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      
      // Debug: In ra giá trị nhận được
      print('🔍 Firebase Data Received: $value');
      print('🔍 Data Type: ${value.runtimeType}');
      
      if (value is Map) {
        return EnvironmentReading.fromMap(value);
      }
      
      // Nếu không có dữ liệu, trả về giá trị mặc định
      print('⚠️ No valid data found at path: $path');
      return const EnvironmentReading(
        temperatureCelsius: 0,
        humidityPercent: 0,
      );
    }).handleError((error) {
      // Xử lý lỗi và log chi tiết
      print('❌ Firebase Stream Error: $error');
      final errorString = error.toString().toLowerCase();
      
      if (errorString.contains('permission') || errorString.contains('denied')) {
        print('💡 FIX: Vào Firebase Console → Realtime Database → Rules');
        print('💡 Set rules: { "rules": { "sensors": { ".read": true, ".write": true } } }');
        throw Exception('Lỗi quyền truy cập Firebase. Cần cấu hình Rules.');
      }
      
      throw Exception('Không thể kết nối Firebase: $error');
    });
  }
  
  // Thêm method để test connection
  Future<bool> testConnection() async {
    try {
      final ref = _database.ref(path);
      final snapshot = await ref.get();
      print('✅ Firebase Connection Test Success');
      print('📊 Data at path "$path": ${snapshot.value}');
      return snapshot.exists;
    } catch (e) {
      print('❌ Firebase Connection Test Failed: $e');
      return false;
    }
  }
}

class EnvironmentPanel extends StatelessWidget {
  final FirebaseEnvironmentService service;
  final EdgeInsetsGeometry padding;

  const EnvironmentPanel({
    super.key,
    required this.service,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EnvironmentReading>(
      stream: service.streamReading(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildContainer(
            context,
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Đang tải dữ liệu môi trường...',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          print('❌ UI Error: ${snapshot.error}');
          final errorString = snapshot.error.toString().toLowerCase();
          final isPermissionError = errorString.contains('permission') || errorString.contains('quyền');
          
          return _buildContainer(
            context,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off,
                    color: Color(0xFFEF4444),
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Không thể tải dữ liệu môi trường',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    snapshot.error.toString().replaceAll('Exception: ', ''),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isPermissionError) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        _showFixDialog(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Hướng dẫn fix',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        final reading =
            snapshot.data ??
            const EnvironmentReading(temperatureCelsius: 0, humidityPercent: 0);
        
        // Kiểm tra nếu dữ liệu = 0, có thể là chưa có dữ liệu
        final hasValidData = reading.temperatureCelsius != 0 || reading.humidityPercent != 0;
        
        // Kiểm tra cảnh báo từng thông số riêng biệt
        final temp = reading.temperatureCelsius;
        final humidity = reading.humidityPercent;
        
        // Check critical và show alert nếu cần
        if ((temp > 60 || humidity > 80) && hasValidData) {
          _showCriticalAlert(context, temp, humidity);
        }
        
        // Xác định màu cho từng thông số
        Color tempBackgroundColor;
        Color tempIconColor;
        bool tempAlert = false;
        
        if (temp > 60) {
          tempBackgroundColor = const Color(0xFF991B1B); // Đỏ
          tempIconColor = Colors.white;
          tempAlert = true;
        } else if (temp > 40) {
          tempBackgroundColor = const Color(0xFF92400E); // Vàng
          tempIconColor = const Color(0xFFFBBF24);
          tempAlert = true;
        } else {
          tempBackgroundColor = const Color(0xFF1E293B); // Bình thường
          tempIconColor = const Color(0xFFFF6B6B);
          tempAlert = false;
        }
        
        Color humidityBackgroundColor;
        Color humidityIconColor;
        bool humidityAlert = false;
        
        if (humidity > 80) {
          humidityBackgroundColor = const Color(0xFF991B1B); // Đỏ
          humidityIconColor = Colors.white;
          humidityAlert = true;
        } else if (humidity > 70) {
          humidityBackgroundColor = const Color(0xFF92400E); // Vàng
          humidityIconColor = const Color(0xFFFBBF24);
          humidityAlert = true;
        } else {
          humidityBackgroundColor = const Color(0xFF1E293B); // Bình thường
          humidityIconColor = const Color(0xFF3B82F6);
          humidityAlert = false;
        }
        
        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricTileWithBackground(
                context,
                icon: Icons.thermostat,
                label: 'Nhiệt độ',
                value: hasValidData 
                    ? '${reading.temperatureCelsius.toStringAsFixed(1)}°C'
                    : '--°C',
                iconColor: tempIconColor,
                backgroundColor: tempBackgroundColor,
                isAlert: tempAlert,
              ),
              _divider(),
              _metricTileWithBackground(
                context,
                icon: Icons.water_drop,
                label: 'Độ ẩm',
                value: hasValidData
                    ? '${reading.humidityPercent.toStringAsFixed(0)}%'
                    : '--%',
                iconColor: humidityIconColor,
                backgroundColor: humidityBackgroundColor,
                isAlert: humidityAlert,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContainer(
    BuildContext context, {
    required Widget child,
    Color? backgroundColor,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: backgroundColor != null 
              ? backgroundColor.withOpacity(0.5)
              : const Color(0xFF334155),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _metricTileWithBackground(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color backgroundColor,
    bool isAlert = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: backgroundColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(icon, color: iconColor, size: 20)),
                  if (isAlert)
                    const Positioned(
                      top: 2,
                      right: 2,
                      child: Icon(
                        Icons.warning,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFF334155),
    );
  }
  
  void _showCriticalAlert(BuildContext context, double temp, double humidity) {
    // Chỉ hiển thị một lần, tránh spam
    if (!context.mounted) return;
    
    Future.delayed(Duration.zero, () {
      if (!context.mounted) return;
      
      final messages = <String>[];
      if (temp > 60) {
        messages.add('🔥 Nhiệt độ: ${temp.toStringAsFixed(1)}°C (Nguy hiểm!)');
      }
      if (humidity > 80) {
        messages.add('💧 Độ ẩm: ${humidity.toStringAsFixed(0)}% (Quá cao!)');
      }
      
      if (messages.isEmpty) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'CẢNH BÁO NGHIÊM TRỌNG!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...messages.map((msg) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(msg, style: const TextStyle(fontSize: 12)),
              )),
              const SizedBox(height: 4),
              const Text(
                '⚠️ Cần kiểm tra ngay!',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF991B1B),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    });
  }
  
  void _showFixDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Color(0xFFFBBF24), size: 20),
            SizedBox(width: 8),
            Text(
              'Cách Fix Lỗi Permission',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bước 1: Vào Firebase Console',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'https://console.firebase.google.com/',
                style: TextStyle(color: Color(0xFF3B82F6), fontSize: 11),
              ),
              SizedBox(height: 12),
              Text(
                'Bước 2: Chọn Project',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'mobile-app-development-1a585',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              SizedBox(height: 12),
              Text(
                'Bước 3: Vào Rules',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Realtime Database → Rules',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              SizedBox(height: 12),
              Text(
                'Bước 4: Paste Rules',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 8),
              SelectableText(
                '{\n  "rules": {\n    "sensors": {\n      ".read": true,\n      ".write": true\n    }\n  }\n}',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Bước 5: Click Publish',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Sau đó restart app',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Đóng',
              style: TextStyle(color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }
}