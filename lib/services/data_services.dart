import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

// Model Data untuk Sensor
class SensorData {
  final double temperature;
  final double turbidity;
  final double waterLevel;
  final bool isSystemOn;

  SensorData({
    required this.temperature,
    required this.turbidity,
    required this.waterLevel,
    required this.isSystemOn,
  });

  factory SensorData.fromMap(Map<dynamic, dynamic> map, bool isSystemOn) {
    // Mengambil data dari Firebase Realtime Database
    return SensorData(
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      turbidity: (map['turbidity'] as num?)?.toDouble() ?? 0.0,
      waterLevel: (map['water_level'] as num?)?.toDouble() ?? 0.0,
      isSystemOn: isSystemOn,
    );
  }
}

class DataService extends ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  SensorData _currentData = SensorData(
      temperature: 0.0, turbidity: 0.0, waterLevel: 0.0, isSystemOn: false);

  SensorData get currentData => _currentData;

  // Stream untuk mendapatkan data sensor dan status switch secara gabungan
  Stream<SensorData> get sensorDataStream {
    final sensorRef = _database.child('sensors');
    final switchRef = _database.child('status/main_switch');

    // Menggabungkan dua stream menjadi satu stream SensorData
    return sensorRef.onValue.zip(switchRef.onValue).map((data) {
      final sensorSnapshot = data.first;
      final switchSnapshot = data.second;

      final sensorMap = sensorSnapshot.snapshot.value as Map<dynamic, dynamic>?;
      final isSystemOn = switchSnapshot.snapshot.value as bool? ?? false;

      if (sensorMap != null) {
        _currentData = SensorData.fromMap(sensorMap, isSystemOn);
        return _currentData;
      }
      return _currentData;
    });
  }
  
  // Fungsi untuk mengontrol tombol On/Off global
  Future<void> toggleMainSwitch(bool newValue) async {
    try {
      await _database.child('status/main_switch').set(newValue);
    } catch (e) {
      print("Error toggling main switch: $e");
    }
  }

  // Stream untuk data History (misalnya, untuk grafik)
  // Asumsi data history disimpan di 'history/temperature_log', 'history/turbidity_log', 'history/level_log'
  Stream<Map<String, List<double>>> get historyDataStream {
    // Implementasi ini memerlukan logika yang lebih kompleks untuk mengambil banyak data log,
    // namun untuk tujuan demonstrasi, kita akan mengembalikan stream sederhana.
    return _database.child('history').onValue.map((event) {
      // Placeholder untuk data log historis
      return {
        'temperature': [25.0, 26.0, 25.5, 27.0, 26.5],
        'turbidity': [10.0, 11.0, 9.5, 12.0, 10.5],
        'water_level': [50.0, 51.0, 50.5, 52.0, 51.5],
      };
    });
  }

  get initialHistoryData => null;
}

extension on (DatabaseEvent, DatabaseEvent) {
   get first => null;
   
   get second => null;
}

// Extension untuk menggabungkan dua Stream (diperlukan karena tidak ada dalam Dart SDK)
extension ZipTwoStreams<T1> on Stream<T1> {
  Stream<(T1, T2)> zip<T2>(Stream<T2> other) {
    final controller = StreamController<(T1, T2)>();
    T1? latestT1;
    T2? latestT2;

    StreamSubscription<T1>? sub1;
    StreamSubscription<T2>? sub2;

    void updateController() {
      if (latestT1 != null && latestT2 != null) {
        controller.add((latestT1!, latestT2!));
      }
    }

    sub1 = listen((value) {
      latestT1 = value;
      updateController();
    }, onError: controller.addError, onDone: () {
      sub2?.cancel();
      controller.close();
    });

    sub2 = other.listen((value) {
      latestT2 = value;
      updateController();
    }, onError: controller.addError, onDone: () {
      sub1?.cancel();
      controller.close();
    });

    return controller.stream;
  }
}