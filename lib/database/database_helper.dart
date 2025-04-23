import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/business.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/user.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'involet_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        photoUrl TEXT
      )
    ''');
    
    // Business table
    await db.execute('''
      CREATE TABLE business(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        website TEXT,
        logoPath TEXT,
        taxId TEXT,
        bankDetails TEXT
      )
    ''');
    
    // Customers table
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        notes TEXT
      )
    ''');
    
    // Products table
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        imagePath TEXT,
        sku TEXT,
        isTaxable INTEGER NOT NULL DEFAULT 1,
        taxRate REAL
      )
    ''');
    
    // Invoices table
    await db.execute('''
      CREATE TABLE invoices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceNumber TEXT NOT NULL,
        issueDate TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        customerId INTEGER NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        subtotal REAL NOT NULL,
        taxAmount REAL NOT NULL,
        totalAmount REAL NOT NULL,
        pdfPath TEXT,
        FOREIGN KEY (customerId) REFERENCES customers (id)
      )
    ''');
    
    // Invoice items table
    await db.execute('''
      CREATE TABLE invoice_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        description TEXT NOT NULL,
        quantity REAL NOT NULL,
        unitPrice REAL NOT NULL,
        taxRate REAL NOT NULL,
        amount REAL NOT NULL,
        FOREIGN KEY (invoiceId) REFERENCES invoices (id),
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add users table if upgrading from version 1
      await db.execute('''
        CREATE TABLE users(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          photoUrl TEXT
        )
      ''');
    }
  }

  // Hash password
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // User authentication methods
  Future<int> insertUser(User user, String password) async {
    final db = await database;
    Map<String, dynamic> userMap = user.toMap();
    userMap['password'] = _hashPassword(password);
    
    try {
      return await db.insert('users', userMap);
    } catch (e) {
      return -1;
    }
  }

  Future<User?> authenticateUser(String email, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );
    
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> updateUserPassword(String id, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': _hashPassword(newPassword)},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Business methods
  Future<int> insertBusiness(Business business) async {
    final db = await database;
    return await db.insert('business', business.toMap());
  }

  Future<Business?> getBusiness() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('business');
    
    if (maps.isEmpty) return null;
    return Business.fromMap(maps.first);
  }

  Future<int> updateBusiness(Business business) async {
    final db = await database;
    return await db.update(
      'business',
      business.toMap(),
      where: 'id = ?',
      whereArgs: [business.id],
    );
  }

  // Customer methods
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  Future<Customer?> getCustomer(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Product methods
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<Product?> getProduct(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Invoice methods
  Future<int> insertInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final db = await database;
    int invoiceId = 0;
    
    await db.transaction((txn) async {
      invoiceId = await txn.insert('invoices', invoice.toMap());
      
      for (var item in items) {
        final itemMap = item.copyWith(invoiceId: invoiceId).toMap();
        await txn.insert('invoice_items', itemMap);
      }
    });
    
    return invoiceId;
  }

  Future<List<Invoice>> getInvoices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('invoices');
    List<Invoice> invoices = [];
    
    for (var map in maps) {
      // Get customer for this invoice
      final customer = await getCustomer(map['customerId']);
      
      // Get items for this invoice
      final items = await getInvoiceItems(map['id']);
      
      invoices.add(Invoice.fromMap(map, items: items, customer: customer));
    }
    
    return invoices;
  }

  Future<Invoice?> getInvoice(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    
    // Get customer for this invoice
    final customer = await getCustomer(maps.first['customerId']);
    
    // Get items for this invoice
    final items = await getInvoiceItems(id);
    
    return Invoice.fromMap(maps.first, items: items, customer: customer);
  }

  Future<int> updateInvoice(Invoice invoice) async {
    final db = await database;
    return await db.update(
      'invoices',
      invoice.toMap(),
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<int> deleteInvoice(int id) async {
    final db = await database;
    
    // First delete all invoice items
    await db.delete(
      'invoice_items',
      where: 'invoiceId = ?',
      whereArgs: [id],
    );
    
    // Then delete the invoice
    return await db.delete(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Invoice items methods
  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'invoice_items',
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
    );
    
    List<InvoiceItem> items = [];
    
    for (var map in maps) {
      final product = await getProduct(map['productId']);
      items.add(InvoiceItem.fromMap(map, product: product));
    }
    
    return items;
  }

  Future<int> insertInvoiceItem(InvoiceItem item) async {
    final db = await database;
    return await db.insert('invoice_items', item.toMap());
  }

  Future<int> updateInvoiceItem(InvoiceItem item) async {
    final db = await database;
    return await db.update(
      'invoice_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteInvoiceItem(int id) async {
    final db = await database;
    return await db.delete(
      'invoice_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 