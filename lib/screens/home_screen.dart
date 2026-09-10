import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cafe.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/cafe_relationship.dart';
import '../widgets/network_image_card.dart';
import '../widgets/section_title.dart';
import '../widgets/loading_skeleton.dart';
import 'cafes_map_screen.dart';
import 'cafe_detail_screen.dart';
import 'my_gotas_screen.dart';

class RadarRecommendation {
  final Cafe cafe;
  final String motivo;

  const RadarRecommendation({
    required this.cafe,
    required this.motivo,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {

    late Future<List<Cafe>> cafesFuture;
    late Future<List<CafeRelationship>> mapaFuture;
    late Future<Map<String, dynamic>> gotasFuture;
    bool estaLogueado = false;
    late Future<RadarRecommendation?> radarFuture;
  
  
  @override
  void initState() {
    super.initState();

    cafesFuture = ApiService.obtenerCafes();

    mapaFuture = Future.value(
      <CafeRelationship>[],
    );

    gotasFuture = Future.value(
      <String, dynamic>{
        'balance': 0,
        'recent_transactions': [],
      },
    );

    radarFuture = calcularCafeEnRadar();

    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final logueado = await AuthService.estaLogueado();

    if (!mounted) return;

    if (logueado) {
      setState(() {
        estaLogueado = true;
        mapaFuture = ApiService.obtenerMiMapa();
        gotasFuture = ApiService.obtenerMisGotas();
        radarFuture = calcularCafeEnRadar();
      });
    }
  }

  Future<RadarRecommendation?> calcularCafeEnRadar() async {
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

    final idsConRelacion = <int>{};
    final pesosPorCafe = <int, double>{};

    for (final relacion in relaciones) {
      final cafe = cafesPorId[relacion.cafeId];

      if (cafe == null) {
        continue;
      }

      idsConRelacion.add(relacion.cafeId);

      if (relacion.status == 'want_to_return') {
        pesosPorCafe[relacion.cafeId] = 3;
      } else if (relacion.status == 'visited') {
        pesosPorCafe[relacion.cafeId] = 2;
      } else if (relacion.status == 'want_to_go') {
        pesosPorCafe[relacion.cafeId] = 1;
      }
    }

    final candidatos = cafes.where((cafe) {
      if (cafe.id == null) {
        return false;
      }

      return !idsConRelacion.contains(cafe.id);
    }).toList();

    if (candidatos.isEmpty) {
      return null;
    }

    if (pesosPorCafe.isEmpty) {
      final indice =
          DateTime.now().day % candidatos.length;

      return RadarRecommendation(
        cafe: candidatos[indice],
        motivo:
            'Una opción distinta para seguir descubriendo.',
      );
    }

    double pesoTotal = 0;

    for (final peso in pesosPorCafe.values) {
      pesoTotal += peso;
    }

    double afinidadCaracteristica(
      bool Function(Cafe cafe) cumple,
    ) {
      double puntos = 0;

      pesosPorCafe.forEach((cafeId, peso) {
        final cafe = cafesPorId[cafeId];

        if (cafe != null && cumple(cafe)) {
          puntos += peso;
        }
      });

      if (pesoTotal == 0) {
        return 0;
      }

      return puntos / pesoTotal;
    }

    final afinidadEspecialidad =
        afinidadCaracteristica(
      (cafe) => cafe.cafeEspecialidad,
    );

    final afinidadBrunch =
        afinidadCaracteristica(
      (cafe) => cafe.brunch,
    );

    final afinidadDesayuno =
        afinidadCaracteristica(
      (cafe) => cafe.desayuno,
    );

    final afinidadPasteleria =
        afinidadCaracteristica(
      (cafe) => cafe.pasteleriaArtesanal,
    );

    final afinidadTrabajar =
        afinidadCaracteristica(
      (cafe) => cafe.laptopFriendly,
    );

    final afinidadTranquilidad =
        afinidadCaracteristica(
      (cafe) => cafe.espacioTranquilo,
    );

    final afinidadPet =
        afinidadCaracteristica(
      (cafe) => cafe.petFriendly,
    );

    final afinidadWifi =
        afinidadCaracteristica(
      (cafe) => cafe.tieneWifi,
    );

    final afinidadLibros =
        afinidadCaracteristica(
      (cafe) => cafe.librosOJuegos,
    );

    final pesoTags = <String, double>{};
    final pesoZonas = <String, double>{};

    pesosPorCafe.forEach((cafeId, peso) {
      final cafe = cafesPorId[cafeId];

      if (cafe == null) {
        return;
      }

      if (cafe.zona.trim().isNotEmpty) {
        pesoZonas[cafe.zona] =
            (pesoZonas[cafe.zona] ?? 0) + peso;
      }

      for (final tag in cafe.tags) {
        final tagTexto =
            tag.toString().trim().toLowerCase();

        if (tagTexto.isEmpty) {
          continue;
        }

        pesoTags[tagTexto] =
            (pesoTags[tagTexto] ?? 0) + peso;
      }
    });

    double puntajeTags(Cafe candidato) {
      double puntos = 0;

      for (final tag in candidato.tags) {
        final tagTexto =
            tag.toString().trim().toLowerCase();

        final peso = pesoTags[tagTexto];

        if (peso == null) {
          continue;
        }

        final afinidad = peso / pesoTotal;

        puntos += afinidad * 6;
      }

      return puntos.clamp(0, 18).toDouble();
    }

    double puntajeZona(Cafe candidato) {
      final peso =
          pesoZonas[candidato.zona] ?? 0;

      if (pesoTotal == 0) {
        return 0;
      }

      return (peso / pesoTotal) * 4;
    }

    Map<String, double> desgloseCafe(
      Cafe candidato,
    ) {
      return {
        'tags': puntajeTags(candidato),

        'tranquilidad':
            candidato.espacioTranquilo
                ? afinidadTranquilidad * 10
                : 0,

        'trabajar':
            candidato.laptopFriendly
                ? afinidadTrabajar * 10
                : 0,

        'especialidad':
            candidato.cafeEspecialidad
                ? afinidadEspecialidad * 8
                : 0,

        'brunch':
            candidato.brunch
                ? afinidadBrunch * 6
                : 0,

        'desayuno':
            candidato.desayuno
                ? afinidadDesayuno * 5
                : 0,

        'pasteleria':
            candidato.pasteleriaArtesanal
                ? afinidadPasteleria * 5
                : 0,

        'pet':
            candidato.petFriendly
                ? afinidadPet * 4
                : 0,

        'wifi':
            candidato.tieneWifi
                ? afinidadWifi * 5
                : 0,

        'libros':
            candidato.librosOJuegos
                ? afinidadLibros * 4
                : 0,

        'zona': puntajeZona(candidato),
      };
    }

    double puntajeCafe(Cafe candidato) {
      return desgloseCafe(
        candidato,
      ).values.fold(
        0,
        (total, valor) => total + valor,
      );
    }

    String motivoCafe(Cafe candidato) {
      final desglose = desgloseCafe(candidato);

      String? claveGanadora;
      double mejorPuntaje = 0;

      desglose.forEach((clave, puntaje) {
        if (puntaje > mejorPuntaje) {
          mejorPuntaje = puntaje;
          claveGanadora = clave;
        }
      });

      switch (claveGanadora) {
        case 'tags':
          return 'Se parece a lugares que ya forman parte de tu recorrido.';

        case 'tranquilidad':
          return 'Porque solés elegir lugares tranquilos.';

        case 'trabajar':
          return 'Porque suele encajar con lugares para trabajar o estudiar.';

        case 'especialidad':
          return 'Porque el café de especialidad aparece mucho en tu recorrido.';

        case 'brunch':
          return 'Porque el brunch aparece entre los lugares que elegís.';

        case 'desayuno':
          return 'Porque coincide con lugares que elegís para desayunar.';

        case 'pasteleria':
          return 'Porque la pastelería artesanal aparece en tu recorrido.';

        case 'pet':
          return 'Porque coincide con lugares pet friendly que elegís.';

        case 'wifi':
          return 'Porque el wifi aparece mucho entre los lugares que guardás.';

        case 'libros':
          return 'Porque coincide con lugares con libros o juegos que elegís.';

        case 'zona':
          return 'Porque está en una zona que aparece en tu recorrido.';

        default:
          return 'Elegido según los cafés de tu recorrido.';
      }
    }

    candidatos.sort(
      (a, b) => puntajeCafe(b).compareTo(
        puntajeCafe(a),
      ),
    );

    final topCinco =
        candidatos.take(5).toList();

    final mejorPuntaje =
        puntajeCafe(topCinco.first);

    final mejores = topCinco.where((cafe) {
      final puntaje = puntajeCafe(cafe);

      return puntaje >= mejorPuntaje * 0.90;
    }).toList();



    final indice =
        DateTime.now().day % mejores.length;

    final cafeElegido =
        mejores[indice];

    return RadarRecommendation(
      cafe: cafeElegido,
      motivo: motivoCafe(cafeElegido),
    );
  }
    Future<void> recargarHome() async {
      final nuevoCafesFuture =
          ApiService.obtenerCafes(
        forzarActualizacion: true,
      );

      final nuevoMapaFuture = estaLogueado
        ? ApiService.obtenerMiMapa(
            forzarActualizacion: true,
          )
        : Future.value(
            <CafeRelationship>[],
          );

    final nuevoGotasFuture = estaLogueado
        ? ApiService.obtenerMisGotas()
        : Future.value(
            <String, dynamic>{
              'balance': 0,
              'recent_transactions': [],
              'milestones': [],
            },
          );

    setState(() {
      cafesFuture = nuevoCafesFuture;
      mapaFuture = nuevoMapaFuture;
      gotasFuture = nuevoGotasFuture;
      radarFuture = calcularCafeEnRadar();
    });

    await Future.wait([
      nuevoCafesFuture,
      nuevoMapaFuture,
      nuevoGotasFuture,
    ]);
    }
    Future<void> abrirInstagram() async {
      final uri = Uri.parse(
        'https://www.instagram.com/app.gota/',
      );

      final abierto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!abierto && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No pudimos abrir Instagram.',
            ),
          ),
        );
      }
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
          if (estaLogueado)
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
                if (value == 'login') {
                  Navigator.pushNamed(
                    context,
                    '/login',
                  );
                }

