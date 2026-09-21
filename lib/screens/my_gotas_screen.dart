import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/api_service.dart';

class MyGotasScreen extends StatefulWidget {
  const MyGotasScreen({super.key});

  @override
  State<MyGotasScreen> createState() => _MyGotasScreenState();
}

class _MyGotasScreenState extends State<MyGotasScreen> {
  late Future<Map<String, dynamic>> _futureGotas;

  @override
  void initState() {
    super.initState();
    _futureGotas = ApiService.obtenerMisGotas();
  }

  Future<void> _recargar() async {
    setState(() {
      _futureGotas = ApiService.obtenerMisGotas();
    });

    await _futureGotas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gotas'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureGotas,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No pudimos cargar tus Gotas.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _recargar,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;

          final balance =
              int.tryParse(
                data['balance']?.toString() ?? '0',
              ) ??
              0;

            final couponsData =
                data['available_coupons'];

            final List<dynamic> coupons =
              couponsData is List
                  ? couponsData
                  : <dynamic>[];

          final pendingUnlocksData =
              data['pending_unlocks'];

          final List<dynamic> pendingUnlocks =
              pendingUnlocksData is List
                  ? pendingUnlocksData
                  : <dynamic>[];

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Tus Gotas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4B5563),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '$balance',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Gotas acumuladas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 28),

                if (pendingUnlocks.isNotEmpty) ...[
                  const Text(
                    'Tenés un beneficio para elegir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Alcanzaste un nuevo hito de Gotas. Elegí el beneficio que más te guste.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  ...pendingUnlocks.map((unlock) {
                    final item =
                        Map<String, dynamic>.from(unlock as Map);

                    final unlockId =
                        int.tryParse(item['id']?.toString() ?? '');

                    final pointsRequired =
                        int.tryParse(
                          item['points_required']?.toString() ?? '',
                        );

                    if (unlockId == null) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (pointsRequired != null)
                              Text(
                                'Llegaste a $pointsRequired Gotas',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RewardUnlockOptionsScreen(
                                        unlockId: unlockId,
                                        pointsRequired: pointsRequired,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Elegir beneficio',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  ],

                const Text(
                'Tus beneficios',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                ),
                ),

                const SizedBox(height: 12),

                if (coupons.isEmpty)
                const Text(
                    'Todavía no tenés beneficios disponibles.',
                    style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    ),
                )
                else
                ...coupons.map((coupon) {
                    final item =
                        Map<String, dynamic>.from(coupon as Map);

                    final cafe =
                        item['cafe'] is Map
                            ? Map<String, dynamic>.from(
                                item['cafe'] as Map,
                            )
                            : <String, dynamic>{};

                    final rewardText =
                        item['reward_text']?.toString() ??
                        'Beneficio';

                    final cafeName =
                        cafe['name']?.toString() ?? '';

                    final code =
                        item['code']?.toString() ?? '';

                    return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (_) => RewardDetailScreen(
                                    rewardText: rewardText,
                                    cafeName: cafeName,
                                    code: code,
                                    terms: item['terms']?.toString() ?? '',
                                    expiresAt:
                                        item['expires_at']?.toString() ?? '',
                                    qrToken:
                                        item['qr_token']?.toString() ?? '',
                                ),
                                ),
                            );
                            },
                            child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                            Text(
                            rewardText,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                            ),
                            ),
                            if (cafeName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(cafeName),
                            ],
                            if (code.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                                'Código: $code',
                                style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                ),
                            ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RewardUnlockOptionsScreen extends StatefulWidget {
  final int unlockId;
  final int? pointsRequired;

  const RewardUnlockOptionsScreen({
    super.key,
    required this.unlockId,
    this.pointsRequired,
  });

  @override
  State<RewardUnlockOptionsScreen> createState() =>
      _RewardUnlockOptionsScreenState();
}

