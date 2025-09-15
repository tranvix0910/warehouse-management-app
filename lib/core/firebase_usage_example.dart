import 'firebase_db_service.dart.dart';

/// Example usage of FirebaseDbService for recording temperature and humidity
/// during stock operations
class FirebaseUsageExample {
  final FirebaseDbService _firebaseService = FirebaseDbService();

  /// Example: Record environmental data for stock in operation
  Future<void> recordStockInWithEnvironmentalData() async {
    // Example data
    const double temperature = 22.5; // Celsius
    const double humidity = 65.0; // Percentage
    const String itemId = 'ITEM_001';
    const String location = 'Warehouse A - Zone 1';
    const String operationType = 'stock_in';

    // Record environmental data for stock in operation
    final success = await _firebaseService
        .recordEnvironmentalDataForStockOperation(
          temperature: temperature,
          humidity: humidity,
          operationType: operationType,
          itemId: itemId,
          location: location,
          additionalData: {
            'operator_id': 'OP_001',
            'quality_check': 'passed',
            'notes': 'Fresh produce delivery',
          },
        );

    if (success) {
      print('Environmental data recorded successfully for stock in operation');
    } else {
      print('Failed to record environmental data');
    }
  }

  /// Example: Record environmental data for stock out operation
  Future<void> recordStockOutWithEnvironmentalData() async {
    // Example data
    const double temperature = 24.0; // Celsius
    const double humidity = 60.0; // Percentage
    const String itemId = 'ITEM_002';
    const String location = 'Warehouse B - Zone 2';
    const String operationType = 'stock_out';

    // Record environmental data for stock out operation
    final success = await _firebaseService
        .recordEnvironmentalDataForStockOperation(
          temperature: temperature,
          humidity: humidity,
          operationType: operationType,
          itemId: itemId,
          location: location,
          additionalData: {
            'operator_id': 'OP_002',
            'quality_check': 'passed',
            'notes': 'Order fulfillment',
          },
        );

    if (success) {
      print('Environmental data recorded successfully for stock out operation');
    } else {
      print('Failed to record environmental data');
    }
  }

  /// Example: Record only temperature data
  Future<void> recordTemperatureOnly() async {
    const double temperature = 23.0;
    const String location = 'Cold Storage Room';

    final success = await _firebaseService.recordTemperature(
      temperature: temperature,
      location: location,
      additionalData: {'sensor_id': 'TEMP_001', 'battery_level': 85},
    );

    if (success) {
      print('Temperature recorded successfully');
    } else {
      print('Failed to record temperature');
    }
  }

  /// Example: Record only humidity data
  Future<void> recordHumidityOnly() async {
    const double humidity = 70.0;
    const String location = 'Humidity Controlled Zone';

    final success = await _firebaseService.recordHumidity(
      humidity: humidity,
      location: location,
      additionalData: {
        'sensor_id': 'HUM_001',
        'calibration_date': '2024-01-15',
      },
    );

    if (success) {
      print('Humidity recorded successfully');
    } else {
      print('Failed to record humidity');
    }
  }

  /// Example: Get environmental data for stock operations
  Future<void> getEnvironmentalData() async {
    // Get all environmental data
    final allData = await _firebaseService
        .getEnvironmentalDataForStockOperations();
    print('Total environmental records: ${allData.length}');

    // Get only stock in operations
    final stockInData = await _firebaseService
        .getEnvironmentalDataForStockOperations(
          operationType: 'stock_in',
          limit: 10,
        );
    print('Stock in operations: ${stockInData.length}');

    // Get only stock out operations
    final stockOutData = await _firebaseService
        .getEnvironmentalDataForStockOperations(
          operationType: 'stock_out',
          limit: 10,
        );
    print('Stock out operations: ${stockOutData.length}');
  }

  /// Example: Listen to real-time updates
  void listenToRealTimeUpdates() {
    // Listen to temperature updates
    _firebaseService.listenToTemperatureUpdates().listen((data) {
      if (data != null) {
        print(
          'Real-time temperature update: ${data['temperature']}°C at ${data['location']}',
        );
      }
    });

    // Listen to humidity updates
    _firebaseService.listenToHumidityUpdates().listen((data) {
      if (data != null) {
        print(
          'Real-time humidity update: ${data['humidity']}% at ${data['location']}',
        );
      }
    });

    // Listen to stock in operations
    _firebaseService.listenToStockOperationUpdates('stock_in').listen((data) {
      if (data != null) {
        print(
          'Real-time stock in: ${data['item_id']} - ${data['temperature']}°C, ${data['humidity']}%',
        );
      }
    });

    // Listen to stock out operations
    _firebaseService.listenToStockOperationUpdates('stock_out').listen((data) {
      if (data != null) {
        print(
          'Real-time stock out: ${data['item_id']} - ${data['temperature']}°C, ${data['humidity']}%',
        );
      }
    });
  }
}
