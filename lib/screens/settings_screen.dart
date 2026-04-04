import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF111111),
      ),
      body: ListView(
        children: [
          _sectionTitle('Display'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle light/dark theme'),
            value: settings.darkMode,
            onChanged: (val) => context.read<SettingsProvider>().setDarkMode(val),
            activeColor: const Color(0xFF00E5FF),
          ),
          SwitchListTile(
            title: const Text('AR Overlay'),
            subtitle: const Text('Show network cards in AR view'),
            value: settings.arOverlay,
            onChanged: (val) => context.read<SettingsProvider>().setArOverlay(val),
            activeColor: const Color(0xFF00E5FF),
          ),
          _sectionTitle('Notifications'),
          SwitchListTile(
            title: const Text('Enable Alerts'),
            subtitle: const Text('Notify when signal drops below -70 dBm'),
            value: settings.alerts,
            onChanged: (val) => context.read<SettingsProvider>().setAlerts(val),
            activeColor: const Color(0xFF00E5FF),
          ),
          _sectionTitle('Plan'),
          _planTile(context, settings, 'Free', 'Basic heatmap, 3 saved maps'),
          _planTile(context, settings, 'Pro', 'Unlimited maps, AR, device tracking, exports'),
          _sectionTitle('About'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.grey),
            title: const Text('Version'),
            trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.grey),
            title: const Text('Privacy Policy'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(title,
          style: const TextStyle(
              color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
    );
  }

  Widget _planTile(BuildContext context, SettingsProvider settings,
      String plan, String description) {
    final isSelected = settings.plan == plan;
    return GestureDetector(
      onTap: () => context.read<SettingsProvider>().setPlan(plan),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00E5FF).withOpacity(0.1)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00E5FF)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(description,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}