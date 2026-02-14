import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';
import 'package:pesantren_mobile/src/features/profile/models/school_model.dart';

class UserModel {
  final String id;
  final String name;
  final String username;
  final String? email;
  final DateTime? emailVerifiedAt;
  final List<String> roles;
  final List<SantriModel> students;

  // Add other fields as necessary, e.g. school

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    this.emailVerifiedAt,
    required this.roles,
    required this.students,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse global school data if present
    SchoolModel? schoolData;
    if (json['school'] != null) {
      schoolData = SchoolModel.fromJson(json['school']);
    }

    final user = UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'User',
      username: json['username'] ?? '',
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'])
          : null,
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

    // Inject school into students if available and not already set
    if (schoolData != null && user.students.isNotEmpty) {
      final updatedStudents = user.students.map((s) {
        return s.school == null ? s.copyWith(school: schoolData) : s;
      }).toList();

      // Need to return a new UserModel or modify the list?
      // UserModel fields are final. We should construct the list first.
      return UserModel(
        id: user.id,
        name: user.name,
        username: user.username,
        email: user.email,
        emailVerifiedAt: user.emailVerifiedAt,
        roles: user.roles,
        students: updatedStudents,
      );
    }

    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'roles': roles,
      'students': students.map((e) => e.toJson()).toList(),
    };
  }
}
