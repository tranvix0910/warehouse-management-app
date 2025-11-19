# 🔥 Hướng Dẫn Setup Firebase Realtime Database

## 📋 Mục Lục
1. [Cấu Hình Firebase Rules](#1-cấu-hình-firebase-rules)
2. [Cấu Trúc Dữ Liệu](#2-cấu-trúc-dữ-liệu)
3. [Test Kết Nối](#3-test-kết-nối)
4. [Troubleshooting](#4-troubleshooting)

---

## 1. Cấu Hình Firebase Rules

### Bước 1: Truy cập Firebase Console
1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project: `mobile-app-development-1a585`
3. Vào **Realtime Database** → **Rules**

### Bước 2: Cấu hình Rules
Thêm rules sau để cho phép đọc/ghi dữ liệu:

```json
{
  "rules": {
    "sensors": {
      ".read": true,
      ".write": true
    }
  }
}
```

**⚠️ Lưu ý:** Rules trên cho phép mọi người đọc/ghi dữ liệu. Đối với production, nên thêm authentication:

```json
{
  "rules": {
    "sensors": {
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
```

---

## 2. Cấu Trúc Dữ Liệu

### Cấu trúc hiện tại app đang mong đợi:

```
mobile-app-development-1a585-default-rtdb (root)
└── sensors
    ├── temperature: 25.5
    └── humidity: 60
```

### Thêm dữ liệu mẫu:

**Cách 1: Qua Firebase Console**
1. Vào **Realtime Database** → **Data**
2. Click vào root node
3. Click nút **+** để thêm child
4. Thêm:
   - Key: `sensors`
   - Value: (để trống, sẽ là object)
5. Click vào `sensors` node vừa tạo
6. Thêm 2 children:
   - Key: `temperature`, Value: `25.5` (Number)
   - Key: `humidity`, Value: `60` (Number)

**Cách 2: Import JSON**
1. Vào **Realtime Database** → **Data**
2. Click vào root node
3. Click nút **⋮** (three dots) → **Import JSON**
4. Paste JSON sau:

```json
{
  "sensors": {
    "temperature": 25.5,
    "humidity": 60
  }
}
```

---

## 3. Test Kết Nối

### Thêm code test vào DashboardPage

Mở `lib/pages/home/dashboard_page.dart` và thêm vào `initState`:

```dart
@override
void initState() {
  super.initState();
  _loadProducts();
  _testFirebaseConnection(); // Thêm dòng này
}

Future<void> _testFirebaseConnection() async {
  final service = FirebaseEnvironmentService();
  final isConnected = await service.testConnection();
  print('🔥 Firebase Connected: $isConnected');
}
```

### Kiểm tra logs

Chạy app và xem logs trong terminal/console. Bạn sẽ thấy:

✅ **Nếu thành công:**
```
🔥 Firebase Connected: true
✅ Firebase Connection Test Success
📊 Data at path "sensors": {temperature: 25.5, humidity: 60}
🔍 Firebase Data Received: {temperature: 25.5, humidity: 60}
🔍 Data Type: _Map<Object?, Object?>
```

❌ **Nếu lỗi:**
```
❌ Firebase Connection Test Failed: [firebase_database/permission-denied]
```

---

## 4. Troubleshooting

### ❌ Lỗi: Permission Denied

**Nguyên nhân:** Firebase Rules chưa cho phép đọc dữ liệu

**Giải pháp:**
1. Vào Firebase Console → Realtime Database → Rules
2. Thay đổi rules như hướng dẫn ở mục 1
3. Click **Publish**
4. Restart app

### ❌ Lỗi: Không có dữ liệu (Data = null)

**Nguyên nhân:** Chưa có dữ liệu trong database hoặc sai path

**Giải pháp:**
1. Kiểm tra Firebase Console → Realtime Database → Data
2. Đảm bảo có node `sensors` với `temperature` và `humidity`
3. Thêm dữ liệu mẫu như hướng dẫn ở mục 2

### ❌ Lỗi: Network Error

**Nguyên nhân:** Không có kết nối internet hoặc firewall chặn

**Giải pháp:**
1. Kiểm tra kết nối internet
2. Kiểm tra firewall/proxy settings
3. Thử chạy app trên thiết bị thật thay vì emulator

### ⚠️ Hiển thị giá trị 0

**Nguyên nhân:** Dữ liệu tồn tại nhưng = 0, hoặc parsing bị lỗi

**Giải pháp:**
1. Kiểm tra logs để xem dữ liệu thật sự nhận được
2. Đảm bảo type của `temperature` và `humidity` là Number (không phải String)

---

## 5. Cấu Trúc Database Khuyến Nghị

Để mở rộng trong tương lai, nên dùng cấu trúc như sau:

```json
{
  "sensors": {
    "current": {
      "temperature": 25.5,
      "humidity": 60,
      "timestamp": 1699999999999
    },
    "history": {
      "2024-11-14-10-30": {
        "temperature": 24.5,
        "humidity": 58
      },
      "2024-11-14-10-31": {
        "temperature": 25.5,
        "humidity": 60
      }
    }
  }
}
```

Nếu dùng cấu trúc này, cần update code trong `FirebaseEnvironmentService`:

```dart
FirebaseEnvironmentService({
  FirebaseDatabase? database,
  this.path = 'sensors/current',  // Thay đổi path
}) : _database = database ?? FirebaseDatabase.instance;
```

---

## 6. Database URL

Database URL hiện tại:
```
https://mobile-app-development-1a585-default-rtdb.asia-southeast1.firebasedatabase.app
```

Region: **asia-southeast1** (Singapore)

---

## 📞 Support

Nếu vẫn gặp vấn đề:
1. Kiểm tra logs trong console
2. Verify Firebase configuration trong `firebase_options.dart`
3. Đảm bảo `firebase_core` và `firebase_database` đã được cài đặt đúng phiên bản

**Versions hiện tại:**
- firebase_core: ^3.8.0
- firebase_database: ^11.0.4

