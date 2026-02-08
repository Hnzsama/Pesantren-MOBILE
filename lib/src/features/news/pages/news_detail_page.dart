import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/constants/app_colors.dart';
import 'package:pesantren_mobile/src/features/news/models/news_model.dart';
import 'package:pesantren_mobile/src/features/news/services/news_service.dart';

class NewsDetailPage extends StatefulWidget {
  final String newsId;

  const NewsDetailPage({super.key, required this.newsId});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final NewsService _newsService = NewsService();
  NewsModel? _news;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNewsDetail();
  }

  Future<void> _loadNewsDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final news = await _newsService.getNewsById(widget.newsId);
      if (mounted) {
        setState(() {
          _news = news;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat detail pengumuman';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Pengumuman',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _news == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Pengumuman tidak ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNewsDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Gallery
          if (_news!.images != null && _news!.images!.isNotEmpty)
            _buildImageGallery(),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Author
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _news!.formattedDate,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    if (_news!.author != null) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _news!.author!.name,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  _news!.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),

                // Content
                Text(
                  _stripHtmlTags(_news!.content),
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),

                // School Info
                if (_news!.school != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.school, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _news!.school!.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = _news!.images!;

    if (images.length == 1) {
      final imageUrl = images.first;
      return kIsWeb
          ? FutureBuilder<http.Response>(
              future: http.get(
                Uri.parse(imageUrl),
                headers: {'ngrok-skip-browser-warning': 'true'},
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data!.statusCode == 200) {
                  return Image.memory(
                    snapshot.data!.bodyBytes,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  );
                }
                return _buildErrorPlaceholder();
              },
            )
          : Image.network(
              imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildErrorPlaceholder(),
            );
    }

    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              kIsWeb
                  ? FutureBuilder<http.Response>(
                      future: http.get(
                        Uri.parse(images[index]),
                        headers: {'ngrok-skip-browser-warning': 'true'},
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData &&
                            snapshot.data!.statusCode == 200) {
                          return Image.memory(
                            snapshot.data!.bodyBytes,
                            fit: BoxFit.cover,
                          );
                        }
                        return _buildErrorPlaceholder();
                      },
                    )
                  : Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorPlaceholder(),
                    ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${index + 1} / ${images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _stripHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').replaceAll('&nbsp;', ' ');
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: 250,
      color: Colors.grey[200],
      child: Icon(Icons.broken_image, size: 64, color: Colors.grey[400]),
    );
  }
}
