import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.wifi,
      'title': 'Welcome to Wavemap',
      'description':
          'Wavemap helps you visualize, analyze and navigate WiFi signals around you. Walk around any space and understand your network coverage like never before.',
    },
    {
      'icon': Icons.map,
      'title': 'WiFi Heatmap',
      'description':
          'Pick a network and tap anywhere on screen as you walk around. Wavemap paints a color map of signal strength — green is strong, orange is okay, red is weak. Each network gets its own map and your data is saved automatically.',
    },
    {
      'icon': Icons.devices,
      'title': 'Devices',
      'description':
          'See all nearby WiFi networks detected by your phone. Each card shows the network name, signal strength in dBm, and connection quality in real time.',
    },
    {
      'icon': Icons.bar_chart,
      'title': 'Diagnostics',
      'description':
          'Tap any network from the list to see its full details — frequency band, security type, signal quality and ping speed. Great for troubleshooting slow connections.',
    },
    {
      'icon': Icons.explore,
      'title': 'WiFi Compass',
      'description':
          'Pick a network and walk around. The compass arrow points toward the direction where you recorded the strongest signal. Tap "Scan Signal" as you move to update the reading.',
    },
    {
      'icon': Icons.settings,
      'title': 'Settings',
      'description':
          'Toggle dark mode, enable or disable the AR overlay, and turn weak signal alerts on or off. You can also contact the creator directly from here and revisit this tutorial anytime.',
    },
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  void _close() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Close button for when accessed from settings
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _close,
                child: const Text('Close',
                    style: TextStyle(color: Colors.grey)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF00E5FF), width: 2),
                          ),
                          child: Icon(page['icon'] as IconData,
                              color: const Color(0xFF00E5FF), size: 48),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title'] as String,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00E5FF)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page['description'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              height: 1.6),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? const Color(0xFF00E5FF)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _close,
                    child: const Text('Skip',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}