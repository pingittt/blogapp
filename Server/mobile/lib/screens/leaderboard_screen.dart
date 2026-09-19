import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class LeaderboardScreen extends StatefulWidget {
  LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _apiService.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Top Kontributor'),
        backgroundColor: AppColors.surface,
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: AppColors.neonPink));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Gagal memuat: ${snapshot.error}',
                    style: TextStyle(color: Colors.redAccent)));
          }
          final posts = snapshot.data ?? [];

          // Ranking dihitung dari data post ASLI (jumlah post per penulis),
          // bukan angka dummy.
          final counts = <String, int>{};
          for (final p in posts) {
            counts[p.author] = (counts[p.author] ?? 0) + 1;
          }
          final ranked = counts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          if (ranked.isEmpty) {
            return Center(
                child: Text('Belum ada post untuk dirangking',
                    style: TextStyle(color: AppColors.textMuted)));
          }

          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: ranked.length,
            itemBuilder: (context, index) {
              final entry = ranked[index];
              final isTop3 = index < 3;
              final medalColor = index == 0
                  ? Color(0xFFFFD700)
                  : index == 1
                      ? Color(0xFFC0C0C0)
                      : Color(0xFFCD7F32);
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isTop3
                            ? medalColor.withOpacity(0.2)
                            : AppColors.surfaceAlt,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${index + 1}',
                            style: TextStyle(
                                color: isTop3 ? medalColor : AppColors.textMuted,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(entry.key,
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                    Text('${entry.value} post',
                        style: TextStyle(
                            color: AppColors.neonCyan,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
