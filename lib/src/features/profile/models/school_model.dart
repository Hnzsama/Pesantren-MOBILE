import 'package:flutter_dotenv/flutter_dotenv.dart';

class SchoolModel {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? description;
  final String? logoPath;

  const SchoolModel({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.description,
    this.logoPath,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    String? logo = json['logo_path'];
    if (logo != null && !logo.startsWith('http')) {
      final baseUrl = dotenv.env['IMG_URL'] ?? '';
      if (baseUrl.isNotEmpty) {
        if (logo!.startsWith('/')) {
          logo = '$baseUrl$logo';
        } else {
          logo = '$baseUrl/$logo';
        }
      }
    }

    return SchoolModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['school_name'] ?? 'Unknown',
      address: json['address'] ?? json['school_address'] ?? '-',
      phone: json['phone'] ?? json['phone_number'],
      description: json['description'],
      logoPath: logo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'logo_path': logoPath,
    };
  }
}
