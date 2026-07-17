import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';

import '../models/cafe.dart';
import '../services/app_state.dart';

class CafeDetailScreen extends StatefulWidget {
  final int cafeId;
  final String nombre;
  final String zona;
  final String rating;
  final String foto;
  final String foto2;
  final String foto3;

  final String direccion;
  final double? latitude;
  final double? longitude;

  final bool tieneWifi;
  final bool petFriendly;
  final bool veganFriendly;

  final bool enchufes;
  final bool cafeEspecialidad;
  final bool brunch;
  final bool laptopFriendly;
  final bool espacioTranquilo;

  final List<String> tags;

  const CafeDetailScreen({
    super.key,
    required this.cafeId,
    required this.nombre,
    required this.zona,
    required this.rating,
    required this.foto,
    required this.foto2,
    required this.foto3,
    required this.direccion,
    required this.latitude,
    required this.longitude,
    required this.tieneWifi,
    required this.petFriendly,
    required this.veganFriendly,
    required this.enchufes,
    required this.cafeEspecialidad,
    required this.brunch,
    required this.laptopFriendly,
    required this.espacioTranquilo,
    required this.tags,
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

  @override
  void initState() {
    super.initState();

    Cafe? cafeGuardado;

    try {
      cafeGuardado = AppState.quieroIr.firstWhere(
        (cafe) => cafe.nombre == widget.nombre,
      );
    } catch (_) {}

    try {
      cafeGuardado ??= AppState.quieroVolver.firstWhere(
        (cafe) => cafe.nombre == widget.nombre,
      );
    } catch (_) {}

    try {
      cafeGuardado ??= AppState.yaFui.firstWhere(
        (cafe) => cafe.nombre == widget.nombre,
      );
    } catch (_) {}

    selectedCollection = cafeGuardado?.collection;

    cargarEstadoActual();
  }

  Future<void> cargarEstadoActual() async {
    try {
      final relaciones = await ApiService.obtenerMiMapa();

      String? estadoEncontrado;

      for (final relacion in relaciones) {
        if (relacion.cafeId == widget.cafeId) {
          estadoEncontrado = relacion.status;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        estadoActual = estadoEncontrado;
      });
    } catch (error) {
      print(
        'Error al cargar el estado del café: $error',
      );
    }
  }

  List<String> get fotosDisponibles {
    return [
      widget.foto,
      if (widget.foto2.isNotEmpty) widget.foto2,
      if (widget.foto3.isNotEmpty) widget.foto3,
    ];
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

  Cafe crearCafeActual() {
    return Cafe(
      nombre: widget.nombre,
      zona: widget.zona,
      rating: widget.rating,
      foto: widget.foto,
      foto2: widget.foto2,
      foto3: widget.foto3,
      direccion: widget.direccion,
      latitude: widget.latitude,
      longitude: widget.longitude,
      tieneWifi: widget.tieneWifi,
      petFriendly: widget.petFriendly,
      veganFriendly: widget.veganFriendly,
      enchufes: widget.enchufes,
      cafeEspecialidad: widget.cafeEspecialidad,
      brunch: widget.brunch,
      laptopFriendly: widget.laptopFriendly,
      espacioTranquilo: widget.espacioTranquilo,
      tags: widget.tags,
    );
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

  Cafe cafe = crearCafeActual();

  Cafe? cafeExistente;

  try {
  cafeExistente = AppState.quieroIr.firstWhere(
  (item) => item.nombre == widget.nombre,
  );
  } catch (_) {}

  try {
  cafeExistente ??= AppState.quieroVolver.firstWhere(
  (item) => item.nombre == widget.nombre,
  );
  } catch (_) {}

  try {
  cafeExistente ??= AppState.yaFui.firstWhere(
  (item) => item.nombre == widget.nombre,
  );
  } catch (_) {}

  if (cafeExistente != null) {
  cafe = cafe.copyWith(
  collection: cafeExistente.collection,
  );
  }

  AppState.quieroIr.removeWhere(
  (item) => item.nombre == widget.nombre,
  );

  AppState.quieroVolver.removeWhere(
  (item) => item.nombre == widget.nombre,
  );

  AppState.yaFui.removeWhere(
  (item) => item.nombre == widget.nombre,
  );

  if (estado == 'quiero_ir') {
  AppState.quieroIr.add(cafe);
  } else if (estado == 'quiero_volver') {
  AppState.quieroVolver.add(cafe);
  } else if (estado == 'ya_fui') {
  AppState.yaFui.add(cafe);
  }

  await AppState.guardarDatos();

  setState(() {});

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
    bool actualizado = false;

    for (int i = 0; i < AppState.quieroIr.length; i++) {
      if (AppState.quieroIr[i].nombre == widget.nombre) {
        AppState.quieroIr[i] =
            AppState.quieroIr[i].copyWith(
          collection: collection,
        );
        actualizado = true;
      }
    }

    for (int i = 0; i < AppState.quieroVolver.length; i++) {
      if (AppState.quieroVolver[i].nombre == widget.nombre) {
        AppState.quieroVolver[i] =
            AppState.quieroVolver[i].copyWith(
          collection: collection,
        );
        actualizado = true;
      }
    }

    for (int i = 0; i < AppState.yaFui.length; i++) {
      if (AppState.yaFui[i].nombre == widget.nombre) {
        AppState.yaFui[i] =
            AppState.yaFui[i].copyWith(
          collection: collection,
        );
        actualizado = true;
      }
    }

    if (!actualizado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Primero agregá el café a tu mapa',
          ),
        ),
      );
      return;
    }
    for (final cafe in AppState.quieroIr) {
      print('${cafe.nombre} -> ${cafe.collection}');
    }

    await AppState.guardarDatos();

    setState(() {
      selectedCollection = collection;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Guardado en $collection',
        ),
      ),
    );
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
    final tieneServicios =
        widget.tieneWifi ||
        widget.petFriendly ||
        widget.veganFriendly ||
        widget.enchufes ||
        widget.cafeEspecialidad ||
        widget.brunch ||
        widget.laptopFriendly ||
        widget.espacioTranquilo;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombre),
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
              widget.nombre,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.rating == '0.0'
                  ? '📍 ${widget.zona} · Aún sin reseñas'
                  : '📍 ${widget.zona} · ⭐ ${widget.rating}',
              style: const TextStyle(
                fontSize: 17,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            etiquetaEstadoActual(),

            const SizedBox(height: 24),

            if (widget.tags.isNotEmpty) ...[
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
                            '✨ ${widget.tags.first}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (widget.tags.length > 1) ...[
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
                            children: widget.tags.skip(1).map((tag) {
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
                  if (widget.tieneWifi)
                    const Chip(label: Text('📶 Wifi')),
                  if (widget.enchufes)
                    const Chip(label: Text('🔌 Enchufes')),
                  if (widget.cafeEspecialidad)
                    const Chip(label: Text('☕ Especialidad')),
                  if (widget.brunch)
                    const Chip(label: Text('🍳 Brunch')),
                  if (widget.laptopFriendly)
                    const Chip(label: Text('💻 Para trabajar')),
                  if (widget.espacioTranquilo)
                    const Chip(label: Text('🤫 Tranquilo')),
                  if (widget.petFriendly)
                    const Chip(label: Text('🐶 Pet Friendly')),
                  if (widget.veganFriendly)
                    const Chip(label: Text('🌱 Vegan Friendly')),
                ],
              ),

              const SizedBox(height: 28),
            ],

            if (widget.direccion.isNotEmpty) ...[
              const Text(
                'Ubicación',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.direccion,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 16),
            ],

            if (widget.latitude != null && widget.longitude != null) ...[
              SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        widget.latitude!,
                        widget.longitude!,
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
                              widget.latitude!,
                              widget.longitude!,
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
                      'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}',
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