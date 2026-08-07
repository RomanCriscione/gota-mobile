import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/cafe.dart';
import 'network_image_card.dart';

class MiniCafeCard extends StatelessWidget {
  final Cafe cafe;
  final VoidCallback onTap;

  const MiniCafeCard({
    super.key,
    required this.cafe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rating = double.tryParse(cafe.rating) ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(
                alpha: 0.65,
              ),
            ),
          ),
          child: Row(
            children: [
              NetworkImageCard(
                imageUrl: cafe.foto,
                width: 86,
                height: 86,
                borderRadius: 14,
                heroTag: 'cafe-${cafe.id}',
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cafe.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            cafe.zona,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (rating > 0) ...[
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/rating_cup.svg',
                            width: 17,
                            height: 17,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            cafe.rating.replaceAll('.', ','),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF172C6D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                size: 25,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}