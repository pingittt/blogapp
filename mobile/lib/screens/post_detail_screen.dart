import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/category_style.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final _commentController = TextEditingController();
  final _galleryController = PageController();

  late Future<List<Comment>> _commentsFuture;
  bool _isLoggedIn = false;
  bool _isSubmitting = false;
  int _galleryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final loggedIn = await _authService.isLoggedIn();
    setState(() => _isLoggedIn = loggedIn);
  }

  void _loadComments() {
    setState(() {
      _commentsFuture = _apiService.getComments(widget.post.id);
    });
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      await _apiService.createComment(
          widget.post.id, _commentController.text.trim());
      _commentController.clear();
      _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _galleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final gallery =
        post.images.isNotEmpty
            ? post.images.map((img) => img.imageUrl).toList()
            : (post.imageUrl != null ? [post.imageUrl!] : []);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Detail Post'),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                if (gallery.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          PageView.builder(
                            controller: _galleryController,
                            itemCount: gallery.length,
                            onPageChanged: (i) =>
                                setState(() => _galleryIndex = i),
                            itemBuilder: (context, index) => Image.network(
                              gallery[index],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.accentLight,
                                child: Icon(Icons.image_not_supported_rounded,
                                    color: AppColors.accent),
                              ),
                            ),
                          ),
                          if (gallery.length > 1)
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  gallery.length,
                                  (i) => Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 3),
                                    width: i == _galleryIndex ? 18 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: i == _galleryIndex
                                          ? AppColors.neonPink
                                          : Colors.white54,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                ],
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorForCategory(post.category).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(post.category,
                      style: TextStyle(
                          color: colorForCategory(post.category),
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 10),
                Text(post.title,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.accentLight,
                      child: Icon(Icons.person_rounded,
                          size: 14, color: AppColors.accent),
                    ),
                    SizedBox(width: 8),
                    Text(post.author,
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 13)),
                    if (post.isAuthorAdmin) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 11, color: Colors.white),
                            SizedBox(width: 3),
                            Text('ADMIN',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Divider(height: 32, color: AppColors.border),
                Text(post.content,
                    style: TextStyle(
                        fontSize: 15, height: 1.6, color: AppColors.textPrimary)),
                SizedBox(height: 28),
                Text('Komentar',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary)),
                SizedBox(height: 10),
                FutureBuilder<List<Comment>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.neonPink)),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Gagal memuat komentar: ${snapshot.error}',
                          style: TextStyle(color: Colors.redAccent));
                    }
                    final comments = snapshot.data ?? [];
                    if (comments.isEmpty) {
                      return Text('Belum ada komentar. Jadilah yang pertama!',
                          style: TextStyle(color: AppColors.textMuted));
                    }
                    return Column(
                      children: comments
                          .map((c) => Container(
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.accentLight,
                                      child: Icon(Icons.person_rounded,
                                          size: 14, color: AppColors.accent),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(c.author,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: AppColors.textPrimary)),
                                          SizedBox(height: 2),
                                          Text(c.comment,
                                              style: TextStyle(
                                                  fontSize: 13.5,
                                                  color: AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          if (_isLoggedIn)
            SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                      top: BorderSide(color: AppColors.border, width: 1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Tulis komentar...',
                          filled: true,
                          fillColor: AppColors.surfaceAlt,
                          isDense: true,
                          hintStyle: TextStyle(color: AppColors.textMuted),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppColors.neonPink,
                      child: _isSubmitting
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : IconButton(
                              icon: Icon(Icons.send_rounded,
                                  color: Colors.white, size: 18),
                              onPressed: _submitComment,
                            ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14),
              color: AppColors.surface,
              child: Text('Masuk untuk menambahkan komentar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted)),
            ),
        ],
      ),
    );
  }
}
