import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'cafe_detail_screen.dart';
import '../widgets/network_image_card.dart';
import '../widgets/rating_badge.dart';

import '../models/cafe.dart';

class CafesMapScreen extends StatelessWidget {
  final List<Cafe> cafes;

  const CafesMapScreen({
    super.key,
    required this.cafes,
  });

  @override
  Widget build(BuildContext context) {
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
          initialCenter: cafesConUbicacion.isNotEmpty
              ? LatLng(
                  cafesConUbicacion.first.latitude!,
                  cafesConUbicacion.first.longitude!,
                )
              : const LatLng(
                  -34.6037,
                  -58.3816,
                ),
          initialZoom:
              cafesConUbicacion.isNotEmpty ? 12 : 11,
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
                    child: const Icon(
                      Icons.local_cafe_outlined,
                      size: 21,
                      color: Colors.white,
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