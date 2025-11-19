import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_services.dart';

class SessionGuard extends StatefulWidget {
  final Widget child;

  const SessionGuard({super.key, required this.child});

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = Provider.of<AuthService>(context, listen: false);

    // Jika tidak ada user, langsung tampilkan isinya (biasanya nanti diarahkan ke login oleh AuthWrapper)
    if (user == null) return widget.child;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Tunggu data tersedia
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return widget.child;
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        String? serverSessionId = data['current_session_id'];
        String? localSessionId = authService.localSessionId;

        // LOGIKA PENGECEKAN:
        
        // Kasus A: App baru dibuka (Restart), localSessionId masih kosong.
        // Kita anggap sesi server saat ini adalah milik kita.
        if (localSessionId == null && serverSessionId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
             authService.setLocalSessionId(serverSessionId);
          });
        }

        // Kasus B: Local ID sudah ada, tapi BEDA dengan Server.
        // Artinya: Ada HP lain yang login barusan. -> LOGOUT.
        if (localSessionId != null && serverSessionId != null && localSessionId != serverSessionId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLogoutAlert(context, authService);
          });
        }

        return widget.child;
      },
    );
  }

  void _showLogoutAlert(BuildContext context, AuthService authService) {
    // Mencegah alert muncul berumpuk
    if (!mounted) return; 
    
    showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa tutup paksa
      builder: (ctx) => AlertDialog(
        title: const Text("Sesi Berakhir"),
        content: const Text("Akun Anda telah login di perangkat lain. Anda akan dikeluarkan."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              authService.signOut(); // Logout
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}