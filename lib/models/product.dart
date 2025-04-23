class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String? imagePath;
  final String? sku;
  final bool isTaxable;
  final double? taxRate;
  
  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imagePath,
    this.sku,
    this.isTaxable = true,
    this.taxRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'sku': sku,
      'isTaxable': isTaxable ? 1 : 0,
      'taxRate': taxRate,
    };
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imagePath: map['imagePath'],
      sku: map['sku'],
      isTaxable: map['isTaxable'] == 1,
      taxRate: map['taxRate'],
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imagePath,
    String? sku,
    bool? isTaxable,
    double? taxRate,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      sku: sku ?? this.sku,
      isTaxable: isTaxable ?? this.isTaxable,
      taxRate: taxRate ?? this.taxRate,
    );
  }
} 