import 'package:flutter/material.dart';
import 'package:project_iwaq/services/auth_services.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Gunakan akun demo agar user bisa langsung mencoba
  final _emailController = TextEditingController(text: 'demo@iwaq.com');
  final _passwordController = TextEditingController(text: 'iwaq123');
  final _formKey = GlobalKey<FormState>();

  // Fungsi untuk proses Login
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final user = await authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (user == null) {
        // Tampilkan pesan error jika login gagal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Gagal. Cek email dan password.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Fungsi untuk membuat akun demo (jika belum ada)
  Future<void> _createDemoAccount() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.signUpWithEmailPassword(
      'admin@gmail.com',
      'iwaq123'
    );
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun demo berhasil dibuat. Silahkan Masuk!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun demo sudah ada. Silahkan Masuk.'),
          backgroundColor: Colors.amber,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Logo Proyek
                Image.asset(
                  'assets/1.jpg',
                  height: 100,
                  width: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.water_drop, 
                    size: 100, 
                    color: Color(0xFF1E88E5), 
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'iWAQ Monitoring System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(height: 48),

                // Input Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val!.isEmpty ? 'Masukkan Email' : null,
                ),
                const SizedBox(height: 16),

                // Input Password
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (val) => val!.isEmpty ? 'Masukkan Password' : null,
                ),
                const SizedBox(height: 32),

                // Tombol Login
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                // Tombol untuk mendaftar akun demo
                TextButton(
                  onPressed: _createDemoAccount,
                  child: const Text('Buat Akun Demo (demo@iwaq.com)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}