import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/cafe.dart';
import '../services/api_service.dart';
import 'cafe_detail_screen.dart';
import '../widgets/cafe_card.dart';
import '../widgets/animated_press.dart';
import '../widgets/animated_list_item.dart';
import '../widgets/cafe_card_skeleton.dart';

class NearbyCafesScreen extends StatefulWidget {
    const NearbyCafesScreen({super.key});

    @override
    State<NearbyCafesScreen> createState() => _NearbyCafesScreenState();
}

class _NearbyCafesScreenState extends State<NearbyCafesScreen> {
    String estado = 'Obteniendo ubicación...';
    bool cargando = true;
    bool permisoDenegadoPermanentemente = false;

    List<Cafe> cafesCercanos = [];
    List<Cafe> todosLosCafes = [];

    Position? posicionActual;

    double radioSeleccionado = 5;

    @override
    void initState() {
        super.initState();
        obtenerUbicacion();
    }

    Future<void> obtenerUbicacion() async {
        setState(() {
            cargando = true;
            estado = 'Obteniendo ubicación...';
            permisoDenegadoPermanentemente = false;
            });
        bool servicioHabilitado =
            await Geolocator.isLocationServiceEnabled();

        if (!servicioHabilitado) {
        setState(() {
            cargando = false;
            estado = 'Activá la ubicación del teléfono';
            });
        return;
        }

        LocationPermission permiso =
            await Geolocator.checkPermission();

        if (permiso == LocationPermission.denied) {
            permiso = await Geolocator.requestPermission();
        }

        if (permiso == LocationPermission.denied) {
        if (!mounted) return;

            setState(() {
                cargando = false;
                estado =
                    'Necesitamos acceso a tu ubicación para mostrarte cafeterías cercanas.';
            });

            return;
        }

        if (permiso == LocationPermission.deniedForever) {
            if (!mounted) return;

            setState(() {
                cargando = false;
                permisoDenegadoPermanentemente = true;
                estado =
                    'El permiso de ubicación está desactivado. Activálo desde los ajustes del teléfono.';
                });

            return;
        }

        try {
            final posicion =
                await Geolocator.getCurrentPosition();

            final cafes =
                await ApiService.obtenerCafes();

            final cafesConUbicacion = cafes
                .where(
                    (cafe) =>
                        cafe.latitude != null &&
                        cafe.longitude != null,
                )
                .toList();

            cafesConUbicacion.sort((a, b) {
                final distanciaA =
                    Geolocator.distanceBetween(
                posicion.latitude,
                posicion.longitude,
                a.latitude!,
                a.longitude!,
                );

                final distanciaB =
                    Geolocator.distanceBetween(
                posicion.latitude,
                posicion.longitude,
                b.latitude!,
                b.longitude!,
                );

                return distanciaA.compareTo(
                distanciaB,
                );
            });

            if (!mounted) return;

            setState(() {
                posicionActual = posicion;
                todosLosCafes = cafesConUbicacion;
                filtrarPorRadio();
                cargando = false;
                estado = '';
            });
            } catch (_) {
            if (!mounted) return;

            setState(() {
                cargando = false;
                estado =
                    'No pudimos obtener tu ubicación en este momento.';
            });

            }
    }

