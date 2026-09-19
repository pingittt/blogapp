import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final ThemeService _themeService = ThemeService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isSavingUsername = false;
  bool _isSavingPassword = false;
  bool _isUploadingAvatar = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  String? _avatarUrl;
  Uint8List? _pendingAvatarPreview;

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
  }

  Future<void> _loadCurrentUsername() async {
    setState(() => _isLoading = true);
    final username = await _authService.getUsername();
    final avatarUrl = await _authService.getAvatarUrl();
    _usernameController.text = username ?? '';
    _avatarUrl = avatarUrl;
    setState(() => _isLoading = false);
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() => _pendingAvatarPreview = bytes);

    setState(() => _isUploadingAvatar = true);
    try {
      final newUrl = await _apiService.uploadAvatar(picked);
      await _authService.updateStoredAvatarUrl(newUrl);
      setState(() {
        _avatarUrl = newUrl;
        _pendingAvatarPreview = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Foto profil berhasil diganti')));
      }
    } catch (e) {
      setState(() => _pendingAvatarPreview = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _saveUsername() async {
    if (!_usernameFormKey.currentState!.validate()) return;
    setState(() => _isSavingUsername = true);
    try {
      await _apiService.updateProfile(_usernameController.text.trim());
      await _authService.updateStoredUsername(_usernameController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username berhasil diperbarui')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _isSavingUsername = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _isSavingPassword = true);
    try {
      await _apiService.updateProfile(
        _usernameController.text.trim(),
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password berhasil diganti')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _isSavingPassword = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Pengaturan Akun'),
        backgroundColor: AppColors.surface,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.neonPink))
          : ListView(
              padding: EdgeInsets.all(20),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                          ),
                          child: ClipOval(
                            child: _pendingAvatarPreview != null
                                ? Image.memory(_pendingAvatarPreview!,
                                    fit: BoxFit.cover)
                                : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                    ? Image.network(_avatarUrl!, fit: BoxFit.cover)
                                    : Icon(Icons.person_rounded,
                                        color: Colors.white, size: 44),
                          ),
                        ),
                        if (_isUploadingAvatar)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black45,
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        else
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.neonPink,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.background, width: 2),
                              ),
                              child: Icon(Icons.edit_rounded,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 6),
                Center(
                  child: Text('Tap buat ganti foto profil',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ),
                SizedBox(height: 28),
                Text('Tampilan',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: AppColors.isDarkNotifier,
                    builder: (context, isDark, _) {
                      return SwitchListTile(
                        value: isDark,
                        activeColor: AppColors.neonPink,
                        title: Text('Mode Gelap',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            isDark ? 'Sedang aktif' : 'Mode terang aktif',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 12)),
                        secondary: Icon(
                            isDark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: AppColors.neonCyan),
                        onChanged: (value) => _themeService.setDarkMode(value),
                      );
                    },
                  ),
                ),
                SizedBox(height: 28),
                Text('Username',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Form(
                  key: _usernameFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: _decoration('Username'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Username tidak boleh kosong'
                            : null,
                      ),
                      SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _isSavingUsername ? null : _saveUsername,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.neonCyan,
                          side: BorderSide(color: AppColors.neonCyan),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isSavingUsername
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.neonCyan))
                            : Text('Simpan Username'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28),
                Text('Ganti Password',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Form(
                  key: _passwordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: _decoration('Password saat ini').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscureCurrent
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: AppColors.textMuted,
                                size: 20),
                            onPressed: () => setState(
                                () => _obscureCurrent = !_obscureCurrent),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Wajib diisi untuk ganti password'
                            : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration:
                            _decoration('Password baru (min. 6 karakter)')
                                .copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscureNew
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: AppColors.textMuted,
                                size: 20),
                            onPressed: () =>
                                setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Password baru minimal 6 karakter'
                            : null,
                      ),
                      SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton(
                          onPressed:
                              _isSavingPassword ? null : _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isSavingPassword
                              ? SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text('Ganti Password',
                                  style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
