import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredentials = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredentials.user?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    }
  }

  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    } catch (e) {
      throw 'Помилка анонімного входу: $e';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    } catch (e) {
      throw 'Помилка входу через Google: $e';
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();

      await _googleSignIn.signOut();
    } catch (e) {
      throw 'Помилка при виході з акаунту: $e';
    }
  }

  String _translateAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'Невірний email або пароль.';
      case 'email-already-in-use':
        return 'Акаунт з таким email вже існує.';
      case 'invalid-email':
        return 'Невірний формат email.';
      case 'weak-password':
        return 'Пароль надто слабкий (мінімум 6 символів).';
      case 'too-many-requests':
        return 'Забагато спроб. Будь ласка, зачекайте.';
      default:
        return 'Сталася помилка. Спробуйте пізніше. (${e.code})';
    }
  }
}
