import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:pesantren_mobile/src/features/news/models/news_model.dart';
import 'package:pesantren_mobile/src/features/news/services/news_service.dart';
import 'package:pesantren_mobile/src/features/news/pages/news_list_page.dart';
import 'package:pesantren_mobile/src/features/news/pages/news_detail_page.dart';
import 'package:pesantren_mobile/src/shared/utils/error_handler.dart';

class NewsHomeWidget extends StatefulWidget {
  const NewsHomeWidget({super.key});

  @override
  State<NewsHomeWidget> createState() => _NewsHomeWidgetState();
}

class _NewsHomeWidgetState extends State<NewsHomeWidget> {
  final NewsService _newsService = NewsService();
  List<NewsModel> _newsList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLatestNews();
  }

  Future<void> _loadLatestNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final news = await _newsService.getLatestNews(limit: 5);
      if (mounted) {
        setState(() {
          _newsList = news;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ErrorHandler.getErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Pengumuman Terbaru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewsListPage(),
                    ),
                  );
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Content
        if (_isLoading)
          _buildLoadingState()
        else if (_error != null)
          _buildErrorState()
        else if (_newsList.isEmpty)
          _buildEmptyState()
        else
          _buildNewsList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          width: double.infinity,
          height: 100,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
        );
      }),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Terjadi kesalahan',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadLatestNews,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Belum ada pengumuman',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList() {
    return Column(
      children: _newsList.map((news) {
        return _buildNewsCard(news);
      }).toList(),
    );
  }

  Widget _buildNewsCard(NewsModel news) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailPage(newsId: news.id),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image on the left
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: news.thumbnailImage != null
                  ? (kIsWeb
                        ? FutureBuilder<http.Response>(
                            future: http.get(
                              Uri.parse(news.thumbnailImage!),
                              headers: {'ngrok-skip-browser-warning': 'true'},
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData &&
                                  snapshot.data!.statusCode == 200) {
                                return Image.memory(
                                  snapshot.data!.bodyBytes,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                );
                              }
                              return _buildPlaceholderImage(isCompact: true);
                            },
                          )
                        : Image.network(
                            news.thumbnailImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage(isCompact: true);
                            },
                          ))
                  : _buildPlaceholderImage(isCompact: true),
            ),

            // Content on the right
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      news.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news.formattedDate,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage({bool isCompact = false}) {
    return Container(
      width: isCompact ? 100 : double.infinity,
      height: isCompact ? 100 : 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: isCompact
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              )
            : const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Icon(Icons.article, size: 40, color: Colors.grey[400]),
    );
  }
}
