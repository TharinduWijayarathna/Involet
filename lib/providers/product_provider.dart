import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    _products = await _databaseHelper.getProducts();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    final id = await _databaseHelper.insertProduct(product);
    final newProduct = product.copyWith(id: id);
    
    _products.add(newProduct);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    await _databaseHelper.updateProduct(product);
    
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();

    await _databaseHelper.deleteProduct(id);
    
    _products.removeWhere((product) => product.id == id);
    
    _isLoading = false;
    notifyListeners();
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) {
      return _products;
    }
    
    final normalizedQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(normalizedQuery) ||
             product.description.toLowerCase().contains(normalizedQuery) ||
             (product.sku != null && product.sku!.toLowerCase().contains(normalizedQuery));
    }).toList();
  }

  Future<String?> saveProductImage(File imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'product_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final path = '${directory.path}/$fileName';
      
      await imageFile.copy(path);
      
      _isLoading = false;
      notifyListeners();
      
      return path;
    } catch (e) {
      print('Error saving product image: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
} 