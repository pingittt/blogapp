import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String _tokenKey = 'auth_token';
  static String _userIdKey = 'user_id';
  static String _usernameKey = 'username';
  static String _roleKey = 'role';
  static String _avatarUrlKey = 'avatar_url';
  static String _rememberedEmailKey = 'remembered_email';

  Future<void> saveRememberedEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null || email.isEmpty) {
      await prefs.remove(_rememberedEmailKey);
    } else {
      await prefs.setString(_rememberedEmailKey, email);
    }
  }

  Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rememberedEmailKey);
  }

  Future<void> saveSession({
    required String token,
    required int userId,
    required String username,
    required String role,
    String? avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_roleKey, role);
    if (avatarUrl != null) {
      await prefs.setString(_avatarUrlKey, avatarUrl);
    } else {
      await prefs.remove(_avatarUrlKey);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<String?> getAvatarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarUrlKey);
  }

  Future<void> updateStoredAvatarUrl(String avatarUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarUrlKey, avatarUrl);
  }

  Future<void> updateStoredUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_avatarUrlKey);
  }
}
