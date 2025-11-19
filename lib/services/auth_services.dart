import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  String? _verificationToken;
  String? get verificationToken => _verificationToken;

  Stream<User?> get user => _auth.authStateChanges();

  AuthService() {
    loadTokenFromStorage();
  }

  Future<void> loadTokenFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _verificationToken = prefs.getString('auth_token');
    notifyListeners(); 
  }

  // --- 1. LOGIN ---
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      if (result.user != null) {
        await _updateToken(result.user!.uid);
      }
      
      return result.user;
    } catch (e) {
      print("Error Login: $e");
      return null;
    }
  }

  // --- 2. DAFTAR BARU (SIGN UP) ---
  // Fungsi ini ditambahkan untuk menangani pendaftaran akun baru
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      if (result.user != null) {
        // User baru juga perlu token agar tidak langsung di-kick
        await _updateToken(result.user!.uid);
      }

      return result.user;
    } catch (e) {
      print("Error Sign Up: $e");
      return null;
    }
  }

  // --- 3. LOGOUT ---
  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); 
    
    _verificationToken = null; 
    notifyListeners();

    await _auth.signOut();
  }
  
  // --- 4. UPDATE TOKEN ---
  Future<void> _updateToken(String uid) async {
    String newToken = DateTime.now().millisecondsSinceEpoch.toString();
    
    _verificationToken = newToken;
    notifyListeners(); 

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', newToken);

    DatabaseReference ref = _db.ref("users/$uid");
    await ref.update({
      "token": newToken,
      "last_login": DateTime.now().toString(),
      "email": _auth.currentUser?.email,
    });
  }
}