class _RewardUnlockOptionsScreenState
    extends State<RewardUnlockOptionsScreen> {
  late Future<Map<String, dynamic>> _futureOptions;

  @override
  void initState() {
    super.initState();
    _futureOptions =
        ApiService.obtenerOpcionesRewardUnlock(
      unlockId: widget.unlockId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegí tu beneficio'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureOptions,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No pudimos cargar los beneficios.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data!;

          final rewardsData = data['rewards'];

          final List<dynamic> rewards =
              rewardsData is List
                  ? rewardsData
                  : <dynamic>[];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.pointsRequired != null) ...[
                Text(
                  'Llegaste a ${widget.pointsRequired} Gotas',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (rewards.isEmpty) ...[
                const Text(
                  'No encontramos beneficios cerca por ahora.',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Podés explorar beneficios disponibles en otra localidad.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                ...rewards.map((reward) {
                  final item =
                      Map<String, dynamic>.from(
                    reward as Map,
                  );

                  final rewardId =
                      int.tryParse(
                    item['reward_id']?.toString() ?? '',
                  );

                  final rewardText =
                      item['reward_text']?.toString() ??
                      'Beneficio';

                  final cafeName =
                      item['cafe_name']?.toString() ?? '';

                  final distance =
                      item['distance_km'];

                  return Card(
                    margin:
                        const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            rewardText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (cafeName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(cafeName),
                          ],
                          if (distance != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              '$distance km',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                          if (rewardId != null) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () async {
                                  try {
                                    final response =
                                        await ApiService.elegirRewardUnlock(
                                      unlockId: widget.unlockId,
                                      rewardId: rewardId,
                                    );

                                    if (!context.mounted) {
                                      return;
                                    }

                                    final couponData = response['coupon'];

                                    if (couponData is! Map) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'El beneficio se eligió, pero no pudimos cargar el cupón.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final coupon =
                                        Map<String, dynamic>.from(couponData);

                                    final cafe =
                                        coupon['cafe'] is Map
                                            ? Map<String, dynamic>.from(
                                                coupon['cafe'] as Map,
                                              )
                                            : <String, dynamic>{};

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RewardDetailScreen(
                                          rewardText:
                                              coupon['reward_text']?.toString() ??
                                              'Beneficio',
                                          cafeName:
                                              cafe['name']?.toString() ?? '',
                                          code:
                                              coupon['code']?.toString() ?? '',
                                          terms:
                                              coupon['terms']?.toString() ?? '',
                                          expiresAt:
                                              coupon['expires_at']?.toString() ?? '',
                                          qrToken:
                                              coupon['qr_token']?.toString() ?? '',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) {
                                      return;
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No pudimos elegir el beneficio.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Elegir este beneficio',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
],

const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  child: OutlinedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RewardUnlockLocationsScreen(
            unlockId: widget.unlockId,
            pointsRequired: widget.pointsRequired,
          ),
        ),
      );
    },
    child: const Text(
      'Explorar otra localidad',
    ),
  ),
),
            ],
          );
        },
      ),
    );
  }
}

class RewardUnlockLocationsScreen extends StatefulWidget {
  final int unlockId;
  final int? pointsRequired;

  const RewardUnlockLocationsScreen({
    super.key,
    required this.unlockId,
    this.pointsRequired,
  });

  @override
  State<RewardUnlockLocationsScreen> createState() =>
      _RewardUnlockLocationsScreenState();
}

