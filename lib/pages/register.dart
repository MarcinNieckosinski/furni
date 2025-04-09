import 'package:flutter/material.dart';
import 'package:furniapp/pages/home.dart';
import 'package:furniapp/validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerFromKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _focusEmail = FocusNode();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          registerText(),
          registerSubtext(),
          SizedBox(height: 20),
          emailTextfield(),
          SizedBox(height: 10),
          loginTextfield(),
          SizedBox(height: 10),
          passwordTextfield(),
          SizedBox(height: 10),
          repeatPasswordTextfield(),
          SizedBox(height: 20),
          registerButton(),
          SizedBox(height: 10),
          returnButton(),
          SizedBox(height: 10),
          toMainPageSubtext()
        ],
      ),
    );
  }

  Row registerText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Zarejestruj się',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Row registerSubtext() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Utwórz konto w Furni',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Row passwordTextfield() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Hasło',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Row repeatPasswordTextfield() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Powtórz hasło',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Row loginTextfield() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Login',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Row emailTextfield() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 250,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: (value) => Validator.validateEmail(email: value),
            controller: _emailTextController,
            focusNode: _focusEmail,
          ),
        ),
      ],
    );
  }

  OutlinedButton registerButton() {
    return OutlinedButton(onPressed: () {}, child: Text('Zarejestruj'));
  }

  OutlinedButton returnButton() {
    return OutlinedButton(onPressed: () {Navigator.pop(context);}, child: Text('Powróć'));
  }

  Row toMainPageSubtext() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: Text('Na stronę główną', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
