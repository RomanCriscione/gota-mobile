import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/network_image_card.dart';
import '../models/cafe.dart';
import '../widgets/feature_card.dart';
import '../widgets/mini_cafe_card.dart';
import 'create_review_screen.dart';

class CafeDetailScreen extends StatefulWidget {
  final int cafeId;
  final String? heroImageUrl;

  const CafeDetailScreen({
    super.key,
    required this.cafeId,
    this.heroImageUrl,
  });

  @override
  State<CafeDetailScreen> createState() => _CafeDetailScreenState();
}

class _CafeDetailScreenState extends State<CafeDetailScreen> {
  static const List<String> collections = [
    '📚 Para leer',
    '💻 Para trabajar',
    '🌿 Para bajar un cambio',
    '☁️ Para días grises',
    '🫶 Para charlas largas',
  ];

  String? selectedCollection;
  String? estadoActual;
  Map<String, dynamic>? detalleCafe;
  bool cargandoDetalle = true;
  bool errorCargandoDetalle = false;

  List<Cafe> cafesRelacionados = [];
  bool cargandoRelacionados = true;
  List<Map<String, dynamic>> huellas = [];
  bool cargandoHuellas = true;
  final TextEditingController huellaController =
      TextEditingController();

  bool publicandoHuella = false;

  int fotoActual = 0;

  @override
  void initState() {
    super.initState();

    cargarDetalleCafe();
    cargarEstadoActual();
    cargarCafesRelacionados();
    cargarHuellas();
  }

  @override
  void dispose() {
    huellaController.dispose();
    super.dispose();
  }

  Future<void> cargarDetalleCafe() async {
    setState(() {
      cargandoDetalle = true;
      errorCargandoDetalle = false;
    });

    try {
      final detalle =
          await ApiService.obtenerDetalleCafe(
        widget.cafeId,
      );

      if (!mounted) return;

      setState(() {
        detalleCafe = detalle;
        cargandoDetalle = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        cargandoDetalle = false;
        errorCargandoDetalle = true;
      });

    }
  }

  Future<void> cargarEstadoActual() async {
    try {
      final relaciones = await ApiService.obtenerMiMapa();

      String? estadoEncontrado;
      String? coleccionEncontrada;

      for (final relacion in relaciones) {
        if (relacion.cafeId == widget.cafeId) {
          estadoEncontrado = relacion.status;

          switch (relacion.collection) {
            case 'read':
              coleccionEncontrada = '📚 Para leer';
              break;
            case 'work':
              coleccionEncontrada = '💻 Para trabajar';
              break;
            case 'slow':
              coleccionEncontrada = '🌿 Para bajar un cambio';
              break;
            case 'rain':
              coleccionEncontrada = '☁️ Para días grises';
              break;
            case 'talk':
              coleccionEncontrada = '🫶 Para charlas largas';
              break;
          }

          break;
        }
      }

      if (!mounted) return;

      setState(() {
        estadoActual = estadoEncontrado;
        selectedCollection = coleccionEncontrada;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        estadoActual = null;
        selectedCollection = null;
      });
    }
  }

  Future<void> cargarCafesRelacionados() async {
    try {
      final relacionados =
          await ApiService.obtenerCafesRelacionados(
        widget.cafeId,
      );

      if (!mounted) return;

      setState(() {
        cafesRelacionados = relacionados;
        cargandoRelacionados = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        cargandoRelacionados = false;
      });

    }
  }

  Future<void> cargarHuellas() async {
    try {
      final resultado =
          await ApiService.obtenerHuellas(
        widget.cafeId,
      );

      if (!mounted) return;

      setState(() {
        huellas = resultado;
        cargandoHuellas = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        cargandoHuellas = false;
      });
    }
  }

  String get nombreCafe {
    return detalleCafe?['name']?.toString() ?? '';
  }

  String get zonaCafe {
    return detalleCafe?['location']?.toString() ?? '';
  }

  String get ratingCafe {
    return detalleCafe?['average_rating']?.toString() ?? '0.0';
  }

  String get direccionCafe {
    return detalleCafe?['address']?.toString() ?? '';
  }

