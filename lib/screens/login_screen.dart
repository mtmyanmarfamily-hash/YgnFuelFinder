import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _errorMessage = null; });
    try {
      final result = await AuthService.signInWithGoogle();
      if (mounted) {
        setState(() => _loading = false);
        if (result == null) {
          setState(() => _errorMessage = 'Login မအောင်မြင်ပါ — Google account ရွေးချယ်မှု မပြီးပါ');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.green[900]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(child: Text('⛽', style: TextStyle(fontSize: 52))),
                  ),
                  const SizedBox(height: 24),
                  const Text('ရန်ကုန် ဆီဌာနနေရာ',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('ဆီဆိုင်တွေ real-time ကြည့်ပြီး\nသတင်းပို့နိုင်သော community app',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green[100], fontSize: 14, height: 1.6)),
                  const SizedBox(height: 48),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 12))),
                        ],
                      ),
                    ),

                  // Google Sign-In button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: _loading
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                  width: 22, height: 22,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.login, size: 22),
                                ),
                                const SizedBox(width: 12),
                                const Text('Google နဲ့ Login လုပ်ပါ',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Login လုပ်ခြင်းဖြင့် သတင်းပို့မှုများကို\nပိုယုံကြည်ရပြီး spam ကာကွယ်နိုင်ပါသည်',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green[200], fontSize: 12, height: 1.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
