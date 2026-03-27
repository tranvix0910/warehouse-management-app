import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_management_app/services/activity_log_service.dart';

void main() {
  group('ActivityLog', () {
    test('fromJson creates valid ActivityLog', () {
      final json = {
        'id': '123',
        'type': ActivityType.productCreated.index,
        'title': 'Product Created',
        'description': 'Created product "Test"',
        'userId': 'user123',
        'userName': 'John',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'metadata': {'productName': 'Test'},
      };

      final log = ActivityLog.fromJson(json);

      expect(log.id, '123');
      expect(log.type, ActivityType.productCreated);
      expect(log.title, 'Product Created');
      expect(log.userName, 'John');
    });

    test('toJson returns correct map', () {
      final log = ActivityLog(
        id: '123',
        type: ActivityType.stockIn,
        title: 'Stock In',
        description: 'Received 10 items',
        userId: 'user123',
        userName: 'John',
        timestamp: DateTime(2024, 1, 1, 12, 0),
        metadata: {'quantity': 10},
      );

      final json = log.toJson();

      expect(json['id'], '123');
      expect(json['type'], ActivityType.stockIn.index);
      expect(json['title'], 'Stock In');
    });

    group('icon property', () {
      test('productCreated has add_box icon', () {
        final log = ActivityLog(
          id: '1',
          type: ActivityType.productCreated,
          title: '',
          description: '',
          timestamp: DateTime.now(),
        );
        expect(log.icon.codePoint, isNotNull);
      });

      test('productDeleted has delete icon', () {
        final log = ActivityLog(
          id: '1',
          type: ActivityType.productDeleted,
          title: '',
          description: '',
          timestamp: DateTime.now(),
        );
        expect(log.icon.codePoint, isNotNull);
      });
    });

    group('color property', () {
      test('productCreated has green color', () {
        final log = ActivityLog(
          id: '1',
          type: ActivityType.productCreated,
          title: '',
          description: '',
          timestamp: DateTime.now(),
        );
        expect(log.color.value, 0xFF10B981);
      });

      test('productDeleted has red color', () {
        final log = ActivityLog(
          id: '1',
          type: ActivityType.productDeleted,
          title: '',
          description: '',
          timestamp: DateTime.now(),
        );
        expect(log.color.value, 0xFFEF4444);
      });

      test('stockIn has blue color', () {
        final log = ActivityLog(
          id: '1',
          type: ActivityType.stockIn,
          title: '',
          description: '',
          timestamp: DateTime.now(),
        );
        expect(log.color.value, 0xFF3B82F6);
      });
    });

    group('typeLabel property', () {
      test('returns correct label for each type', () {
        expect(
          ActivityLog(id: '1', type: ActivityType.productCreated, title: '', description: '', timestamp: DateTime.now()).typeLabel,
          'Product Created',
        );
        expect(
          ActivityLog(id: '1', type: ActivityType.productUpdated, title: '', description: '', timestamp: DateTime.now()).typeLabel,
          'Product Updated',
        );
        expect(
          ActivityLog(id: '1', type: ActivityType.stockIn, title: '', description: '', timestamp: DateTime.now()).typeLabel,
          'Stock In',
        );
        expect(
          ActivityLog(id: '1', type: ActivityType.stockOut, title: '', description: '', timestamp: DateTime.now()).typeLabel,
          'Stock Out',
        );
      });
    });
  });

  group('ActivityLogService', () {
    test('singleton returns same instance', () {
      final instance1 = ActivityLogService();
      final instance2 = ActivityLogService();

      expect(identical(instance1, instance2), true);
    });
  });

  group('ActivityType enum', () {
    test('has all expected values', () {
      expect(ActivityType.values.contains(ActivityType.productCreated), true);
      expect(ActivityType.values.contains(ActivityType.productUpdated), true);
      expect(ActivityType.values.contains(ActivityType.productDeleted), true);
      expect(ActivityType.values.contains(ActivityType.stockIn), true);
      expect(ActivityType.values.contains(ActivityType.stockOut), true);
      expect(ActivityType.values.contains(ActivityType.customerCreated), true);
      expect(ActivityType.values.contains(ActivityType.supplierCreated), true);
      expect(ActivityType.values.contains(ActivityType.userLogin), true);
      expect(ActivityType.values.contains(ActivityType.userLogout), true);
      expect(ActivityType.values.contains(ActivityType.settingsChanged), true);
      expect(ActivityType.values.contains(ActivityType.reportExported), true);
      expect(ActivityType.values.contains(ActivityType.batchOperation), true);
    });

    test('has correct count of values', () {
      expect(ActivityType.values.length, 12);
    });
  });
}
