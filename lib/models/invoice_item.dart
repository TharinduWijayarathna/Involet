import 'product.dart';

class InvoiceItem {
  final int? id;
  final int invoiceId;
  final int productId;
  final Product? product;
  final String description;
  final double quantity;
  final double unitPrice;
  final double taxRate;
  final double amount;
  
  InvoiceItem({
    this.id,
    required this.invoiceId,
    required this.productId,
    this.product,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 0.0,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'productId': productId,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'taxRate': taxRate,
      'amount': amount,
    };
  }

  static InvoiceItem fromMap(Map<String, dynamic> map, {Product? product}) {
    return InvoiceItem(
      id: map['id'],
      invoiceId: map['invoiceId'],
      productId: map['productId'],
      product: product,
      description: map['description'],
      quantity: map['quantity'],
      unitPrice: map['unitPrice'],
      taxRate: map['taxRate'],
      amount: map['amount'],
    );
  }

  InvoiceItem copyWith({
    int? id,
    int? invoiceId,
    int? productId,
    Product? product,
    String? description,
    double? quantity,
    double? unitPrice,
    double? taxRate,
    double? amount,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      amount: amount ?? this.amount,
    );
  }
} 