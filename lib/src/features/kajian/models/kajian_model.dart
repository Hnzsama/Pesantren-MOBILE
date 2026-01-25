import 'package:intl/intl.dart';

class VideoLecture {
  final String id;
  final String title;
  final String videoId;
  final String description;
  final DateTime publishedAt;

  const VideoLecture({
    required this.id,
    required this.title,
    required this.videoId,
    required this.description,
    required this.publishedAt,
  });

  factory VideoLecture.fromJson(Map<String, dynamic> json) {
    return VideoLecture(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Judul Kajian',
      // Extract video ID from full URL if needed, or use as is
      videoId: _extractVideoId(
        json['youtube_url'] ?? json['video_url'] ?? json['video_id'] ?? '',
      ),
      description: json['description'] ?? '',
      publishedAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  static String _extractVideoId(String url) {
    if (url.isEmpty) return '';
    // Simple regex for youtube ID
    RegExp regExp = RegExp(
      r'.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|e\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? url;
    }
    return url; // Fallback to original string if regex fails (might be already an ID)
  }

  bool get isLive => false;

  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

  String get formattedDate {
    return DateFormat('d MMMM yyyy', 'id_ID').format(publishedAt);
  }
}
