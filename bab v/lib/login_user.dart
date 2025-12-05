import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_seminar/SelectResetEmailPage.dart';
import 'signup.dart';
import 'users/home.dart';
import 'package:project_seminar/service/firebase_auth_service.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'welcome_screen.dart';

class LoginPageUser extends StatefulWidget {
  const LoginPageUser({super.key});
  @override
  State<LoginPageUser> createState() => _LoginPageUserState();
}

class _LoginPageUserState extends State<LoginPageUser> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool loading = false;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() async {
    final appLinks = AppLinks();

    // Cold start
    try {
      final initialLink = await appLinks.getInitialAppLink();
      if (initialLink != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
        );
      }
    } catch (e) {
      print("Error initial link: $e");
    }

    // Listen for app link changes
    _sub = appLinks.uriLinkStream.listen((Uri uri) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
        );
      }
    }, onError: (err) {
      print("Error listening: $err");
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================
  // CEK ROLE USER
  // ============================
  Future<bool> _isNonAdminUser(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        if (data['role'] == 'admin') {
          return false; // Admin tidak boleh masuk
        } else {
          return true; // Bukan admin
        }
      }
      return false;
    } catch (e) {
      print("Error checking role: $e");
      return false;
    }
  }

  void _showAdminBlockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Akses Ditolak"),
        content: const Text("Admin tidak diperbolehkan mengakses halaman ini."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ============================
  // LOGIN GOOGLE
  // ============================
  Future<void> _handleGoogleSignIn() async {
    setState(() => loading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        setState(() => loading = false);
        return;
      }

      bool allowed = await _isNonAdminUser(user.email ?? '');
      if (!allowed && mounted) {
        _showAdminBlockedDialog();
        setState(() => loading = false);
        return;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(username: user.email ?? "User"),
          ),
        );
      }
    } catch (e) {
      print("ERROR LOGIN GOOGLE: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => loading = false);
    }
  }

  // ============================
  // LOGIN EMAIL & PASSWORD
  // ============================
  Future<void> _login() async {
    setState(() => loading = true);
    try {
      final user = await _authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (user != null) {
        bool allowed = await _isNonAdminUser(user.email ?? '');
        if (!allowed && mounted) {
          _showAdminBlockedDialog();
          setState(() => loading = false);
          return;
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(username: user.email ?? "User"),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = 'Kombinasi email/password salah atau user tidak ditemukan';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah';
      } else {
        message = e.message ?? 'Terjadi kesalahan';
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      setState(() => loading = false);
    }
  }

  // ============================
  // UI LOGIN PAGE
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(128, 3, 106, 224),
      appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WelcomeScreen(),
                        ),
                      ); 
              },
            ),
          ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 41, 238, 241),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6A3BF8).withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A3BF8), Color(0xFF9D4BFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "P",
                    style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Selamat Datang",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF6A3BF8)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Silakan masuk ke akun Pengguna Anda",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 25),
                _buildTextField(controller: emailController, hintText: "Username atau Email", icon: Icons.email_outlined),
                const SizedBox(height: 15),
                _buildTextField(controller: passwordController, hintText: "Kata Sandi", icon: Icons.lock_outlined, obscureText: true),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordPage()));
                    },
                    child: const Text("Lupa kata sandi?",
                        style: TextStyle(color: Color(0xFF6A3BF8), fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A3BF8), Color(0xFF9D4BFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : const Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1, color: Color(0xFFE0E0E0))),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("ATAU MASUK DENGAN", style: TextStyle(color: Colors.black54, fontSize: 13))),
                    Expanded(child: Divider(thickness: 1, color: Color(0xFFE0E0E0))),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: Image.asset('assets/images/google_logo.png', height: 22, errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata_outlined, color: Colors.black54)),
                    label: const Text("Google", style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun? ", style: TextStyle(color: Colors.black54)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
                      },
                      child: const Text("Daftar di sini", style: TextStyle(color: Color(0xFF6A3BF8), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Pembantu untuk TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Color(0xFF222222)),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: Icon(icon, color: const Color(0xFF6A3BF8)),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black45),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
