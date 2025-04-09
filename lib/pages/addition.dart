import 'package:flutter/material.dart';
import 'package:furniapp/components/additionfield.dart';

class AdditionPage extends StatefulWidget {
  const AdditionPage({super.key});

  @override
  State<AdditionPage> createState() => _AdditionPageState();
}

class _AdditionPageState extends State<AdditionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          additionField(),
          const SizedBox(height: 40,)
        ],
      ),
    );
  }
}