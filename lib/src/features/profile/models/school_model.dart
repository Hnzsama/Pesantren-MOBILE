class SchoolModel {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? description;

  const SchoolModel({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.description,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['school_name'] ?? 'Unknown',
      address: json['address'] ?? json['school_address'] ?? '-',
      phone: json['phone'] ?? json['phone_number'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
    };
  }
}
