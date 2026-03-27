# ⚡ Quick Start - Fix Firebase Environment Data

## 🎯 3 Bước Fix Nhanh

### 1️⃣ Firebase Rules (1 phút)
```
1. Vào: https://console.firebase.google.com/
2. Chọn: mobile-app-development-1a585
3. Vào: Realtime Database → Rules
4. Paste:
   {
     "rules": {
       "sensors": {
         ".read": true,
         ".write": true
       }
     }
   }
5. Click: Publish
```

### 2️⃣ Add Data (Chọn 1)

**Option A - Dùng App (Khuyến nghị):**
```
1. flutter run
2. Login → Dashboard
3. Long press panel Nhiệt độ/Độ ẩm
4. Click "Write Test Data"
5. Done! ✅
```

**Option B - Firebase Console:**
```
1. Realtime Database → Data
2. Click ⋮ → Import JSON
3. Paste:
   {
     "sensors": {
       "temperature": 25.5,
       "humidity": 60
     }
   }
4. Import
```

### 3️⃣ Test
```
1. Restart app
2. Vào Dashboard
3. Thấy: 25.5°C và 60%
4. Success! 🎉
```

---

## 🛠️ Debug Tools

### Mở Debug Page
```
Long press panel Nhiệt độ/Độ ẩm → Debug Page mở
```

### Test Connection
```
Debug Page → Click "Test Connection" → Xem status
```

### Xem Logs
```bash
flutter logs
# Tìm: 🔍 ✅ ❌ ⚠️
```

---

## ❌ Nếu Lỗi

### "Permission Denied"
```
→ Fix Firebase Rules (Bước 1)
```

### "Không có dữ liệu"
```
→ Add data (Bước 2)
```

### "Network Error"
```
→ Check internet
→ Disable VPN
```

### Lỗi khác
```
→ Đọc: HUONG_DAN_FIX_FIREBASE.md
```

---

## 📚 Docs

- `CHECKLIST.md` - Checklist đầy đủ
- `HUONG_DAN_FIX_FIREBASE.md` - Hướng dẫn chi tiết (Vietnamese)
- `FIREBASE_SETUP.md` - Setup kỹ thuật
- `README_FIREBASE_FIX.md` - Complete guide

---

## ✅ Success Indicators

| ✅ Good | ❌ Bad |
|---------|--------|
| `25.5°C` | `--°C` |
| `60%` | `--%` |
| No error icon | Error icon |
| Logs: `✅ Success` | Logs: `❌ Error` |

---

## 🚀 That's It!

Chỉ cần 3 bước trên là xong!

**Long press panel để debug khi cần** 👌

