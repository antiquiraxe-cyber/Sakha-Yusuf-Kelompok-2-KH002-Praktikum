class User {
  final int id;
  final String name;
  final String email;
  final String city;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final address = json['address'];
    return User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      city: address is Map<String, dynamic>
          ? address['city'] as String? ?? ''
          : json['city'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'city': city,
      };
}
