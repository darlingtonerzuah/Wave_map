import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'onboarding_screen.dart';
import '../providers/settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
          _sectionTitle('About'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.grey),
            title: const Text('Version'),
            trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.grey),
            title: const Text('Privacy Policy'),
           onTap: () async {
              final uri = Uri.parse('https://darlingtonerzuah.github.io/portfolio/privacy-policy.html');
              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFF00E5FF)),
            title: const Text('View Tutorial'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OnboardingScreen(),
                ),
              );
            },
          ),
          _sectionTitle('Contact Creator'),
          ListTile(
            leading: const Icon(Icons.email, color: Color(0xFF00E5FF)),
            title: const Text('Email'),
            subtitle: const Text('contact.wavemap@gmail.com'),
            onTap: () async {
              final uri = Uri.parse('mailto:contact.wavemap@gmail.com');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: Color(0xFF00E5FF)),
            title: const Text('WhatsApp'),
            subtitle: const Text('+23320540379'),
            onTap: () async {
              final uri = Uri.parse('https://wa.me/+23320540379');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
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
}