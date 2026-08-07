import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/cafe.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/cafe_relationship.dart';
import '../widgets/network_image_card.dart';
import '../widgets/section_title.dart';
import '../widgets/loading_skeleton.dart';
import 'cafes_map_screen.dart';
import 'cafe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {

    late Future<List<Cafe>> cafesFuture;
    late Future<List<CafeRelationship>> mapaFuture;
    late Future<Cafe?> radarFuture;

  @override
  void initState() {
    super.initState();

    cafesFuture = ApiService.obtenerCafes();
    mapaFuture = ApiService.obtenerMiMapa();
    radarFuture = calcularCafeEnRadar();
  }

  Future<Cafe?> calcularCafeEnRadar() async {
    final cafes = await cafesFuture;
    final relaciones = await mapaFuture;

    if (cafes.isEmpty) {
      return null;
    }

    final cafesPorId = <int, Cafe>{};

    for (final cafe in cafes) {
      if (cafe.id != null) {
        cafesPorId[cafe.id!] = cafe;
      }
    }

    final cafesReferencia = <Cafe>[];

    final idsYaVisitados = <int>{};

    for (final relacion in relaciones) {
      final cafe = cafesPorId[relacion.cafeId];

      if (cafe == null) {
        continue;
      }

      if (relacion.status == 'want_to_return') {
        cafesReferencia.add(cafe);
        cafesReferencia.add(cafe);
        cafesReferencia.add(cafe);

        idsYaVisitados.add(relacion.cafeId);
      } else if (relacion.status == 'visited') {
        cafesReferencia.add(cafe);

        idsYaVisitados.add(relacion.cafeId);
      } else if (relacion.status == 'want_to_go') {
        cafesReferencia.add(cafe);
      }
    }

    final candidatos = cafes.where((cafe) {
      if (cafe.id == null) {
        return false;
      }

      return !idsYaVisitados.contains(cafe.id);
    }).toList();

    if (candidatos.isEmpty) {
      return null;
    }

    if (cafesReferencia.isEmpty) {
      final indice =
          DateTime.now().day % candidatos.length;

      return candidatos[indice];
    }

    int puntajeCafe(Cafe candidato) {
      int puntaje = 0;

      for (final referencia in cafesReferencia) {
        if (candidato.id == referencia.id) {
          continue;
        }

        if (candidato.zona == referencia.zona) {
          puntaje += 3;
        }

        if (candidato.cafeEspecialidad &&
            referencia.cafeEspecialidad) {
          puntaje += 3;
        }

        if (candidato.brunch &&
            referencia.brunch) {
          puntaje += 2;
        }

        if (candidato.desayuno &&
            referencia.desayuno) {
          puntaje += 2;
        }

        if (candidato.pasteleriaArtesanal &&
            referencia.pasteleriaArtesanal) {
          puntaje += 2;
        }

        if (candidato.laptopFriendly &&
            referencia.laptopFriendly) {
          puntaje += 4;
        }

        if (candidato.espacioTranquilo &&
            referencia.espacioTranquilo) {
          puntaje += 4;
        }

        if (candidato.petFriendly &&
            referencia.petFriendly) {
          puntaje += 2;
        }

        if (candidato.tieneWifi &&
            referencia.tieneWifi) {
          puntaje += 2;
        }

        if (candidato.librosOJuegos &&
            referencia.librosOJuegos) {
          puntaje += 2;
        }

        final tagsReferencia =
            referencia.tags.map((tag) => tag.toString()).toSet();

        final tagsCandidato =
            candidato.tags.map((tag) => tag.toString()).toSet();

        final coincidencias =
            tagsCandidato.intersection(tagsReferencia).length;

        puntaje += coincidencias * 4;
      }

      return puntaje;
    }

    candidatos.sort(
      (a, b) => puntajeCafe(b).compareTo(
        puntajeCafe(a),
      ),
    );

    final mejores =
        candidatos.take(5).toList();

    final indice =
        DateTime.now().day % mejores.length;

    return mejores[indice];
  }

    Future<void> recargarHome() async {
      final nuevoCafesFuture =
          ApiService.obtenerCafes(
        forzarActualizacion: true,
      );

      final nuevoMapaFuture =
          ApiService.obtenerMiMapa(
        forzarActualizacion: true,
      );

      setState(() {
        cafesFuture = nuevoCafesFuture;
        mapaFuture = nuevoMapaFuture;
        radarFuture = calcularCafeEnRadar();
      });

      await Future.wait([
        nuevoCafesFuture,
        nuevoMapaFuture,
      ]);
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inicio',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF172C6D),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<String>(
              tooltip: 'Cuenta',
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                  ),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF172C6D),
                ),
              ),
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
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 21,
                      ),
                      SizedBox(width: 10),
                      Text('Mi perfil'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 21,
                      ),
                      SizedBox(width: 10),
                      Text('Cerrar sesión'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        
              body: SafeArea(
                child: RefreshIndicator(
                  onRefresh: recargarHome,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      24,
                      24,
                      32,
                    ),
                    
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/rating_cup.svg',
                          ),
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Text(
                            'Gota',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172C6D),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Descubrí tu próximo café',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172C6D),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Encontrá lugares según el momento que querés vivir.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 16),

                    FutureBuilder<List<Cafe>>(
                      future: cafesFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return LoadingSkeleton(
                            width: 190,
                            height: 38,
                            borderRadius: BorderRadius.circular(14),
                          );
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/rating_cup.svg',
                                width: 19,
                                height: 19,
                              ),

                              const SizedBox(width: 7),

                              Text(
                                '${snapshot.data!.length} cafeterías para explorar',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF172C6D),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 18),

            const SectionTitle(
            title: '¿Cuál es el plan de hoy?',
          ),

          const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/cafes',
                      );
                    },
                    child: Container(
                      height: 110,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 30,
                            color: Color(0xFF172C6D),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Explorar\ncafeterías',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: Color(0xFF172C6D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/nearby',
                      );
                    },
                    child: Container(
                      height: 110,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.near_me_rounded,
                            size: 30,
                            color: Color(0xFF172C6D),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Cafés\ncerca mío',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: Color(0xFF172C6D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/my-map',
                      );
                    },
                    child: Container(
                      height: 110,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            size: 30,
                            color: Color(0xFF172C6D),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Mi mapa\ncafetero',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: Color(0xFF172C6D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () async {
                      final cafes = await cafesFuture;

                      if (!context.mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CafesMapScreen(
                            cafes: cafes,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 110,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_rounded,
                            size: 30,
                            color: Color(0xFF172C6D),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Ver mapa\nde cafés',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: Color(0xFF172C6D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingSkeleton(
                      width: 180,
                      height: 22,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 18),
                    LoadingSkeleton(
                      width: double.infinity,
                      height: 70,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ],
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
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/rating_cup.svg',
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Text(
                        'Tu recorrido cafetero',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF172C6D),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  relaciones.isEmpty
                      ? 'Tu recorrido empieza con un café.'
                      : '${relaciones.length} cafeterías forman parte de tu recorrido.',
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.favorite_border_rounded,
                              size: 22,
                              color: Color(0xFF172C6D),
                            ),
                            const SizedBox(height: 6),

                            Text(
                              '$quieroIr',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: Color(0xFF111827),
                              ),
                            ),

                            const SizedBox(height: 2),

                            const Text(
                              'Quiero ir',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '❤️',
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$quieroVolver',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const Text(
                              'Quiero volver',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 22,
                              color: Color(0xFF172C6D),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$yaFui',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const Text(
                              'Ya fui',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),

      const SizedBox(height: 22),

      const SectionTitle(
        title: '✨ En tu radar',
      ),

      const SizedBox(height: 6),

      const Text(
        'Una cafetería que creemos que puede gustarte.',
        style: TextStyle(
          fontSize: 15,
          color: Colors.black54,
          height: 1.4,
        ),
      ),

      const SizedBox(height: 16),

            FutureBuilder<Cafe?>(
              future: radarFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return LoadingSkeleton(
                    width: double.infinity,
                    height: 230,
                    borderRadius: BorderRadius.circular(18),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final cafeEnRadar = snapshot.data!;

                return Padding(
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CafeDetailScreen(
                            cafeId: cafeEnRadar.id!,
                            heroImageUrl: cafeEnRadar.foto,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            NetworkImageCard(
                              imageUrl: cafeEnRadar.foto,
                              width: double.infinity,
                              height: 160,
                              borderRadius: 12,
                              heroTag: 'radar-${cafeEnRadar.id!}',
                            ),

                            
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
                              cafeEnRadar.nombre,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            Text(
                              cafeEnRadar.zona,
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


            
          ],
        ),
      ),
    ),
  ),
);
  }
}