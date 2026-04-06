class NewsItem {
  final String id;
  final String headline;
  final String summary;
  final String imageUrl;
  final String source;
  final String publishedAt;
  final String category;

  const NewsItem({
    required this.id,
    required this.headline,
    required this.summary,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.category,
  });
}
