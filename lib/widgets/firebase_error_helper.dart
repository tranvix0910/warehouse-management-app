import 'package:flutter/material.dart';

class FirebaseErrorHelper {
  /// Hiển thị thông báo lỗi Firebase
  static void showError(BuildContext context, dynamic error) {
    final errorMessage = _parseError(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lỗi Firebase',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    errorMessage,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF991B1B),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Fix',
          textColor: Colors.white,
          onPressed: () {
            _showFixDialog(context, error);
          },
        ),
      ),
    );
  }

  /// Parse error message
  static String _parseError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('permission')) {
      return 'Lỗi quyền truy cập. Kiểm tra Firebase Rules.';
    } else if (errorString.contains('network') || errorString.contains('timeout')) {
      return 'Lỗi kết nối mạng. Kiểm tra internet.';
    } else if (errorString.contains('not found') || errorString.contains('null')) {
      return 'Không tìm thấy dữ liệu. Thêm dữ liệu vào Firebase.';
    } else {
      return errorString.replaceAll('exception:', '').trim();
    }
  }

  /// Hiển thị dialog với hướng dẫn fix
  static void _showFixDialog(BuildContext context, dynamic error) {
    final errorString = error.toString().toLowerCase();
    String title = 'Cách Khắc Phục';
    String content = '';

    if (errorString.contains('permission')) {
      title = 'Lỗi Quyền Truy Cập';
      content = '''
1. Vào Firebase Console
2. Chọn Realtime Database → Rules
3. Thêm rule:
   {
     "rules": {
       "sensors": {
         ".read": true,
         ".write": true
       }
     }
   }
4. Click Publish
5. Restart app
''';
    } else if (errorString.contains('network') || errorString.contains('timeout')) {
      title = 'Lỗi Kết Nối';
      content = '''
1. Kiểm tra kết nối internet
2. Thử tắt VPN/Proxy
3. Chạy app trên thiết bị thật
4. Kiểm tra firewall settings
''';
    } else if (errorString.contains('not found') || errorString.contains('null')) {
      title = 'Không Có Dữ Liệu';
      content = '''
Có 2 cách thêm dữ liệu:

Cách 1 - Dùng App:
1. Long press panel Nhiệt độ/Độ ẩm
2. Mở Debug Page
3. Click "Write Test Data"

Cách 2 - Firebase Console:
1. Vào Realtime Database → Data
2. Import JSON:
   {
     "sensors": {
       "temperature": 25.5,
       "humidity": 60
     }
   }
''';
    } else {
      content = '''
Lỗi không xác định.

Debug steps:
1. Long press panel Nhiệt độ/Độ ẩm
2. Mở Debug Page
3. Click "Test Connection"
4. Xem logs trong console

Error: $error
''';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Color(0xFFFBBF24)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
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

  /// Kiểm tra và hiển thị thông báo nếu không có dữ liệu
  static void checkEmptyData(
    BuildContext context,
    double temperature,
    double humidity,
  ) {
    if (temperature == 0 && humidity == 0) {
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Dữ liệu môi trường trống. Long press để debug.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFD97706),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }
}

