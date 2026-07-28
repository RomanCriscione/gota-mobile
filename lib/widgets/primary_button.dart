import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: isLoading || onPressed == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onPressed!();
            },
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
                return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                    scale: Tween<double>(
                    begin: 0.92,
                    end: 1,
                    ).animate(animation),
                    child: child,
                ),
                );
            },
            child: isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                    ),
                    )
                : Row(
                    key: const ValueKey('content'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        if (icon != null) ...[
                        Icon(icon, size: 20),
                        const SizedBox(width: 8),
                        ],
                        Text(
                        text,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                        ),
                        ),
                    ],
                    ),
            ),
      ),
    );
  }
}