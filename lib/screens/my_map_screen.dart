import 'package:flutter/material.dart';

class MyMapScreen extends StatelessWidget {
  const MyMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi mapa cafetero'),
      ),
      body: const Center(
        child: Text(
          'Todavía no guardaste cafés',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}