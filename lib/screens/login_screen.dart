import 'package:flutter/material.dart';
import 'package:mental_zen/services/auth_service.dart';
import 'package:mental_zen/screens/notif_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signInWithGoogle();
      
      if (user != null && mounted) {
        // Navigate to notification setup
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => NotificationSetupScreen(userId: user.uid),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in. Please try again.';
      });
      print('Sign in error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      const Text(
                        '🧘',
                        style: TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      
                      // Title
                      const Text(
                        'Mental Zen',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Tagline
                      const Text(
                        'Your private space for mindful reflection',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Welcome text
                      const Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue your wellness journey',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Google Sign-In Button (FIXED)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF333333),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // FIXED: Use Google's PNG logo instead of SVG
                                    Image.network(
                                      'https://www.gstatic.com/images/branding/product/1x/gsa_96dpd.png',
                                      height: 24,
                                      width: 24,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback to icon if image fails to load
                                        return const Icon(
                                          Icons.g_mobiledata,
                                          size: 30,
                                          color: Color(0xFF4285F4),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Privacy notice
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              '🔒 Your data is private and secure',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'We use Firebase Authentication to keep your information safe. No data is shared with third parties.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}