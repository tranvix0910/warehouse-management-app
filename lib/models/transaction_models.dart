class Product {
  final String id;
  final String productName;
  final String cost;
  final String price;
  final String sku;
  final String category;
  final String ram;
  final String date;
  final String gpu;
  final String color;
  final String processor;
  final int quantity;
  final String image;
  final String? updatedAt;

  Product({
    required this.id,
    required this.productName,
    required this.cost,
    required this.price,
    required this.sku,
    required this.category,
    required this.ram,
    required this.date,
    required this.gpu,
    required this.color,
    required this.processor,
    required this.quantity,
    required this.image,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      productName: json['productName'] ?? '',
      cost: json['cost'] ?? '0',
      price: json['price'] ?? '0',
      sku: json['SKU'] ?? '',
      category: json['category'] ?? '',
      ram: json['RAM'] ?? '',
      date: json['date'] ?? '',
      gpu: json['GPU'] ?? '',
      color: json['color'] ?? '',
      processor: json['processor'] ?? '',
      quantity: json['quantity'] ?? 0,
      image: json['image'] ?? '',
      updatedAt: json['updatedAt'],
    );
  }
}

class TransactionItem {
  final String id;
  final Product product;
  final int quantity;

  TransactionItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['_id'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 0,
    );
  }
}

class Transaction {
  final String id;
  final String type;
  final int quantity;
  final List<TransactionItem> items;
  final String? supplier;
  final String? customer;
  final String? note;
  final String date;
  final String createdAt;
  final String updatedAt;

  Transaction({
    required this.id,
    required this.type,
    required this.quantity,
    required this.items,
    this.supplier,
    this.customer,
    this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      quantity: json['quantity'] ?? 0,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => TransactionItem.fromJson(item))
          .toList() ?? [],
      supplier: json['supplier'],
      customer: json['customer'],
      note: json['note'],
      date: json['date'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  bool get isStockIn => type == 'stock_in';
  
  String get partyName => isStockIn ? (supplier ?? 'Unknown Supplier') : (customer ?? 'Unknown Customer');
  
  int get itemCount => items.length;
}

class TransactionResponse {
  final bool success;
  final String message;
  final List<Transaction> data;

  TransactionResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((transaction) => Transaction.fromJson(transaction))
          .toList() ?? [],
    );
  }
}
