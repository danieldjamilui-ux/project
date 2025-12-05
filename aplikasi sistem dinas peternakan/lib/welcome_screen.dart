import 'package:flutter/material.dart';
import 'package:project_seminar/login_user.dart';
import 'package:project_seminar/login_admin.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  // Hover state untuk tiap card
  bool isHoverUser = false;
  bool isHoverAdmin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(128, 3, 106, 224),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // LOGO ANIMASI FLOATING (TweenAnimationBuilder yang sudah Anda buat)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - value) * -30),
                      // PERBAIKAN: Menggunakan .clamp(0.0, 1.0) untuk memastikan
                      // nilai opacity tidak pernah melampaui 1.0 (karena Curves.easeOutBack)
                      child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 34, vertical: 24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A3BF8), Color(0xFF9D4BFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          // PERBAIKAN: 0.4 opacity -> 102 alpha (255 * 0.4)
                          color: Colors.purple.shade100.withAlpha(102),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: const Text(
                      "Peternakan",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                const Text(
                  "Selamat Datang",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A3BF8),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Silakan pilih jenis akun Anda untuk\nmelanjutkan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(135, 255, 39, 39), 
                  ),
                ),

                const SizedBox(height: 32),

                // CARD PENGGUNA
                MouseRegion(
                  onEnter: (_) => setState(() => isHoverUser = true),
                  onExit: (_) => setState(() => isHoverUser = false),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isHoverUser ? 1.04 : 1.0,
                    curve: Curves.easeOutBack,
                    child: _roleCard(
                      icon: Icons.person,
                      bgBigIcon: Icons.person,
                      title: "Pengguna",
                      description:
                          "Akses Masuk, Melihat data, dan Hubungi kami Jika diperlukan.",
                      actionLabel: "Masuk sebagai Pengguna",
                      highlightColor: const Color(0xFF6A3BF8),
                      shadow: isHoverUser,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPageUser(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // CARD ADMIN
                MouseRegion(
                  onEnter: (_) => setState(() => isHoverAdmin = true),
                  onExit: (_) => setState(() => isHoverAdmin = false),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isHoverAdmin ? 1.04 : 1.0,
                    curve: Curves.easeOutBack,
                    child: _roleCard(
                      icon: Icons.admin_panel_settings_outlined,
                      bgBigIcon: Icons.shield_outlined,
                      title: "Administrator",
                      description:
                          "Kelola manajemen administrasi di Bidang Peternakan.",
                      actionLabel: "Masuk sebagai Administrator",
                      highlightColor: const Color(0xFF6A3BF8),
                      shadow: isHoverAdmin,
                      onTap: () {
                        // Navigasi ke login admin
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPageAdmin(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // CARD REUSABLE + ANIMASI (Semua penggunaan withOpacity diganti dengan withAlpha)
  // =====================================================
  Widget _roleCard({
    required IconData icon,
    required IconData bgBigIcon,
    required String title,
    required String description,
    required String actionLabel,
    required Color highlightColor,
    required bool shadow,
    required VoidCallback onTap,
  }) {
    // Perhitungan Alpha Integer:
    // 0.25 -> 64
    // 0.15 -> 39
    // 0.8  -> 204

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 41, 238, 241),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            // PERBAIKAN: Mengganti withOpacity(0.25) dan (0.15) dengan withAlpha(64) dan (39)
            color: shadow
                ? highlightColor.withAlpha(64) // 0.25
                : Colors.black.withAlpha(39), // 0.15
            blurRadius: shadow ? 30 : 15,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          // PERBAIKAN: Mengganti withOpacity(0.8) dan (0.15) dengan withAlpha(204) dan (39)
          color: shadow
              ? highlightColor.withAlpha(204) // 0.8
              : highlightColor.withAlpha(39), // 0.15
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Opacity(
              opacity: 0.07,
              child: Icon(
                bgBigIcon,
                size: 165,
                color: highlightColor,
              ),
            ),
          ),

          // KONTEN UTAMA
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E8FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, size: 32, color: highlightColor),
              ),
              const SizedBox(height: 18),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 10),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              GestureDetector(
                onTap: onTap,
                child: Row(
                  children: [
                    Text(
                      actionLabel,
                      style: TextStyle(
                        color: highlightColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}