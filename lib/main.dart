import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'screens/heatmap_screen.dart';
import 'screens/device_screen.dart';
import 'screens/diagnostics_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/ar_screen.dart';
import 'screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboarded = prefs.getBool('onboarded') ?? false;
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: WifiARApp(onboarded: onboarded),
    ),
  );
}

class WifiARApp extends StatelessWidget {
  final bool onboarded;
  const WifiARApp({super.key, required this.onboarded});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      title: 'WiFi AR',
      debugShowCheckedModeBanner: false,
      theme: settings.darkMode
          ? ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00E5FF),
                secondary: Color(0xFF00E5FF),
              ),
              scaffoldBackgroundColor: const Color(0xFF0A0A0A),
            )
          : ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF0077CC),
                secondary: Color(0xFF0077CC),
              ),
            ),
      initialRoute: onboarded ? '/home' : '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const MainShell(),
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HeatmapScreen(),
    DevicesScreen(),
    DiagnosticsScreen(),
    ARScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: const Color(0xFF111111),
        selectedItemColor: const Color(0xFF00E5FF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wifi), label: 'Heatmap'),
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'Devices'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Diagnostics'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'AR'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}