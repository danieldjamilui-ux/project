import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../SelectResetEmailPage.dart';
import '../login_user.dart';
import 'home.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const LoginPageUser();
    }

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // ===================== APPBAR =====================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HomeScreen(username: currentUser.email ?? "User"),
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
            const Text(
              "Profile",
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: userDoc.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Data pengguna tidak ditemukan"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name =
              data['nama lengkap'] ?? data['name'] ?? 'Tidak tersedia';
          final email = data['email'] ?? 'Tidak tersedia';
          final initials = _getInitials(name);

          return SingleChildScrollView(
            child: Column(
              children: [
                // ===================== GRADIENT HEADER =====================
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF7D2CFF),
                        Color(0xFF2E8BFF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(26),
                      bottomRight: Radius.circular(26),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color.fromARGB(255, 0, 60, 134),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color:  kPrimaryColor, fontWeight: FontWeight.bold,
                            fontSize: 44,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ===================== NAME & EMAIL =====================
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 10),

                // ===================== BADGES =====================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _badge("Member", Colors.purple),
                    const SizedBox(width: 6),
                    _badge("Active", Colors.green),
                  ],
                ),

                const SizedBox(height: 25),

                // ===================== INFO CARDS =====================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _infoTile(
                        icon: Icons.email_outlined,
                        title: "Email",
                        value: email,
                      ),
                      const SizedBox(height: 12),

                      _infoTile(
                        icon: Icons.phone_outlined,
                        title: "Telepon",
                        value: "+62 812 3456 7890",
                      ),
                      const SizedBox(height: 12),

                      _infoTile(
                        icon: Icons.location_on_outlined,
                        title: "Lokasi",
                        value: "Ternate, Indonesia",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ===================== CHANGE CREDENTIALS =====================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ResetPasswordPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 131, 53, 255),
                                  Color(0xFF2E8BFF),
                                ],
                              ),
                            ),
                            child: const Icon(Icons.key, color: Colors.white),
                          ),
                          const SizedBox(width: 18),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mengubah Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Perbarui kredensial akun Anda",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ===================== LOGOUT =====================
                SizedBox(
                  height: 48,
                  width: 160,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPageUser()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Log out",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===================== BADGE WIDGET =====================
  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ===================== INFO TILE =====================
  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.purple, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== INITIALS GENERATOR =====================
  String _getInitials(String name) {
    List<String> parts = name.split(" ");
    if (parts.length >= 1) {
      return "${parts[0][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
