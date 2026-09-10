import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/api_service.dart';

class RedeemCouponScreen extends StatefulWidget {
  const RedeemCouponScreen({super.key});

  @override
  State<RedeemCouponScreen> createState() =>
      _RedeemCouponScreenState();
}

class _RedeemCouponScreenState
    extends State<RedeemCouponScreen> {
  bool procesando = false;

  Future<void> procesarCodigo(String qrToken) async {
    if (procesando) return; 

    setState(() {
      procesando = true;
    });

    try {
      final resultado =
          await ApiService.canjearBeneficio(
        qrToken: qrToken,
      );

      if (!mounted) return;

      await mostrarResultadoCanje(resultado);

    } catch (e) {
      if (!mounted) return;

      setState(() {
        procesando = false;
      });

      final message = e
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  Future<void> mostrarResultadoCanje(
    Map<String, dynamic> resultado,
    ) async {
    if (!mounted) return;

    final coupon =
        resultado['coupon'] as Map<String, dynamic>?;

    final rewardText =
        coupon?['reward_text']?.toString() ??
            'Beneficio canjeado correctamente.';

    final cafeData =
        coupon?['cafe'] as Map<String, dynamic>?;

    final cafeName =
        cafeData?['name']?.toString() ?? '';

    await showDialog<void>(
        context: context,
        builder: (dialogContext) {
        return AlertDialog(
            title: const Text(
            'Beneficio canjeado',
            ),
            content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
                Text(
                rewardText,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                ),
                ),
                if (cafeName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(cafeName),
                ],
            ],
            ),
            actions: [
            TextButton(
                onPressed: () {
                Navigator.pop(dialogContext);
                },
                child: const Text('Listo'),
            ),
            ],
        );
        },
    );

    if (!mounted) return;

    Navigator.pop(context, true);
    }

  Future<void> ingresarCodigoManual() async {
    final controller = TextEditingController();

    final code = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
        return AlertDialog(
            title: const Text(
            'Ingresar código',
            ),
            content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization:
                TextCapitalization.characters,
            decoration: const InputDecoration(
                labelText: 'Código del beneficio',
                hintText: 'GOTA-XXXXXX',
                border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
                final code = value.trim();

                if (code.isNotEmpty) {
                Navigator.pop(
                    dialogContext,
                    code,
                );
                }
            },
            ),
            actions: [
            TextButton(
                onPressed: () {
                Navigator.pop(dialogContext);
                },
                child: const Text('Cancelar'),
            ),
            FilledButton(
                onPressed: () {
                final code =
                    controller.text.trim();

                if (code.isNotEmpty) {
                    Navigator.pop(
                    dialogContext,
                    code,
                    );
                }
                },
                child: const Text('Validar'),
            ),
            ],
        );
        },
    );

    controller.dispose();

    if (code == null || code.isEmpty) {
        return;
    }

    await procesarCodigoManual(code);
    }

    Future<void> procesarCodigoManual(
    String code,
    ) async {
    if (procesando) return;

    setState(() {
        procesando = true;
    });

    try {
        final resultado =
            await ApiService.canjearBeneficio(
        code: code,
        );

        await mostrarResultadoCanje(resultado);
    } catch (e) {
        if (!mounted) return;

        setState(() {
        procesando = false;
        });

        final message = e
            .toString()
            .replaceFirst('Exception: ', '');

        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
        ),
        );
    }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Canjear beneficio',
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (procesando) return;

              final barcodes =
                  capture.barcodes;

              if (barcodes.isEmpty) return;

              final rawValue =
                  barcodes.first.rawValue;

              if (rawValue == null ||
                  rawValue.trim().isEmpty) {
                return;
              }

              procesarCodigo(
                rawValue.trim(),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.black54,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Text(
                    procesando
                        ? 'Validando beneficio...'
                        : 'Apuntá la cámara al QR del beneficio.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    ),
                ),
                if (!procesando) ...[
                    const SizedBox(height: 12),
                    const Text(
                        'o',
                        style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                        onPressed: ingresarCodigoManual,
                        icon: const Icon(
                        Icons.keyboard_outlined,
                        color: Colors.white,
                        ),
                        label: const Text(
                        'Ingresar código',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                        ),
                        ),
                        style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Colors.white,
                        ),
                        ),
                    ),
                    ],
                ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}