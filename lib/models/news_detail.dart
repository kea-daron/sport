import 'news_item.dart';

class NewsDetail {
  final String id;
  final String headline;
  final String summary;
  final String content;
  final String imageUrl;
  final String source;
  final String publishedAt;
  final String category;

  const NewsDetail({
    required this.id,
    required this.headline,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.category,
  });

  factory NewsDetail.fromNewsItem(NewsItem item) {
    return NewsDetail(
      id: item.id,
      headline: item.headline,
      summary: item.summary,
      content: item.summary,
      imageUrl: item.imageUrl,
      source: item.source,
      publishedAt: item.publishedAt,
      category: item.category,
    );
  }
}
