import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/recommendation.dart';
import '../models/notification.dart';
import 'auth_service.dart';

class ApiService {
  // PENTING - sesuaikan base URL dengan environment kamu:
  // - Flutter Web (Chrome)   -> http://127.0.0.1:3000 (pakai 127.0.0.1, BUKAN localhost -
  //   di sebagian Windows, 'localhost' coba resolve ke IPv6 dulu dan gagal connect)
  // - Emulator Android       -> http://10.0.2.2:3000
  // - iOS Simulator          -> http://127.0.0.1:3000
  // - Device fisik (HP asli) -> http://<IP-komputer-kamu>:3000
  static String baseUrl = 'http://127.0.0.1:3000';
  static String apiUrl = '$baseUrl/api';

  final AuthService _authService = AuthService();

  // Bikin MultipartFile dengan Content-Type yang benar (image/jpeg, image/png, dll).
  // Tanpa ini, backend akan menolak file karena dianggap bukan gambar
  // (default MultipartFile.fromBytes adalah application/octet-stream).
  Future<http.MultipartFile> _toMultipartFile(XFile image,
      {String fieldName = 'images'}) async {
    final bytes = await image.readAsBytes();
    final mimeType = lookupMimeType(image.name, headerBytes: bytes) ?? 'image/jpeg';
    return http.MultipartFile.fromBytes(
      fieldName,
      bytes,
      filename: image.name.isNotEmpty ? image.name : 'upload.jpg',
      contentType: MediaType.parse(mimeType),
    );
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ---------------- AUTH ----------------

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Registrasi gagal');
    }
    return data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Login gagal');
    }
    return data;
  }

  Future<Map<String, dynamic>> updateProfile(
    String username, {
    String? currentPassword,
    String? newPassword,
  }) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$apiUrl/auth/me'),
      headers: headers,
      body: jsonEncode({
        'username': username,
        if (currentPassword != null) 'currentPassword': currentPassword,
        if (newPassword != null) 'newPassword': newPassword,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal memperbarui profil');
    }
    return data;
  }

  Future<String> uploadAvatar(XFile image) async {
    final token = await _authService.getToken();
    final request =
        http.MultipartRequest('PUT', Uri.parse('$apiUrl/auth/me/avatar'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await _toMultipartFile(image, fieldName: 'avatar'));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal mengganti foto profil');
    }
    return data['avatarUrl'];
  }

  // ---------------- POSTS ----------------

  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse('$apiUrl/posts'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    }
    throw Exception(
        'Gagal memuat data post (status ${response.statusCode}): ${response.body}');
  }

  Future<Post> getPostById(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/posts/$id'));
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    }
    throw Exception('Post tidak ditemukan');
  }

  Future<List<Post>> getMyPosts() async {
    final headers = await _authHeaders();
    final response =
        await http.get(Uri.parse('$apiUrl/posts/mine'), headers: headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    }
    throw Exception('Gagal memuat post kamu');
  }

  // Membuat post baru. images opsional, bisa lebih dari satu gambar sekaligus.
  // Pakai XFile + bytes (bukan dart:io File) supaya jalan di Flutter Web juga.
  Future<Post> createPost(String title, String content, String category,
      List<XFile> images) async {
    final token = await _authService.getToken();
    final request =
        http.MultipartRequest('POST', Uri.parse('$apiUrl/posts'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['category'] = category;
    for (final image in images) {
      request.files.add(await _toMultipartFile(image));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    }
    final data = jsonDecode(response.body);
    throw Exception(data['message'] ?? 'Gagal membuat post');
  }

  Future<Post> updatePost(int id, String title, String content,
      String category, List<XFile> newImages) async {
    final token = await _authService.getToken();
    final request =
        http.MultipartRequest('PUT', Uri.parse('$apiUrl/posts/$id'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['category'] = category;
    for (final image in newImages) {
      request.files.add(await _toMultipartFile(image));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    }
    final data = jsonDecode(response.body);
    throw Exception(data['message'] ?? 'Gagal update post');
  }

  Future<void> deletePost(int id) async {
    final headers = await _authHeaders();
    final response =
        await http.delete(Uri.parse('$apiUrl/posts/$id'), headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus post');
    }
  }

  Future<void> deletePostImage(int postId, int imageId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
        Uri.parse('$apiUrl/posts/$postId/images/$imageId'),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus gambar');
    }
  }

  // ---------------- COMMENTS ----------------

  Future<List<Comment>> getComments(int postId) async {
    final response =
        await http.get(Uri.parse('$apiUrl/posts/$postId/comments'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
    }
    throw Exception('Gagal memuat komentar');
  }

  Future<Comment> createComment(int postId, String comment) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$apiUrl/posts/$postId/comments'),
      headers: headers,
      body: jsonEncode({'comment': comment}),
    );
    if (response.statusCode == 201) {
      return Comment.fromJson(jsonDecode(response.body));
    }
    final data = jsonDecode(response.body);
    throw Exception(data['message'] ?? 'Gagal menambah komentar');
  }

  Future<void> deleteComment(int id) async {
    final headers = await _authHeaders();
    final response =
        await http.delete(Uri.parse('$apiUrl/comments/$id'), headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus komentar');
    }
  }

  // ---------------- RECOMMENDATIONS ----------------

  Future<List<Recommendation>> getRecommendations() async {
    final response = await http.get(Uri.parse('$apiUrl/recommendations'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Recommendation.fromJson(json)).toList();
    }
    throw Exception(
        'Gagal memuat rekomendasi (status ${response.statusCode}): ${response.body}');
  }

  // ---------------- NOTIFIKASI ----------------

  Future<List<AppNotification>> getNotifications() async {
    final headers = await _authHeaders();
    final response =
        await http.get(Uri.parse('$apiUrl/notifications'), headers: headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => AppNotification.fromJson(json)).toList();
    }
    throw Exception(
        'Gagal memuat notifikasi (status ${response.statusCode}): ${response.body}');
  }

  // ---------------- FEEDBACK ----------------

  Future<void> submitFeedback(String message) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('$apiUrl/feedback'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'message': message}),
    );
    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Gagal mengirim masukan');
    }
  }
}
