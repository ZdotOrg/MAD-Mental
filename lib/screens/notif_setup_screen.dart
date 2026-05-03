import 'package:flutter/material.dart';
import 'package:mental_zen/services/fcm_service.dart';
import 'package:mental_zen/screens/home_screen.dart';

class NotificationSetupScreen extends StatefulWidget {
  final String userId;

  const NotificationSetupScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationSetupScreen> createState() => _NotificationSetupScreenState();
}

class _NotificationSetupScreenState extends State<NotificationSetupScreen> {
  final FCMService _fcmService = FCMService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _permissionDenied = false;

  Future<void> _handleEnableNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _permissionDenied = false;
    });

    try {
      final token = await _fcmService.requestPermissionAndGetToken(widget.userId);

      if (token != null) {
        // Success - navigate to home
        if (mounted) {
          _navigateToHome();
        }
      } else {
        setState(() {
          _permissionDenied = true;
          _errorMessage = 'Notification permission was denied. You can enable it later in settings.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to enable notifications. Please try again.';
      });
      print('Notification setup error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSkip() async {
    await _fcmService.skipNotificationSetup(widget.userId);
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
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
                      // Animated bell icon
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, double value, child) {
                          return Transform.rotate(
                            angle: value * 0.3 * 3.14159,
                            child: const Text(
                              '🔔',
                              style: TextStyle(fontSize: 64),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      const Text(
                        'Stay on Track with Reminders',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Description
                      const Text(
                        'Enable notifications to receive gentle reminders for your daily journaling and mindfulness practices.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Benefits list
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildBenefitItem('Daily journaling reminders'),
                            const SizedBox(height: 12),
                            _buildBenefitItem('Mindfulness practice prompts'),
                            const SizedBox(height: 12),
                            _buildBenefitItem('Customizable schedule'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _permissionDenied 
                                ? Colors.orange.shade50 
                                : Colors.red.shade50,
                            border: Border.all(
                              color: _permissionDenied 
                                  ? Colors.orange.shade200 
                                  : Colors.red.shade200,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _permissionDenied 
                                  ? Colors.orange.shade900 
                                  : Colors.red.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Enable button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleEnableNotifications,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667EEA),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Enable Notifications',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Skip button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _handleSkip,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF666666),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Skip for Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Privacy text
                      const Text(
                        '🔒 You can change notification settings anytime in your profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
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

  Widget _buildBenefitItem(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: Color(0xFF4CAF50),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}