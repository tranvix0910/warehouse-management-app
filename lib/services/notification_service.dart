import 'dart:io';
import 'dart:ui' show Color;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/product_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    await _requestPermissions();
    await _initializeLocalNotifications();
    await _configureFCM();
    
    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_lowStockChannel);
      await androidPlugin?.createNotificationChannel(_generalChannel);
    }
  }

  static const AndroidNotificationChannel _lowStockChannel = AndroidNotificationChannel(
    'low_stock_alerts',
    'Low Stock Alerts',
    description: 'Notifications for low stock items',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _generalChannel = AndroidNotificationChannel(
    'general',
    'General Notifications',
    description: 'General app notifications',
    importance: Importance.defaultImportance,
  );

  Future<void> _configureFCM() async {
    _fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $_fcmToken');

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      debugPrint('FCM Token refreshed: $newToken');
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    
    final notification = message.notification;
    if (notification != null) {
      showLocalNotification(
        title: notification.title ?? 'Warehouse Alert',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    bool isLowStock = false,
  }) async {
    if (kIsWeb) return;

    final androidDetails = AndroidNotificationDetails(
      isLowStock ? _lowStockChannel.id : _generalChannel.id,
      isLowStock ? _lowStockChannel.name : _generalChannel.name,
      channelDescription: isLowStock ? _lowStockChannel.description : _generalChannel.description,
      importance: isLowStock ? Importance.high : Importance.defaultImportance,
      priority: isLowStock ? Priority.high : Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF3B82F6),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> checkLowStockAndNotify({
    required int minimumQuantity,
  }) async {
    try {
      final products = await ProductService.instance.getProducts();
      final lowStockProducts = products.where((p) => p.quantity > 0 && p.quantity <= minimumQuantity).toList();
      final outOfStockProducts = products.where((p) => p.quantity == 0).toList();

      if (outOfStockProducts.isNotEmpty) {
        await showLocalNotification(
          title: 'Out of Stock Alert!',
          body: '${outOfStockProducts.length} product(s) are out of stock. Restock needed!',
          isLowStock: true,
        );
      }

      if (lowStockProducts.isNotEmpty) {
        await showLocalNotification(
          title: 'Low Stock Warning',
          body: '${lowStockProducts.length} product(s) have low stock (≤$minimumQuantity units)',
          isLowStock: true,
        );
      }
    } catch (e) {
      debugPrint('Error checking low stock: $e');
    }
  }

  Future<void> showLowStockNotification({
    required String productName,
    required int currentStock,
    required int threshold,
  }) async {
    await showLocalNotification(
      title: 'Low Stock Alert: $productName',
      body: 'Current stock: $currentStock units (threshold: $threshold)',
      isLowStock: true,
    );
  }

  Future<void> showOutOfStockNotification({
    required String productName,
  }) async {
    await showLocalNotification(
      title: 'Out of Stock: $productName',
      body: 'This product is now out of stock. Please restock immediately.',
      isLowStock: true,
    );
  }

  Future<void> showTransactionNotification({
    required String type,
    required int quantity,
    required String partyName,
  }) async {
    final isStockIn = type == 'stock_in';
    await showLocalNotification(
      title: isStockIn ? 'Stock In Completed' : 'Stock Out Completed',
      body: '${isStockIn ? "Received" : "Shipped"} $quantity items ${isStockIn ? "from" : "to"} $partyName',
    );
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _localNotifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _localNotifications.cancel(id);
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

void debugPrint(String message) {
  if (!kIsWeb) {
    // ignore: avoid_print
    print(message);
  }
}
