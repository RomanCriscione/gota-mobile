import 'package:flutter/material.dart';
import '../models/cafe.dart';
import '../services/app_state.dart';


class CafeDetailScreen extends StatelessWidget {
  final String nombre;
  final String zona;
  final String rating;
  final String foto;
  final String foto2;
  final String foto3;

  final String direccion;
  final bool tieneWifi;
  final bool petFriendly;
  final bool veganFriendly;

  final List<String> tags;

  const CafeDetailScreen({
    super.key,
    required this.nombre,
    required this.zona,
    required this.rating,
    required this.foto,
    required this.foto2,
    required this.foto3,

    required this.direccion,
    required this.tieneWifi,
    required this.petFriendly,
    required this.veganFriendly,

    required this.tags,
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
              nombre,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 220,
              child: PageView(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      foto,
                      fit: BoxFit.cover,
                    ),
                  ),

                  if (foto2.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        foto2,
                        fit: BoxFit.cover,
                      ),
                    ),

                  if (foto3.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        foto3,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                '📸 ${[
                  foto,
                  if (foto2.isNotEmpty) foto2,
                  if (foto3.isNotEmpty) foto3,
                ].length} fotos',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 20),

            Text(
              '📍 $zona',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 8),

            rating == '0.0'
                ? const Text(
                    'Aún sin reseñas',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Text(
                    '⭐ $rating',
                    style: const TextStyle(fontSize: 18),
                  ),

            const SizedBox(height: 16),

            Text(
              direccion,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 16),

            if (tieneWifi || petFriendly || veganFriendly)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (tieneWifi)
                    const Chip(
                      label: Text('📶 Wifi'),
                    ),

                  if (petFriendly)
                    const Chip(
                      label: Text('🐶 Pet Friendly'),
                    ),

                  if (veganFriendly)
                    const Chip(
                      label: Text('🌱 Vegan Friendly'),
                    ),
                ],
              ),
                if (tieneWifi)
                  const Chip(
                    label: Text('📶 Wifi'),
                  ),

                if (petFriendly)
                  const Chip(
                    label: Text('🐶 Pet Friendly'),
                  ),

                if (veganFriendly)
                  const Chip(
                    label: Text('🌱 Vegan Friendly'),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            if (tags.isNotEmpty) ...[
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
                children: tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
            ],

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
                        foto2: foto2,
                        foto3: foto3,
                        direccion: direccion,
                        tieneWifi: tieneWifi,
                        petFriendly: petFriendly,
                        veganFriendly: veganFriendly,
                        tags: tags,
                      )
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
                        foto2: foto2,
                        foto3: foto3,
                        direccion: direccion,
                        tieneWifi: tieneWifi,
                        petFriendly: petFriendly,
                        veganFriendly: veganFriendly,
                        tags: tags,
                      )
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
                        foto2: foto2,
                        foto3: foto3,
                        direccion: direccion,
                        tieneWifi: tieneWifi,
                        petFriendly: petFriendly,
                        veganFriendly: veganFriendly,
                        tags: tags,
                      )
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