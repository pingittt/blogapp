import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/category_style.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post; // null = mode tambah, tidak null = mode edit

  PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;

  // Foto yang sudah ada di server (mode edit) - bisa dihapus satu-satu.
  late List<PostImage> _existingImages;
  int? _deletingImageId; // id gambar yang lagi dihapus (buat loading spinner)

  // Pakai XFile + bytes (BUKAN dart:io File) supaya preview & upload
  // jalan baik di Flutter Web maupun Android/iOS.
  final List<XFile> _newImages = [];
  final List<Uint8List> _newImagePreviews = [];
  bool _isSubmitting = false;

  bool get isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _contentController =
        TextEditingController(text: widget.post?.content ?? '');
    _selectedCategory = widget.post?.category ?? 'Umum';
    if (!postCategories.contains(_selectedCategory)) {
      _selectedCategory = 'Umum';
    }
    _existingImages = List.of(widget.post?.images ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;

    final bytesList = await Future.wait(picked.map((x) => x.readAsBytes()));
    setState(() {
      _newImages.addAll(picked);
      _newImagePreviews.addAll(bytesList);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
      _newImagePreviews.removeAt(index);
    });
  }

  // Hapus foto yang SUDAH ada di server (langsung terhapus permanen, bukan
  // cuma dilepas dari preview). Ini yang bikin fitur edit foto beneran jalan.
  Future<void> _removeExistingImage(PostImage image) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Hapus foto ini?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Foto akan dihapus permanen dari post ini.',
            style: TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Hapus', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _deletingImageId = image.id);
    try {
      await _apiService.deletePostImage(widget.post!.id, image.id);
      setState(() {
        _existingImages.removeWhere((img) => img.id == image.id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _deletingImageId = null);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      if (isEditing) {
        await _apiService.updatePost(
          widget.post!.id,
          _titleController.text,
          _contentController.text,
          _selectedCategory,
          _newImages,
        );
      } else {
        await _apiService.createPost(
          _titleController.text,
          _contentController.text,
          _selectedCategory,
          _newImages,
        );
      }
      if (mounted) Navigator.pop(context);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Post' : 'Tulis Post Baru'),
        backgroundColor: AppColors.surface,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Foto',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              if (isEditing) ...[
                SizedBox(height: 4),
                Text('Tap ikon silang buat hapus foto lama',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
              ],
              SizedBox(height: 10),
              SizedBox(
                height: 96,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Gambar yang sudah ada di server (mode edit) - bisa dihapus
                    ..._existingImages.map((img) => Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(img.imageUrl,
                                    width: 96, height: 96, fit: BoxFit.cover),
                              ),
                              if (_deletingImageId == img.id)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => _removeExistingImage(img),
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close,
                                          color: Colors.white, size: 14),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )),
                    // Gambar baru yang baru dipilih (preview dari bytes, belum diupload)
                    ..._newImagePreviews.asMap().entries.map((entry) => Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.memory(entry.value,
                                    width: 96, height: 96, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => _removeNewImage(entry.key),
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.close,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    // Tombol tambah gambar
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.add_a_photo_rounded,
                            color: AppColors.accent, size: 26),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text('Kategori',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: postCategories.map((cat) {
                  final selected = cat == _selectedCategory;
                  final color = colorForCategory(cat);
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: color.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selected ? color : AppColors.textMuted,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.5,
                    ),
                    side: BorderSide(
                        color: selected ? color : AppColors.border),
                    backgroundColor: AppColors.surface,
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Judul',
                  labelStyle: TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border)),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Judul wajib diisi' : null,
              ),
              SizedBox(height: 14),
              TextFormField(
                controller: _contentController,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Isi Konten',
                  labelStyle: TextStyle(color: AppColors.textMuted),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border)),
                ),
                maxLines: 6,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Konten wajib diisi' : null,
              ),
              SizedBox(height: 24),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.neonPink.withOpacity(0.35),
                        blurRadius: 16,
                        offset: Offset(0, 6)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(isEditing ? 'Simpan Perubahan' : 'Publikasikan',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