  double? get latitudeCafe {
    final valor = detalleCafe?['latitude'];

    if (valor is num) {
      return valor.toDouble();
    }

    return null;
  }

double? get longitudeCafe {
  final valor = detalleCafe?['longitude'];

  if (valor is num) {
    return valor.toDouble();
  }

  return null;
}

  List<String> get tagsCafe {
    final dynamic tagsApi = detalleCafe?['tags'];

    if (tagsApi is List) {
      return tagsApi
          .map(
            (tag) => tag.toString(),
          )
          .toList();
    }

    return [];
  }

  List<dynamic> get reviewsCafe {
    final dynamic reviewsApi = detalleCafe?['reviews'];

    if (reviewsApi is List) {
      return reviewsApi;
    }

    return [];
  }

  int get reviewsCount {
    final dynamic total = detalleCafe?['reviews_count'];

    if (total is int) {
      return total;
    }

    return 0;
  }

  Map<String, dynamic>? get miReview {
    final dynamic data =
        detalleCafe?['my_review'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  bool get tieneWifiCafe {
    return detalleCafe?['has_wifi'] == true;
  }

  bool get petFriendlyCafe {
    return detalleCafe?['is_pet_friendly'] == true;
  }

  bool get veganFriendlyCafe {
    return detalleCafe?['is_vegan_friendly'] == true;
  }

  bool get enchufesCafe {
    return detalleCafe?['has_power_outlets'] == true;
  }

  bool get cafeEspecialidadCafe {
    return detalleCafe?['has_specialty_coffee'] == true;
  }

  bool get brunchCafe {
    return detalleCafe?['serves_brunch'] == true;
  }

  bool get aireAcondicionadoCafe {
    return detalleCafe?['has_air_conditioning'] == true;
  }

  bool get aireLibreCafe {
    return detalleCafe?['has_outdoor_seating'] == true;
  }

  bool get estacionamientoCafe {
    return detalleCafe?['has_parking'] == true;
  }

  bool get accesibleCafe {
    return detalleCafe?['is_accessible'] == true;
  }

  bool get cambiadorBebesCafe {
    return detalleCafe?['has_baby_changing'] == true;
  }

  bool get desayunoCafe {
    return detalleCafe?['serves_breakfast'] == true;
  }

  bool get alcoholCafe {
    return detalleCafe?['serves_alcohol'] == true;
  }

  bool get pasteleriaArtesanalCafe {
    return detalleCafe?['has_artisanal_pastries'] == true;
  }

  bool get vegetarianoCafe {
    return detalleCafe?['has_vegetarian_options'] == true;
  }

  bool get sinTaccCafe {
    return detalleCafe?['has_gluten_free_options'] == true;
  }

  bool get librosOJuegosCafe {
    return detalleCafe?['has_books_or_games'] == true;
  }

  bool get kidsFriendlyCafe {
  return detalleCafe?['is_kids_friendly'] == true;
}

  bool get opcionesSaludablesCafe {
    return detalleCafe?['has_healthy_options'] == true;
  }

  bool get sinAzucarCafe {
    return detalleCafe?['has_sugar_free_options'] == true;
  }

  bool get lechesVegetalesCafe {
    return detalleCafe?['has_plant_based_milk'] == true;
  }

  bool get jardinCafe {
    return detalleCafe?['has_garden'] == true;
  }

  bool get vistaAguaCafe {
    return detalleCafe?['has_water_view'] == true;
  }

  bool get vistaMontanasCafe {
    return detalleCafe?['has_mountain_view'] == true;
  }

  bool get rodeadoNaturalezaCafe {
    return detalleCafe?['surrounded_by_nature'] == true;
  }

  bool get terrazaRooftopCafe {
    return detalleCafe?['has_rooftop'] == true;
  }

  bool get ventanalesGrandesCafe {
    return detalleCafe?['has_large_windows'] == true;
  }

  bool get casaAntiguaCafe {
    return detalleCafe?['is_old_house'] == true;
  }

  bool get edificioHistoricoCafe {
    return detalleCafe?['is_historic_building'] == true;
  }

  bool get dentroLibreriaCafe {
    return detalleCafe?['inside_bookstore'] == true;
  }

  bool get espacioCulturalCafe {
    return detalleCafe?['inside_cultural_space'] == true;
  }

  List<String> get fotosDisponibles {
    final dynamic fotosApi = detalleCafe?['photos'];

    if (fotosApi is List && fotosApi.isNotEmpty) {
      return fotosApi
          .map(
            (foto) => foto.toString(),
          )
          .where(
            (foto) => foto.isNotEmpty,
          )
          .toList();
    }

    return [];
  }

  bool get estaEnQuieroIr {
    return estadoActual == 'want_to_go';
  }

  bool get estaEnQuieroVolver {
    return estadoActual == 'want_to_return';
  }

  bool get estaEnYaFui {
    return estadoActual == 'visited';
  }

  Future<void> guardarEnMapa(String estado) async {
    String apiStatus = '';

    if (estado == 'quiero_ir') {
      apiStatus = 'want_to_go';
    } else if (estado == 'quiero_volver') {
      apiStatus = 'want_to_return';
    } else if (estado == 'ya_fui') {
      apiStatus = 'visited';
    }

    try {
      final response = await ApiService.setCafeStatus(
        cafeId: widget.cafeId,
        status: apiStatus,
      );

      if (!mounted) return;

      setState(() {
        estadoActual = response['status'];
      });

      String mensaje = '';

      if (estado == 'quiero_ir') {
        mensaje = 'Agregado a Quiero ir';
      } else if (estado == 'quiero_volver') {
        mensaje = 'Agregado a Quiero volver';
      } else if (estado == 'ya_fui') {
        mensaje = 'Agregado a Ya fui';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No pudimos actualizar tu mapa. Intentá nuevamente.',
          ),
        ),
      );
    }
  }


