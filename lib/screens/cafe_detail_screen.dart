import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import 'package:flutter_svg/flutter_svg.dart';


class CafeDetailScreen extends StatefulWidget {
  final int cafeId;

  const CafeDetailScreen({
    super.key,
    required this.cafeId,
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
    if (estaEnQuieroIr) {
      return const Chip(
        label: Text('☕ En tu mapa: Quiero ir'),
      );
    }

    if (estaEnQuieroVolver) {
      return const Chip(
        label: Text('❤️ En tu mapa: Quiero volver'),
      );
    }

    if (estaEnYaFui) {
      return const Chip(
        label: Text('✔️ En tu mapa: Ya fui'),
      );
    }

    return const SizedBox.shrink();
  }

  Widget botonMapa({
    required String texto,
    required String estado,
    required bool activo,
  }) {
    return SizedBox(
      width: double.infinity,
      child: activo
          ? OutlinedButton(
              onPressed: () {},
              child: Text('$texto · seleccionado'),
            )
          : ElevatedButton(
              onPressed: () {
                guardarEnMapa(estado);
              },
              child: Text(texto),
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
        body: const Center(
          child: CircularProgressIndicator(),
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
                height: 240,
                child: PageView(
                  children: fotosDisponibles.map((foto) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        foto,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                        ) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Container(
                            color: const Color(0xFFF3F4F6),
                            child: const Center(
                              child: Icon(
                                Icons.coffee,
                                size: 70,
                                color: Colors.black38,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                '📸 ${fotosDisponibles.length} fotos',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              nombreCafe,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              ratingCafe == '0.0' ||
                      ratingCafe == 'Sin calificación'
                  ? '📍 $zonaCafe · Aún sin reseñas'
                  : '📍 $zonaCafe · ⭐ $ratingCafe',
              style: const TextStyle(
                fontSize: 17,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

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
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '✨ ${tagsCafe.first}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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

            DropdownButtonFormField<String>(
              value: selectedCollection,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              hint: const Text('Elegir colección'),
              items: collections.map((collection) {
                return DropdownMenuItem(
                  value: collection,
                  child: Text(collection),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                guardarColeccion(value);
              },
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
                          const CircleAvatar(
                            child: Icon(
                              Icons.person,
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

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: Opacity(
                                opacity: index < rating ? 1 : 0.25,
                                child: SvgPicture.asset(
                                  'assets/icons/rating_cup.svg',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '$rating,0',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      if (comentario.isNotEmpty) ...[
                        const SizedBox(height: 10),

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
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Respuesta del café',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                respuestaDueno,
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
                      icon: const Icon(Icons.coffee),
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