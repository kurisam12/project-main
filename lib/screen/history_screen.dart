import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_iwaq/services/data_services.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Riwayat Data Sensor'),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<Map<String, List<double>>>(
        // Menggunakan stream data history simulasi
        stream: dataService.historyDataStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
if (snapshot.hasError || !snapshot.hasData) {
  // Gunakan data simulasi awal jika stream gagal
  final historyData = dataService.initialHistoryData;
  return _buildContent(historyData);
}

          
          final historyData = snapshot.data!;
          return _buildContent(historyData);
        },
      ),
    );
  }
  
  // Widget untuk membuat konten grafik
  Widget _buildContent(Map<String, List<double>> historyData) {
    final dataLength = historyData['temperature']?.length ?? 0;
    
    if (dataLength == 0) {
      return const Center(child: Text('Tidak ada data riwayat simulasi untuk ditampilkan.'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren Data Historis',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // --- Grafik Suhu Air ---
          _buildChartCard(
            'Suhu Air (°C)',
            historyData['temperature']!,
            Colors.red,
            dataLength,
          ),
          const SizedBox(height: 20),

          // --- Grafik Kekeruhan ---
          _buildChartCard(
            'Kekeruhan (PPM)',
            historyData['turbidity']!,
            Colors.amber[700]!,
            dataLength,
          ),
          const SizedBox(height: 20),

          // --- Grafik Ketinggian Air ---
          _buildChartCard(
            'Ketinggian Air (cm)',
            historyData['water_level']!,
            const Color(0xFF1E88E5),
            dataLength,
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // Widget Pembantu untuk membuat kartu grafik
  Widget _buildChartCard(String title, List<double> data, Color color, int dataLength) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    // Tentukan min dan max Y berdasarkan data
    final minY = (data.reduce((a, b) => a < b ? a : b) * 0.9).floorToDouble();
    final maxY = (data.reduce((a, b) => a > b ? a : b) * 1.1).ceilToDouble();
    
    // Konversi List<double> menjadi List<FlSpot>
    List<FlSpot> spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: (maxY - minY) / 4,
                    verticalInterval: dataLength > 1 ? (dataLength - 1) / 4 : 1,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                    getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          // Tampilkan label Index/Waktu
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8.0,
                            child: Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: (maxY - minY) / 4, 
                        getTitlesWidget: (value, meta) {
                          // Tampilkan nilai Y
                          return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  minX: 0,
                  maxX: dataLength > 0 ? dataLength.toDouble() - 1 : 1,
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}