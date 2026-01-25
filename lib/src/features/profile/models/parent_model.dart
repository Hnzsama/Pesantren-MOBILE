class ParentModel {
  final String id;
  final String name;
  final String phone;
  final String? email;

  const ParentModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? 'Unknown',
      phone: json['phone_number'] ?? json['phone'] ?? '-',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'phone': phone, 'email': email};
  }
}
