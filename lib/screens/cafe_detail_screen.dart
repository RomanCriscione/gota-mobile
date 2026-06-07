import 'package:flutter/material.dart';

class CafeDetailScreen extends StatelessWidget {
  final String nombre;
  final String zona;
  final String rating;

  const CafeDetailScreen({
    super.key,
    required this.nombre,
    required this.zona,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nombre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '☕ $nombre',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://picsum.photos/600/300',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              '📍 $zona',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 8),

            Text(
              '⭐ $rating',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 24),

            const Text(
              'Etiquetas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                Chip(label: Text('💻 Ideal para trabajar')),
                Chip(label: Text('📖 Para leer')),
                Chip(label: Text('☕ Café de especialidad')),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('☕ Quiero ir'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('❤️ Quiero volver'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}