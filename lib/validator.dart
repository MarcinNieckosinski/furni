import 'package:flutter/material.dart';

class Validator {

  static String? validateLogin({required String? login}) {
    if (login == null) {
      return null;
    }

    if (login.isEmpty) {
      return 'Login nie może być pusty!';
    }
    return null;
  }

  static String? validateEmail({required String? email}) {
    if (email == null) {
      return null;
    }

    RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$"
    );

    if (email.isEmpty) {
      debugPrint('Email is empty!');
      // return 'Email nie może być pusty!';
    } else if (!emailRegExp.hasMatch(email)) {
      debugPrint('Email is not valid!');
      // return 'Niepoprawny format adresu email!';
    }

    return null;
  }

  static String? validatePassword({required String? password}) {
    if (password == null) {
      return null;
    }

    if (password.isEmpty) {
      return 'Hasło nie może być puste!';
    } else if (password.length < 8) {
      return 'Hasło musi mieć co najmniej 8 znaków!';
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Hasło musi zawierać przynajmniej jedną wielką literę!';
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Hasło musi zawierać przynajmniej jedną małą literę!';
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Hasło musi zawierać przynajmniej jedną cyfrę!';
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Hasło musi zawierać przynajmniej jeden znak specjalny!';
    }

    return null;
  }

  static String? validatePasswordRepeat({
    required String? password,
    required String? repeatPassword,
  }) {
    if (repeatPassword == null) {
      return null;
    }

    if (repeatPassword.isEmpty) {
      return 'Powtórz hasło!';
    } else if (password != repeatPassword) {
      return 'Hasła nie są takie same!';
    }

    return null;
  }
  
}