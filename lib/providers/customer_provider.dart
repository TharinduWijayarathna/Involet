import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/customer.dart';

class CustomerProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Customer> _customers = [];
  bool _isLoading = false;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;

  CustomerProvider() {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    _customers = await _databaseHelper.getCustomers();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    _isLoading = true;
    notifyListeners();

    final id = await _databaseHelper.insertCustomer(customer);
    final newCustomer = customer.copyWith(id: id);
    
    _customers.add(newCustomer);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateCustomer(Customer customer) async {
    _isLoading = true;
    notifyListeners();

    await _databaseHelper.updateCustomer(customer);
    
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCustomer(int id) async {
    _isLoading = true;
    notifyListeners();

    await _databaseHelper.deleteCustomer(id);
    
    _customers.removeWhere((customer) => customer.id == id);
    
    _isLoading = false;
    notifyListeners();
  }

  Customer? getCustomerById(int id) {
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) {
      return _customers;
    }
    
    final normalizedQuery = query.toLowerCase();
    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(normalizedQuery) ||
             customer.email.toLowerCase().contains(normalizedQuery) ||
             (customer.phone != null && customer.phone!.contains(normalizedQuery));
    }).toList();
  }
} 