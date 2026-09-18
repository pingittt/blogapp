class Recommendation {
  final int id;
  final String title;
  final String teks;
  final String category;
  final String? imageUrl;
  final String iconName;
  final String colorHex;

  Recommendation({
    required this.id,
    required this.title,
    required this.teks,
    required this.category,
    required this.imageUrl,
    required this.iconName,
    required this.colorHex,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      title: json['title'] ?? '',
      teks: json['teks'] ?? '',
      category: json['category'] ?? 'Umum',
      imageUrl: json['imageUrl'],
      iconName: json['iconName'] ?? 'sports_esports',
      colorHex: json['colorHex'] ?? '#8B5CF6',
    );
  }
}