    void filtrarPorRadio() {
        if (posicionActual == null) return;

        cafesCercanos = todosLosCafes.where((cafe) {
            final distancia = Geolocator.distanceBetween(
                posicionActual!.latitude,
                posicionActual!.longitude,
                cafe.latitude ?? posicionActual!.latitude,
                cafe.longitude ?? posicionActual!.longitude,
            );

            return distancia <= radioSeleccionado * 1000;
        }).toList();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            title: const Text('Cerca mío'),
        ),
            body: cargando
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                    return const CafeCardSkeleton();
                    },
                )
                : estado.isNotEmpty
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            const Icon(
                                Icons.location_off_outlined,
                                size: 56,
                                color: Colors.black45,
                            ),
                            const SizedBox(height: 16),
                            Text(
                                estado,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                ),
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                                onPressed: permisoDenegadoPermanentemente
                                    ? () async {
                                        await Geolocator.openAppSettings();
                                        }
                                    : obtenerUbicacion,
                                icon: Icon(
                                    permisoDenegadoPermanentemente
                                        ? Icons.settings_outlined
                                        : Icons.refresh_rounded,
                                ),
                                label: Text(
                                    permisoDenegadoPermanentemente
                                        ? 'Abrir ajustes'
                                        : 'Reintentar',
                                ),
                                ),
                            ],
                        ),
                        ),
                    )
                    : Column(
                        children: [
                            Container(
                                width: double.infinity,
                                margin: const EdgeInsets.fromLTRB(
                                    16,
                                    12,
                                    16,
                                    8,
                                ),
                                    padding: const EdgeInsets.fromLTRB(
                                    16,
                                    14,
                                    16,
                                    14,
                                ),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF172C6D),
                                    borderRadius: BorderRadius.circular(22),
                                ),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                    const Text(
                                        'Cafeterías cerca tuyo',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                        ),
                                        ),

                                    Text(
                                        cafesCercanos.length == 1
                                            ? 'Encontramos 1 cafetería a menos de '
                                                '${radioSeleccionado.toInt()} km.'
                                            : 'Encontramos ${cafesCercanos.length} cafeterías '
                                                'a menos de ${radioSeleccionado.toInt()} km.',
                                        style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        height: 1.35,
                                        ),
                                    ),

                                    const SizedBox(height: 11),

                                    Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [3, 5, 10, 20].map((km) {
                                            final seleccionado =
                                                radioSeleccionado == km.toDouble();

                                            return GestureDetector(
                                            onTap: () {
                                                setState(() {
                                                radioSeleccionado = km.toDouble();
                                                filtrarPorRadio();
                                                });
                                            },
                                            child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 180),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 13,
                                                    vertical: 7,
                                                    ),
                                                decoration: BoxDecoration(
                                                color: seleccionado
                                                    ? Colors.white
                                                    : Colors.white.withValues(alpha: .14),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: seleccionado
                                                        ? Colors.white
                                                        : Colors.white.withValues(alpha: .55),
                                                    width: 1.2,
                                                ),
                                                ),
                                                child: Text(
                                                '$km km',
                                                style: TextStyle(
                                                    color: seleccionado
                                                        ? const Color(0xFF172C6D)
                                                        : Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                ),
                                                ),
                                            ),
                                            );
                                        }).toList(),
                                        ),

                                        const SizedBox(height: 10),

                                        GestureDetector(
                                        onTap: obtenerUbicacion,
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: .12),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                                color: Colors.white.withValues(alpha: .35),
                                            ),
                                            ),
                                            child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                                Icon(
                                                Icons.my_location_rounded,
                                                size: 17,
                                                color: Colors.white,
                                                ),
                                                SizedBox(width: 7),
                                                Text(
                                                'Actualizar ubicación',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                ),
                                                ),
                                            ],
                                            ),
                                        ),
                                        ),
                                    ],
                                ),
                                ),

                                const SizedBox(height: 2),

                            Expanded(
                                child: cafesCercanos.isEmpty
                                    ? RefreshIndicator(
                                        onRefresh: obtenerUbicacion,
                                        child: ListView(
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            padding: const EdgeInsets.all(24),
                                            children: [
                                            const SizedBox(height: 70),

                                            const Icon(
                                                Icons.location_searching_rounded,
                                                size: 58,
                                                color: Colors.black38,
                                            ),

                                            const SizedBox(height: 18),

                                            const Text(
                                                'No encontramos cafeterías en este radio',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF111827),
                                                ),
                                            ),

                                            const SizedBox(height: 8),

                                            Text(
                                                'Probá ampliando la búsqueda a más de '
                                                '${radioSeleccionado.toInt()} km.',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                fontSize: 14,
                                                height: 1.4,
                                                color: Colors.black54,
                                                ),
                                            ),
                                            ],
                                        ),
                                        )
                                    : RefreshIndicator(
                                        onRefresh: obtenerUbicacion,
                                        child: ListView.builder(
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            padding: const EdgeInsets.fromLTRB(
                                            16,
                                            8,
                                            16,
                                            24,
                                            ),
                                            itemCount: cafesCercanos.length,
                                            itemBuilder: (context, index) {
                                            final cafe = cafesCercanos[index];

                                            final distanciaKm =
                                                Geolocator.distanceBetween(
                                                    posicionActual!.latitude,
                                                    posicionActual!.longitude,
                                                    cafe.latitude!,
                                                    cafe.longitude!,
                                                ) /
                                                1000;

                                            return AnimatedListItem(
                                                index: index,
                                                child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                    Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 4,
                                                        bottom: 7,
                                                    ),
                                                    child: Row(
                                                        children: [
                                                        const Icon(
                                                            Icons.near_me_outlined,
                                                            size: 16,
                                                            color: Color(0xFF172C6D),
                                                        ),

                                                        const SizedBox(width: 5),

                                                        Text(
                                                            '${distanciaKm.toStringAsFixed(1)} km de distancia',
                                                            style: const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w600,
                                                            color: Color(0xFF172C6D),
                                                            ),
                                                        ),
                                                        ],
                                                    ),
                                                    ),

                                                    AnimatedPress(
                                                    borderRadius:
                                                        BorderRadius.circular(22),
                                                    onTap: () {
                                                        Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                CafeDetailScreen(
                                                            cafeId: cafe.id!,
                                                            ),
                                                        ),
                                                        );
                                                    },
                                                    child: CafeCard(
                                                        cafe: cafe,
                                                    ),
                                                    ),
                                                ],
                                                ),
                                            );
                                            },
                                        ),
                                        ),
                                ),
        ],
    ),
    );
  }
}