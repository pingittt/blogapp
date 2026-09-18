// Mapping kategori -> nama ikon & warna, dipakai untuk kartu rekomendasi.
// Nilai iconName harus cocok dengan mapping di Flutter (lib/theme/category_style.dart).

export function iconForCategory(category: string): string {
  switch (category) {
    case "Review":
      return "gps_fixed";
    case "Berita":
      return "auto_awesome";
    case "Tips & Trik":
      return "construction";
    case "Rilis Baru":
      return "rocket_launch";
    case "Esports":
      return "emoji_events";
    default:
      return "sports_esports";
  }
}

export function colorForCategory(category: string): string {
  switch (category) {
    case "Review":
      return "#E17055";
    case "Berita":
      return "#6C5CE7";
    case "Tips & Trik":
      return "#00B894";
    case "Rilis Baru":
      return "#0984E3";
    case "Esports":
      return "#FDCB6E";
    default:
      return "#8B5CF6";
  }
}
