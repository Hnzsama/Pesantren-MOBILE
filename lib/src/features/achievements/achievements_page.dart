import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/achievements/models/achievement_model.dart';
import 'package:pesantren_mobile/src/features/achievements/service/achievement_service.dart';
import 'package:pesantren_mobile/src/features/achievements/widgets/achievement_card.dart';
import 'package:pesantren_mobile/src/features/home/models/santri_model.dart';

class AchievementsPage extends StatefulWidget {
  final SantriModel activeSantri;
  final VoidCallback? onBack;

  const AchievementsPage({super.key, required this.activeSantri, this.onBack});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final AchievementService _service = AchievementService();
  late Future<List<AchievementModel>> _achievementsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant AchievementsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeSantri.id != widget.activeSantri.id) {
      _loadData();
    }
  }

  void _loadData() {
    setState(() {
      _achievementsFuture = _service.getAchievements(
        widget.activeSantri.id,
        schoolId: widget.activeSantri.schoolId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Fixed Pattern Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.40,
              child: Image.asset('assets/background.jpeg', fit: BoxFit.cover),
            ),
          ),

          // 2. Main Content
          FutureBuilder<List<AchievementModel>>(
            future: _achievementsFuture,
            builder: (context, snapshot) {
              // ... existing builder logic ...
              final data = snapshot.data ?? [];

              return RefreshIndicator(
                onRefresh: () async {
                  _loadData();
                  await _achievementsFuture;
                },
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 220, // Reduced from 230
                        pinned: true,
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        scrolledUnderElevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(32),
                          ),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(32),
                              ),
                            ),
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 24,
                                  right: 24,
                                  bottom: 40,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Prestasi Santri",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.activeSantri.nama,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20, // Reduced from 22
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Colors.white
                                              .withOpacity(0.2),
                                          radius: 24,
                                          child: const Icon(
                                            Icons.emoji_events,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Total Pencapaian",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${data.length} Prestasi",
                                      style: const TextStyle(
                                        fontSize: 22, // Reduced from 24
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -1.0,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 4),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        leading: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (widget.onBack != null) {
                              widget.onBack!();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        title: const Text(
                          "Buku Prestasi",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        centerTitle: true,
                      ),
                    ];
                  },
                  body: snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : snapshot.hasError
                      ? Center(child: Text("Error: ${snapshot.error}"))
                      : data.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: data.length,
                          physics:
                              const AlwaysScrollableScrollPhysics(), // Ensure refreshable even if empty
                          itemBuilder: (context, index) {
                            return AchievementCard(achievement: data[index]);
                          },
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada prestasi yang tercatat",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Prestasi santri akan muncul di sini.",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
