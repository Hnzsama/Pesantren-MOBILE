import 'package:flutter/material.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/kajian/models/kajian_model.dart';
import 'package:pesantren_mobile/src/features/kajian/service/kajian_service.dart';
import 'package:pesantren_mobile/src/features/kajian/widgets/kajian_card.dart';
import 'package:pesantren_mobile/src/features/kajian/kajian_detail_page.dart';
import 'package:pesantren_mobile/src/shared/utils/error_handler.dart';

class KajianPage extends StatefulWidget {
  final VoidCallback? onBack;
  const KajianPage({super.key, this.onBack});

  @override
  State<KajianPage> createState() => _KajianPageState();
}

class _KajianPageState extends State<KajianPage> {
  final KajianService _service = KajianService();
  late Future<List<VideoLecture>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = _service.getVideos();
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
          FutureBuilder<List<VideoLecture>>(
            future: _videosFuture,
            builder: (context, snapshot) {
              // ... existing builder logic ...
              final data = snapshot.data ?? [];

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _videosFuture = _service.getVideos();
                  });
                  await _videosFuture;
                },
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 160, // Increased for consistency
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
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  40,
                                  24,
                                  40,
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
                                              "Kajian & Tausiyah",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              "Majelis Ilmu",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    22, // Adjusted for consistency
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Colors.white
                                              .withOpacity(0.2),
                                          radius: 28,
                                          child: const Icon(
                                            Icons.mosque,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                      ],
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
                          "Video Kajian",
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
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  ErrorHandler.getErrorMessage(snapshot.error),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _videosFuture = _service.getVideos();
                                    });
                                  },
                                  child: const Text("Coba Lagi"),
                                ),
                              ],
                            ),
                          ),
                        )
                      : data.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return KajianCard(
                              video: data[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        KajianDetailPage(video: data[index]),
                                  ),
                                );
                              },
                            );
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
              Icons.play_circle_outline,
              size: 64,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada kajian tersedia",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
