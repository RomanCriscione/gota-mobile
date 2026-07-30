import 'package:flutter/material.dart';

import 'loading_skeleton.dart';

class CafeCardSkeleton extends StatelessWidget {
  const CafeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(
                alpha: 0.12,
              ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoadingSkeleton(
            width: double.infinity,
            height: 190,
            borderRadius: BorderRadius.zero,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: LoadingSkeleton(
                        width: double.infinity,
                        height: 22,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    LoadingSkeleton(
                      width: 54,
                      height: 30,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LoadingSkeleton(
                  width: 130,
                  height: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    LoadingSkeleton(
                      width: 88,
                      height: 30,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    const SizedBox(width: 8),
                    LoadingSkeleton(
                      width: 105,
                      height: 30,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    const SizedBox(width: 8),
                    LoadingSkeleton(
                      width: 72,
                      height: 30,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}