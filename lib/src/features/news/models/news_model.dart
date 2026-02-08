import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pesantren_mobile/src/features/profile/models/school_model.dart';

class AuthorModel {
  final String id;
  final String name;

  const AuthorModel({required this.id, required this.name});

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class NewsModel {
  final String id;
  final String? schoolId;
  final String authorId;
  final String title;
  final String content;
  final List<String>? images;
  final String targetRole; // 'admin', 'guardian', 'student', 'all'
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AuthorModel? author;
  final SchoolModel? school;

  const NewsModel({
    required this.id,
    this.schoolId,
    required this.authorId,
    required this.title,
    required this.content,
    this.images,
    required this.targetRole,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.school,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    // Get IMG_URL from .env
    final imgBaseUrl = dotenv.env['IMG_URL'] ?? '';

    // Parse images array and prepend base URL if needed
    List<String>? imageList;
    if (json['images'] != null) {
      if (json['images'] is List) {
        imageList = (json['images'] as List).map((img) {
          final imgStr = img.toString();
          // If the image path starts with 'http', it's already a full URL
          if (imgStr.startsWith('http')) {
            return imgStr;
          }
          // Otherwise, prepend the IMG_URL base
          // Remove leading slash if present to avoid double slashes
          final cleanPath = imgStr.startsWith('/')
              ? imgStr.substring(1)
              : imgStr;
          return '$imgBaseUrl/$cleanPath';
        }).toList();
      }
    }

    return NewsModel(
      id: json['id']?.toString() ?? '',
      schoolId: json['school_id']?.toString(),
      authorId: json['author_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      images: imageList,
      targetRole: json['target_role']?.toString() ?? 'all',
      isPublished:
          json['is_published'] == true ||
          json['is_published']?.toString() == 'true',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      author: json['author'] != null
          ? AuthorModel.fromJson(json['author'])
          : null,
      school: json['school'] != null
          ? SchoolModel.fromJson(json['school'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'author_id': authorId,
      'title': title,
      'content': content,
      'images': images,
      'target_role': targetRole,
      'is_published': isPublished,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'author': author?.toJson(),
      'school': school?.toJson(),
    };
  }

  // Helper getter for content preview (first 100 characters)
  String get contentPreview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  // Helper getter for thumbnail image
  String? get thumbnailImage {
    if (images != null && images!.isNotEmpty) {
      return images!.first;
    }
    return null;
  }

  // Helper getter for formatted date
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }
}
