import 'package:flutter/material.dart';
import 'package:furniapp/pages/home.dart';
import 'package:furniapp/pages/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          logoImage(),
          welcomeText(),
          loginSubtext(),
          SizedBox(height: 20),
          loginTextfield(),
          SizedBox(height: 10),
          passwordTextfield(),
          SizedBox(height: 10),
          loginButton(),
          SizedBox(height: 20),
          registerSubtext(),
          toMainPageSubtext()
        ],
      ),
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

  Row loginSubtext() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Zaloguj się, aby kontynuować',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Row welcomeText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Witaj w Furni',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Row logoImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Image(image: AssetImage('assets/images/Design.jpg'))],
    );
  }

  Row registerSubtext() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Nie masz konta?',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
          },
          child: Text(
            'Zarejestruj się',
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Row toMainPageSubtext() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
          },
          child: Text(
            'Na stronę główną',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  OutlinedButton loginButton() {
    return OutlinedButton(onPressed: () {}, child: Text('Zaloguj'));
  }
}
