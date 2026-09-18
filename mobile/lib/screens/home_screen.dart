import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/post.dart';
import '../models/recommendation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/category_style.dart';
import 'post_detail_screen.dart';
import 'post_form_screen.dart';
import 'login_screen.dart';
import 'category_browse_screen.dart';
import 'leaderboard_screen.dart';
import 'notifications_screen.dart';
import 'edit_profile_screen.dart';
import 'feedback_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoggedIn = false;
  String? _username;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final loggedIn = await _authService.isLoggedIn();
    final username = await _authService.getUsername();
    final avatarUrl = await _authService.getAvatarUrl();
    setState(() {
      _isLoggedIn = loggedIn;
      _username = username;
      _avatarUrl = avatarUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        drawer: _AppDrawer(
          isLoggedIn: _isLoggedIn,
          username: _username,
          authService: _authService,
          onChanged: _checkSession,
        ),
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          surfaceTintColor: AppColors.surface,
          titleSpacing: 8,
          leading: IconButton(
            icon: Icon(Icons.menu_rounded, color: AppColors.textPrimary),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10),
              Text('Stray',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                if (!_isLoggedIn) {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()));
                  _checkSession();
                }
              },
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                        ? Image.network(_avatarUrl!, fit: BoxFit.cover)
                        : Icon(Icons.person_rounded,
                            color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(52),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: TabBar(
                isScrollable: false,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: AppColors.neonPink,
                indicatorWeight: 3,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                tabs: [
                  Tab(text: 'For You'),
                  Tab(text: 'Semua Post'),
                  Tab(text: 'Post Saya'),
                  Tab(text: 'Profil'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _ForYouTab(apiService: _apiService),
            _AllPostsTab(apiService: _apiService),
            _isLoggedIn
                ? _MyPostsTab(apiService: _apiService)
                : _LoginPrompt(onLoggedIn: _checkSession),
            _ProfileTab(
              isLoggedIn: _isLoggedIn,
              username: _username,
              avatarUrl: _avatarUrl,
              authService: _authService,
              onChanged: _checkSession,
            ),
          ],
        ),
        floatingActionButton: _isLoggedIn
            ? Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.neonPink.withOpacity(0.4),
                        blurRadius: 16,
                        offset: Offset(0, 6)),
                  ],
                ),
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PostFormScreen()),
                    );
                    setState(() {});
                  },
                  icon: Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                  label: Text('Tulis', style: TextStyle(color: Colors.white)),
                ),
              )
            : null,
      ),
    );
  }
}

// --------------------- DRAWER (menu tambahan) ---------------------

class _AppDrawer extends StatelessWidget {
  final bool isLoggedIn;
  final String? username;
  final AuthService authService;
  final VoidCallback onChanged;

  _AppDrawer({
    required this.isLoggedIn,
    required this.username,
    required this.authService,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/images/logo.png',
                        width: 44, height: 44, fit: BoxFit.cover),
                  ),
                  SizedBox(height: 10),
                  Text('Stray',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(
                    isLoggedIn ? 'Halo, ${username ?? ''}' : 'Belum masuk',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            if (isLoggedIn)
              _drawerTile(context, Icons.notifications_none_rounded, 'Notifikasi', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => NotificationsScreen()));
              }),
            _drawerTile(context, Icons.category_rounded, 'Kategori', () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CategoryBrowseScreen()));
            }),
            _drawerTile(context, Icons.leaderboard_rounded, 'Top Kontributor', () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => LeaderboardScreen()));
            }),
            if (isLoggedIn)
              _drawerTile(context, Icons.settings_outlined, 'Pengaturan Akun', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => EditProfileScreen()));
              }),
            _drawerTile(context, Icons.share_rounded, 'Bagikan', () {
              Navigator.pop(context);
              Share.share(
                  'Coba Stray — blog komunitas gamer buat review, tips, dan berita game!');
            }),
            _drawerTile(context, Icons.feedback_outlined, 'Kirim Masukan', () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => FeedbackScreen()));
            }),
            _drawerTile(context, Icons.info_outline_rounded, 'Tentang Aplikasi', () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: Text('Tentang Stray',
                      style: TextStyle(color: AppColors.textPrimary)),
                  content: Text(
                    'Stray adalah blog komunitas gamer: review, tips, dan berita game. '
                    'Dibangun dengan Express.js + MySQL (backend) dan Flutter (mobile).',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Tutup')),
                  ],
                ),
              );
            }),
            _drawerTile(context, Icons.help_outline_rounded, 'Bantuan', () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: Text('Bantuan',
                      style: TextStyle(color: AppColors.textPrimary)),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _FaqItem(
                          q: 'Kenapa gambar gagal diupload?',
                          a: 'Pastikan file berformat gambar (jpg/png) dan ukuran di bawah 5MB.',
                        ),
                        SizedBox(height: 12),
                        _FaqItem(
                          q: 'Kenapa data gagal dimuat?',
                          a: 'Pastikan server backend (npm run dev) sedang berjalan.',
                        ),
                        SizedBox(height: 12),
                        _FaqItem(
                          q: 'Bagaimana cara menghapus post?',
                          a: 'Buka tab "Post Saya", tekan ikon tempat sampah di post yang ingin dihapus.',
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Tutup')),
                  ],
                ),
              );
            }),
            Spacer(),
            Divider(color: AppColors.border, height: 1),
            if (isLoggedIn)
              _drawerTile(context, Icons.logout_rounded, 'Keluar', () async {
                await authService.logout();
                onChanged();
                if (context.mounted) Navigator.pop(context);
              }, color: Colors.redAccent),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(BuildContext context, IconData icon, String label,
      VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textMuted, size: 22),
      title: Text(label,
          style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14)),
      onTap: onTap,
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String q;
  final String a;
  _FaqItem({required this.q, required this.a});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(q,
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
        SizedBox(height: 3),
        Text(a, style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
      ],
    );
  }
}

