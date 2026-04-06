import 'package:flutter/material.dart';

import '../../models/news_detail.dart';
import '../../models/news_item.dart';
import '../../services/live_score_service.dart';

class NewsDetailPage extends StatefulWidget {
  final NewsItem item;

  const NewsDetailPage({
    required this.item,
    super.key,
  });

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final LiveScoreService _liveScoreService = const LiveScoreService();
  late Future<NewsDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  Future<NewsDetail> _loadDetail() {
    if (widget.item.id.trim().isEmpty) {
      return Future.value(NewsDetail.fromNewsItem(widget.item));
    }

    return _liveScoreService.fetchNewsDetail(
      id: widget.item.id,
      fallbackItem: widget.item,
    );
  }

  Future<void> _refresh() async {
    final future = _loadDetail();
    setState(() {
      _detailFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'News Detail',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.yellow.shade600,
        backgroundColor: const Color(0xFF1E1E1E),
        onRefresh: _refresh,
        child: FutureBuilder<NewsDetail>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 420,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white70),
                    ),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMessageCard(
                    title: 'Unable to load article',
                    subtitle: '${snapshot.error}',
                  ),
                ],
              );
            }

            final detail = snapshot.data ?? NewsDetail.fromNewsItem(widget.item);
            return _buildContent(detail);
          },
        ),
      ),
    );
  }

  Widget _buildContent(NewsDetail detail) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _buildHeroImage(detail),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryTag(detail.category),
              const SizedBox(height: 14),
              Text(
                detail.headline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _formatMeta(detail),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              if (detail.summary.trim().isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  detail.summary,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _buildBodyCard(detail.content.trim().isEmpty ? detail.summary : detail.content),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage(NewsDetail detail) {
    if (detail.imageUrl.trim().isEmpty) {
      return Container(
        height: 260,
        color: const Color(0xFF191919),
        alignment: Alignment.center,
        child: Icon(Icons.newspaper_rounded, color: Colors.yellow.shade600, size: 56),
      );
    }

    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Image.network(
        detail.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF191919),
            alignment: Alignment.center,
            child: Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 48),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTag(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.yellow.shade600,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category.trim().isEmpty ? 'NEWS' : category.toUpperCase(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildBodyCard(String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        body.trim().isEmpty ? 'No article body available.' : body,
        style: TextStyle(
          color: Colors.white.withOpacity(0.88),
          fontSize: 15,
          height: 1.75,
        ),
      ),
    );
  }

  Widget _buildMessageCard({
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMeta(NewsDetail detail) {
    final parts = <String>[];
    if (detail.source.trim().isNotEmpty) {
      parts.add(detail.source.trim());
    }

    final published = _formatPublishedAt(detail.publishedAt);
    if (published.isNotEmpty) {
      parts.add(published);
    }

    return parts.isEmpty ? 'LiveScore News' : parts.join(' . ');
  }

  String _formatPublishedAt(String value) {
    if (value.trim().isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    final difference = DateTime.now().difference(parsed.toLocal());
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes.clamp(1, 59);
      return '${minutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }
}