                if (value == 'register') {
                  Navigator.pushNamed(
                    context,
                    '/register',
                  );
                }

                if (value == 'profile') {
                  Navigator.pushNamed(
                    context,
                    '/profile',
                  );
                }

                if (value == 'logout') {
                  await AuthService.logout();

                  if (!context.mounted) return;

                  setState(() {
                    estaLogueado = false;
                    mapaFuture = Future.value(
                      <CafeRelationship>[],
                    );
                    radarFuture = calcularCafeEnRadar();
                  });
                }
              },
              itemBuilder: (context) {
                if (estaLogueado) {
                  return const [
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
                  ];
                }

                return const [
                  PopupMenuItem(
                    value: 'login',
                    child: Row(
                      children: [
                        Icon(
                          Icons.login_rounded,
                          size: 21,
                        ),
                        SizedBox(width: 10),
                        Text('Ingresar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'register',
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 21,
                        ),
                        SizedBox(width: 10),
                        Text('Crear cuenta'),
                      ],
                    ),
                  ),
                ];
              },
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

              if (!estaLogueado) ...[
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Querés guardar tus cafés?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF172C6D),
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Creá tu mapa cafetero, guardá lugares y compartí tus experiencias.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/login',
                            );
                          },
                          child: const Text('Ingresar'),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        flex: 5,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/register',
                            );
                          },
                          child: const Text(
                            'Crear cuenta',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

              if (estaLogueado) ...[
                const SizedBox(height: 14),

                FutureBuilder<Map<String, dynamic>>(
                  future: gotasFuture,
                  builder: (context, snapshot) {
                    final data = snapshot.data;

                    final balance = int.tryParse(
                          data?['balance']?.toString() ?? '0',
                        ) ??
                        0;

                    final rawMilestones =
                      data?['milestones'] as List<dynamic>? ??
                          <dynamic>[];

                  final milestones = rawMilestones
                      .map(
                        (item) => int.tryParse(
                          (item as Map<String, dynamic>)['points_required']
                              .toString(),
                        ),
                      )
                      .whereType<int>()
                      .toList();

                  return _GotasProgressCard(
                    balance: balance,
                    milestones: milestones,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const MyGotasScreen(),
                        ),
                      );
                    },
                  );
                  },
                ),
              ],

              const SizedBox(height: 14),

              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  if (!estaLogueado) {
                    Navigator.pushNamed(
                      context,
                      '/login',
                    );
                    return;
                  }

                  Navigator.pushNamed(
                    context,
                    '/profile',
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 26,
                        color: Color(0xFF172C6D),
                      ),

                      SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Tenés una cafetería?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF172C6D),
                              ),
                            ),

                            SizedBox(height: 3),

                            Text(
                              'Sumala a Gota',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ],
                  ),
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
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        '/cafes',
                      );

                      if (!mounted || !estaLogueado) return;

                      setState(() {
                        gotasFuture = ApiService.obtenerMisGotas();
                      });
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
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        '/nearby',
                      );

                      if (!mounted || !estaLogueado) return;

                      setState(() {
                        gotasFuture = ApiService.obtenerMisGotas();
                      });
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
                    onTap: () async {
                      if (!estaLogueado) {
                        Navigator.pushNamed(
                          context,
                          '/login',
                        );
                        return;
                      }

                      await Navigator.pushNamed(
                        context,
                        '/my-map',
                      );

                      if (!mounted) return;

                      setState(() {
                        gotasFuture = ApiService.obtenerMisGotas();
                      });
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

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CafesMapScreen(
                  cafes: cafes,
                ),
              ),
            );

            if (!mounted || !estaLogueado) return;

            setState(() {
              gotasFuture = ApiService.obtenerMisGotas();
            });
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

            FutureBuilder<RadarRecommendation?>(
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

                final recomendacion = snapshot.data!;
                final cafeEnRadar = recomendacion.cafe;

                return Padding(
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CafeDetailScreen(
                            cafeId: cafeEnRadar.id!,
                            heroImageUrl: cafeEnRadar.foto,
                          ),
                        ),
                      );

                      if (!mounted || !estaLogueado) return;

                      setState(() {
                        gotasFuture = ApiService.obtenerMisGotas();
                      });
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
                            const SizedBox(height: 10),

                            Text(
                              recomendacion.motivo,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: Color(0xFF172C6D),
                                fontWeight: FontWeight.w500,
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

            const SizedBox(height: 24),

            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: abrirInstagram,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 28,
                      color: Color(0xFF172C6D),
                    ),

                    SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seguinos en Instagram',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF172C6D),
                            ),
                          ),

                          SizedBox(height: 3),

                          Text(
                            '@app.gota',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    ),
  ),
);
  }
}