  Future<void> publicarHuella() async {
    final texto = huellaController.text.trim();

    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Escribí una huella.',
          ),
        ),
      );
      return;
    }

    if (texto.length > 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La huella puede tener hasta 40 caracteres.',
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      publicandoHuella = true;
    });

    try {
      final response = await ApiService.crearHuella(
        cafeId: widget.cafeId,
        text: texto,
      );

      if (!mounted) return;

      huellaController.clear();

      await cargarHuellas();

      if (!mounted) return;

      final message =
          response['message']?.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message != null && message.isNotEmpty
                ? message
                : 'Tu huella fue guardada.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final mensaje = e
          .toString()
          .replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          publicandoHuella = false;
        });
      }
    }
  }

    Future<void> _mostrarReporteResena(int reviewId) async {
      final motivo = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reportar reseña',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '¿Por qué querés reportar esta reseña?',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    leading: const Icon(Icons.block_outlined),
                    title: const Text('Spam'),
                    onTap: () => Navigator.pop(context, 'SPAM'),
                  ),

                  ListTile(
                    leading: const Icon(Icons.warning_amber_rounded),
                    title: const Text('Contenido ofensivo'),
                    onTap: () => Navigator.pop(context, 'OFFENSIVE'),
                  ),

                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('Información falsa'),
                    onTap: () => Navigator.pop(context, 'FALSE_INFO'),
                  ),

                  ListTile(
                    leading: const Icon(Icons.more_horiz_rounded),
                    title: const Text('Otro motivo'),
                    onTap: () => Navigator.pop(context, 'OTHER'),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (motivo == null || !mounted) return;

      try {
        await ApiService.reportarResena(
          reviewId: reviewId,
          reason: motivo,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gracias. Recibimos tu reporte y lo vamos a revisar.',
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        final mensaje = e
            .toString()
            .replaceFirst('Exception: ', '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
          ),
        );
      }
    }


  Future<void> guardarColeccion(String collection) async {
    String apiCollection = '';

    if (collection == '📚 Para leer') {
      apiCollection = 'read';
    } else if (collection == '💻 Para trabajar') {
      apiCollection = 'work';
    } else if (collection == '🌿 Para bajar un cambio') {
      apiCollection = 'slow';
    } else if (collection == '☁️ Para días grises') {
      apiCollection = 'rain';
    } else if (collection == '🫶 Para charlas largas') {
      apiCollection = 'talk';
    }

    try {
      await ApiService.setCafeCollection(
        cafeId: widget.cafeId,
        collection: apiCollection,
      );

      if (!mounted) return;

      setState(() {
        selectedCollection = collection;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Guardado en $collection',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No pudimos guardar la colección. Revisá que el café esté en tu mapa e intentá nuevamente.',
          ),
        ),
      );
    }
  }

  Widget etiquetaEstadoActual() {
    if (estadoActual == null) {
      return const SizedBox.shrink();
    }

    IconData icono;
    String titulo;
    Color color;

    switch (estadoActual) {
      case 'want_to_go':
        icono = Icons.bookmark_add_rounded;
        titulo = 'Quiero ir';
        color = const Color(0xFFE0F2FE);
        break;

      case 'want_to_return':
        icono = Icons.favorite;
        titulo = 'Quiero volver';
        color = const Color(0xFFFCE7F3);
        break;

      case 'visited':
        icono = Icons.check_circle;
        titulo = 'Ya fui';
        color = const Color(0xFFDCFCE7);
        break;

      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icono,
            size: 28,
          ),

          const SizedBox(width: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EN TU MAPA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget botonMapa({
    required String texto,
    required String estado,
    required bool activo,
  }) {
    late final IconData icono;
    late final String titulo;
    late final String descripcion;

    switch (estado) {
      case 'quiero_ir':
        icono = Icons.bookmark_add_rounded;
        titulo = 'Quiero ir';
        descripcion = 'Guardalo para visitarlo más adelante.';
        break;

      case 'quiero_volver':
        icono = Icons.favorite_rounded;
        titulo = 'Quiero volver';
        descripcion = 'Ya fuiste y querés regresar.';
        break;

      case 'ya_fui':
        icono = Icons.check_circle_rounded;
        titulo = 'Ya fui';
        descripcion = 'Marcá este café como visitado.';
        break;

      default:
        icono = Icons.bookmark_outline_rounded;
        titulo = texto;
        descripcion = '';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: activo
            ? null
            : () {
                guardarEnMapa(estado);
              },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: activo
                ? const Color(0xFFEFF6FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: activo
                  ? const Color(0xFF1E3A8A)
                  : const Color(0xFFE5E7EB),
              width: activo ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: activo
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icono,
                  color: activo
                      ? Colors.white
                      : const Color(0xFF1E3A8A),
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: activo
                            ? const Color(0xFF172C6D)
                            : const Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      descripcion,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              if (activo)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF1E3A8A),
                  size: 24,
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black38,
                  size: 26,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargandoDetalle) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando café...'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (widget.heroImageUrl != null &&
                  widget.heroImageUrl!.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 260,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Hero(
                      tag: 'cafe-${widget.cafeId}',
                      child: Image.network(
                        widget.heroImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Container(
                            color: const Color(0xFFF3F4F6),
                            child: Center(
                              child: Opacity(
                                opacity: 0.38,
                                child: SvgPicture.asset(
                                  'assets/icons/rating_cup.svg',
                                  width: 70,
                                  height: 70,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 28),

              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    if (errorCargandoDetalle || detalleCafe == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cafetería'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 44,
                  color: Colors.black45,
                ),
                const SizedBox(height: 14),
                const Text(
                  'No pudimos cargar esta cafetería.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Revisá tu conexión e intentá nuevamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: cargarDetalleCafe,
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: const Text(
                    'Reintentar',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final tieneServicios =
        tieneWifiCafe ||
        petFriendlyCafe ||
        veganFriendlyCafe ||
        enchufesCafe ||
        cafeEspecialidadCafe ||
        brunchCafe ||
        aireAcondicionadoCafe ||
        aireLibreCafe ||
        estacionamientoCafe ||
        accesibleCafe ||
        cambiadorBebesCafe ||
        desayunoCafe ||
        alcoholCafe ||
        pasteleriaArtesanalCafe ||
        vegetarianoCafe ||
        sinTaccCafe ||
        librosOJuegosCafe ||
        kidsFriendlyCafe ||
        opcionesSaludablesCafe ||
        sinAzucarCafe ||
        lechesVegetalesCafe ||
        jardinCafe ||
        vistaAguaCafe ||
        vistaMontanasCafe ||
        rodeadoNaturalezaCafe ||
        terrazaRooftopCafe ||
        ventanalesGrandesCafe ||
        casaAntiguaCafe ||
        edificioHistoricoCafe ||
        dentroLibreriaCafe ||
        espacioCulturalCafe;

    return Scaffold(
      appBar: AppBar(
        title: Text(nombreCafe),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fotosDisponibles.isNotEmpty)
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                PageView(
                  padEnds: false,
                  controller: PageController(
                    viewportFraction: 0.94,
                  ),
                  onPageChanged: (index) {
                    setState(() {
                      fotoActual = index;
                    });
                  },
                  children: fotosDisponibles.asMap().entries.map((entry) {
                    final indice = entry.key;
                    final foto = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            indice == 0
                                ? NetworkImageCard(
                                    imageUrl: foto,
                                    height: 260,
                                    heroTag: 'cafe-${widget.cafeId}',
                                  )
                                : NetworkImageCard(
                                    imageUrl: foto,
                                    height: 260,
                                  ),

                            Positioned(
                              top: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(
                                    alpha: 0.55,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${fotosDisponibles.length} fotos',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                if (fotosDisponibles.length > 1)
                  Positioned(
                    left: 0,
                    right: 10,
                    bottom: 14,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: 0.62,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${fotoActual + 1} / ${fotosDisponibles.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

            const SizedBox(height: 18),

            Text(
              nombreCafe,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 19,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        zonaCafe,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                if (direccionCafe.isNotEmpty) ...[
                                  const SizedBox(height: 7),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.signpost_outlined,
                                        size: 18,
                                        color: Colors.black45,
                                      ),

                                      const SizedBox(width: 5),

                                      Expanded(
                                        child: Text(
                                          direccionCafe,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.3,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                const SizedBox(height: 12),

                  if (ratingCafe == '0.0' ||
                    ratingCafe == 'Sin calificación')
                  const Text(
                    'Aún sin reseñas',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  )
                else
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/rating_cup.svg',
                        width: 24,
                        height: 24,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        ratingCafe.replaceAll('.', ','),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF172C6D),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        reviewsCount == 1
                            ? '1 reseña'
                            : '$reviewsCount reseñas',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateReviewScreen(
                            cafeId: widget.cafeId,
                            cafeName: nombreCafe,
                            existingReview: miReview,
                          ),
                    ),
                  );

                  if (!mounted) return;

                  await cargarDetalleCafe();
                },
                icon: miReview == null
                    ? SvgPicture.asset(
                        'assets/icons/rating_cup.svg',
                        width: 20,
                        height: 20,
                      )
                    : const Icon(
                        Icons.edit_outlined,
                      ),
                label: Text(
                  miReview == null
                      ? 'Contá cómo fue'
                      : 'Editar mi reseña',
                ),
              ),
            ),

            const SizedBox(height: 18),

            etiquetaEstadoActual(),

            const SizedBox(height: 24),
            if (tagsCafe.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cómo se siente este café',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Experiencias reales que otras personas asociaron con este lugar.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFBFDBFE),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.format_quote_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Text(
                                  tagsCafe.first,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    height: 1.35,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF172C6D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (tagsCafe.length > 1) ...[
                          const SizedBox(height: 16),

                          const Text(
                            'También asociado con:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tagsCafe.skip(1).map((tag) {
                              return Chip(
                                label: Text(tag),
                                backgroundColor: Colors.white,
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],

            const SizedBox(height: 28),

            const Text(
              '🍃 Huellas de este lugar',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Pequeñas sensaciones que este café dejó en alguien.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: huellaController,
                    maxLength: 40,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!publicandoHuella) {
                        publicarHuella();
                      }
                    },
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      hintText: 'Ej: Para charlas largas',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Máximo 40 caracteres · 1 huella por día',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        '${huellaController.text.length}/40',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: huellaController.text.length >= 40
                              ? Colors.red
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          publicandoHuella ? null : publicarHuella,
                      icon: publicandoHuella
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.eco_outlined,
                            ),
                      label: Text(
                        publicandoHuella
                            ? 'Guardando...'
                            : 'Dejá cómo se sintió',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            if (cargandoHuellas)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (huellas.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                child: const Text(
                  'Todavía nadie dejó una huella acá.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: huellas.take(6).map((huella) {
                  final texto =
                      huella['text']?.toString() ?? '';

                  return Container(
                    constraints: const BoxConstraints(
                      minWidth: 150,
                      maxWidth: 220,
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7D6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE7D69C),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.06,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      '“$texto”',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5A472A),
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 28),

            const Text(
              'Guardarlo en tu mapa',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Elegí qué lugar ocupa este café en tu recorrido.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 16),

            botonMapa(
              texto: 'Quiero ir',
              estado: 'quiero_ir',
              activo: estaEnQuieroIr,
            ),

            const SizedBox(height: 10),

            botonMapa(
              texto: 'Quiero volver',
              estado: 'quiero_volver',
              activo: estaEnQuieroVolver,
            ),

            const SizedBox(height: 10),

            botonMapa(
              texto: 'Ya fui',
              estado: 'ya_fui',
              activo: estaEnYaFui,
            ),

            const SizedBox(height: 28),

                        const Text(
                          'Colección',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          '¿Para qué momento guardarías este café?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Column(
                            children: collections.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final String collection = entry.value;
                              final bool activo =
                                  selectedCollection == collection;

                              final String emoji =
                                  collection.substring(0, collection.indexOf(' '));

                              final String titulo =
                                  collection.substring(collection.indexOf(' ') + 1);

                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == collections.length - 1 ? 0 : 8,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      guardarColeccion(collection);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: activo
                                            ? const Color(0xFFEFF6FF)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: activo
                                              ? const Color(0xFF1E3A8A)
                                              : const Color(0xFFE5E7EB),
                                          width: activo ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: activo
                                                  ? const Color(0xFFDBEAFE)
                                                  : const Color(0xFFF3F4F6),
                                              borderRadius: BorderRadius.circular(13),
                                            ),
                                            child: Text(
                                              emoji,
                                              style: const TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Text(
                                              titulo,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: activo
                                                    ? FontWeight.w700
                                                    : FontWeight.w600,
                                                color: activo
                                                    ? const Color(0xFF172C6D)
                                                    : const Color(0xFF111827),
                                              ),
                                            ),
                                          ),

                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 160,
                                            ),
                                            child: activo
                                                ? const Icon(
                                                    Icons.check_circle_rounded,
                                                    key: ValueKey('activo'),
                                                    color: Color(0xFF1E3A8A),
                                                    size: 23,
                                                  )
                                                : const Icon(
                                                    Icons.add_circle_outline_rounded,
                                                    key: ValueKey('inactivo'),
                                                    color: Colors.black38,
                                                    size: 22,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 28),

                        if (tieneServicios) ...[
              const Text(
                'Lo que ofrece',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.25,
                children: [
                  if (cafeEspecialidadCafe)
                    const FeatureCard(
                      label: 'Especialidad',
                      svgAsset: 'assets/icons/rating_cup.svg',
                    ),

                  if (tieneWifiCafe)
                    const FeatureCard(
                      label: 'Wifi',
                      icon: Icons.wifi_rounded,
                    ),

                  if (enchufesCafe)
                    const FeatureCard(
                      label: 'Enchufes',
                      icon: Icons.power_rounded,
                    ),

                  if (aireAcondicionadoCafe)
                    const FeatureCard(
                      label: 'Aire acondicionado',
                      icon: Icons.ac_unit_rounded,
                    ),

                  if (aireLibreCafe)
                    const FeatureCard(
                      label: 'Aire libre',
                      icon: Icons.wb_sunny_outlined,
                    ),

                  if (estacionamientoCafe)
                    const FeatureCard(
                      label: 'Estacionamiento',
                      icon: Icons.local_parking_rounded,
                    ),

                  if (accesibleCafe)
                    const FeatureCard(
                      label: 'Accesible',
                      icon: Icons.accessible_rounded,
                    ),

                  if (cambiadorBebesCafe)
                    const FeatureCard(
                      label: 'Cambiador',
                      icon: Icons.baby_changing_station_rounded,
                    ),

                  if (brunchCafe)
                    const FeatureCard(
                      label: 'Brunch',
                      icon: Icons.brunch_dining_rounded,
                    ),
                  
                  if (desayunoCafe)
                    const FeatureCard(
                      label: 'Desayuno',
                      icon: Icons.breakfast_dining_rounded,
                    ),

                  if (pasteleriaArtesanalCafe)
                    const FeatureCard(
                      label: 'Pastelería',
                      icon: Icons.cake_outlined,
                    ),

                  if (vegetarianoCafe)
                    const FeatureCard(
                      label: 'Vegetariano',
                      icon: Icons.eco_outlined,
                    ),

                  if (sinTaccCafe)
                    const FeatureCard(
                      label: 'Sin TACC',
                      icon: Icons.no_food_outlined,
                    ),
                  
                  if (opcionesSaludablesCafe)
                    const FeatureCard(
                      label: 'Saludables',
                      icon: Icons.health_and_safety_outlined,
                    ),

                  if (sinAzucarCafe)
                    const FeatureCard(
                      label: 'Sin azúcar',
                      icon: Icons.no_meals_outlined,
                    ),

                  if (lechesVegetalesCafe)
                    const FeatureCard(
                      label: 'Leches vegetales',
                      icon: Icons.local_drink_outlined,
                    ),

                  if (jardinCafe)
                    const FeatureCard(
                      label: 'Con jardín',
                      icon: Icons.yard_outlined,
                    ),

                  if (vistaAguaCafe)
                    const FeatureCard(
                      label: 'Vista al agua',
                      icon: Icons.water_outlined,
                    ),

                  if (vistaMontanasCafe)
                    const FeatureCard(
                      label: 'Sierras / montañas',
                      icon: Icons.landscape_outlined,
                    ),

                  if (rodeadoNaturalezaCafe)
                    const FeatureCard(
                      label: 'Naturaleza',
                      icon: Icons.park_outlined,
                    ),

                  if (terrazaRooftopCafe)
                    const FeatureCard(
                      label: 'Terraza / rooftop',
                      icon: Icons.roofing_outlined,
                    ),

                  if (ventanalesGrandesCafe)
                    const FeatureCard(
                      label: 'Grandes ventanales',
                      icon: Icons.window_outlined,
                    ),

                  if (casaAntiguaCafe)
                    const FeatureCard(
                      label: 'Casa antigua',
                      icon: Icons.home_outlined,
                    ),

                  if (edificioHistoricoCafe)
                    const FeatureCard(
                      label: 'Edificio histórico',
                      icon: Icons.account_balance_outlined,
                    ),

                  if (dentroLibreriaCafe)
                    const FeatureCard(
                      label: 'Dentro de librería',
                      icon: Icons.menu_book_outlined,
                    ),

                  if (espacioCulturalCafe)
                    const FeatureCard(
                      label: 'Espacio cultural',
                      icon: Icons.palette_outlined,
                    ),

                  if (kidsFriendlyCafe)
                    const FeatureCard(
                      label: 'Kids friendly',
                      icon: Icons.child_friendly_outlined,
                    ),

                  if (alcoholCafe)
                    const FeatureCard(
                      label: 'Alcohol',
                      icon: Icons.local_bar_outlined,
                    ),

                  if (librosOJuegosCafe)
                    const FeatureCard(
                      label: 'Libros / juegos',
                      icon: Icons.menu_book_outlined,
                    ),

                  if (petFriendlyCafe)
                    const FeatureCard(
                      label: 'Pet Friendly',
                      icon: Icons.pets_rounded,
                    ),

                  if (veganFriendlyCafe)
                    const FeatureCard(
                      label: 'Vegan Friendly',
                      icon: Icons.eco_rounded,
                    ),
                ],
              ),

              const SizedBox(height: 28),
            ],

                        if (latitudeCafe != null && longitudeCafe != null) ...[
              const Text(
                'Ubicación',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        latitudeCafe!,
                        longitudeCafe!,
                      ),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                        userAgentPackageName: 'ar.gogota.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              latitudeCafe!,
                              longitudeCafe!,
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final Uri url = Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=$latitudeCafe,$longitudeCafe',
                    );

                    final abierto = await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );

                    if (!context.mounted) return;

                    if (!abierto) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No pudimos abrir Google Maps.',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Abrir en Google Maps'),
                ),
              ),
            ],
            

            const SizedBox(height: 32),

            if (reviewsCafe.isNotEmpty) ...[
              Text(
                'Reseñas ($reviewsCount)',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Experiencias compartidas por la comunidad de Gota.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 16),

              ...reviewsCafe.map((review) {
                final reviewMap = review is Map
                    ? Map<String, dynamic>.from(review)
                    : <String, dynamic>{};

                final String usuario =
                    reviewMap['user']?.toString() ??
                    'Usuario de Gota';
                
                final String? avatarUrl =
                  reviewMap['avatar']?.toString().trim();

              final bool tieneAvatar =
                  avatarUrl != null &&
                  avatarUrl.isNotEmpty &&
                  avatarUrl != 'null';

                final int rating =
                    reviewMap['rating'] is num
                    ? (reviewMap['rating'] as num).toInt()
                    : 0;

                final String comentario =
                    reviewMap['comment']?.toString() ?? '';

                final String fecha =
                    reviewMap['created_at']?.toString() ?? '';

                final String respuestaDueno =
                    reviewMap['owner_reply']?.toString() ?? '';

                final int? reviewId = reviewMap['id'] is num
                    ? (reviewMap['id'] as num).toInt()
                    : int.tryParse(reviewMap['id']?.toString() ?? '');

                return Container(
                   width: double.infinity,
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF1E3A8A),
                            child: tieneAvatar
                              ? ClipOval(
                                  child: NetworkImageCard(
                                    imageUrl: avatarUrl,
                                    width: 48,
                                    height: 48,
                                    borderRadius: 24,
                                  ),
                                )
                              : Text(
                                  usuario.isNotEmpty
                                      ? usuario[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  usuario,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                if (fecha.isNotEmpty)
                                  Text(
                                    fecha,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                                                    ),

                          if (reviewId != null)
                            PopupMenuButton<String>(
                              tooltip: 'Opciones',
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: Colors.black54,
                              ),
                              onSelected: (value) {
                                if (value == 'report') {
                                  _mostrarReporteResena(reviewId);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem<String>(
                                  value: 'report',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.flag_outlined,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text('Reportar reseña'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/rating_cup.svg',
                            width: 22,
                            height: 22,
                          ),

                          const SizedBox(width: 7),

                          Text(
                            '$rating,0',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF172C6D),
                            ),
                          ),
                        ],
                      ),

                      if (comentario.isNotEmpty) ...[
                        const SizedBox(height: 16),

                        Text(
                          comentario,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],

                      if (respuestaDueno.isNotEmpty) ...[
                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD97706),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.storefront,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      'Respuesta de $nombreCafe',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Text(
                                respuestaDueno,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ] else ...[
              const Text(
                'Reseñas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Este café todavía no tiene reseñas.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ],

                        const SizedBox(height: 32),

            if (cargandoRelacionados)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 24,
                  ),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (cafesRelacionados.isNotEmpty) ...[
              const Text(
                'También podría gustarte',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Otros lugares para seguir descubriendo.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 16),

              ...cafesRelacionados.map(
                (cafe) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: MiniCafeCard(
                    cafe: cafe,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CafeDetailScreen(
                            cafeId: cafe.id!,
                            heroImageUrl: cafe.foto,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 6),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/cafes',
                    );
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/rating_cup.svg',
                    width: 20,
                    height: 20,
                  ),
                  label: const Text(
                    'Ver todas las cafeterías',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}