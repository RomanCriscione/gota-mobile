import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'cafe_detail_screen.dart';
import '../widgets/network_image_card.dart';
import '../widgets/rating_badge.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

import '../models/cafe.dart';

class CafesMapScreen extends StatefulWidget {
  final List<Cafe> cafes;

  const CafesMapScreen({
    super.key,
    required this.cafes,
  });

  @override
  State<CafesMapScreen> createState() =>
      _CafesMapScreenState();
}

class _CafesMapScreenState
    extends State<CafesMapScreen> {
  Position? posicionActual;
  bool buscandoUbicacion = true;
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    obtenerUbicacionInicial();
  }

  Future<void> obtenerUbicacionInicial() async {
    try {
      final servicioHabilitado =
          await Geolocator.isLocationServiceEnabled();

      if (!servicioHabilitado) {
        if (!mounted) return;

        setState(() {
          buscandoUbicacion = false;
        });

        return;
      }

      final permiso =
          await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          buscandoUbicacion = false;
        });

        return;
      }

      final posicion =
          await Geolocator.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        posicionActual = posicion;
        buscandoUbicacion = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        mapController.move(
          LatLng(
            posicion.latitude,
            posicion.longitude,
          ),
          14.5,
        );
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        buscandoUbicacion = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cafes = widget.cafes;
    final cafesConUbicacion = cafes.where((cafe) {
        return cafe.latitude != null &&
            cafe.longitude != null &&
            cafe.latitude!.isFinite &&
            cafe.longitude!.isFinite;
        }).toList();

    final LatLng centroInicial;

    if (cafesConUbicacion.isNotEmpty) {
      final promedioLat = cafesConUbicacion
              .map((cafe) => cafe.latitude!)
              .reduce((a, b) => a + b) /
          cafesConUbicacion.length;

      final promedioLng = cafesConUbicacion
              .map((cafe) => cafe.longitude!)
              .reduce((a, b) => a + b) /
          cafesConUbicacion.length;

      centroInicial = LatLng(
        promedioLat,
        promedioLng,
      );
    } else {
      centroInicial = const LatLng(
        -34.6037,
        -58.3816,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa (${cafesConUbicacion.length})',
        ),
      ),
        body: buscandoUbicacion
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: posicionActual != null
                  ? LatLng(
                      posicionActual!.latitude,
                      posicionActual!.longitude,
                    )
                  : centroInicial,
              initialZoom:
                  posicionActual != null ? 14 : 11,
              maxZoom: 18,
            ),
        children: [
            TileLayer(
            urlTemplate:
                'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.gota_mobile',
            ),

          MarkerLayer(
            markers: cafesConUbicacion.map((cafe) {
              return Marker(
                point: LatLng(
                  cafe.latitude!,
                  cafe.longitude!,
                ),
                width: 46,
                height: 46,
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      builder: (sheetContext) {
                        final rating =
                            double.tryParse(cafe.rating) ?? 0;

                        return SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              4,
                              20,
                              24,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  child: NetworkImageCard(
                                    imageUrl: cafe.foto,
                                    width: double.infinity,
                                    height: 180,
                                    borderRadius: 20,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        cafe.nombre,
                                        maxLines: 2,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight:
                                                  FontWeight.w800,
                                            ),
                                      ),
                                    ),

                                    if (rating > 0) ...[
                                      const SizedBox(width: 12),
                                      RatingBadge(
                                        rating: cafe.rating,
                                      ),
                                    ],
                                  ],
                                ),

                                const SizedBox(height: 9),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        cafe.zona,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: () {
                                      Navigator.pop(sheetContext);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              CafeDetailScreen(
                                            cafeId: cafe.id!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Ver cafetería',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF172C6D),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .18),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        'assets/icons/rating_cup.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}