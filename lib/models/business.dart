class Business {
  final int? id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String? website;
  final String? logoPath;
  final String? taxId;
  final String? bankDetails;
  
  Business({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    this.website,
    this.logoPath,
    this.taxId,
    this.bankDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'logoPath': logoPath,
      'taxId': taxId,
      'bankDetails': bankDetails,
    };
  }

  static Business fromMap(Map<String, dynamic> map) {
    return Business(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      website: map['website'],
      logoPath: map['logoPath'],
      taxId: map['taxId'],
      bankDetails: map['bankDetails'],
    );
  }

  Business copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? logoPath,
    String? taxId,
    String? bankDetails,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      logoPath: logoPath ?? this.logoPath,
      taxId: taxId ?? this.taxId,
      bankDetails: bankDetails ?? this.bankDetails,
    );
  }
} 