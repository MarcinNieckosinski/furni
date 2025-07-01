import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:furniapp/pages/home.dart';
import 'package:furniapp/validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final phoneFormatter = MaskTextInputFormatter(
    mask: '### ### ###',
    filter: {"#": RegExp(r'\d')},
  );

  final postalCodeFormatter = MaskTextInputFormatter(
    mask: '##-###',
    filter: {"#": RegExp(r'\d')},
  );

  final _auth = FirebaseAuth.instance;

  final _emailController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _postalCodeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('login', isEqualTo: _loginController.text.trim())
            .get();

    if (snapshot.docs.isNotEmpty) {
      Fluttertoast.showToast(
        msg: 'Login jest już zajęty',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'city': _cityController.text.trim(),
            'phone': _phoneController.text.trim(),
            'postalCode': _postalCodeController.text.trim(),
            'email': _emailController.text.trim(),
            'login': _loginController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      Fluttertoast.showToast(
        msg: 'Zarejestrowano pomyślnie!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'Ten e-mail jest już zajęty';
          break;
        case 'invalid-email':
          msg = 'Nieprawidłowy adres e-mail';
          break;
        default:
          msg = 'Błąd: ${e.message}';
      }

      Fluttertoast.showToast(
        msg: msg,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Zarejestruj się',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Utwórz konto w Furni',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                _buildTextField(
                  label: 'Kod pocztowy',
                  controller: _postalCodeController,
                  validator: (val) => Validator.validatePostalCode(code: val),
                  inputFormatters: [postalCodeFormatter],
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  label: 'Miejscowość',
                  controller: _cityController,
                  validator: (val) => Validator.validateCity(city: val),
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  label: 'Telefon',
                  controller: _phoneController,
                  validator: (val) => Validator.validatePhone(phone: val),
                  inputFormatters: [phoneFormatter],
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  validator: (val) => Validator.validateEmail(email: val),
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  label: 'Login',
                  controller: _loginController,
                  validator: (val) => Validator.validateLogin(login: val),
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  label: 'Hasło',
                  controller: _passwordController,
                  isObscure: true,
                  validator: (val) => Validator.validatePassword(password: val),
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  label: 'Powtórz hasło',
                  controller: _repeatPasswordController,
                  isObscure: true,
                  validator:
                      (val) => Validator.validatePasswordRepeat(
                        password: _passwordController.text,
                        repeatPassword: val,
                      ),
                ),
                const SizedBox(height: 24),

                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Zarejestruj'),
                    ),
                const SizedBox(height: 10),

                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Powrót'),
                ),
                const SizedBox(height: 10),

                TextButton(
                  onPressed:
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      ),
                  child: const Text(
                    'Na stronę główną',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isObscure = false,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
