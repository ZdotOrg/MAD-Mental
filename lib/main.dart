import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:mental_zen/services/auth_service.dart';
import 'package:mental_zen/services/fcm_service.dart';
import 'package:mental_zen/screens/login_screen.dart';
import 'package:mental_zen/screens/notif_setup_screen.dart';
import 'package:mental_zen/screens/nav_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize FCM listeners
  FCMService().initializeFCMListeners();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Zen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  final FCMService _fcmService = FCMService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is not logged in
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // User is logged in - check if they've set up notifications
        final user = snapshot.data!;
        
        return FutureBuilder<bool>(
          future: _fcmService.hasSetupNotifications(user.uid),
          builder: (context, notificationSnapshot) {
            if (notificationSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final hasSetupNotifications = notificationSnapshot.data ?? false;

            if (!hasSetupNotifications) {
              return NotificationSetupScreen(userId: user.uid);
            }

            // Changed from HomeScreen to MainNavigation
            return const MainNavigation();
          },
        );
      },
    );
  }
}