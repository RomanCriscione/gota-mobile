import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/cafe_relationship.dart';
import '../services/api_service.dart';
import 'cafe_detail_screen.dart';

class MyMapScreen extends StatefulWidget {
  const MyMapScreen({super.key});

  @override
  State<MyMapScreen> createState() => _MyMapScreenState();
}

class _MyMapScreenState extends State<MyMapScreen> {
  late Future<List<CafeRelationship>> mapaFuture;

  String? filtroColeccion;

  @override
  void initState() {
    super.initState();

    mapaFuture = ApiService.obtenerMiMapa();
  }

  Future<void> recargarMapa() async {
    final nuevoFuture = ApiService.obtenerMiMapa();

    setState(() {
      mapaFuture = nuevoFuture;
    });

    await nuevoFuture;
  }

  Future<void> abrirCafe(
    CafeRelationship relacion,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CafeDetailScreen(
          cafeId: relacion.cafeId,
        ),
      ),
    );

    if (!mounted) return;

    await recargarMapa();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi mapa cafetero',
        ),
      ),
      body: FutureBuilder<List<CafeRelationship>>(
        future: mapaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorMapa(
              onRetry: recargarMapa,
            );
          }

          final relaciones =
              snapshot.data ?? <CafeRelationship>[];

          final quieroIr = relaciones
              .where(
                (relacion) =>
                    relacion.status == 'want_to_go',
              )
              .toList();

          final quieroVolver = relaciones
              .where(
                (relacion) =>
                    relacion.status == 'want_to_return',
              )
              .toList();

          final yaFui = relaciones
              .where(
                (relacion) =>
                    relacion.status == 'visited',
              )
              .toList();

          final colecciones = relaciones
              .where(
                (relacion) =>
                    relacion.collection != null &&
                    relacion.collection!.trim().isNotEmpty,
              )
              .map(
                (relacion) => relacion.collection!,
              )
              .toSet()
              .toList()
            ..sort();

          List<CafeRelationship> filtrar(
            List<CafeRelationship> lista,
          ) {
            if (filtroColeccion == null) {
              return lista;
            }

            return lista
                .where(
                  (relacion) =>
                      relacion.collection ==
                      filtroColeccion,
                )
                .toList();
          }

          return RefreshIndicator(
            onRefresh: recargarMapa,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '☕ Mi recorrido cafetero',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${relaciones.length} cafeterías guardadas',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: _ResumenCard(
                          icono: Icons.bookmark_add_rounded,
                          color: Color(0xFFEA580C),
                          cantidad: quieroIr.length,
                          titulo: 'Quiero ir',
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _ResumenCard(
                          icono: Icons.favorite,
                          color: Color(0xFFE11D48),
                          cantidad: quieroVolver.length,
                          titulo: 'Volver',
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _ResumenCard(
                          icono: Icons.check_circle,
                          color: Color(0xFF16A34A),
                          cantidad: yaFui.length,
                          titulo: 'Visitados',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _FiltrosMapa(
              colecciones: colecciones,
              relaciones: relaciones,
              filtroSeleccionado: filtroColeccion,
              onSeleccionar: (coleccion) {
                setState(() {
                  filtroColeccion = coleccion;
                });
              },
            ),
          ],
        ),

                _SeccionMapa(
                  titulo: '☕ Quiero ir',
                  estado: '☕ Quiero ir',
                  relaciones: filtrar(quieroIr),
                  colorFondo:
                      const Color(0xFFFFF7ED),
                  colorTexto: Colors.brown,
                  onTap: abrirCafe,
                ),

                const SizedBox(height: 24),

                _SeccionMapa(
                  titulo: '❤️ Quiero volver',
                  estado: '❤️ Quiero volver',
                  relaciones: filtrar(quieroVolver),
                  colorFondo:
                      const Color(0xFFFFF1F2),
                  colorTexto: Colors.red,
                  onTap: abrirCafe,
                ),

                const SizedBox(height: 24),

                _SeccionMapa(
                  titulo: '✔️ Ya fui',
                  estado: '✔️ Ya fui',
                  relaciones: filtrar(yaFui),
                  colorFondo:
                      const Color(0xFFF0FDF4),
                  colorTexto: Colors.green,
                  onTap: abrirCafe,
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FiltrosMapa extends StatelessWidget {
  final List<String> colecciones;
  final List<CafeRelationship> relaciones;
  final String? filtroSeleccionado;
  final ValueChanged<String?> onSeleccionar;

  const _FiltrosMapa({
    required this.colecciones,
    required this.relaciones,
    required this.filtroSeleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 24,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Organizá tu recorrido',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(
                    '☕ Todo mi recorrido '
                    '(${relaciones.length})',
                  ),
                  selected:
                      filtroSeleccionado == null,
                  onSelected: (_) {
                    onSeleccionar(null);
                  },
                ),

                ...colecciones.map(
                  (coleccion) {
                    final cantidad = relaciones
                        .where(
                          (relacion) =>
                              relacion.collection ==
                              coleccion,
                        )
                        .length;

                    return FilterChip(
                      label: Text(
                        '$coleccion ($cantidad)',
                      ),
                      selected:
                          filtroSeleccionado ==
                          coleccion,
                      onSelected: (_) {
                        onSeleccionar(coleccion);
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionMapa extends StatelessWidget {
  final String titulo;
  final String estado;
  final List<CafeRelationship> relaciones;
  final Color colorFondo;
  final Color colorTexto;
  final ValueChanged<CafeRelationship> onTap;

  const _SeccionMapa({
    required this.titulo,
    required this.estado,
    required this.relaciones,
    required this.colorFondo,
    required this.colorTexto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          '$titulo (${relaciones.length})',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        if (relaciones.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Text(
              'Todavía no guardaste cafeterías aquí.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

        ...relaciones.map(
          (relacion) => _CafeMapaCard(
            relacion: relacion,
            estado: estado,
            colorFondo: colorFondo,
            colorTexto: colorTexto,
            onTap: () {
              onTap(relacion);
            },
          ),
        ),
      ],
    );
  }
}

class _CafeMapaCard extends StatelessWidget {
  final CafeRelationship relacion;
  final String estado;
  final Color colorFondo;
  final Color colorTexto;
  final VoidCallback onTap;

  const _CafeMapaCard({
    required this.relacion,
    required this.estado,
    required this.colorFondo,
    required this.colorTexto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tieneRating =
        relacion.averageRating != '0.0' &&
        relacion.averageRating != 'null';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        minVerticalPadding: 12,
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            relacion.cafePhoto,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return Container(
                width: 100,
                height: 100,
                color: const Color(0xFFF3F4F6),
                child: Center(
                  child: Opacity(
                    opacity: 0.35,
                    child: SvgPicture.asset(
                      'assets/icons/rating_cup.svg',
                      width: 42,
                      height: 42,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              relacion.cafeName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            _Etiqueta(
              texto: estado,
              colorFondo: colorFondo,
              colorTexto: colorTexto,
            ),

            if (relacion.collection != null &&
                relacion.collection!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(height: 3),
              _Etiqueta(
                texto: relacion.collection!,
                colorFondo:
                    const Color(0xFFEFF6FF),
                colorTexto: Colors.blue,
              ),
            ],

            if (relacion.privateNote != null &&
                relacion.privateNote!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                '📝 ${relacion.privateNote}',
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(top: 6),
          child: Text(
            tieneRating
                ? '⭐ ${relacion.averageRating} · '
                    '${relacion.cafeLocation}'
                : relacion.cafeLocation,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  final Color colorFondo;
  final Color colorTexto;

  const _Etiqueta({
    required this.texto,
    required this.colorFondo,
    required this.colorTexto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 10,
          color: colorTexto,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final IconData icono;
  final Color color;
  final int cantidad;
  final String titulo;

  const _ResumenCard({
    required this.icono,
    required this.color,
    required this.cantidad,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icono,
            color: color,
            size: 26,
          ),

          const SizedBox(height: 10),

          Text(
            '$cantidad',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorMapa extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorMapa({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.black45,
            ),

            const SizedBox(height: 16),

            const Text(
              'No pudimos cargar tu mapa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Revisá tu conexión e intentá nuevamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: onRetry,
              child: const Text(
                'Reintentar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}