class PostImage {
  final int id;
  final String imageUrl;

  PostImage({required this.id, required this.imageUrl});

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(id: json['id'], imageUrl: json['imageUrl']);
  }
}

class Post {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final List<PostImage> images;
  final String category;
  final String status;
  final String author;
  final String authorRole;
  final int userId;
  final String createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.images,
    required this.category,
    required this.status,
    required this.author,
    required this.authorRole,
    required this.userId,
    required this.createdAt,
  });

  bool get isAuthorAdmin => authorRole == 'admin';

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => PostImage.fromJson(e))
          .toList(),
      category: json['category'] ?? 'Umum',
      status: json['status'] ?? 'published',
      author: json['author'] ?? 'Anonim',
      authorRole: json['authorRole'] ?? 'user',
      userId: json['userId'] ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
