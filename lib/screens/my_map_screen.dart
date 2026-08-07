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
          heroImageUrl: relacion.cafePhoto,
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

          if (relaciones.isEmpty) {
            return RefreshIndicator(
              onRefresh: recargarMapa,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 90),

                  Center(
                    child: Container(
                      width: 86,
                      height: 86,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/rating_cup.svg',
                        width: 48,
                        height: 48,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Todavía no empezaste tu recorrido',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Guardá cafeterías para volver a encontrarlas cuando quieras.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 26),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/cafes',
                        );
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/rating_cup.svg',
                        width: 20,
                        height: 20,
                      ),
                      label: const Text(
                        'Explorar cafeterías',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

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
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/rating_cup.svg',
                          width: 25,
                          height: 25,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          'Mi recorrido cafetero',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
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

            const SizedBox(height: 44),

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
                  titulo: 'Quiero ir',
                  icono: Icons.bookmark_add_rounded,
                  colorIcono: const Color(0xFFEA580C),
                  estado: '☕ Quiero ir',
                  relaciones: filtrar(quieroIr),
                  colorFondo:
                      const Color(0xFFFFF7ED),
                  colorTexto: Colors.brown,
                  onTap: abrirCafe,
                ),

                const SizedBox(height: 44),

                _SeccionMapa(
                  titulo: 'Quiero volver',
                  icono: Icons.favorite,
                  colorIcono: const Color(0xFFE11D48),
                  estado: '❤️ Quiero volver',
                  relaciones: filtrar(quieroVolver),
                  colorFondo:
                      const Color(0xFFFFF1F2),
                  colorTexto: Colors.red,
                  onTap: abrirCafe,
                ),

                const SizedBox(height: 44),

                _SeccionMapa(
                  titulo: 'Ya fui',
                  icono: Icons.check_circle,
                  colorIcono: const Color(0xFF16A34A),
                  estado: '✔️ Ya fui',
                  relaciones: filtrar(yaFui),
                  colorFondo:
                      const Color(0xFFF0FDF4),
                  colorTexto: Colors.green,
                  onTap: abrirCafe,
                ),

                const SizedBox(height: 44),
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
  final IconData icono;
  final Color colorIcono;
  final String estado;
  final List<CafeRelationship> relaciones;
  final Color colorFondo;
  final Color colorTexto;
  final ValueChanged<CafeRelationship> onTap;

  const _SeccionMapa({
    required this.titulo,
    required this.icono,
    required this.colorIcono,
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
        _TituloSeccion(
          titulo: titulo,
          cantidad: relaciones.length,
          icono: icono,
          color: colorIcono,
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

        ...relaciones.asMap().entries.map(
          (entry) {
            final relacion = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                top: entry.key == 0 ? 18 : 0,
              ),
              child: _CafeMapaCard(
                relacion: relacion,
                estado: estado,
                colorFondo: colorFondo,
                colorTexto: colorTexto,
                onTap: () {
                  onTap(relacion);
                },
              ),
            );
          },
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
        bottom: 16,
      ),
      elevation: 2,
      shadowColor: Colors.black.withValues(
        alpha: .05,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFFF1F5F9),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: const Color(0xFF1E3A8A).withValues(
          alpha: .08,
        ),
        highlightColor: const Color(0xFF1E3A8A).withValues(
          alpha: .03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 185,
                child: Hero(
                  tag: 'cafe-${relacion.cafeId}',
                  child: Image.network(
                    relacion.cafePhoto,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    color: const Color(0xFFF3F4F6),
                    child: Center(
                      child: Opacity(
                        opacity: 0.35,
                        child: SvgPicture.asset(
                          'assets/icons/rating_cup.svg',
                          width: 56,
                          height: 56,
                        ),
                      ),
                      
                    ),
                  );
                },
              ),
            ),
            ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                15,
                12,
                16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          relacion.cafeName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 19,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Padding(
                        padding: EdgeInsets.only(
                          top: 1,
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 24,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  Row(
                    children: [
                      if (tieneRating) ...[
                        SvgPicture.asset(
                          'assets/icons/rating_cup.svg',
                          width: 17,
                          height: 17,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          relacion.averageRating,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF172C6D),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: Colors.black38,
                            ),
                          ),
                        ),
                      ],

                      Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.black45,
              ),

              const SizedBox(width: 4),

              Expanded(
                child: Text(
                  relacion.cafeLocation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
                    ],
                  ),

                  const SizedBox(height: 13),

                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _Etiqueta(
                        texto: estado,
                        colorFondo: colorFondo,
                        colorTexto: colorTexto,
                      ),

                      if (relacion.collection != null &&
                          relacion.collection!
                              .trim()
                              .isNotEmpty)
                        _Etiqueta(
                          texto: relacion.collection!,
                          colorFondo:
                              const Color(0xFFEFF6FF),
                          colorTexto:
                              const Color(0xFF1E3A8A),
                        ),
                    ],
                  ),

                  if (relacion.privateNote != null &&
                      relacion.privateNote!
                          .trim()
                          .isNotEmpty) ...[
                    const SizedBox(height: 13),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.edit_note_rounded,
                            size: 18,
                            color: Colors.black45,
                          ),

                          const SizedBox(width: 7),

                          Expanded(
                            child: Text(
                              relacion.privateNote!,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                fontStyle:
                                    FontStyle.italic,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
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

class _TituloSeccion extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String titulo;
  final int cantidad;

  const _TituloSeccion({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.cantidad,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: .10,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icono,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              '$titulo ($cantidad)',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
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