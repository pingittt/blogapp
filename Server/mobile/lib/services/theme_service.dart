import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class ThemeService {
  static String _key = 'is_dark_mode';

  /// Dipanggil sekali di awal (main.dart) sebelum runApp, supaya tema
  /// tersimpan sebelumnya langsung kepakai tanpa "kedip" ganti tema.
  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Default true (dark) kalau belum pernah diset sebelumnya.
    AppColors.isDarkNotifier.value = prefs.getBool(_key) ?? true;
  }

  Future<void> setDarkMode(bool isDark) async {
    AppColors.isDarkNotifier.value = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
  }
}
