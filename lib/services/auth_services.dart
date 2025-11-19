import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variabel untuk menyimpan Session ID di memori HP ini
  String? _localSessionId;
  String? get localSessionId => _localSessionId;

  // Setter untuk memperbarui session ID lokal (dipakai saat app restart)
  void setLocalSessionId(String id) {
    _localSessionId = id;
    // Tidak perlu notifyListeners di sini untuk mencegah rebuild berulang
  }

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Fungsi Login
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      if (result.user != null) {
        await _updateSession(result.user!.uid);
      }
      
      return result.user;
    } catch (e) {
      print("Error during sign in: $e");
      return null;
    }
  }

  // Fungsi Logout
  Future<void> signOut() async {
    _localSessionId = null; // Hapus sesi lokal
    await _auth.signOut();
  }
  
  // Fungsi Sign Up
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      if (result.user != null) {
        await _updateSession(result.user!.uid);
      }

      return result.user;
    } catch (e) {
      print("Error during sign up: $e");
      return null;
    }
  }

  // -- LOGIKA KHUSUS SINGLE SESSION --
  // Fungsi ini membuat ID unik (timestamp) dan upload ke Firestore
  Future<void> _updateSession(String uid) async {
    String newSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // 1. Simpan di HP ini
    _localSessionId = newSessionId;

    // 2. Simpan di Server (Firestore)
    await _firestore.collection('users').doc(uid).set({
      'current_session_id': newSessionId,
      'last_login': FieldValue.serverTimestamp(),
      'email': _auth.currentUser?.email,
    }, SetOptions(merge: true));
  }
}