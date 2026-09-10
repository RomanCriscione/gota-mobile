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