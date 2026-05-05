import 'package:flutter/material.dart';
import 'package:mental_zen/screens/home_screen.dart';
import 'package:mental_zen/screens/mood_entry_screen.dart';
import 'package:mental_zen/screens/mindfulness_screen.dart';
import 'package:mental_zen/screens/login_screen.dart';
import 'package:mental_zen/services/auth_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  final List<Widget> _screens = [
    const HomeScreen(),
    const MoodEntryScreen(),
    const MindfulnessScreen(),
  ];

  final List<String> _titles = [
    'Mental Zen',
    'Track Your Mood',
    'Mindfulness Library',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        actions: _currentIndex == 0 ? [
          // In nav_screen.dart, around line 46-54
IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    await _authService.signOut();
    // Remove the Navigator code - let AuthWrapper handle it
  },
),
        ] : null,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF667EEA),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mood),
            label: 'Mood',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Mindfulness',
          ),
        ],
      ),
    );
  }
}