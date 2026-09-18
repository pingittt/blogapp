import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'post_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<AppNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = _apiService.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifikasi'),
        backgroundColor: AppColors.surface,
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: _future,
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
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada notifikasi.\nKalau ada yang komen di post kamu, muncul di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.accentLight,
                      child:
                          Icon(Icons.comment_rounded, color: AppColors.neonCyan, size: 18),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 13.5),
                          children: [
                            TextSpan(
                                text: n.commenter,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ' mengomentari '),
                            TextSpan(
                                text: '"${n.postTitle}"',
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.neonCyan)),
                            TextSpan(text: ': ${n.comment}'),
                          ],
                        ),
                      ),
                    ),
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
