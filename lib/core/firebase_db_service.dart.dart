import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

/// Service class for managing Firebase database operations
/// Handles temperature, humidity, and stock operations data
class FirebaseDbService {
  static final FirebaseDbService _instance = FirebaseDbService._internal();
  factory FirebaseDbService() => _instance;
  FirebaseDbService._internal();

  // Firestore instance
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;

  // Realtime Database instance
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Collection references
  static const String _temperatureCollection = 'temperature_data';
  static const String _humidityCollection = 'humidity_data';
  static const String _environmentalDataCollection = 'environmental_data';

  /// Realtime Database references
  static const String _temperaturePath = 'temperature';
  static const String _humidityPath = 'humidity';
  static const String _stockInPath = 'stock_in';
  static const String _stockOutPath = 'stock_out';

  /// Record temperature data
  /// [temperature] - Temperature value in Celsius
  /// [location] - Location where temperature was measured
  /// [timestamp] - Optional timestamp, defaults to current time
  Future<bool> recordTemperature({
    required double temperature,
    required String location,
    DateTime? timestamp,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final now = timestamp ?? DateTime.now();
      final data = {
        'temperature': temperature,
        'location': location,
        'timestamp': firestore.Timestamp.fromDate(now),
        'created_at': firestore.FieldValue.serverTimestamp(),
        'additional_data': additionalData ?? {},
      };

      // Store in Firestore
      await _firestore.collection(_temperatureCollection).add(data);

      // Store in Realtime Database for real-time updates
      await _database
          .ref('$_temperaturePath/${now.millisecondsSinceEpoch}')
          .set({
            'temperature': temperature,
            'location': location,
            'timestamp': now.toIso8601String(),
          });

      if (kDebugMode) {
        print('Temperature recorded successfully: $temperature°C at $location');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error recording temperature: $e');
      }
      return false;
    }
  }

  /// Record humidity data
  /// [humidity] - Humidity percentage (0-100)
  /// [location] - Location where humidity was measured
  /// [timestamp] - Optional timestamp, defaults to current time
  Future<bool> recordHumidity({
    required double humidity,
    required String location,
    DateTime? timestamp,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final now = timestamp ?? DateTime.now();
      final data = {
        'humidity': humidity,
        'location': location,
        'timestamp': firestore.Timestamp.fromDate(now),
        'created_at': firestore.FieldValue.serverTimestamp(),
        'additional_data': additionalData ?? {},
      };

      // Store in Firestore
      await _firestore.collection(_humidityCollection).add(data);

      // Store in Realtime Database for real-time updates
      await _database.ref('$_humidityPath/${now.millisecondsSinceEpoch}').set({
        'humidity': humidity,
        'location': location,
        'timestamp': now.toIso8601String(),
      });

      if (kDebugMode) {
        print('Humidity recorded successfully: $humidity% at $location');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error recording humidity: $e');
      }
      return false;
    }
  }

  /// Record environmental data (temperature + humidity) for stock operations
  /// [temperature] - Temperature value in Celsius
  /// [humidity] - Humidity percentage (0-100)
  /// [operationType] - Type of operation ('stock_in' or 'stock_out')
  /// [itemId] - ID of the item being processed
  /// [location] - Location where measurement was taken
  /// [timestamp] - Optional timestamp, defaults to current time
  Future<bool> recordEnvironmentalDataForStockOperation({
    required double temperature,
    required double humidity,
    required String operationType,
    required String itemId,
    required String location,
    DateTime? timestamp,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final now = timestamp ?? DateTime.now();
      final environmentalData = {
        'temperature': temperature,
        'humidity': humidity,
        'operation_type': operationType,
        'item_id': itemId,
        'location': location,
        'timestamp': firestore.Timestamp.fromDate(now),
        'created_at': firestore.FieldValue.serverTimestamp(),
        'additional_data': additionalData ?? {},
      };

      // Store environmental data in Firestore
      await _firestore
          .collection(_environmentalDataCollection)
          .add(environmentalData);

      // Store in Realtime Database for real-time updates
      final operationPath = operationType == 'stock_in'
          ? _stockInPath
          : _stockOutPath;
      await _database.ref('$operationPath/${now.millisecondsSinceEpoch}').set({
        'temperature': temperature,
        'humidity': humidity,
        'item_id': itemId,
        'location': location,
        'timestamp': now.toIso8601String(),
      });

      if (kDebugMode) {
        print(
          'Environmental data recorded for $operationType: $temperature°C, $humidity%',
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error recording environmental data: $e');
      }
      return false;
    }
  }

  /// Get environmental data for stock operations
  /// [operationType] - Filter by operation type ('stock_in' or 'stock_out')
  /// [limit] - Maximum number of records to retrieve
  /// [startAfter] - Document to start after for pagination
  Future<List<Map<String, dynamic>>> getEnvironmentalDataForStockOperations({
    String? operationType,
    int limit = 50,
    firestore.DocumentSnapshot? startAfter,
  }) async {
    try {
      firestore.Query query = _firestore
          .collection(_environmentalDataCollection)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (operationType != null) {
        query = query.where('operation_type', isEqualTo: operationType);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting environmental data: $e');
      }
      return [];
    }
  }

  /// Listen to real-time temperature updates
  Stream<Map<String, dynamic>?> listenToTemperatureUpdates() {
    return _database.ref(_temperaturePath).onValue.map((event) {
      if (event.snapshot.value != null) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }

  /// Listen to real-time humidity updates
  Stream<Map<String, dynamic>?> listenToHumidityUpdates() {
    return _database.ref(_humidityPath).onValue.map((event) {
      if (event.snapshot.value != null) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }

  /// Listen to real-time stock operation updates
  /// [operationType] - Type of operation to listen to ('stock_in' or 'stock_out')
  Stream<Map<String, dynamic>?> listenToStockOperationUpdates(
    String operationType,
  ) {
    final path = operationType == 'stock_in' ? _stockInPath : _stockOutPath;
    return _database.ref(path).onValue.map((event) {
      if (event.snapshot.value != null) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }
}
