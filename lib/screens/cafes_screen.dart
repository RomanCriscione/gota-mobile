import 'package:flutter/material.dart';
import 'cafe_detail_screen.dart';
import '../models/cafe.dart';

class CafesScreen extends StatelessWidget {
  const CafesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cafes = [
      Cafe(
        nombre: 'Cuervo Café',
        zona: 'Palermo',
        rating: '4.8',
      ),
      Cafe(
        nombre: 'LAB',
        zona: 'Palermo',
        rating: '4.7',
      ),
      Cafe(
        nombre: 'Gorrión',
        zona: 'Chacarita',
        rating: '4.9',
      ),
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
              contentPadding: const EdgeInsets.all(12),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CafeDetailScreen(
                      nombre: cafe.nombre,
                      zona: cafe.zona,
                      rating: cafe.rating,
                    ),
                  ),
                );
              },

              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://picsum.photos/80',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),

              title: Text(
                cafe.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(cafe.zona),

              trailing: Text(
                '⭐ ${cafe.rating}',
              ),
            ),
          );
        },
      ),
    );
  }
}