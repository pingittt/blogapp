import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Daftar kategori post, harus sama persis dengan POST_CATEGORIES di backend
/// (Server/src/config/schema.ts).
List<String> postCategories = [
  'Umum',
  'Review',
  'Berita',
  'Tips & Trik',
  'Rilis Baru',
  'Esports',
];

/// Konversi string hex ("#RRGGBB") dari backend jadi Color.
Color colorFromHex(String hex) {
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

/// Peta nama ikon (string dari backend/JSON) ke IconData Flutter.
/// Dipakai supaya backend cukup kirim string, tidak perlu kirim aset gambar.
IconData iconFromName(String name) {
  switch (name) {
    case 'auto_awesome':
      return Icons.auto_awesome_rounded;
    case 'sports_esports':
      return Icons.sports_esports_rounded;
    case 'gps_fixed':
      return Icons.gps_fixed_rounded;
    case 'rocket_launch':
      return Icons.rocket_launch_rounded;
    case 'emoji_events':
      return Icons.emoji_events_rounded;
    case 'construction':
      return Icons.construction_rounded;
    default:
      return Icons.sports_esports_rounded;
  }
}

/// Warna badge untuk tiap kategori post, dipakai konsisten di seluruh app.
Color colorForCategory(String category) {
  switch (category) {
    case 'Review':
      return Color(0xFFE17055);
    case 'Berita':
      return Color(0xFF6C5CE7);
    case 'Tips & Trik':
      return Color(0xFF00B894);
    case 'Rilis Baru':
      return Color(0xFF0984E3);
    case 'Esports':
      return Color(0xFFFDCB6E);
    default:
      return AppColors.textMuted;
  }
}
