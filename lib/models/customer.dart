class Customer {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? notes;
  
  Customer({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
    };
  }

  static Customer fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      notes: map['notes'],
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? notes,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
    );
  }
} 