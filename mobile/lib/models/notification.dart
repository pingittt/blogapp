class AppNotification {
  final int id;
  final String comment;
  final String createdAt;
  final int postId;
  final String postTitle;
  final String commenter;

  AppNotification({
    required this.id,
    required this.comment,
    required this.createdAt,
    required this.postId,
    required this.postTitle,
    required this.commenter,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      comment: json['comment'] ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      postId: json['postId'],
      postTitle: json['postTitle'] ?? '',
      commenter: json['commenter'] ?? 'Seseorang',
    );
  }
}
