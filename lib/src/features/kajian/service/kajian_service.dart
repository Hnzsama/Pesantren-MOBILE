import 'package:pesantren_mobile/src/features/kajian/models/kajian_model.dart';

class KajianService {
  // Mock Data
  static final List<VideoLecture> _mockVideos = [
    VideoLecture(
      id: '1',
      title: 'Tausiyah Rutin Bulanan',
      videoId: 'APaxt8Bp4D0',
      description:
          'Kajian rutin bulanan membahas pentingnya pendidikan karakter di era digital.',
      publishedAt: DateTime(2025, 12, 10),
    ),
    VideoLecture(
      id: '2',
      title: 'Persiapan Menghadapi Ujian',
      videoId: 'Fwa9B31IQaM',
      description:
          'Tips dan trik bagi santri dan wali santri dalam menghadapi ujian akhir semester.',
      publishedAt: DateTime(2025, 11, 25),
    ),
    VideoLecture(
      id: '3',
      title: 'Pengajian Akbar Wali Santri',
      videoId: 'MZntmydTc-o',
      description:
          'Siaran tunda pengajian akbar tahunan bersama Kyai Pimpinan Pondok.',
      publishedAt: DateTime(2025, 10, 15),
    ),
  ];

  Future<List<VideoLecture>> getVideos() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockVideos;
  }
}
