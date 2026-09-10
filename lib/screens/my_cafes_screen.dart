import 'package:flutter/material.dart';

import '../models/cafe.dart';
import '../services/cafe_service.dart';
import 'cafe_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'create_cafe_screen.dart';
import 'redeem_coupon_screen.dart';

class MyCafesScreen extends StatefulWidget {
  const MyCafesScreen({super.key});

  @override
  State<MyCafesScreen> createState() =>
      _MyCafesScreenState();
}

class _MyCafesScreenState
    extends State<MyCafesScreen> {
  late Future<List<Cafe>> cafesFuture;

  @override
  void initState() {
    super.initState();
    cafesFuture = cargarCafeterias();
  }

  Future<List<Cafe>> cargarCafeterias() async {
    final data =
        await CafeService.obtenerMisCafeterias();

    return data
        .map(
          (item) => Cafe.fromJson(item),
        )
        .toList();
  }

  void abrirGestionCafe(Cafe cafe) {
    if (cafe.id == null) {
        return;
    }

    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (bottomSheetContext) {
        return SafeArea(
            child: Padding(
            padding: const EdgeInsets.fromLTRB(
                16,
                4,
                16,
                20,
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                ListTile(
                    leading: const Icon(
                    Icons.visibility_outlined,
                    ),
                    title: const Text(
                    'Ver cafetería',
                    ),
                    onTap: () {
                    Navigator.pop(
                        bottomSheetContext,
                    );

                    Navigator.of(context).push(
                        MaterialPageRoute(
                        builder: (_) =>
                            CafeDetailScreen(
                            cafeId: cafe.id!,
                        ),
                        ),
                    );
                    },
                ),

                ListTile(
                    leading: const Icon(
                        Icons.edit_outlined,
                    ),
                    title: const Text(
                        'Editar cafetería',
                    ),
                    onTap: () async {
                        Navigator.pop(
                        bottomSheetContext,
                        );

                        final actualizado =
                            await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                            builder: (_) => CreateCafeScreen(
                            cafe: cafe,
                            ),
                        ),
                        );

                        if (actualizado == true && mounted) {
                        setState(() {
                            cafesFuture = cargarCafeterias();
                        });
                        }
                    },
                    ),

                ListTile(
                    leading: const Icon(
                    Icons.delete_outline,
                    ),
                    title: const Text(
                    'Eliminar cafetería',
                    ),
                    onTap: () async {
                    Navigator.pop(
                        bottomSheetContext,
                    );

                    final url = Uri.parse(
                        'https://gogota.ar/reviews/cafes/${cafe.id}/eliminar/',
                    );

                    await launchUrl(
                        url,
                        mode:
                            LaunchMode.externalApplication,
                    );
                    },
                ),
                ],
            ),
            ),
        );
        },
    );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Mis cafeterías',
        ),
        actions: [
            Padding(
                padding: const EdgeInsets.only(
                right: 8,
                ),
                child: TextButton.icon(
                onPressed: () {
                    Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            const RedeemCouponScreen(),
                    ),
                    );
                },
                icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                ),
                label: const Text(
                    'Canjear',
                ),
                ),
            ),
            ],
        ),
      body: FutureBuilder<List<Cafe>>(
        future: cafesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

         if (snapshot.hasError) {
            return const Center(
                child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                    'No pudimos cargar tus cafeterías.',
                    textAlign: TextAlign.center,
                ),
                ),
            );
            }

          final cafes =
              snapshot.data ?? [];

          if (cafes.isEmpty) {
            return const Center(
              child: Padding(
                padding:
                    EdgeInsets.all(24),
                child: Text(
                  'Todavía no tenés cafeterías en Gota.',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding:
                const EdgeInsets.all(16),
            itemCount: cafes.length,
            separatorBuilder:
                (_, _) =>
                    const SizedBox(
                    height: 12,
                    ),
            itemBuilder: (
              context,
              index,
            ) {
              final cafe = cafes[index];

              return Card(
                child: ListTile(
                    title: Text(
                    cafe.nombre,
                    ),
                    subtitle: Text(
                    cafe.zona,
                    ),
                    trailing: const Icon(
                    Icons.chevron_right,
                    ),
                    onTap: () {
                        abrirGestionCafe(cafe);
                        },
                ),
                );
            },
          );
        },
      ),
    );
  }
}