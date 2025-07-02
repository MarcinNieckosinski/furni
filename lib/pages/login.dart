import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:furniapp/pages/home.dart';
import 'package:furniapp/pages/register.dart';
import 'package:furniapp/validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.only(top: 100),
        children: [
          Column(
            children: [
              _logoImage(),
              _welcomeText(),
              _loginSubtext(),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _loginTextfield(),
                    const SizedBox(height: 10),
                    _passwordTextfield(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _loginButton(),
              const SizedBox(height: 20),
              _registerSubtext(),
              _toMainPageSubtext(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _passwordTextfield() {
    return SizedBox(
      width: 250,
      child: TextFormField(
        controller: _passwordController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => Validator.validatePasswordOnLogin(password: value),
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Hasło',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _loginTextfield() {
    return SizedBox(
      width: 250,
      child: TextFormField(
        controller: _loginController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => Validator.validateLogin(login: value),
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _loginSubtext() {
    return const Text(
      'Zaloguj się, aby kontynuować',
      style: TextStyle(fontSize: 16, color: Colors.grey),
    );
  }

  Widget _welcomeText() {
    return const Text(
      'Witaj w Furni',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _logoImage() {
    return const Image(
      image: AssetImage('assets/images/Design.jpg'),
      height: 120,
    );
  }

  Widget _registerSubtext() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Nie masz konta?', style: TextStyle(fontSize: 16, color: Colors.grey)),
        TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
          },
          child: const Text('Zarejestruj się', style: TextStyle(fontSize: 16, color: Colors.blue)),
        ),
      ],
    );
  }

  Widget _toMainPageSubtext() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      },
      child: const Text('Na stronę główną', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _loginButton() {
    return OutlinedButton(
      onPressed: () async {
        if (!_formKey.currentState!.validate()) return;

        try {
          final credential = await _auth.signInWithEmailAndPassword(
            email: _loginController.text.trim(),
            password: _passwordController.text.trim(),
          );

          if (credential.user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Zalogowano pomyślnie!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
          }
        } catch (e) {
          debugPrint(e.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Niepoprawny email lub hasło!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      style: OutlinedButton.styleFrom(
        fixedSize: const Size(200, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Zaloguj', style: TextStyle(fontSize: 18)),
    );
  }
}
