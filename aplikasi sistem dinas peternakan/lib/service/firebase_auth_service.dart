import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================
  // ⭐ LOGIN DENGAN EMAIL
  // ============================
  Future<User?> signIn({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // ============================
  // ⭐ REGISTER EMAIL
  // ============================
  Future<User?> signUp({required String email, required String password}) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // ============================
  // ⭐ LOGIN DENGAN GOOGLE
  // ============================
  Future<User?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();

      // Pastikan user memilih akun setiap login
      await googleSignIn.signOut();

      // 1. Google Sign-In
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 2. Login ke Firebase Auth
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        throw Exception("Gagal mengambil data akun Google.");
      }

      // 3. Cek Firestore
      final userRef =
          FirebaseFirestore.instance.collection("users").doc(user.uid);

      final doc = await userRef.get();

      // =========================================
      // ❌ Jika user pernah dibuat, tetapi DI-BANNED
      // =========================================
      if (doc.exists && doc.data()?["banned"] == true) {
        await _auth.signOut();
        await googleSignIn.signOut();
        throw Exception("Akun Anda telah diblokir oleh admin.");
      }

      // =========================================
      // ✔ Jika user lama dan valid
      // =========================================
      if (doc.exists) {
        return user; // lanjut login
      }

      // =========================================
      // 🟢 USER BARU → auto-register Firestore
      // =========================================
      await userRef.set({
        "uid": user.uid,
        "email": user.email,
        "name": user.displayName ?? "",
        "photoUrl": user.photoURL ?? "",
        "createdAt": DateTime.now(),
        "loginMethod": "google",
        "banned": false
      });

      return user;
    } catch (e) {
      throw Exception("Google Sign-In gagal: $e");
    }
  }

  // ============================
  // ⭐ LOGOUT
  // ============================
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // ============================
  // ⭐ CURRENT USER
  // ============================
  User? get currentUser => _auth.currentUser;
}
