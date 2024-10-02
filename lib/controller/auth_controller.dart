import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ]);

  AuthController() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        refreshGoogleSignInToken();
      }
    });
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception("Google sign-in canceled.");
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      print("User signed in: ${googleUser.email}");

      return UserModel(
        email: googleUser.email,
        character: '', // Set default or fetched character here
        name: googleUser.displayName ?? '', // Fetch the display name
        points: 20,
        categoryPoints: {},
      );
    } catch (e) {
      print("Error signing in with Google: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> refreshGoogleSignInToken() async {
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        if (googleAuth.accessToken != null && googleAuth.idToken != null) {
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await _auth.signInWithCredential(credential);
          print("Google sign-in token.");
        }
      }
    } catch (error) {
      print("Failed to refresh Google token: $error");
      rethrow;
    }
  }
}