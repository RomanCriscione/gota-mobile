import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'primary_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onPressed;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/rating_cup.svg',
              ),
            ),

            const SizedBox(height: 24),

            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),

            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 28),

              PrimaryButton(
                text: buttonText!,
                onPressed: onPressed,
                ),
            ],
          ],
        ),
      ),
    );
  }
}