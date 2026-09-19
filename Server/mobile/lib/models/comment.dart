class Comment {
  final int id;
  final String comment;
  final String author;
  final int userId;
  final String createdAt;

  Comment({
    required this.id,
    required this.comment,
    required this.author,
    required this.userId,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      comment: json['comment'],
      author: json['author'] ?? 'Anonim',
      userId: json['userId'] ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
