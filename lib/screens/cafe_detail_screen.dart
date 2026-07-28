import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/network_image_card.dart';


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

  @override
  void initState() {
    super.initState();

    cargarDetalleCafe();
    cargarEstadoActual();
  }

  Future<void> cargarDetalleCafe() async {
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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargandoDetalle = false;
      });

      print(
        'Error cargando detalle: $e',
      );
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
    } catch (error) {
      print(
        'Error al cargar el estado del café: $error',
      );
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

  bool get laptopFriendlyCafe {
    return detalleCafe?['laptop_friendly'] == true;
  }

  bool get espacioTranquiloCafe {
    return detalleCafe?['quiet_space'] == true;
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

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  content: Text(mensaje),
  ),
  );
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
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Primero agregá el café a tu mapa',
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
          padding: const EdgeInsets.all(16),
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
                width: 52,
                height: 52,
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
                  size: 26,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: activo
                            ? const Color(0xFF172C6D)
                            : const Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 3),

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

    final tieneServicios =
        tieneWifiCafe ||
        petFriendlyCafe ||
        veganFriendlyCafe ||
        enchufesCafe ||
        cafeEspecialidadCafe ||
        brunchCafe ||
        laptopFriendlyCafe ||
        espacioTranquiloCafe;

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
                child: PageView(
                  padEnds: false,
                  controller: PageController(
                    viewportFraction: 0.94,
                  ),
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

                const SizedBox(height: 10),

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
              texto: '☕ Quiero ir',
              estado: 'quiero_ir',
              activo: estaEnQuieroIr,
            ),

            const SizedBox(height: 10),

            botonMapa(
              texto: '❤️ Quiero volver',
              estado: 'quiero_volver',
              activo: estaEnQuieroVolver,
            ),

            const SizedBox(height: 10),

            botonMapa(
              texto: '✔️ Ya fui',
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
              'Organizá este café dentro de tu recorrido.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 12),

            Column(
              children: collections.map((collection) {
                final bool activo =
                    selectedCollection == collection;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        guardarColeccion(collection);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(16),
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
                            Expanded(
                              child: Text(
                                collection,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: activo
                                      ? const Color(0xFF172C6D)
                                      : const Color(0xFF111827),
                                ),
                              ),
                            ),
                            if (activo)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF1E3A8A),
                              )
                            else
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.black38,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
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

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (tieneWifiCafe)
                    const Chip(label: Text('📶 Wifi')),
                  if (enchufesCafe)
                    const Chip(label: Text('🔌 Enchufes')),
                  if (cafeEspecialidadCafe)
                    const Chip(label: Text('☕ Especialidad')),
                  if (brunchCafe)
                    const Chip(label: Text('🍳 Brunch')),
                  if (laptopFriendlyCafe)
                    const Chip(label: Text('💻 Para trabajar')),
                  if (espacioTranquiloCafe)
                    const Chip(label: Text('🤫 Tranquilo')),
                  if (petFriendlyCafe)
                    const Chip(label: Text('🐶 Pet Friendly')),
                  if (veganFriendlyCafe)
                    const Chip(label: Text('🌱 Vegan Friendly')),
                ],
              ),

              const SizedBox(height: 28),
            ],

            if (direccionCafe.isNotEmpty) ...[
              const Text(
                'Ubicación',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                direccionCafe,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 16),
            ],

            if (latitudeCafe != null && longitudeCafe != null) ...[
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
                        userAgentPackageName: 'com.example.gota_mobile',
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
                      'https://www.google.com/maps/search/?api=1&query=${latitudeCafe},${longitudeCafe}',
                    );

                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
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
                                    imageUrl: avatarUrl!,
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

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                    '¿Y después de este?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cada café tiene algo distinto para ofrecer.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
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
                        'Seguir explorando',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}