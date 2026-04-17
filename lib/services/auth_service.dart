import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
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
