import 'package:flutter/material.dart';
import '../services/app_state.dart';

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