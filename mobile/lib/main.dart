import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Muat tema tersimpan (dark/light) sebelum app pertama kali dirender,
  // supaya tidak ada "kedip" ganti tema.
  await ThemeService().loadSavedTheme();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dengarkan perubahan tema (toggle dark/light dari Pengaturan Akun) dan
    // rebuild seluruh MaterialApp supaya semua warna ke-refresh.
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Stray',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.neonPurple,
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: AppColors.neonPurple,
              secondary: AppColors.neonPink,
              surface: AppColors.surface,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
            ),
            textTheme: TextTheme(
              headlineSmall: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              titleMedium: TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              bodyLarge: TextStyle(color: AppColors.textPrimary, height: 1.5),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          // Melihat post & rekomendasi bersifat publik (tanpa login).
          // Login hanya diperlukan untuk menulis post & komentar
          // (diatur di dalam HomeScreen -> tab "Post Saya" & "Profil").
          home: HomeScreen(),
        );
      },
    );
  }
}
