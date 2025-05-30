import 'package:flutter/material.dart';

class Dictionarypage extends StatefulWidget {
  const Dictionarypage({super.key});

  @override
  State<Dictionarypage> createState() => _DicitionarypageState();
}

class _DicitionarypageState extends State<Dictionarypage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Dictionary Page Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}