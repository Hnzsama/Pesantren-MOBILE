import 'package:pesantren_mobile/src/features/achievements/models/achievement_model.dart';

class AchievementService {
  // Mock Data attached to Students
  // Assuming student IDs match what we have in SantriModel or are generic
  // "1" = Ahmad Fulan
  // "2" = Siti Aminah

  static final List<AchievementModel> _mockAchievements = [
    AchievementModel(
      id: '1',
      studentId: '1',
      title: 'Juara 1 Lomba Tahfidz Juz 30',
      dateAchieved: DateTime(2025, 12, 15),
      description:
          'Meraih juara pertama dalam musabaqah hifdzil quran kategori juz 30 tingkat kabupaten.',
      images: [
        'https://picsum.photos/id/1018/400/300',
        'https://picsum.photos/id/1015/400/300',
      ],
    ),
    AchievementModel(
      id: '2',
      studentId: '1',
      title: 'Santri Teladan Bulan November',
      dateAchieved: DateTime(2025, 11, 30),
      description:
          'Penghargaan atas kedisiplinan dan akhlak mulia selama bulan November.',
      images: ['https://picsum.photos/id/1025/400/300'],
    ),
    AchievementModel(
      id: '3',
      studentId: '2',
      title: 'Juara 2 Kaligrafi Nasional',
      dateAchieved: DateTime(2025, 10, 20),
      description:
          'Kompetisi seni kaligrafi tingkat nasional yang diadakan di Jakarta.',
      images: [], // Test no image
    ),
  ];

  Future<List<AchievementModel>> getAchievements(String studentId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return _mockAchievements.where((a) => a.studentId == studentId).toList();
  }
}
