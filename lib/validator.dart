class Validator {
  static String? validateCity({required String? city}) {
    final regex = RegExp(r"^[a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻ\s\-']+$");

    if (city == null || city.trim().isEmpty) {
      return 'Podaj miejscowość';
    } else if (city.length < 2) {
      return 'Nazwa jest za krótka';
    } else if (!regex.hasMatch(city.trim())) {
      return 'Niepoprawne znaki w nazwie miejscowości';
    }
    return null;
  }

  static String? validatePhone({required String? phone}) {
    final clean = phone?.replaceAll(RegExp(r'\s|-'), '');
    final regex = RegExp(r'^[+]?[0-9]{9,15}$');

    if (clean == null || clean.isEmpty) {
      return 'Podaj numer telefonu';
    } else if (!regex.hasMatch(clean)) {
      return 'Nieprawidłowy numer telefonu';
    }
    return null;
  }

  static String? validatePostalCode({required String? code}) {
    final regex = RegExp(r'^\d{2}-\d{3}$');

    if (code == null || code.trim().isEmpty) {
      return 'Podaj kod pocztowy';
    } else if (!regex.hasMatch(code.trim())) {
      return 'Kod pocztowy powinien mieć format XX-XXX';
    }
    return null;
  }

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
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
    );

    if (email.isEmpty) {
      return 'Email nie może być pusty!';
    } else if (!emailRegExp.hasMatch(email)) {
      return 'Niepoprawny format adresu email!';
    }

    return null;
  }

  static String? validatePasswordOnLogin({required String? password}) {
    if (password == null) {
      return null;
    }

    if (password.isEmpty) {
      return 'Hasło nie może być puste!';
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
      return 'Co najmniej 8 znaków!';
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Przynajmniej jedna wielka litera!';
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Przynajmniej jedna mała litera!';
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Przynajmniej jedna cyfra!';
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Przynajmniej jeden znak specjalny!';
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
