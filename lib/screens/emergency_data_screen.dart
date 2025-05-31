import 'package:flutter/material.dart';

class EmergencyDataScreen extends StatelessWidget {
  const EmergencyDataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos de Emergencia'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contactos de emergencia
            _buildSection(
              title: 'Contactos de Emergencia',
              icon: Icons.emergency,
              children: [
                _buildContactCard(
                  name: 'María Pérez',
                  relationship: 'Esposa',
                  phone: '+52 123 456 7890',
                ),
                _buildContactCard(
                  name: 'Juan Pérez Jr.',
                  relationship: 'Hijo',
                  phone: '+52 123 456 7891',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Información médica
            _buildSection(
              title: 'Información Médica',
              icon: Icons.medical_services,
              children: [
                _buildInfoCard(
                  title: 'Tipo de Sangre',
                  content: 'O+',
                  icon: Icons.bloodtype,
                ),
                _buildInfoCard(
                  title: 'Alergias',
                  content: 'Penicilina, Polen',
                  icon: Icons.warning,
                ),
                _buildInfoCard(
                  title: 'Medicamentos',
                  content: 'Ninguno',
                  icon: Icons.medication,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Información de seguro
            _buildSection(
              title: 'Información de Seguro',
              icon: Icons.security,
              children: [
                _buildInfoCard(
                  title: 'Compañía de Seguros',
                  content: 'Seguros XYZ',
                  icon: Icons.business,
                ),
                _buildInfoCard(
                  title: 'Número de Póliza',
                  content: 'POL-123456',
                  icon: Icons.numbers,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Información funeraria
            _buildSection(
              title: 'Información Funeraria',
              icon: Icons.church,
              children: [
                _buildInfoCard(
                  title: 'Funeraria Preferida',
                  content: 'Funeraria ABC',
                  icon: Icons.location_city,
                ),
                _buildInfoCard(
                  title: 'Contacto',
                  content: '+52 123 456 7892',
                  icon: Icons.phone,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildContactCard({
    required String name,
    required String relationship,
    required String phone,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name),
        subtitle: Text(relationship),
        trailing: TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.phone, color: Colors.red),
          label: const Text('Llamar'),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title),
        subtitle: Text(content),
      ),
    );
  }
}
