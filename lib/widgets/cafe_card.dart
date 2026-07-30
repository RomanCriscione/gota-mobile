import 'package:flutter/material.dart';

import '../models/cafe.dart';
import 'network_image_card.dart';
import 'rating_badge.dart';
import 'tag_chip.dart';

class CafeCard extends StatelessWidget {
  final Cafe cafe;

  const CafeCard({
    super.key,
    required this.cafe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final features = <String>[];

    if (cafe.cafeEspecialidad) {
      features.add('Café de especialidad');
    }

    if (cafe.brunch) {
      features.add('Brunch');
    }

    if (cafe.pasteleriaArtesanal) {
      features.add('Pastelería artesanal');
    }

    if (cafe.mesasAlAireLibre) {
      features.add('Mesas al aire libre');
    }

    if (cafe.petFriendly) {
      features.add('Pet friendly');
    }

    if (cafe.laptopFriendly) {
      features.add('Para trabajar');
    }

    if (cafe.espacioTranquilo) {
      features.add('Espacio tranquilo');
    }

    final visibleFeatures = features.take(3).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(
            alpha: .55,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              NetworkImageCard(
                imageUrl: cafe.foto,
                width: double.infinity,
                height: 190,
                borderRadius: 0,
                heroTag: 'cafe-${cafe.id}',
              ),
              if (double.tryParse(cafe.rating) != null &&
                double.parse(cafe.rating) > 0)
              Positioned(
                top: 14,
                right: 14,
                child: RatingBadge(
                  rating: cafe.rating,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cafe.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        cafe.zona,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                if (visibleFeatures.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: visibleFeatures
                      .map(
                        (feature) => TagChip(
                          label: feature,
                        ),
                      )
                      .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}