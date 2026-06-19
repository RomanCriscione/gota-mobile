import 'package:flutter/material.dart';
import '../services/app_state.dart';
import 'cafe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalGuardados =
        AppState.quieroIr.length +
        AppState.quieroVolver.length +
        AppState.yaFui.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gota'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '☕ Gota',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Descubrí tu próximo café',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '☕ Tu recorrido',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '$totalGuardados cafeterías guardadas',
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '☕ ${AppState.quieroIr.length} para visitar',
                  ),

                  Text(
                    '❤️ ${AppState.quieroVolver.length} para volver',
                  ),

                  Text(
                    '✔️ ${AppState.yaFui.length} visitadas',
                  ),
                ],
              ),
            ),

            if (AppState.quieroIr.isNotEmpty) ...[
              const SizedBox(height: 16),

              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final cafe = AppState.quieroIr.first;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CafeDetailScreen(
                        nombre: cafe.nombre,
                        zona: cafe.zona,
                        rating: cafe.rating,
                        foto: cafe.foto,
                        foto2: cafe.foto2,
                        foto3: cafe.foto3,
                        direccion: cafe.direccion,
                        latitude: cafe.latitude,
                        longitude: cafe.longitude,
                        tieneWifi: cafe.tieneWifi,
                        petFriendly: cafe.petFriendly,
                        veganFriendly: cafe.veganFriendly,
                        enchufes: cafe.enchufes,
                        cafeEspecialidad: cafe.cafeEspecialidad,
                        brunch: cafe.brunch,
                        laptopFriendly: cafe.laptopFriendly,
                        espacioTranquilo: cafe.espacioTranquilo,
                        tags: cafe.tags,
                      ),
                    ),
                  );
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '☕ Tu próxima parada',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        AppState.quieroIr.first.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        AppState.quieroIr.first.zona,
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ],

            const SizedBox(height: 32),

            const Text(
              'Mi recorrido',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${AppState.quieroIr.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('☕ Quiero ir'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${AppState.quieroVolver.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('❤️ Volver'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${AppState.yaFui.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('✔️ Ya fui'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              color: const Color(0xFFF9FAFB),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (totalGuardados == 0) ...[
                      const Text(
                        '☕ Empezá tu mapa cafetero',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Todavía no guardaste cafeterías. Explorá lugares y empezá a construir tu recorrido.',
                      ),
                    ],

                    if (totalGuardados > 0 &&
                        AppState.quieroIr.isNotEmpty) ...[
                      const Text(
                        '☕ Próximas visitas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Tenés ${AppState.quieroIr.length} cafeterías pendientes para visitar.',
                      ),
                    ],

                    if (totalGuardados > 0 &&
                        AppState.quieroIr.isEmpty &&
                        AppState.yaFui.isNotEmpty) ...[
                      const Text(
                        '✔️ Tu recorrido sigue creciendo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Ya visitaste ${AppState.yaFui.length} cafeterías.',
                      ),
                    ],

                    const SizedBox(height: 12),

                    Text(
                      'Total guardadas: $totalGuardados',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Explorar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/cafes',
                  );
                },
                label: const Text(
                  'Explorar cafeterías',
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.location_on),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/nearby',
                  );
                },
                label: const Text(
                  'Cerca mío',
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.favorite),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/my-map',
                  );
                },
                label: const Text(
                  'Mi mapa cafetero',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}