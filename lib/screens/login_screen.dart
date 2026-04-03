import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final Dio _dio = Dio();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _dio.post(
        'http://10.11.59.210:5000/api/auth/login',
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.data['token']);
      await prefs.setString('plan', response.data['plan']);
      await prefs.setString('email', response.data['email']);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data['error'] ?? 'Login failed';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi, color: Color(0xFF00E5FF), size: 64),
              const SizedBox(height: 12),
              const Text('WiFi AR',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
              const SizedBox(height: 8),
              const Text('Sign in to continue',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: _inputDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: _inputDecoration('Password'),
                obscureText: true,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Demo: demo@wifiar.com / demo123',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const Text('Pro: pro@wifiar.com / pro123',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00E5FF)),
      ),
    );
  }
}