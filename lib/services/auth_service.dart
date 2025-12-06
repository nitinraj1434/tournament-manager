import 'package:firebase_auth/firebase_auth.dart';
import 'package:turnament/models/user_model.dart';
import 'package:turnament/services/database_service.dart';
import 'package:turnament/services/notification_service.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _dbService = DatabaseService();

  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        String? token = await NotificationService().getToken();
        await _dbService.updateUserToken(result.user!.uid, token ?? '');

        // Subscribe to topics
        await NotificationService().subscribeToTopic('all_users');
        if (email == 'admin@turnament.app') {
          await NotificationService().subscribeToTopic('admin_notifications');
        }
      }
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signUp(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(name);
        String? token = await NotificationService().getToken();

        await _dbService.createUser(
          UserModel(
            uid: user.uid,
            name: name,
            email: email,
            photoUrl: '',
            walletBalance: 0.0,
            role: email == 'admin@turnament.app' ? 'admin' : 'user',
            fcmToken: token,
          ),
        );

        // Subscribe to topics
        await NotificationService().subscribeToTopic('all_users');
        if (email == 'admin@turnament.app') {
          await NotificationService().subscribeToTopic('admin_notifications');
        }
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        String? token = await NotificationService().getToken();

        // Check if user exists in Firestore, if not create
        final userDoc = await _dbService.getUser(user.uid).first;
        if (userDoc == null) {
          await _dbService.createUser(
            UserModel(
              uid: user.uid,
              name: user.displayName ?? 'User',
              email: user.email ?? '',
              photoUrl: user.photoURL ?? '',
              walletBalance: 0.0,
              role: 'user',
              fcmToken: token,
            ),
          );
        } else {
          await _dbService.updateUserToken(user.uid, token ?? '');
        }

        // Subscribe to topics
        await NotificationService().subscribeToTopic('all_users');
        // Check role from Firestore if needed, but for now check email
        if (user.email == 'admin@turnament.app') {
          await NotificationService().subscribeToTopic('admin_notifications');
        }
      }
      return user;
    } catch (e) {
      // print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
