import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableSound = true;
  bool _enableVibration = true;
  bool _enableAROverlay = true;
  double _sensitivity = 0.7;
  String _selectedAlertSound = 'Default';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Alert Settings'),
          _buildSettingSwitch(
            'Sound Alerts',
            'Play sound when drowsiness detected',
            _enableSound,
            (value) {
              setState(() {
                _enableSound = value;
              });
            },
          ),
          _buildSettingSwitch(
            'Vibration',
            'Vibrate when drowsiness detected',
            _enableVibration,
            (value) {
              setState(() {
                _enableVibration = value;
              });
            },
          ),
          _buildSettingSwitch(
            'AR Overlay',
            'Show augmented reality overlay',
            _enableAROverlay,
            (value) {
              setState(() {
                _enableAROverlay = value;
              });
            },
          ),
          const SizedBox(height: 10),
          
          _buildSectionTitle('Detection Settings'),
          _buildSliderSetting(
            'Sensitivity',
            'Adjust detection sensitivity',
            _sensitivity,
            (value) {
              setState(() {
                _sensitivity = value;
              });
            },
          ),
          const SizedBox(height: 10),
          
          _buildSectionTitle('Alert Sound'),
          _buildDropdownSetting(
            'Select Alert Sound',
            _selectedAlertSound,
            ['Default', 'Alarm', 'Beep', 'Voice'],
            (value) {
              setState(() {
                _selectedAlertSound = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          
          ElevatedButton(
            onPressed: () {
              // Reset to default settings
              setState(() {
                _enableSound = true;
                _enableVibration = true;
                _enableAROverlay = true;
                _sensitivity = 0.7;
                _selectedAlertSound = 'Default';
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to default'),
                  backgroundColor: Color(0xFF9C27B0),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Reset to Default'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              // Save settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings saved'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9C27B0),
              side: const BorderSide(color: Color(0xFF9C27B0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF9C27B0),
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF9C27B0),
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    String subtitle,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: value.toStringAsFixed(1),
              activeColor: const Color(0xFF9C27B0),
              onChanged: onChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Low'),
                Text('Medium'),
                Text('High'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSetting(
    String title,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
