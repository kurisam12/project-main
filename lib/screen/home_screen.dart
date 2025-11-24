import 'package:flutter/material.dart';
import 'package:project_iwaq/services/auth_services.dart';
import 'package:project_iwaq/services/data_services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:project_iwaq/services/auth_service.dart';
//import 'package:project_iwaq/services/data_service.dart';
import 'package:project_iwaq/screen/detail_screen.dart'; // Menggunakan path 'screen' (singular)
import 'package:project_iwaq/screen/history_screen.dart'; // Menggunakan path 'screen' (singular)

// --- Widget Kustom Sensor Card ---
class SensorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const SensorCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon Sensor
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            // Nilai Sensor
            Text(
              title, 
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            // Satuan (untuk melengkapi informasi)
            Text(
              'Detail',
              style: TextStyle(
                fontSize: 14,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Halaman Utama dengan Bottom Navigasi ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // Widget untuk menampilkan konten halaman yang dipilih (Home atau History)
  final List<Widget> _pages = [
    const HomeContent(), // Index 0: Halaman Home
    const HistoryScreen(), // Index 1: Halaman Grafik/History
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; 
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mendengarkan status switch dari DataService (Simulasi)
    final isSystemOn = Provider.of<DataService>(context).currentData.isSystemOn;
    final dataService = Provider.of<DataService>(context, listen: false);

    // Fungsi untuk mengontrol Tombol On/Off Global
    void toggleMainSwitch() {
      dataService.toggleMainSwitch(!isSystemOn);
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), 
      // Tampilkan halaman yang dipilih
      body: _pages[_selectedIndex],
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex == 0 ? 0 : 2, 
        onTap: (index) {
          if (index == 1) {
            // Tombol tengah (index 1) adalah tombol On/Off (aksi)
            toggleMainSwitch();
          } else {
            // Index 0 adalah Home, Index 2 adalah Grafik (dipetakan ke index 1 di _pages)
            _onItemTapped(index == 0 ? 0 : 1);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E88E5), 
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          // 0: HOME
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          // 1: TOMBOL ON/OFF BESAR (Aksi)
          BottomNavigationBarItem(
            icon: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isSystemOn 
                      ? [const Color(0xFF42A5F5), const Color(0xFF1E88E5)]
                      : [Colors.grey[400]!, Colors.grey[600]!], 
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSystemOn ? const Color(0xFF1E88E5).withOpacity(0.5) : Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                isSystemOn ? Icons.power_settings_new : Icons.power_off,
                color: Colors.white,
                size: 30,
              ),
            ),
            label: 'On/Off',
          ),
          // 2: GRAFIK (Navigasi)
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Grafik',
          ),
        ],
      ),
    );
  }
}

// --- Konten Halaman Home ---

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan user yang login saat ini
    final user = Provider.of<User?>(context);
    // Mendengarkan data sensor simulasi
    final sensorData = Provider.of<DataService>(context).currentData;
    final authService = Provider.of<AuthService>(context, listen: false);

    // Bagian App Bar Custom
    Widget buildAppBar() {
      String displayName = user?.email?.split('@').first ?? 'User';
      displayName = displayName.substring(0, 1).toUpperCase() + displayName.substring(1);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Menu & Logout
                IconButton(
                  icon: const Icon(Icons.grid_view, size: 28),
                  onPressed: () {
                    // Tampilkan dialog konfirmasi Logout
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Apakah Anda yakin ingin keluar?"),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Batal"),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text("Logout", style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              authService.signOut();
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                // Logo Proyek
                Image.asset(
                  'assets/2.png', 
                  height: 40,
                  width: 40,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.water_drop, 
                    size: 40, 
                    color: Color(0xFF1E88E5), 
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Sambutan User
            Text(
              'Hello $displayName',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Selamat datang kembali!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    // Fungsi untuk navigasi ke halaman detail
    void navigateToDetail(String type) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DetailScreen(sensorType: type),
      ));
    }

    // StreamBuilder agar UI bereaksi terhadap perubahan data simulasi
    return StreamBuilder<SensorData>(
      stream: Provider.of<DataService>(context).sensorDataStream,
      builder: (context, snapshot) {
        final currentData = snapshot.data ?? sensorData;

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildAppBar(),
                
                // --- Status Sistem ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: currentData.isSystemOn ? const Color(0xFFDCEAF5) : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: currentData.isSystemOn ? const Color(0xFF1E88E5) : Colors.grey[400]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Sistem iWAQ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: currentData.isSystemOn ? const Color(0xFF1E88E5) : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentData.isSystemOn ? 'Aktif dan Memantau' : 'Nonaktif',
                              style: TextStyle(
                                fontSize: 16,
                                color: currentData.isSystemOn ? const Color(0xFF1E88E5) : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          currentData.isSystemOn ? Icons.check_circle_outline : Icons.cancel_outlined,
                          color: currentData.isSystemOn ? Colors.green : Colors.red,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'Data Realtime Sensor',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                
                // --- Grid Sensor Cards ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      SensorCard(
                        icon: Icons.thermostat_rounded,
                        title: 'Suhu Air',
                        color: Colors.red,
                        onTap: () => navigateToDetail('temperature'),
                      ),
                      SensorCard(
                        icon: Icons.opacity_rounded,
                        title: 'Kekeruhan',
                        color: Colors.amber[700]!,
                        onTap: () => navigateToDetail('turbidity'),
                      ),
                      SensorCard(
                        icon: Icons.water_damage_rounded,
                        title: 'Ketinggian Air',
                        color: const Color(0xFF1E88E5),
                        onTap: () => navigateToDetail('water_level'),
                      ),
                      // Kartu untuk Riwayat
                      SensorCard(
                        icon: Icons.history_toggle_off_rounded,
                        title: 'Lihat Riwayat',
                        color: Colors.green,
                        onTap: () {
                          // Pindah ke tab History (Index 2 di Bottom Nav)
                          if (context.findAncestorStateOfType<_HomeScreenState>() != null) {
                             context.findAncestorStateOfType<_HomeScreenState>()!._onItemTapped(1);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }
}