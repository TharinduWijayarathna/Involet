import 'package:involet/models/customer.dart';
import 'invoice_item.dart';

class Invoice {
  final int? id;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime dueDate;
  final int customerId;
  final Customer? customer;
  final List<InvoiceItem> items;
  final String status; // draft, sent, paid, overdue, cancelled
  final String? notes;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String? pdfPath;
  
  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.customerId,
    this.customer,
    required this.items,
    this.status = 'draft',
    this.notes,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    this.pdfPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'customerId': customerId,
      'status': status,
      'notes': notes,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'pdfPath': pdfPath,
    };
  }

  static Invoice fromMap(Map<String, dynamic> map, {List<InvoiceItem>? items, Customer? customer}) {
    return Invoice(
      id: map['id'],
      invoiceNumber: map['invoiceNumber'],
      issueDate: DateTime.parse(map['issueDate']),
      dueDate: DateTime.parse(map['dueDate']),
      customerId: map['customerId'],
      customer: customer,
      items: items ?? [],
      status: map['status'],
      notes: map['notes'],
      subtotal: map['subtotal'],
      taxAmount: map['taxAmount'],
      totalAmount: map['totalAmount'],
      pdfPath: map['pdfPath'],
    );
  }

  Invoice copyWith({
    int? id,
    String? invoiceNumber,
    DateTime? issueDate,
    DateTime? dueDate,
    int? customerId,
    Customer? customer,
    List<InvoiceItem>? items,
    String? status,
    String? notes,
    double? subtotal,
    double? taxAmount,
    double? totalAmount,
    String? pdfPath,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      customerId: customerId ?? this.customerId,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }
} 