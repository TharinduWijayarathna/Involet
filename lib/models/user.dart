class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  
  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      photoUrl: map['photoUrl'],
    );
  }
} 