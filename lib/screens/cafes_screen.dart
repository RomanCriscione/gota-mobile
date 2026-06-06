import 'package:flutter/material.dart';

class CafesScreen extends StatelessWidget {
  const CafesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cafes = [
      {
        'nombre': 'Cuervo Café',
        'zona': 'Palermo',
        'rating': '4.8',
      },
      {
        'nombre': 'LAB',
        'zona': 'Palermo',
        'rating': '4.7',
      },
      {
        'nombre': 'Gorrión',
        'zona': 'Chacarita',
        'rating': '4.9',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafeterías'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cafes.length,
        itemBuilder: (context, index) {
          final cafe = cafes[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.coffee),
              title: Text(cafe['nombre']!),
              subtitle: Text(cafe['zona']!),
              trailing: Text('⭐ ${cafe['rating']}'),
            ),
          );
        },
      ),
    );
  }
}