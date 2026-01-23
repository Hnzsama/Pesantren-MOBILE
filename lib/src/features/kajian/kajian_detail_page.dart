import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/kajian/models/kajian_model.dart';
import 'package:pesantren_mobile/src/features/kajian/service/kajian_service.dart';
import 'package:pesantren_mobile/src/features/kajian/widgets/kajian_card.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class KajianDetailPage extends StatefulWidget {
  final VideoLecture video;
  const KajianDetailPage({super.key, required this.video});

  @override
  State<KajianDetailPage> createState() => _KajianDetailPageState();
}

class _KajianDetailPageState extends State<KajianDetailPage> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  final KajianService _service = KajianService();
  late Future<List<VideoLecture>> _relatedVideosFuture;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        isLive: false,
        forceHD: false,
        enableCaption: false,
      ),
    )..addListener(_listener);

    // Fetch related videos (excluding current one)
    _relatedVideosFuture = _service.getVideos().then(
      (list) => list.where((v) => v.id != widget.video.id).toList(),
    );
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      //
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // YoutubePlayerBuilder handles fullscreen automatically
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primary,
        onReady: () {
          _isPlayerReady = true;
        },
        topActions: [
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text("Detail Kajian"),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              // 0. Pattern Overlay
              Positioned.fill(
                child: Opacity(
                  opacity: 0.40,
                  child: Image.asset(
                    'assets/background.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 1. Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1.1 The Player (Fixed)
                  player,

                  // 1.2 Details (Fixed)
                  Container(
                    color: Colors.white.withOpacity(
                      0.95,
                    ), // Semi-transparent for readability over pattern
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.video.formattedDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            if (widget.video.isLive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "LIVE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.video.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // 1.3 Scrollable Related Videos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: const Text(
                            "Kajian Lainnya",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: FutureBuilder<List<VideoLecture>>(
                            future: _relatedVideosFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final related = snapshot.data ?? [];
                              if (related.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text("Tidak ada kajian lain."),
                                );
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: related.length,
                                itemBuilder: (context, index) {
                                  return KajianCard(
                                    video: related[index],
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => KajianDetailPage(
                                            video: related[index],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