class _GotasProgressCard extends StatelessWidget {
  final int balance;
  final List<int> milestones;
  final VoidCallback onTap;

  const _GotasProgressCard({
    required this.balance,
    required this.milestones,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final proximos = milestones
        .where((points) => points > balance)
        .toList()
      ..sort();

    final proximoObjetivo =
        proximos.isNotEmpty ? proximos.first : null;

    final faltan = proximoObjetivo != null
        ? proximoObjetivo - balance
        : 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F6F1),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE7E2D9),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TUS GOTAS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: Color(0xFF172C6D),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '$balance Gotas',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172C6D),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              balance == 0
                  ? 'Tu recorrido empieza acá.'
                  : proximoObjetivo == null
                      ? 'Ya alcanzaste todos los beneficios disponibles.'
                      : faltan == 1
                          ? 'Te falta 1 Gota para tu próximo beneficio.'
                          : 'Te faltan $faltan Gotas para tu próximo beneficio.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: Color(0xFF4B5563),
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 100,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final sortedMilestones = [...milestones]..sort();

                  final previousMilestones = sortedMilestones
                      .where((points) => points <= balance)
                      .toList();

                  final previousPoint = previousMilestones.isNotEmpty
                      ? previousMilestones.last
                      : 0;

                  final upcomingMilestones = sortedMilestones
                      .where((points) => points > balance)
                      .take(2)
                      .toList();

                  final endPoint = upcomingMilestones.isNotEmpty
                    ? upcomingMilestones.last
                    : balance;

                final range = endPoint - previousPoint;

                final progress = range > 0
                    ? ((balance - previousPoint) / range)
                        .clamp(0.0, 1.0)
                    : balance == 0
                        ? 0.0
                        : 1.0;

                const horizontalPadding = 22.0;

                final usableWidth =
                    constraints.maxWidth - (horizontalPadding * 2);

                final cupLeft =
                    horizontalPadding + (usableWidth * progress);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: horizontalPadding,
                        right: horizontalPadding,
                        top: 38,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),

                      Positioned(
                        left: horizontalPadding,
                        top: 38,
                        child: Container(
                          width: usableWidth * progress,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF172C6D),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),

                      Positioned(
                        left: (cupLeft - 18).clamp(
                          0.0,
                          constraints.maxWidth - 36,
                        ),
                        top: 20,
                        child: Container(
                          width: 36,
                          height: 36,
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF172C6D),
                              width: 2,
                            ),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/rating_cup.svg',
                          ),
                        ),
                      ),

                      Positioned(
                        left: (cupLeft - 20).clamp(
                          0.0,
                          constraints.maxWidth - 40,
                        ),
                        top: 61,
                        child: SizedBox(
                          width: 40,
                          child: Text(
                            '$balance',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF172C6D),
                            ),
                          ),
                        ),
                      ),

                      for (int i = 0; i < upcomingMilestones.length; i++)
                        Positioned(
                          left: (
                            horizontalPadding +
                            usableWidth *
                                (
                                  range > 0
                                      ? (
                                          (upcomingMilestones[i] - previousPoint) /
                                          range
                                        ).clamp(0.0, 1.0)
                                      : 1.0
                                ) -
                            21
                          ).clamp(
                            0.0,
                            constraints.maxWidth - 42,
                          ),
                          top: 16,
                          child: _GotaRewardMilestone(
                            value: upcomingMilestones[i],
                            isNext: i == 0,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ver mis Gotas y beneficios',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF172C6D),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 19,
                  color: Color(0xFF172C6D),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GotaRewardMilestone extends StatelessWidget {
  final int value;
  final bool isNext;

  const _GotaRewardMilestone({
    required this.value,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF172C6D),
              width: isNext ? 2.5 : 1.5,
            ),
          ),
          child: const Icon(
            Icons.card_giftcard_rounded,
            size: 22,
            color: Color(0xFF172C6D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF172C6D),
          ),
        ),
        if (isNext)
          const Text(
            'PRÓXIMO',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: Color(0xFF6B7280),
            ),
          ),
      ],
    );
  }
}

