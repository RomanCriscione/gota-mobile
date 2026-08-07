import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class FeatureCard extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? svgAsset;

  const FeatureCard({
    super.key,
    required this.label,
    this.icon,
    this.svgAsset,
  }) : assert(
          icon != null || svgAsset != null,
          'FeatureCard necesita un icon o un svgAsset.',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(
        minHeight: 70,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
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
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(
                alpha: 0.55,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: svgAsset != null
                ? SvgPicture.asset(
                    svgAsset!,
                    width: 21,
                    height: 21,
                  )
                : Icon(
                    icon,
                    size: 21,
                    color: theme.colorScheme.primary,
                  ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}