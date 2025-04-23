import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';
import '../models/business.dart';

class BusinessProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Business? _business;
  bool _isLoading = false;

  Business? get business => _business;
  bool get isLoading => _isLoading;

  BusinessProvider() {
    loadBusiness();
  }

  Future<void> loadBusiness() async {
    _isLoading = true;
    notifyListeners();

    _business = await _databaseHelper.getBusiness();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveBusiness(Business business) async {
    _isLoading = true;
    notifyListeners();
    
    if (business.id == null) {
      final id = await _databaseHelper.insertBusiness(business);
      _business = business.copyWith(id: id);
    } else {
      await _databaseHelper.updateBusiness(business);
      _business = business;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> saveBusinessLogo(File logoFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'business_logo_${DateTime.now().millisecondsSinceEpoch}.png';
      final path = '${directory.path}/$fileName';
      
      await logoFile.copy(path);
      
      if (_business != null) {
        // Delete old logo if exists
        if (_business!.logoPath != null) {
          final oldLogo = File(_business!.logoPath!);
          if (await oldLogo.exists()) {
            await oldLogo.delete();
          }
        }
        
        // Update business with new logo path
        final updatedBusiness = _business!.copyWith(logoPath: path);
        await _databaseHelper.updateBusiness(updatedBusiness);
        _business = updatedBusiness;
      }
      
      _isLoading = false;
      notifyListeners();
      
      return path;
    } catch (e) {
      print('Error saving logo: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
} 