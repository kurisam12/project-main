import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_iwaq/services/auth_services.dart';

class SessionGuard extends StatefulWidget {
  final Widget child;
  const SessionGuard({super.key, required this.child});

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  bool _isKickingOut = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Listen: true agar jika token berubah, widget ini rebuild
    final authService = Provider.of<AuthService>(context, listen: true);

    // Jika user null, lewatkan
    if (user == null) return widget.child;

    // 1. Ambil Token Lokal dari RAM (AuthService)
    final String? localToken = authService.verificationToken;

    // Jika token belum siap (misal baru buka aplikasi), coba load dulu
    if (localToken == null) {
      authService.loadTokenFromStorage();
      return widget.child; // Tampilkan konten sementara loading
    }

    // 2. Pantau Token di Database
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref("users/${user.uid}").onValue,
      builder: (context, serverSnapshot) {
        
        if (!serverSnapshot.hasData || 
            serverSnapshot.data!.snapshot.value == null) {
          return widget.child;
        }

        try {
          // Ambil data server
          final data = serverSnapshot.data!.snapshot.value;
          String? serverToken;
          
          if (data is Map) {
            serverToken = data['token'] as String?;
          } 

          // --- LOGIKA KICK ---
          // Bandingkan: Token di Saku Saya vs Token di Server Pusat
          if (serverToken != null && 
              localToken != serverToken && 
              !_isKickingOut) {
            
            _isKickingOut = true;
            
            // Debugging Log (Cek di Terminal jika masih error)
            print("KICK DETECTED! Local: $localToken vs Server: $serverToken");

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _forceLogout(context, authService);
            });
          }
        } catch (e) {
          print("Error parsing token guard: $e");
        }

        return widget.child;
      },
    );
  }

  void _forceLogout(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Sesi Berakhir"),
        content: const Text(
          "Akun Anda telah login di perangkat lain. Anda akan dikeluarkan."
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); 
              // Reset flag
              _isKickingOut = false;
              await authService.signOut(); 
            },
            child: const Text("OK, Keluar"),
          )
        ],
      ),
    );
  }
}