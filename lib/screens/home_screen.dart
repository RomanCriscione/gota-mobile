import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        child: SingleChildScrollView(
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
                          return const Text(
                            'Cargando cafeterías...',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
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
                  '${relaciones.length} cafeterías guardadas',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
                            const Text(
                              '☕',
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$quieroIr',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const Text(
                              'Quiero ir',
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
                              'Volver',
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
                            const Text(
                              '✔️',
                              style: TextStyle(fontSize: 20),
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
                              'Visitados',
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
                                    color: const Color(0xFFF3F4F6),
                                    alignment: Alignment.center,
                                    child: Opacity(
                                      opacity: 0.38,
                                      child: SvgPicture.asset(
                                        'assets/icons/rating_cup.svg',
                                        width: 52,
                                        height: 52,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/rating_cup.svg',
                                  ),
                                ),

                                const SizedBox(width: 12),

                                const Expanded(
                                  child: Text(
                                    'En tu radar',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF172C6D),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'Uno de los próximos cafés que querés descubrir.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 14),

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


            const SizedBox(height: 20),

            const Text(
              '¿Qué querés hacer?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172C6D),
              ),
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
                      height: 120,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 30,
                            color: Color(0xFF172C6D),
                          ),
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
                      height: 120,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.near_me_rounded,
                            size: 30,
                            color: Color(0xFF172C6D),
                          ),
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
                      height: 120,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            size: 30,
                            color: Color(0xFF172C6D),
                          ),
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
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/map',
                      );
                    },
                    child: Container(
                      height: 120,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.map_rounded,
                            size: 30,
                            color: Color(0xFF172C6D),
                          ),
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
          ],
        ),
      ),
    ),
  );
}
}