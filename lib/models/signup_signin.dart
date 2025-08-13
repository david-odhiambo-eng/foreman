import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:foreman/views/home/home_page.dart';
import 'package:foreman/views/onboarding/sign_in.dart';
import 'package:foreman/views/onboarding/splash_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId (required for web)
    // clientId: 'your-client-id.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  // EMAIL/PASSWORD AUTH METHODS

  Future<void> createUser({
    required BuildContext context,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (password != confirmPassword) {
        throw AuthException('Passwords do not match');
      }
      if (password.length < 6) {
        throw AuthException('Password must be at least 6 characters');
      }

      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _showMessage(context, 'Account created successfully');
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(context, e);
    } on AuthException catch (e) {
      _showMessage(context, e.message);
    } catch (_) {
      _showMessage(context, 'An unexpected error occurred');
    }
  }

  Future<void> signIn({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _showMessage(context, 'Signed in successfully');
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(context, e);
    } catch (_) {
      _showMessage(context, 'An unexpected error occurred');
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      if (email.trim().isEmpty) {
        _showMessage(context, 'Please enter your email.');
        return;
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      _showMessage(
        context,
        'Check your email for reset instructions. Don\'t forget to check your spam folder.',
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'No user found with this email.';
          break;
        case 'invalid-email':
          errorMsg = 'The email address is not valid.';
          break;
        default:
          errorMsg = 'An error occurred: ${e.message}';
      }
      _showMessage(context, errorMsg);
    } catch (_) {
      _showMessage(context, 'Something went wrong. Please try again.');
    }
  }

  // GOOGLE SIGN-IN METHODS (version 6.3.0)

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Trigger the sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      await _auth.signInWithCredential(credential);

      if (!context.mounted) return;
      _showMessage(context, 'Signed in with Google successfully');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    } catch (e) {
      if (!context.mounted) return;
      _showMessage(context, 'Google Sign-In failed: ${e.toString()}');
    }
  }

  // For silent sign-in (when app starts)
  Future<void> trySilentSignIn(BuildContext context) async {
    try {
      // Attempt to sign in silently
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = 
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);

        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      }
    } catch (e) {
      // Silent sign-in failed, proceed with regular sign-in when user requests it
      print('Silent sign-in failed: $e');
    }
  }

  // Sign out user
  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } catch (_) {
      _showMessage(context, 'Error signing out. Please try again.');
    }
  }

  // HELPERS
  
  void _handleAuthError(BuildContext context, FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'email-already-in-use':
        message = 'An account already exists for that email';
        break;
      case 'invalid-email':
        message = 'Please enter a valid email address';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      case 'operation-not-allowed':
        message = 'Email/password accounts are not enabled';
        break;
      case 'user-disabled':
        message = 'This account has been disabled';
        break;
      case 'user-not-found':
      case 'wrong-password':
        message = 'Invalid email or password';
        break;
      default:
        message = 'Authentication failed. Please try again';
    }
    _showMessage(context, message);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}