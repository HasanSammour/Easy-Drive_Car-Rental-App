class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? driverLicense;
  final String? profileImageUrl;
  final bool isAdmin;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.driverLicense,
    this.profileImageUrl,
    this.isAdmin = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'driverLicense': driverLicense,
      'profileImageUrl': profileImageUrl,
      'isAdmin': isAdmin,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      phone: map['phone'],
      driverLicense: map['driverLicense'],
      profileImageUrl: map['profileImageUrl'],
      isAdmin: map['isAdmin'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}