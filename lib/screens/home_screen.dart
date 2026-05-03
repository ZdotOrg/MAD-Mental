import 'package:flutter/material.dart';
import 'package:mental_zen/services/auth_service.dart';
import 'package:mental_zen/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🧘',
                    style: TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome to Mental Zen',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (user?.email != null) ...[
                    Text(
                      'Signed in as ${user!.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: const Text(
                      'Build your dashboard, journal, and mood tracking components here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667EEA),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}