import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectCafeLocationScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const SelectCafeLocationScreen({
    super.key,
    this.initialLocation,
  });

  @override
  State<SelectCafeLocationScreen> createState() =>
      _SelectCafeLocationScreenState();
}

class _SelectCafeLocationScreenState
    extends State<SelectCafeLocationScreen> {
  late LatLng ubicacionSeleccionada;

  @override
  void initState() {
    super.initState();

    ubicacionSeleccionada =
        widget.initialLocation ??
        const LatLng(
          -34.6037,
          -58.3816,
        );
  }

  void _seleccionarUbicacion(
    TapPosition tapPosition,
    LatLng punto,
  ) {
    setState(() {
      ubicacionSeleccionada = punto;
    });
  }

  void _confirmarUbicacion() {
    Navigator.pop(
      context,
      ubicacionSeleccionada,
    );
  }

  @override
  Widget build(BuildContext context) {
    final direccionEncontrada =
        widget.initialLocation != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ubicación de la cafetería',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                14,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Marcá la ubicación exacta',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 6),

                                    Text(
                    direccionEncontrada
                        ? 'Ubicamos la dirección que ingresaste. '
                            'Si el pin no está exactamente donde corresponde, '
                            'tocá el mapa para corregirlo.'
                        : 'No pudimos ubicar automáticamente la dirección. '
                            'Tocá el mapa para marcar dónde está la cafetería.',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter:
                      ubicacionSeleccionada,
                  initialZoom:
                      direccionEncontrada ? 16 : 11,
                  onTap: _seleccionarUbicacion,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=${const String.fromEnvironment('CARTO_API_KEY')}',
                    userAgentPackageName:
                        'ar.gogota.app',
                  ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point:
                            ubicacionSeleccionada,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 52,
                          color:
                              Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),

                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => launchUrl(
                          Uri.parse(
                            'https://www.openstreetmap.org/copyright',
                          ),
                        ),
                      ),
                      TextSourceAttribution(
                        'CARTO',
                        onTap: () => launchUrl(
                          Uri.parse(
                            'https://carto.com/attributions',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                18,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color:
                        Color(0xFFE5E7EB),
                  ),
                ),
              ),
              child: ElevatedButton.icon(
                onPressed:
                    _confirmarUbicacion,
                icon: const Icon(
                  Icons.check_rounded,
                ),
                label: const Text(
                  'Confirmar ubicación',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}