class _RewardUnlockLocationsScreenState
    extends State<RewardUnlockLocationsScreen> {
  late Future<Map<String, dynamic>> _futureLocations;

  @override
  void initState() {
    super.initState();
    _futureLocations =
        ApiService.obtenerLocalidadesRewardUnlock(
      unlockId: widget.unlockId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegí una localidad'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureLocations,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No pudimos cargar las localidades.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final locationsData = data['locations'];

          final List<dynamic> locations =
              locationsData is List
                  ? locationsData
                  : <dynamic>[];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.pointsRequired != null) ...[
                Text(
                  'Beneficio de ${widget.pointsRequired} Gotas',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (locations.isEmpty)
                const Text(
                  'No hay localidades con beneficios disponibles por ahora.',
                )
              else
                ...locations.map((location) {
                  final item =
                      Map<String, dynamic>.from(location as Map);

                  final locationName =
                      item['name']?.toString() ?? '';

                  final rewardsCount =
                      int.tryParse(
                        item['rewards_count']?.toString() ?? '',
                      ) ??
                      0;

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ListTile(
                      title: Text(locationName),
                      subtitle: Text(
                        rewardsCount == 1
                            ? '1 beneficio disponible'
                            : '$rewardsCount beneficios disponibles',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RewardUnlockLocationOptionsScreen(
                              unlockId: widget.unlockId,
                              pointsRequired: widget.pointsRequired,
                              location: locationName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class RewardUnlockLocationOptionsScreen extends StatefulWidget {
  final int unlockId;
  final int? pointsRequired;
  final String location;

  const RewardUnlockLocationOptionsScreen({
    super.key,
    required this.unlockId,
    required this.location,
    this.pointsRequired,
  });

  @override
  State<RewardUnlockLocationOptionsScreen> createState() =>
      _RewardUnlockLocationOptionsScreenState();
}

class _RewardUnlockLocationOptionsScreenState
    extends State<RewardUnlockLocationOptionsScreen> {
  late Future<Map<String, dynamic>> _futureOptions;

  @override
  void initState() {
    super.initState();

    _futureOptions =
        ApiService.obtenerOpcionesRewardUnlockPorLocalidad(
      unlockId: widget.unlockId,
      location: widget.location,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureOptions,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No pudimos cargar los beneficios.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final rewardsData = data['rewards'];

          final List<dynamic> rewards =
              rewardsData is List
                  ? rewardsData
                  : <dynamic>[];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.pointsRequired != null) ...[
                Text(
                  'Beneficio de ${widget.pointsRequired} Gotas',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (rewards.isEmpty)
                const Text(
                  'No hay beneficios disponibles en esta localidad por ahora.',
                )
              else
                ...rewards.map((reward) {
                  final item =
                      Map<String, dynamic>.from(
                    reward as Map,
                  );

                  final rewardId =
                      int.tryParse(
                    item['reward_id']?.toString() ?? '',
                  );

                  final rewardText =
                      item['reward_text']?.toString() ??
                      'Beneficio';

                  final cafeName =
                      item['cafe_name']?.toString() ?? '';

                  final terms =
                      item['terms']?.toString() ?? '';

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            rewardText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (cafeName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(cafeName),
                          ],
                          if (terms.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              terms,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                          if (rewardId != null) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () async {
                                  try {
                                    final response =
                                        await ApiService.elegirRewardUnlock(
                                      unlockId: widget.unlockId,
                                      rewardId: rewardId,
                                      location: widget.location,
                                    );

                                    if (!context.mounted) {
                                      return;
                                    }

                                    final couponData = response['coupon'];

                                    if (couponData is! Map) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'El beneficio se eligió, pero no pudimos cargar el cupón.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final coupon =
                                        Map<String, dynamic>.from(couponData);

                                    final cafe =
                                        coupon['cafe'] is Map
                                            ? Map<String, dynamic>.from(
                                                coupon['cafe'] as Map,
                                              )
                                            : <String, dynamic>{};

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RewardDetailScreen(
                                          rewardText:
                                              coupon['reward_text']?.toString() ??
                                              'Beneficio',
                                          cafeName:
                                              cafe['name']?.toString() ?? '',
                                          code:
                                              coupon['code']?.toString() ?? '',
                                          terms:
                                              coupon['terms']?.toString() ?? '',
                                          expiresAt:
                                              coupon['expires_at']?.toString() ?? '',
                                          qrToken:
                                              coupon['qr_token']?.toString() ?? '',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) {
                                      return;
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No pudimos elegir el beneficio.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Elegir este beneficio',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class RewardDetailScreen extends StatelessWidget {
  final String rewardText;
  final String cafeName;
  final String code;
  final String terms;
  final String expiresAt;
  final String qrToken;

  const RewardDetailScreen({
    super.key,
    required this.rewardText,
    required this.cafeName,
    required this.code,
    required this.terms,
    required this.expiresAt,
    required this.qrToken,
  });

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
        return value;
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            rewardText,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            cafeName,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4B5563),
            ),
          ),

          const SizedBox(height: 12),

            Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
            ),
            decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
                'Disponible',
                style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172C6D),
                ),
            ),
            ),

            const SizedBox(height: 20),

          if (qrToken.isNotEmpty) ...[
            Center(
                child: QrImageView(
                data: qrToken,
                version: QrVersions.auto,
                size: 220,
                ),
            ),
            const SizedBox(height: 24),
            ],

          const Text(
            'Código',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            code,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (expiresAt.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Vence: ${_formatDate(expiresAt)}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],

          if (terms.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Condiciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(terms),
          ],
        ],
      ),
    );
  }
}