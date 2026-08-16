import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/review_service.dart';

class CreateReviewScreen extends StatefulWidget {
  final int cafeId;
  final String cafeName;

  const CreateReviewScreen({
    super.key,
    required this.cafeId,
    required this.cafeName,
  });

  @override
  State<CreateReviewScreen> createState() =>
      _CreateReviewScreenState();
}

class _CreateReviewScreenState
    extends State<CreateReviewScreen> {
  final comentarioController =
      TextEditingController();

  final precioController =
      TextEditingController();

  int rating = 0;
  String? bestForPlan;

  int pasoActual = 0;

  bool cargandoTags = true;
  List<Map<String, dynamic>> tags = [];
  final Set<int> tagsSeleccionados = {};

  final planes = const [
    {
        'value': 'trabajar',
        'label': '💻 Trabajar o estudiar',
    },
    {
        'value': 'al_paso',
        'label': '🚶 Tomar algo rápido',
    },
    {
        'value': 'amigos',
        'label': '💬 Charlar con amigos',
    },
    {
        'value': 'cita',
        'label': '❤️ Cita',
    },
    {
        'value': 'leer',
        'label': '📖 Leer o desconectar',
    },
    {
        'value': 'solo',
        'label': '☕ Salir solo',
    },
    ];

    @override
    void initState() {
    super.initState();

    cargarTags();
    }

    @override
    void dispose() {
    comentarioController.dispose();
    precioController.dispose();

    super.dispose();
  }

  Future<void> cargarTags() async {
    try {
        final resultado =
            await ReviewService.obtenerTags();

        if (!mounted) return;

        setState(() {
        tags = resultado;
        cargandoTags = false;
        });
    } catch (_) {
        if (!mounted) return;

        setState(() {
        cargandoTags = false;
        });

        mostrarError(
        'No pudimos cargar las etiquetas.',
        );
    }
    }

  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  void continuar() {
    if (rating < 1 || rating > 5) {
      mostrarError(
        'Elegí una calificación entre 1 y 5.',
      );
      return;
    }

    if (bestForPlan == null) {
      mostrarError(
        'Elegí para qué plan recomendarías este café.',
      );
      return;
    }

    final precioTexto =
        precioController.text.trim();

    if (precioTexto.isNotEmpty) {
      final precio =
          int.tryParse(precioTexto);

      if (precio == null ||
          precio < 1000 ||
          precio > 15000) {
        mostrarError(
          'El precio del capuccino debe estar entre \$1.000 y \$15.000.',
        );
        return;
      }
    }

    setState(() {
        pasoActual = 1;
    });
  }

  Widget _buildPasoExperiencia() {
    return ListView(
        padding: const EdgeInsets.fromLTRB(
        24,
        20,
        24,
        32,
        ),
        children: [
        Text(
            widget.cafeName,
            style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
            ),
        ),

        const SizedBox(height: 8),

        const Text(
            '¿Cómo fue tu experiencia?',
            style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
            ),
        ),

        const SizedBox(height: 8),

        const Text(
            'Tu experiencia puede ayudar a otra persona a encontrar un café que vaya con ella.',
            style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Colors.black54,
            ),
        ),

        const SizedBox(height: 28),

        const Text(
            'Tu calificación *',
            style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            ),
        ),

        const SizedBox(height: 12),

        Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: List.generate(
            5,
            (index) {
                final valor = index + 1;
                final seleccionado =
                    valor <= rating;

                return GestureDetector(
                onTap: () {
                    setState(() {
                    rating = valor;
                    });
                },
                child: AnimatedOpacity(
                    duration: const Duration(
                    milliseconds: 140,
                    ),
                    opacity:
                        seleccionado ? 1 : 0.28,
                    child: SvgPicture.asset(
                    'assets/icons/rating_cup.svg',
                    width: 44,
                    height: 44,
                    ),
                ),
                );
            },
            ),
        ),

        if (rating > 0) ...[
            const SizedBox(height: 10),

            Center(
            child: Text(
                '$rating de 5',
                style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172C6D),
                ),
            ),
            ),
        ],

        const SizedBox(height: 28),

        TextField(
            controller: comentarioController,
            minLines: 3,
            maxLines: 5,
            maxLength: 600,
            textCapitalization:
                TextCapitalization.sentences,
            decoration:
                const InputDecoration(
            labelText: 'Contanos un poco más',
            hintText:
                '¿Qué te gustó? ¿Cómo fue estar ahí?',
            alignLabelWithHint: true,
            ),
        ),

        const SizedBox(height: 18),

        TextField(
            controller: precioController,
            keyboardType:
                TextInputType.number,
            decoration:
                const InputDecoration(
            labelText:
                'Precio del capuccino',
            hintText: 'Ej: 4500',
            prefixText: '\$ ',
            ),
        ),

        const SizedBox(height: 6),

        const Text(
            'Opcional · Capuccino mediano.',
            style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            ),
        ),

        const SizedBox(height: 28),

        const Text(
            'Si tuvieras que elegir una sola, ¿para qué plan es mejor este café? *',
            style: TextStyle(
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            ),
        ),

        const SizedBox(height: 14),

        ...planes.map(
            (plan) {
            final value =
                plan['value']!;
            final label =
                plan['label']!;

            final seleccionado =
                bestForPlan == value;

            return Padding(
                padding:
                    const EdgeInsets.only(
                bottom: 10,
                ),
                child: InkWell(
                borderRadius:
                    BorderRadius.circular(16),
                onTap: () {
                    setState(() {
                    bestForPlan = value;
                    });
                },
                child: AnimatedContainer(
                    duration:
                        const Duration(
                    milliseconds: 160,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                    ),
                    decoration: BoxDecoration(
                    color: seleccionado
                        ? const Color(
                            0xFFEFF6FF,
                            )
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                        16,
                    ),
                    border: Border.all(
                        color: seleccionado
                            ? const Color(
                                0xFF1E3A8A,
                            )
                            : const Color(
                                0xFFE5E7EB,
                            ),
                        width:
                            seleccionado
                                ? 1.5
                                : 1,
                    ),
                    ),
                    child: Row(
                    children: [
                        Expanded(
                        child: Text(
                            label,
                            style:
                                TextStyle(
                            fontSize: 15,
                            fontWeight:
                                seleccionado
                                    ? FontWeight
                                        .w700
                                    : FontWeight
                                        .w600,
                            color:
                                const Color(
                                0xFF111827,
                            ),
                            ),
                        ),
                        ),

                        if (seleccionado)
                        const Icon(
                            Icons
                                .check_circle_rounded,
                            color: Color(
                            0xFF1E3A8A,
                            ),
                        ),
                    ],
                    ),
                ),
                ),
            );
            },
        ),

        const SizedBox(height: 20),

        ElevatedButton(
            onPressed: continuar,
            child: const Text(
            'Continuar',
            ),
        ),
        ],
    );
    }

    Widget _buildPasoTags() {
        final grupos =
            <String, List<Map<String, dynamic>>>{};

        for (final tag in tags) {
        final grupo =
            tag['group']?.toString().trim() ?? '';

        if (grupo.isEmpty) {
            continue;
        }

        grupos.putIfAbsent(
            grupo,
            () => [],
        );

        grupos[grupo]!.add(tag);
        }

        final ordenCategorias = [
            'conexion',
            'refugio',
            'ritual',
            'inspiracion',
            ];

            final nombresCategorias = {
            'conexion': '🤝 Conexión',
            'refugio': '🫶 Refugio',
            'ritual': '☕ Ritual',
            'inspiracion': '✨ Inspiración',
            };

        return ListView(
            padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            32,
            ),
            children: [
            const Text(
                '¿Cómo describirías tu experiencia?',
                style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                ),
            ),

            const SizedBox(height: 8),

            const Text(
                'Elegí todas las frases que representen cómo se sintió estar ahí.',
                style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black54,
                ),
            ),

            const SizedBox(height: 24),

            if (cargandoTags)
                const Center(
                child: Padding(
                    padding: EdgeInsets.symmetric(
                    vertical: 40,
                    ),
                    child:
                        CircularProgressIndicator(),
                ),
                )
            else if (tags.isEmpty)
                const Text(
                'No encontramos etiquetas disponibles.',
                style: TextStyle(
                    color: Colors.black54,
                ),
                )
            else
                ...ordenCategorias.map(
                (categoria) {
                    final tagsCategoria =
                        grupos[categoria] ?? [];

                    if (tagsCategoria.isEmpty) {
                    return const SizedBox.shrink();
                    }

                    return Padding(
                    padding:
                        const EdgeInsets.only(
                        bottom: 26,
                    ),
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                        Text(
                            nombresCategorias[
                                categoria]!,
                            style:
                                const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w800,
                            color: Color(
                                0xFF111827,
                            ),
                            ),
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                tagsCategoria.map((tag) {
                            final id =
                                tag['id'] as int;

                            final nombre =
                                tag['name']
                                        ?.toString() ??
                                    '';

                            final seleccionado =
                                tagsSeleccionados
                                    .contains(id);

                            return FilterChip(
                                selected: seleccionado,
                                label: Text(nombre),
                                onSelected: (value) {
                                setState(() {
                                    if (value) {
                                    tagsSeleccionados
                                        .add(id);
                                    } else {
                                    tagsSeleccionados
                                        .remove(id);
                                    }
                                });
                                },
                            );
                            }).toList(),
                        ),
                        ],
                    ),
                    );
                },
                ),

            const SizedBox(height: 8),

            OutlinedButton(
                onPressed: () {
                setState(() {
                    pasoActual = 0;
                });
                },
                child: const Text(
                'Volver',
                ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
                onPressed: () {
                    setState(() {
                    pasoActual = 2;
                    });
                },
                child: const Text(
                    'Continuar',
                ),
                ),
            ],
        );
        }

