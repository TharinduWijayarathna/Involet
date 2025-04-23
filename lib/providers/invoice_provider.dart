import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../database/database_helper.dart';
import '../models/business.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class InvoiceProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Invoice> _invoices = [];
  bool _isLoading = false;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;

  InvoiceProvider() {
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();

    _invoices = await _databaseHelper.getInvoices();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<int> createInvoice(Invoice invoice, List<InvoiceItem> items) async {
    _isLoading = true;
    notifyListeners();

    final id = await _databaseHelper.insertInvoice(invoice, items);
    final newInvoice = await _databaseHelper.getInvoice(id);
    
    if (newInvoice != null) {
      _invoices.add(newInvoice);
    }
    
    _isLoading = false;
    notifyListeners();
    
    return id;
  }

  Future<void> updateInvoice(Invoice invoice) async {
    _isLoading = true;
    notifyListeners();

    await _databaseHelper.updateInvoice(invoice);
    
    final index = _invoices.indexWhere((i) => i.id == invoice.id);
    if (index != -1) {
      _invoices[index] = invoice;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteInvoice(int id) async {
    _isLoading = true;
    notifyListeners();

    await _databaseHelper.deleteInvoice(id);
    
    _invoices.removeWhere((invoice) => invoice.id == id);
    
    _isLoading = false;
    notifyListeners();
  }

  Invoice? getInvoiceById(int id) {
    try {
      return _invoices.firstWhere((invoice) => invoice.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) {
      return _invoices;
    }
    
    final normalizedQuery = query.toLowerCase();
    return _invoices.where((invoice) {
      return invoice.invoiceNumber.toLowerCase().contains(normalizedQuery) ||
             invoice.customer!.name.toLowerCase().contains(normalizedQuery) ?? false;
    }).toList();
  }

  List<Invoice> getInvoicesByStatus(String status) {
    return _invoices.where((invoice) => invoice.status == status).toList();
  }

  Future<String?> generateInvoicePdf(
    Invoice invoice,
    Business business,
    Customer customer,
    List<InvoiceItem> items,
  ) async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          business.name,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(business.address),
                        pw.Text(business.phone),
                        pw.Text(business.email),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 24,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text('Invoice #: ${invoice.invoiceNumber}'),
                        pw.Text('Date: ${_formatDate(invoice.issueDate)}'),
                        pw.Text('Due Date: ${_formatDate(invoice.dueDate)}'),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 40),
                
                // Bill To
                pw.Text(
                  'BILL TO:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  customer.name,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (customer.address != null) pw.Text(customer.address!),
                pw.Text(customer.email),
                if (customer.phone != null) pw.Text(customer.phone!),
                
                pw.SizedBox(height: 30),
                
                // Items Table
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 1,
                  ),
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue100,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'ITEM',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'QTY',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'UNIT PRICE',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'AMOUNT',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    
                    // Table Items
                    ...items.map((item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(item.description),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            item.quantity.toString(),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            '\$${item.unitPrice.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            '\$${item.amount.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
                
                pw.SizedBox(height: 10),
                
                // Total
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Container(
                            width: 100,
                            child: pw.Text(
                              'Subtotal:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.Container(
                            width: 100,
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('\$${invoice.subtotal.toStringAsFixed(2)}'),
                          ),
                        ],
                      ),
                      pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Container(
                            width: 100,
                            child: pw.Text(
                              'Tax:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.Container(
                            width: 100,
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('\$${invoice.taxAmount.toStringAsFixed(2)}'),
                          ),
                        ],
                      ),
                      pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Container(
                            width: 100,
                            child: pw.Text(
                              'Total:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          pw.Container(
                            width: 100,
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              '\$${invoice.totalAmount.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 40),
                
                // Notes
                if (invoice.notes != null) ...[
                  pw.Text(
                    'NOTES:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(invoice.notes!),
                ],
                
                pw.SizedBox(height: 40),
                
                // Thank You
                pw.Center(
                  child: pw.Text(
                    'Thank you for your business!',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
      
      // Save PDF
      final output = await getApplicationDocumentsDirectory();
      final fileName = 'invoice_${invoice.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      // Update invoice with PDF path
      if (invoice.id != null) {
        final updatedInvoice = invoice.copyWith(pdfPath: file.path);
        await updateInvoice(updatedInvoice);
      }
      
      return file.path;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
} 