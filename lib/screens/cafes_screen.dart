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
        foto: 'https://picsum.photos/300?1',
      ),
      Cafe(
        nombre: 'LAB',
        zona: 'Palermo',
        rating: '4.7',
        foto: 'https://picsum.photos/300?2',
      ),
      Cafe(
        nombre: 'Gorrión',
        zona: 'Chacarita',
        rating: '4.9',
        foto: 'https://picsum.photos/300?3',
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
                      foto: cafe.foto,
                    ),
                  ),
                );
              },

              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  cafe.foto,
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