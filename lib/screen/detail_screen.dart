import 'package:flutter/material.dart';
import 'package:project_iwaq/services/data_services.dart';
import 'package:provider/provider.dart';
//import 'package:project_iwaq/services/data_service.dart';
import 'package:fl_chart/fl_chart.dart';

class DetailScreen extends StatelessWidget {
  final String sensorType;
  const DetailScreen({super.key, required this.sensorType});

  // Fungsi untuk mendapatkan detail berdasarkan tipe sensor (Simulasi)
  Map<String, dynamic> _getSensorDetails(SensorData data) {
    switch (sensorType) {
      case 'temperature':
        return {
          'title': 'Suhu Air',
          'value': data.temperature,
          'unit': '°C',
          'icon': Icons.thermostat_rounded,
          'color': Colors.red,
        };
      case 'turbidity':
        return {
          'title': 'Kekeruhan',
          'value': data.turbidity,
          'unit': 'NTU',
          'icon': Icons.opacity_rounded,
          'color': Colors.amber[700]!,
        };
      case 'water_level':
        return {
          'title': 'Ketinggian Air',
          'value': data.waterLevel,
          'unit': 'cm',
          'icon': Icons.water_damage_rounded,
          'color': const Color(0xFF1E88E5),
        };
      default:
        return {
          'title': 'Data Tidak Ditemukan',
          'value': 0.0,
          'unit': '',
          'icon': Icons.error,
          'color': Colors.grey,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text('${_getSensorDetails(dataService.currentData)['title']} Detail'),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<SensorData>(
        stream: dataService.sensorDataStream,
        builder: (context, snapshot) {
          // Gunakan data realtime dari stream
          final sensorData = snapshot.data ?? dataService.currentData;
          final details = _getSensorDetails(sensorData);
          final title = details['title'];
          final value = details['value'];
          final unit = details['unit'];
          final icon = details['icon'];
          final color = details['color'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Kartu Nilai Realtime ---
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.1), Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(icon, size: 60, color: color),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              value.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                color: color,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                unit,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: color.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text('Data Terakhir Diperbarui: Realtime (Simulasi)', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- Grafik Mini (Simulasi) ---
                const Text(
                  'Tren Realtime (Simulasi)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                  ),
                  child: LineChartSample1(color: color), 
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget Grafik Dummy (Menggunakan fl_chart)
class LineChartSample1 extends StatelessWidget {
  final Color color;
  const LineChartSample1({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3.5),
              FlSpot(2.6, 2.0),
              FlSpot(4.9, 4.5),
              FlSpot(6.8, 3.1),
              FlSpot(8, 4.0),
              FlSpot(9.5, 3.0),
              FlSpot(11, 4.0),
            ],
            isCurved: true,
            color: color,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}