Widget _buildPasoRevision() {
  final precioTexto =
      precioController.text.trim();

  final comentario =
      comentarioController.text.trim();

  final planSeleccionado =
      planes.firstWhere(
    (plan) => plan['value'] == bestForPlan,
  );

  final nombresTagsSeleccionados = tags
      .where(
        (tag) => tagsSeleccionados.contains(
          tag['id'],
        ),
      )
      .map(
        (tag) => tag['name']?.toString() ?? '',
      )
      .where(
        (nombre) => nombre.isNotEmpty,
      )
      .toList();

  return ListView(
    padding: const EdgeInsets.fromLTRB(
      24,
      20,
      24,
      32,
    ),
    children: [
      Text(
        widget.cafeName,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E3A8A),
        ),
      ),

      const SizedBox(height: 8),

      const Text(
        'Revisá tu reseña',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Color(0xFF111827),
        ),
      ),

      const SizedBox(height: 8),

      const Text(
        'Antes de publicarla, comprobá que represente bien tu experiencia.',
        style: TextStyle(
          fontSize: 15,
          height: 1.4,
          color: Colors.black54,
        ),
      ),

      const SizedBox(height: 28),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu calificación',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/rating_cup.svg',
                  width: 26,
                  height: 26,
                ),

                const SizedBox(width: 8),

                Text(
                  '$rating de 5',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172C6D),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Plan',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              planSeleccionado['label']!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            if (comentario.isNotEmpty) ...[
              const SizedBox(height: 20),

              const Text(
                'Tu comentario',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                comentario,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],

            if (precioTexto.isNotEmpty) ...[
              const SizedBox(height: 20),

              const Text(
                'Capuccino mediano',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                '\$$precioTexto',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),

      if (nombresTagsSeleccionados.isNotEmpty) ...[
        const SizedBox(height: 24),

        const Text(
          'Cómo describiste la experiencia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              nombresTagsSeleccionados.map(
            (nombre) {
              return Chip(
                label: Text(nombre),
              );
            },
          ).toList(),
        ),
      ],

      const SizedBox(height: 32),

      OutlinedButton(
        onPressed: () {
          setState(() {
            pasoActual = 1;
          });
        },
        child: const Text(
          'Volver',
        ),
      ),

      const SizedBox(height: 12),

      ElevatedButton(
        onPressed: () {
          // En el siguiente cambio
          // conectamos la publicación real.
        },
        child: const Text(
          'Publicar reseña',
        ),
      ),
    ],
  );
}

  @override
    Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text(
            'Dejar una reseña',
        ),
        ),
        body: SafeArea(
            child: pasoActual == 0
                ? _buildPasoExperiencia()
                : pasoActual == 1
                    ? _buildPasoTags()
                    : _buildPasoRevision(),
            ),
    );
  }
}