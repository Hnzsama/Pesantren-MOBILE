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

  bool get isLive => false;

  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

  String get formattedDate {
    return DateFormat('d MMMM yyyy', 'id_ID').format(publishedAt);
  }
}
