import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user document exists, if not create it
        await _createOrUpdateUserDocument(user);
      }

      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Create or update user document in Firestore
  Future<void> _createOrUpdateUserDocument(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      // Create new user document
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      // Update last login
      await userRef.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete the Firebase Auth account
        await user.delete();
      }
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
}