// --------------------- FOR YOU TAB ---------------------

class _ForYouTab extends StatefulWidget {
  final ApiService apiService;
  _ForYouTab({required this.apiService});

  @override
  State<_ForYouTab> createState() => _ForYouTabState();
}

class _ForYouTabState extends State<_ForYouTab> {
  late Future<List<Recommendation>> _recommendationsFuture;
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _recommendationsFuture = widget.apiService.getRecommendations();
    _postsFuture = widget.apiService.getPosts();
  }

  Future<void> _refresh() async {
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.neonPink,
      backgroundColor: AppColors.surface,
      onRefresh: _refresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: AppColors.neonPurple.withOpacity(0.35),
                    blurRadius: 20,
                    offset: Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Update Terkini Dunia Game',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text(
                        'Review, tips, dan bocoran rilis — langsung dari komunitas.',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.videogame_asset_rounded,
                      color: Colors.white, size: 26),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          _SectionTitle(title: 'Rekomendasi Untukmu', trailing: 'Terbaru'),
          SizedBox(height: 14),
          SizedBox(
            height: 175,
            child: FutureBuilder<List<Recommendation>>(
              future: _recommendationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _HorizontalSkeleton();
                }
                if (snapshot.hasError) {
                  return _InlineError(message: '${snapshot.error}');
                }
                final recs = snapshot.data ?? [];
                if (recs.isEmpty) {
                  return _EmptyInline(
                      text: 'Belum ada post. Tulis post pertamamu dulu!');
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recs.length,
                  itemBuilder: (context, index) {
                    final r = recs[index];
                    final color = colorFromHex(r.colorHex);
                    final hasImage = r.imageUrl != null && r.imageUrl!.isNotEmpty;
                    return Container(
                      width: 210,
                      margin: EdgeInsets.only(right: 14),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.35),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Latar: gambar asli post (kalau ada) atau gradient polos
                          if (hasImage)
                            Image.network(r.imageUrl!, fit: BoxFit.cover)
                          else
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color, color.withOpacity(0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          // Overlay gelap supaya teks tetap terbaca di atas foto
                          if (hasImage)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.15),
                                    Colors.black.withOpacity(0.75),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.22),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Icon(iconFromName(r.iconName),
                                      color: Colors.white, size: 17),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(r.category.toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5)),
                                    SizedBox(height: 3),
                                    Text(r.title,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    SizedBox(height: 2),
                                    Text(r.teks,
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 28),
          _SectionTitle(title: 'Blog Terbaru'),
          SizedBox(height: 14),
          _PostsList(future: _postsFuture),
        ],
      ),
    );
  }
}

// --------------------- ALL POSTS TAB ---------------------

class _AllPostsTab extends StatefulWidget {
  final ApiService apiService;
  _AllPostsTab({required this.apiService});

  @override
  State<_AllPostsTab> createState() => _AllPostsTabState();
}

class _AllPostsTabState extends State<_AllPostsTab> {
  late Future<List<Post>> _postsFuture;
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _postsFuture = widget.apiService.getPosts();
  }

  Future<void> _refresh() async {
    setState(() {
      _postsFuture = widget.apiService.getPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.neonPink,
      backgroundColor: AppColors.surface,
      onRefresh: _refresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          _SectionTitle(title: 'Semua Post'),
          SizedBox(height: 12),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'Semua',
                  selected: _categoryFilter == null,
                  color: AppColors.neonPurple,
                  onTap: () => setState(() => _categoryFilter = null),
                ),
                ...postCategories.where((c) => c != 'Umum').map((c) => Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: _FilterChip(
                        label: c,
                        selected: _categoryFilter == c,
                        color: colorForCategory(c),
                        onTap: () => setState(() => _categoryFilter = c),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(height: 16),
          _PostsList(future: _postsFuture, categoryFilter: _categoryFilter),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  _FilterChip(
      {required this.label,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? color : AppColors.textMuted,
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}

// --------------------- MY POSTS TAB ---------------------

class _MyPostsTab extends StatefulWidget {
  final ApiService apiService;
  _MyPostsTab({required this.apiService});

  @override
  State<_MyPostsTab> createState() => _MyPostsTabState();
}

class _MyPostsTabState extends State<_MyPostsTab> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _postsFuture = widget.apiService.getMyPosts();
    });
  }

  Future<void> _delete(int id) async {
    await widget.apiService.deletePost(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.neonPink,
      backgroundColor: AppColors.surface,
      onRefresh: () async => _load(),
      child: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: AppColors.neonPink));
          }
          if (snapshot.hasError) {
            return _InlineError(message: '${snapshot.error}');
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return ListView(
              padding: EdgeInsets.all(20),
              children: [
                _EmptyState(
                  icon: Icons.edit_note_rounded,
                  title: 'Belum ada tulisan',
                  subtitle: 'Yuk mulai tulis post pertamamu lewat tombol Tulis',
                ),
              ],
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 100),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _PostCard(
                post: post,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PostDetailScreen(post: post)),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined,
                          color: AppColors.neonCyan, size: 20),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PostFormScreen(post: post)),
                        );
                        _load();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent, size: 20),
                      onPressed: () => _delete(post.id),
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

