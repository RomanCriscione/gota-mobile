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

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool espacioReducido =
            constraints.maxWidth < 180;

        return Container(
          constraints: const BoxConstraints(
            minHeight: 76,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
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
          child: espacioReducido
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIcon(theme),

                    const SizedBox(height: 7),

                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    _buildIcon(theme),

                    const SizedBox(width: 10),

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
      },
    );
  }

  Widget _buildIcon(ThemeData theme) {
    return Container(
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
    );
  }
}