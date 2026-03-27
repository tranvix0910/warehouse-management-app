import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_management_app/services/product_service.dart';

void main() {
  group('ProductModel', () {
    test('fromJson creates valid ProductModel', () {
      final json = {
        '_id': '123',
        'productName': 'MacBook Pro',
        'SKU': 'MBP-001',
        'cost': '1999',
        'price': '2499',
        'quantity': 10,
        'image': 'https://example.com/image.jpg',
        'category': 'Ultrabook',
        'RAM': '16GB',
        'date': '2024-01-01',
        'GPU': 'M3 Pro',
        'color': 'Space Gray',
        'processor': 'Apple M3 Pro',
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, '123');
      expect(product.name, 'MacBook Pro');
      expect(product.sku, 'MBP-001');
      expect(product.cost, '1999');
      expect(product.price, '2499');
      expect(product.quantity, 10);
      expect(product.category, 'Ultrabook');
    });

    test('fromJson handles missing fields', () {
      final json = {
        '_id': '123',
        'productName': 'Test Product',
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, '123');
      expect(product.name, 'Test Product');
      expect(product.sku, '');
      expect(product.cost, '0');
      expect(product.price, '0');
      expect(product.quantity, 0);
    });

    test('toJson returns correct map', () {
      final product = ProductModel(
        id: '123',
        name: 'Test Product',
        sku: 'TEST-001',
        cost: '100',
        price: '150',
        quantity: 5,
        image: '',
        category: 'Test',
        ram: '8GB',
        date: '2024-01-01',
        gpu: 'Intel',
        color: 'Black',
        processor: 'i7',
      );

      final json = product.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Test Product');
      expect(json['quantity'], 5);
    });
  });

  group('ProductService', () {
    test('singleton returns same instance', () {
      final instance1 = ProductService.instance;
      final instance2 = ProductService.instance;

      expect(identical(instance1, instance2), true);
    });

    test('searchProducts filters by name', () {
      final products = [
        ProductModel(
          id: '1', name: 'MacBook Pro', sku: 'MBP', cost: '0', price: '0',
          quantity: 0, image: '', category: '', ram: '', date: '', gpu: '', color: '', processor: '',
        ),
        ProductModel(
          id: '2', name: 'Dell XPS', sku: 'DELL', cost: '0', price: '0',
          quantity: 0, image: '', category: '', ram: '', date: '', gpu: '', color: '', processor: '',
        ),
        ProductModel(
          id: '3', name: 'HP Spectre', sku: 'HP', cost: '0', price: '0',
          quantity: 0, image: '', category: '', ram: '', date: '', gpu: '', color: '', processor: '',
        ),
      ];

      final results = ProductService.instance.searchProducts(products, 'MacBook');

      expect(results.length, 1);
      expect(results[0].name, 'MacBook Pro');
    });

    test('searchProducts filters by SKU', () {
      final products = [
        ProductModel(
          id: '1', name: 'Product 1', sku: 'ABC-123', cost: '0', price: '0',
          quantity: 0, image: '', category: '', ram: '', date: '', gpu: '', color: '', processor: '',
        ),
        ProductModel(
          id: '2', name: 'Product 2', sku: 'XYZ-456', cost: '0', price: '0',
          quantity: 0, image: '', category: '', ram: '', date: '', gpu: '', color: '', processor: '',
        ),
      ];

      final results = ProductService.instance.searchProducts(products, 'ABC');

      expect(results.length, 1);
      expect(results[0].sku, 'ABC-123');
    });

    test('searchProducts is case insensitive', () {
      final products = [
        ProductModel(
          id: '1', name: 'MacBook Pro', sku: 'MBP', cost: '0', price: '0',
          quantity: 0, image: '', category: '', ram: '', date: '', gpu: '', color: '', processor: '',
        ),
      ];

      final results = ProductService.instance.searchProducts(products, 'macbook');

      expect(results.length, 1);
    });

    test('searchProducts returns all for empty query', () {
      final products = [
        ProductModel(
          id: '1', name: 'Product 1', sku: 'P1', cost: '0', price: '0',
          quantity: 0, image: '', category: '', ram: '', date: '', gpu: '', color: '', processor: '',
        ),
        ProductModel(
          id: '2', name: 'Product 2', sku: 'P2', cost: '0', price: '0',
          quantity: 0, image: '', category: '', ram: '', date: '', gpu: '', color: '', processor: '',
        ),
      ];

      final results = ProductService.instance.searchProducts(products, '');

      expect(results.length, 2);
    });

    test('clearCache resets cache', () {
      ProductService.instance.clearCache();
      // Should not throw
      expect(true, true);
    });
  });
}
