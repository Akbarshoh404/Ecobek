import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> _ensureUserNode({
    required User user,
    String? name,
    String? photo,
  }) async {
    final ref = _db.child('users').child(user.uid);
    final snapshot = await ref.get();

    final now = DateTime.now().millisecondsSinceEpoch;

    if (snapshot.exists) {
      final updates = <String, dynamic>{'updatedAt': now};

      if (user.email != null) updates['email'] = user.email!.trim();
      if (name != null && name.trim().isNotEmpty) updates['name'] = name.trim();
      if (photo != null && photo.trim().isNotEmpty) updates['photo'] = photo.trim();

      await ref.update(updates);
      return;
    }

    // Create new user node
    await ref.set({
      'name': name?.trim(),
      'email': user.email?.trim(),
      'photo': photo?.trim(),
      'phone': null,
      'gender': null,
      'dateMs': null, // DOB later
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<UserCredential> signUpWithEmail({
    required String username,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user != null) {
      await _ensureUserNode(
        user: user,
        name: username,
      );
    }

    return credential;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user != null) {
      await _ensureUserNode(
        user: user,
        name: user.displayName,
        photo: user.photoURL,
      );
    }

    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '615554705127-2jcpv77miah2ggdnkqegb8hbj70op6eh.apps.googleusercontent.com', // Only for Web
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'canceled',
          message: 'Google sign-in was canceled by the user',
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        await _ensureUserNode(
          user: user,
          name: user.displayName,
          photo: user.photoURL,
        );
      }

      return userCredential;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'google-signin-failed',
        message: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Sign out from Google
      await _auth.signOut();       // Sign out from Firebase
    } catch (_) {
      // Silent fail is acceptable
    }
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}