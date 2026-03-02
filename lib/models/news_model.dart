class NewsModel {
  final String title;
  final String category;
  final String imageUrl;
  final String author;
  final String content;

  NewsModel({
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.author,
    required this.content,
  });

  factory NewsModel.fromMap(Map<dynamic, dynamic> map) {
    return NewsModel(
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      author: map['author']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
    );
  }
}