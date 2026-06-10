import 'package:flutter/material.dart';
import '../models/cafe.dart';
import '../services/app_state.dart';


class CafeDetailScreen extends StatelessWidget {
  final String nombre;
  final String zona;
  final String rating;
  final String foto;

  const CafeDetailScreen({
    super.key,
    required this.nombre,
    required this.zona,
    required this.rating,
    required this.foto,
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
                foto,
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
                onPressed: () async {
                  if (!AppState.quieroIr.any((cafe) => cafe.nombre == nombre)) {
                    AppState.quieroIr.add(
                      Cafe(
                        nombre: nombre,
                        zona: zona,
                        rating: rating,
                        foto: foto,
                      ),
                    );

                    await AppState.guardarDatos();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Café agregado a Quiero ir',
                      ),
                    ),
                  );
                },
                child: const Text('☕ Quiero ir'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!AppState.quieroVolver.any((cafe) => cafe.nombre == nombre)) {
                    AppState.quieroVolver.add(
                      Cafe(
                        nombre: nombre,
                        zona: zona,
                        rating: rating,
                        foto: foto,
                      ),
                    );
                    await AppState.guardarDatos();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Café agregado a Quiero volver',
                      ),
                    ),
                  );
                },
                child: const Text('❤️ Quiero volver'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!AppState.yaFui.any((cafe) => cafe.nombre == nombre)) {
                    AppState.yaFui.add(
                      Cafe(
                        nombre: nombre,
                        zona: zona,
                        rating: rating,
                        foto: foto,
                      ),
                    );
                    await AppState.guardarDatos();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Café agregado a Ya fui',
                      ),
                    ),
                  );
                },
                child: const Text('✔️ Ya fui'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}