import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool loading = false;
  String? selectedEmail;
  List<String> userEmails = [];

  @override
  void initState() {
    super.initState();
    _loadUserEmails();
  }

  Future<void> _loadUserEmails() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      List<String> emails = snapshot.docs
          .map((doc) => doc['email'] as String?)
          .where((email) => email != null)
          .cast<String>()
          .toList();

      setState(() {
        userEmails = emails;
        if (userEmails.isNotEmpty) selectedEmail = userEmails.first;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengambil data user")),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (selectedEmail == null) return;

    setState(() => loading = true);

    try {
      await _auth.sendPasswordResetEmail(email: selectedEmail!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Link reset password dikirim ke $selectedEmail")),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Terjadi kesalahan")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Reset Password",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A30FF),
                ),
              ),
              const SizedBox(height: 25),

              userEmails.isEmpty
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: selectedEmail,
                      decoration: InputDecoration(
                        labelText: "Pilih Email",
                        labelStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFFBFA8FF)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFFE8DEFF)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      items: userEmails
                          .map((email) => DropdownMenuItem(
                                value: email,
                                child: Text(email),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => selectedEmail = val),
                    ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A30FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: loading ? null : _resetPassword,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Reset Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "kembali",
                  style: TextStyle(
                    color: Color(0xFF7A30FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
