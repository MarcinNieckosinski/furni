import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthHelper {
  static Future<User?> registerUsingEmailPassword({
    required String login,
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
      await user!.updateProfile(displayName: login);
      await user.reload();
      user = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('Podane hasło jest za słabe!');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('Konto z podanym adresem mail już istnieje!');
      } else {
        debugPrint(e.message);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return user;
  }

  static Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        debugPrint('Nie znaleziono użytkownika lub błędne hasło!');
      } else {
        debugPrint(e.message);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return user;
  }
}
