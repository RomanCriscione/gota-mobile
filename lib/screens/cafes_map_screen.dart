import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/cafe.dart';

class CafesMapScreen extends StatelessWidget {
  final List<Cafe> cafes;

  const CafesMapScreen({
    super.key,
    required this.cafes,
  });

  @override
  Widget build(BuildContext context) {
    for (final cafe in cafes) {
        if (cafe.latitude == null ||
            cafe.longitude == null ||
            !cafe.latitude!.isFinite ||
            !cafe.longitude!.isFinite) {
            print(
            'COORDENADAS INVALIDAS: ${cafe.nombre} '
            '(${cafe.latitude}, ${cafe.longitude})',
            );
        }
        }

        final cafesConUbicacion = cafes.where((cafe) {
        return cafe.latitude != null &&
            cafe.longitude != null &&
            cafe.latitude!.isFinite &&
            cafe.longitude!.isFinite;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa (${cafesConUbicacion.length})',
        ),
      ),
        body: FlutterMap(
        options: MapOptions(
            initialCenter: const LatLng(
            -34.6037,
            -58.3816,
            ),
            initialZoom: 11,
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
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                cafe.nombre,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(cafe.zona),

                              const SizedBox(height: 8),

                              Text(
                                '⭐ ${cafe.rating}',
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Icon(
                    Icons.location_on,
                    size: 40,
                    color: Colors.red,
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