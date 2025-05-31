import 'package:flutter/material.dart';

class DetectionHistoryScreen extends StatelessWidget {
  const DetectionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Detecciones'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10, // Ejemplo con 10 registros
        itemBuilder: (context, index) {
          return _buildHistoryCard(
            date: '2024-03-${index + 1}',
            time: '${10 + index}:30',
            status: index % 3 == 0
                ? 'Normal'
                : index % 3 == 1
                    ? 'Advertencia'
                    : 'Peligro',
            confidence: (85 - index * 5).toString(),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard({
    required String date,
    required String time,
    required String status,
    required String confidence,
  }) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'Normal':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Advertencia':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'Peligro':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Text(
                  'Confianza: $confidence%',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
