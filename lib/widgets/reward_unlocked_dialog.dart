import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<void> mostrarBeneficiosDesbloqueados(
  BuildContext context,
  List<dynamic> rewards,
) async {
  if (rewards.isEmpty) return;

  final firstReward = rewards.first;

  if (firstReward is! Map) return;

  final rewardText =
      firstReward['reward_text']?.toString() ??
      'Desbloqueaste un nuevo beneficio.';

  final cafeName =
      firstReward['cafe_name']?.toString() ?? '';

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/rating_cup.svg',
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                '¡Desbloqueaste un beneficio!',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              rewardText,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (cafeName.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(cafeName),
            ],
            if (rewards.length > 1) ...[
              const SizedBox(height: 12),
              Text(
                'Además desbloqueaste ${rewards.length - 1} beneficio${rewards.length == 2 ? '' : 's'} más.',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Genial'),
          ),
        ],
      );
    },
  );
}