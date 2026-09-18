import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Header ilustratif untuk layar Login/Register, menampilkan logo/gambar
/// Stray (assets/images/logo.png) dengan efek glow neon di belakangnya.
class AuthHero extends StatelessWidget {
  AuthHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Glow blur besar di belakang (simulasi neon glow)
          Positioned(
            top: -30,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.neonPurple.withOpacity(0.55),
                    AppColors.neonPurple.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Aksen kecil melayang
          Positioned(
            top: 6,
            left: 30,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.neonCyan,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.6), blurRadius: 12),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 34,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neonCyan, width: 2),
              ),
            ),
          ),
          // Logo Stray, melayang di atas glow
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonPink.withOpacity(0.4),
                  blurRadius: 30,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
