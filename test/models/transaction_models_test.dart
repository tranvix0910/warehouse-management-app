import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_management_app/models/transaction_models.dart';

void main() {
  group('Product', () {
    test('fromJson creates valid Product', () {
      final json = {
        '_id': '123',
        'productName': 'MacBook Pro',
        'cost': '1999',
        'price': '2499',
        'SKU': 'MBP-001',
        'category': 'Ultrabook',
        'RAM': '16GB',
        'date': '2024-01-01',
        'GPU': 'M3 Pro',
        'color': 'Space Gray',
        'processor': 'Apple M3',
        'quantity': 10,
        'image': 'https://example.com/image.jpg',
      };

      final product = Product.fromJson(json);

      expect(product.id, '123');
      expect(product.productName, 'MacBook Pro');
      expect(product.quantity, 10);
      expect(product.category, 'Ultrabook');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final product = Product.fromJson(json);

      expect(product.id, '');
      expect(product.productName, '');
      expect(product.quantity, 0);
    });

    test('fromJson handles null values', () {
      final json = {
        '_id': null,
        'productName': null,
        'quantity': null,
      };

      final product = Product.fromJson(json);

      expect(product.id, '');
      expect(product.productName, '');
      expect(product.quantity, 0);
    });
  });

  group('TransactionItem', () {
    test('fromJson creates valid TransactionItem', () {
      final json = {
        '_id': 'item123',
        'product': {
          '_id': 'prod123',
          'productName': 'Test Product',
          'quantity': 5,
        },
        'quantity': 3,
      };

      final item = TransactionItem.fromJson(json);

      expect(item.id, 'item123');
      expect(item.product.id, 'prod123');
      expect(item.quantity, 3);
    });

    test('fromJson handles missing product', () {
      final json = {
        '_id': 'item123',
        'quantity': 3,
      };

      final item = TransactionItem.fromJson(json);

      expect(item.id, 'item123');
      expect(item.product.id, '');
    });
  });

  group('Transaction', () {
    test('fromJson creates valid Transaction', () {
      final json = {
        '_id': 'trans123',
        'type': 'stock_in',
        'quantity': 10,
        'items': [
          {
            '_id': 'item1',
            'product': {'_id': 'prod1', 'productName': 'Product 1'},
            'quantity': 5,
          },
          {
            '_id': 'item2',
            'product': {'_id': 'prod2', 'productName': 'Product 2'},
            'quantity': 5,
          },
        ],
        'supplier': 'Supplier A',
        'note': 'Test note',
        'date': '2024-01-01',
        'createdAt': '2024-01-01T10:00:00Z',
        'updatedAt': '2024-01-01T10:00:00Z',
      };

      final transaction = Transaction.fromJson(json);

      expect(transaction.id, 'trans123');
      expect(transaction.type, 'stock_in');
      expect(transaction.quantity, 10);
      expect(transaction.items.length, 2);
      expect(transaction.supplier, 'Supplier A');
    });

    test('isStockIn returns true for stock_in type', () {
      final transaction = Transaction(
        id: '1',
        type: 'stock_in',
        quantity: 10,
        items: [],
        date: '',
        createdAt: '',
        updatedAt: '',
      );

      expect(transaction.isStockIn, true);
    });

    test('isStockIn returns false for stock_out type', () {
      final transaction = Transaction(
        id: '1',
        type: 'stock_out',
        quantity: 10,
        items: [],
        date: '',
        createdAt: '',
        updatedAt: '',
      );

      expect(transaction.isStockIn, false);
    });

    test('partyName returns supplier for stock_in', () {
      final transaction = Transaction(
        id: '1',
        type: 'stock_in',
        quantity: 10,
        items: [],
        supplier: 'Test Supplier',
        date: '',
        createdAt: '',
        updatedAt: '',
      );

      expect(transaction.partyName, 'Test Supplier');
    });

    test('partyName returns customer for stock_out', () {
      final transaction = Transaction(
        id: '1',
        type: 'stock_out',
        quantity: 10,
        items: [],
        customer: 'Test Customer',
        date: '',
        createdAt: '',
        updatedAt: '',
      );

      expect(transaction.partyName, 'Test Customer');
    });

    test('partyName returns default when null', () {
      final transaction = Transaction(
        id: '1',
        type: 'stock_in',
        quantity: 10,
        items: [],
        date: '',
        createdAt: '',
        updatedAt: '',
      );

      expect(transaction.partyName, 'Unknown Supplier');
    });

    test('itemCount returns correct count', () {
      final transaction = Transaction(
        id: '1',
        type: 'stock_in',
        quantity: 10,
        items: [
          TransactionItem(id: '1', product: Product.fromJson({}), quantity: 5),
          TransactionItem(id: '2', product: Product.fromJson({}), quantity: 5),
          TransactionItem(id: '3', product: Product.fromJson({}), quantity: 5),
        ],
        date: '',
        createdAt: '',
        updatedAt: '',
      );

      expect(transaction.itemCount, 3);
    });
  });

  group('TransactionResponse', () {
    test('fromJson creates valid response', () {
      final json = {
        'success': true,
        'message': 'Success',
        'data': [
          {
            '_id': 'trans1',
            'type': 'stock_in',
            'quantity': 10,
            'items': [],
            'date': '',
            'createdAt': '',
            'updatedAt': '',
          },
        ],
      };

      final response = TransactionResponse.fromJson(json);

      expect(response.success, true);
      expect(response.message, 'Success');
      expect(response.data.length, 1);
    });

    test('fromJson handles empty data', () {
      final json = {
        'success': true,
        'message': 'No data',
        'data': null,
      };

      final response = TransactionResponse.fromJson(json);

      expect(response.success, true);
      expect(response.data.isEmpty, true);
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};

      final response = TransactionResponse.fromJson(json);

      expect(response.success, false);
      expect(response.message, '');
      expect(response.data.isEmpty, true);
    });
  });
}
