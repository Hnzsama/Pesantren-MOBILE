import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';

class UserModel {
  final String id;
  final String name;
  final String username;
  final String? email;
  final List<String> roles;
  final List<SantriModel> students;

  // Add other fields as necessary, e.g. school

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    required this.roles,
    required this.students,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'User',
      username: json['username'] ?? '',
      email: json['email'],
      roles:
          (json['roles'] as List?)
              ?.map((e) => e is Map ? e['name'].toString() : e.toString())
              .toList() ??
          [],
      students:
          (json['students'] as List?)
              ?.map((e) => SantriModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'roles': roles,
      'students': students.map((e) => e.toJson()).toList(),
    };
  }
}
