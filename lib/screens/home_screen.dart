import 'package:flutter/material.dart';
import '../models/cafe.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/cafe_relationship.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {

    late Future<List<Cafe>> cafesFuture;
    late Future<List<CafeRelationship>> mapaFuture;

  @override
  void initState() {
    super.initState();

    cafesFuture = ApiService.obtenerCafes();
    mapaFuture = ApiService.obtenerMiMapa();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gota'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.pushNamed(
                  context,
                  '/profile',
                );
              }

              if (value == 'logout') {
                await AuthService.logout();

                if (!context.mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'profile',
                child: Text('Mi perfil'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
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

              const SizedBox(height: 8),

              FutureBuilder<List<Cafe>>(
                future: cafesFuture,
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Text(
                      'Cargando cafeterías...',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    );
                  }

                  return Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '☕ ${snapshot.data!.length} cafeterías para explorar',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

      FutureBuilder<List<CafeRelationship>>(
        future: mapaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Cargando tu recorrido...',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'No pudimos cargar tu recorrido.',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            );
          }

          final relaciones =
              snapshot.data ?? <CafeRelationship>[];

          final quieroIr = relaciones
              .where(
                (relacion) =>
                    relacion.status == 'want_to_go',
              )
              .length;

          final quieroVolver = relaciones
              .where(
                (relacion) =>
                    relacion.status == 'want_to_return',
              )
              .length;

          final yaFui = relaciones
              .where(
                (relacion) =>
                    relacion.status == 'visited',
              )
              .length;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                  '${relaciones.length} cafeterías guardadas',
                ),

                const SizedBox(height: 12),

                Text(
                  '☕ $quieroIr para visitar',
                ),

                Text(
                  '❤️ $quieroVolver para volver',
                ),

                Text(
                  '✔️ $yaFui visitadas',
                ),
              ],
            ),
          );
        },
      ),

            FutureBuilder<List<CafeRelationship>>(
              future: mapaFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final quieroIr = snapshot.data!
                    .where(
                      (relacion) =>
                          relacion.status == 'want_to_go',
                    )
                    .toList();

                if (quieroIr.isEmpty) {
                  return const SizedBox.shrink();
                }

                final cafeEnRadar = quieroIr.first;

                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/my-map',
                      );
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(12),
                              child: Image.network(
                                cafeEnRadar.cafePhoto,
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                                errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return Container(
                                    width: double.infinity,
                                    height: 160,
                                    color:
                                        const Color(0xFFF3F4F6),
                                    child: const Icon(
                                      Icons.coffee,
                                      size: 50,
                                      color: Colors.black38,
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              '☕ En tu radar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            if (cafeEnRadar.collection != null &&
                                cafeEnRadar.collection!
                                    .trim()
                                    .isNotEmpty)
                              Container(
                                margin:
                                    const EdgeInsets.only(
                                  bottom: 8,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFF3F4F6),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  cafeEnRadar.collection!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                            Text(
                              cafeEnRadar.cafeName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            Text(
                              cafeEnRadar.cafeLocation,
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
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