// --------------------- PROFILE TAB ---------------------

class _ProfileTab extends StatelessWidget {
  final bool isLoggedIn;
  final String? username;
  final String? avatarUrl;
  final AuthService authService;
  final VoidCallback onChanged;

  _ProfileTab({
    required this.isLoggedIn,
    required this.username,
    required this.avatarUrl,
    required this.authService,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return _LoginPrompt(onLoggedIn: onChanged);
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? Image.network(avatarUrl!, fit: BoxFit.cover)
                  : Icon(Icons.person_rounded, color: Colors.white, size: 42),
            ),
          ),
          SizedBox(height: 16),
          Text(username ?? '',
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          SizedBox(height: 6),
          Text('Gamer • Stray Member',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
          SizedBox(height: 32),
          SizedBox(
            width: 180,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () async {
                await authService.logout();
                onChanged();
              },
              icon: Icon(Icons.logout_rounded, size: 18),
              label: Text('Keluar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------- SHARED WIDGETS ---------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;
  _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.textPrimary)),
        if (trailing != null)
          Text(trailing!,
              style: TextStyle(
                  color: AppColors.neonPink,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
      ],
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  final VoidCallback onLoggedIn;
  _LoginPrompt({required this.onLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: AppColors.accentLight, shape: BoxShape.circle),
            child: Icon(Icons.lock_outline_rounded,
                color: AppColors.neonPink, size: 32),
          ),
          SizedBox(height: 16),
          Text('Masuk untuk melihat fitur ini',
              style: TextStyle(color: AppColors.textMuted)),
          SizedBox(height: 16),
          Container(
            width: 160,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
                onLoggedIn();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Masuk', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostsList extends StatelessWidget {
  final Future<List<Post>> future;
  final String? categoryFilter;
  _PostsList({required this.future, this.categoryFilter});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _VerticalSkeleton();
        }
        if (snapshot.hasError) {
          return _InlineError(message: '${snapshot.error}');
        }
        var posts = snapshot.data ?? [];
        if (categoryFilter != null) {
          posts = posts.where((p) => p.category == categoryFilter).toList();
        }
        if (posts.isEmpty) {
          return _EmptyState(
            icon: Icons.article_outlined,
            title: 'Belum ada post',
            subtitle: 'Post baru akan muncul di sini',
          );
        }
        return Column(
          children: posts
              .map((post) => _PostCard(
                    post: post,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PostDetailScreen(post: post)),
                      );
                    },
                  ))
              .toList(),
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final Widget? trailing;

  _PostCard({required this.post, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: post.imageUrl != null && post.imageUrl!.isNotEmpty
                      ? Image.network(
                          post.imageUrl!,
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderThumb(),
                        )
                      : _placeholderThumb(),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorForCategory(post.category)
                              .withOpacity(0.16),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(post.category,
                            style: TextStyle(
                                color: colorForCategory(post.category),
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 6),
                      Text(post.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4),
                      Text(post.content,
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person_rounded,
                              size: 12, color: AppColors.textMuted),
                          SizedBox(width: 4),
                          Text(post.author,
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                          if (post.isAuthorAdmin) ...[
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded,
                                      size: 9, color: Colors.white),
                                  SizedBox(width: 2),
                                  Text('ADMIN',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderThumb() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: Icon(Icons.sports_esports_rounded,
          color: Colors.white, size: 26),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}

class _EmptyInline extends StatelessWidget {
  final String text;
  _EmptyInline({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(text, style: TextStyle(color: AppColors.textMuted)));
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Gagal memuat data. Pastikan backend Express sedang berjalan.\n$message',
              style: TextStyle(color: Colors.redAccent, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalSkeleton extends StatelessWidget {
  _HorizontalSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        width: 210,
        margin: EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class _VerticalSkeleton extends StatelessWidget {
  _VerticalSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          height: 92,
          margin: EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
