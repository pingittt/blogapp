import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/category_style.dart';
import 'post_detail_screen.dart';

class CategoryBrowseScreen extends StatefulWidget {
  CategoryBrowseScreen({super.key});

  @override
  State<CategoryBrowseScreen> createState() => _CategoryBrowseScreenState();
}

class _CategoryBrowseScreenState extends State<CategoryBrowseScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Post>> _postsFuture;
  String? _selectedCategory;

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
        title: Text('Kategori'),
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
          final allPosts = snapshot.data ?? [];

          // Hitung jumlah post per kategori dari data asli
          final counts = <String, int>{};
          for (final p in allPosts) {
            counts[p.category] = (counts[p.category] ?? 0) + 1;
          }

          final filtered = _selectedCategory == null
              ? allPosts
              : allPosts.where((p) => p.category == _selectedCategory).toList();

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: postCategories.map((cat) {
                    final color = colorForCategory(cat);
                    final selected = _selectedCategory == cat;
                    final count = counts[cat] ?? 0;
                    return GestureDetector(
                      onTap: () => setState(
                          () => _selectedCategory = selected ? null : cat),
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withOpacity(0.18)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: selected ? color : AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat,
                                style: TextStyle(
                                    color: selected
                                        ? color
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            SizedBox(height: 4),
                            Text('$count post',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Divider(color: AppColors.border, height: 1),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text('Belum ada post di kategori ini',
                            style: TextStyle(color: AppColors.textMuted)))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final post = filtered[index];
                          return Card(
                            color: AppColors.surface,
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: AppColors.border)),
                            child: ListTile(
                              title: Text(post.title,
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(post.author,
                                  style:
                                      TextStyle(color: AppColors.textMuted)),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        PostDetailScreen(post: post)),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
