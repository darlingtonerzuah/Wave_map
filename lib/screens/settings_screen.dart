import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _arOverlay = false;
  bool _notifications = true;
  bool _darkMode = true;
  String _selectedPlan = 'Free';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF111111),
      ),
      body: ListView(
        children: [
          _sectionTitle('Display'),
          _toggle('AR Overlay', _arOverlay, (val) => setState(() => _arOverlay = val)),
          _toggle('Dark Mode', _darkMode, (val) => setState(() => _darkMode = val)),
          _sectionTitle('Notifications'),
          _toggle('Enable Alerts', _notifications, (val) => setState(() => _notifications = val)),
          _sectionTitle('Plan'),
          _planTile('Free', 'Basic heatmap, 3 saved maps'),
          _planTile('Pro', 'Unlimited maps, AR, device tracking, exports'),
          _sectionTitle('Account'),
          _actionTile('Privacy Policy', Icons.privacy_tip),
          _actionTile('Sign Out', Icons.logout),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(title,
          style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
    );
  }

  Widget _toggle(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF00E5FF),
    );
  }

  Widget _planTile(String plan, String description) {
    final isSelected = _selectedPlan == plan;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E5FF).withOpacity(0.1) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(label),
      onTap: () {},
    );
  }
}