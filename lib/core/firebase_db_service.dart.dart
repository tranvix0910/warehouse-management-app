import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EnvironmentReading {
  final double temperatureCelsius;
  final double humidityPercent;

  const EnvironmentReading({
    required this.temperatureCelsius,
    required this.humidityPercent,
  });

  factory EnvironmentReading.fromMap(Map<dynamic, dynamic> data) {
    final temp = data['temperature'];
    final hum = data['humidity'];
    double parseNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return EnvironmentReading(
      temperatureCelsius: parseNum(temp),
      humidityPercent: parseNum(hum),
    );
  }
}

class FirebaseEnvironmentService {
  final FirebaseDatabase _database;
  final String path;

  FirebaseEnvironmentService({
    FirebaseDatabase? database,
    this.path = 'sensors',
  }) : _database = database ?? FirebaseDatabase.instance;

  Stream<EnvironmentReading> streamReading() {
    final ref = _database.ref(path);
    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        return EnvironmentReading.fromMap(value);
      }
      // Support a nested map like { temperature: x, humidity: y }
      return const EnvironmentReading(
        temperatureCelsius: 0,
        humidityPercent: 0,
      );
    });
  }
}

class EnvironmentPanel extends StatelessWidget {
  final FirebaseEnvironmentService service;
  final EdgeInsetsGeometry padding;

  const EnvironmentPanel({
    super.key,
    required this.service,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EnvironmentReading>(
      stream: service.streamReading(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildContainer(
            context,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildContainer(
            context,
            child: const Center(
              child: Text(
                'Không thể tải dữ liệu môi trường',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        final reading =
            snapshot.data ??
            const EnvironmentReading(temperatureCelsius: 0, humidityPercent: 0);
        return _buildContainer(
          context,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricTile(
                context,
                icon: Icons.thermostat,
                label: 'Nhiệt độ',
                value: '${reading.temperatureCelsius.toStringAsFixed(1)}°C',
                color: const Color(0xFFFF6B6B),
              ),
              _divider(),
              _metricTile(
                context,
                icon: Icons.water_drop,
                label: 'Độ ẩm',
                value: '${reading.humidityPercent.toStringAsFixed(0)}%',
                color: const Color(0xFF3B82F6),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContainer(BuildContext context, {required Widget child}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _metricTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFF334155),
    );
  }
}
