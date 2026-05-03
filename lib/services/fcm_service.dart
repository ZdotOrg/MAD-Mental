import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Request notification permission and get FCM token
  Future<String?> requestPermissionAndGetToken(String userId) async {
    try {
      // Request permission (iOS specific, Android auto-grants)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
        
        // Get FCM token
        String? token = await _messaging.getToken();
        
        if (token != null) {
          print('FCM Token: $token');
          
          // Save token to Firestore
          await saveFCMToken(userId, token);
          
          // Save locally that user has set up notifications
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('notifications_setup_$userId', true);
          
          return token;
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('User denied permission');
      }
      
      return null;
    } catch (e) {
      print('Error requesting notification permission: $e');
      rethrow;
    }
  }

  /// Save FCM token to Firestore
  Future<void> saveFCMToken(String userId, String token) async {
    try {
      final remindersRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('reminders');

      await remindersRef.set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('FCM token saved successfully');
    } catch (e) {
      print('Error saving FCM token: $e');
      rethrow;
    }
  }

  /// Remove FCM token (on logout)
  Future<void> removeFCMToken(String userId, String token) async {
    try {
      final remindersRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('reminders');

      await remindersRef.update({
        'fcmTokens': FieldValue.arrayRemove([token]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('FCM token removed successfully');
    } catch (e) {
      print('Error removing FCM token: $e');
      rethrow;
    }
  }

  /// Initialize FCM listeners
  void initializeFCMListeners() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // TODO: Show local notification
      }
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');
      // TODO: Navigate to specific screen based on message data
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Check if user has set up notifications
  Future<bool> hasSetupNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_setup_$userId') ?? false;
  }

  /// Mark that user skipped notification setup
  Future<void> skipNotificationSetup(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications_setup_$userId', 'skipped');
  }
}

/// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // TODO: Handle background notification
}