class SantriModel {
  final String id;
  final String nama;
  final String kelas;
  final String? photoUrl;
  final double uangSaku;
  final String kehadiranStatus; // "Hadir", "Izin", "Sakit", "Alpha"
  final double kehadiranPercentage;

  const SantriModel({
    required this.id,
    required this.nama,
    required this.kelas,
    this.photoUrl,
    required this.uangSaku,
    required this.kehadiranStatus,
    required this.kehadiranPercentage,
  });
}

class MockData {
  static const List<SantriModel> santriList = [
    SantriModel(
      id: '1',
      nama: 'Ahmad Fulan',
      kelas: '10 MA',
      uangSaku: 150000,
      kehadiranStatus: 'Hadir',
      kehadiranPercentage: 95.0,
    ),
    SantriModel(
      id: '2',
      nama: 'Siti Fulanah',
      kelas: '8 MTs',
      uangSaku: 50000,
      kehadiranStatus: 'Sakit',
      kehadiranPercentage: 88.5,
    ),
  ];
}
