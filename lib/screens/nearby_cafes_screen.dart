import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/cafe.dart';
import '../services/api_service.dart';
import '../services/app_state.dart';
import 'cafe_detail_screen.dart';

class NearbyCafesScreen extends StatefulWidget {
    const NearbyCafesScreen({super.key});

    @override
    State<NearbyCafesScreen> createState() => _NearbyCafesScreenState();
}

class _NearbyCafesScreenState extends State<NearbyCafesScreen> {
    String estado = 'Obteniendo ubicación...';

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
        bool servicioHabilitado =
            await Geolocator.isLocationServiceEnabled();

        if (!servicioHabilitado) {
        setState(() {
            estado = 'Activá la ubicación del teléfono';
        });
        return;
        }

        LocationPermission permiso =
            await Geolocator.checkPermission();

        if (permiso == LocationPermission.denied) {
            permiso = await Geolocator.requestPermission();
        }

        if (permiso == LocationPermission.deniedForever) {
            setState(() {
                estado = 'Permiso denegado';
            });
            return;
        }

        final posicion =
            await Geolocator.getCurrentPosition();

        final cafes = await ApiService.obtenerCafes();

        cafes.sort((a, b) {
            final distanciaA = Geolocator.distanceBetween(
                posicion.latitude,
                posicion.longitude,
                a.latitude ?? posicion.latitude,
                a.longitude ?? posicion.longitude,
            );

            final distanciaB = Geolocator.distanceBetween(
                posicion.latitude,
                posicion.longitude,
                b.latitude ?? posicion.latitude,
                b.longitude ?? posicion.longitude,
            );

            return distanciaA.compareTo(distanciaB);
        });

        setState(() {
            posicionActual = posicion;
            todosLosCafes = cafes;
            filtrarPorRadio();
            estado = '';
        });
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
            title: const Text('📍 Cerca mío'),
        ),
            body: estado.isNotEmpty
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                            estado,
                            textAlign: TextAlign.center,
                        ),
                    ),
                )
                    : Column(
                        children: [
                            Padding(
                                padding: const EdgeInsets.all(12),
                                child: Wrap(
                                    spacing: 8,
                                    children: [3, 5, 10, 20].map((km) {
                                        return ChoiceChip(
                                    label: Text('$km km'),
                                        selected:
                                            radioSeleccionado == km.toDouble(),
                                    onSelected: (_) {
                                        setState(() {
                                            radioSeleccionado =
                                                km.toDouble();
                                            filtrarPorRadio();
                                        });
                                    },
                                );
                            }).toList(),
                        ),
                    ),

                        Text(
                            '${cafesCercanos.length} cafeterías encontradas',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                            ),
                        ),

                        const SizedBox(height: 8),

                            Expanded(
                                child: ListView.builder(
                                    itemCount: cafesCercanos.length,
                                    itemBuilder: (context, index) {
                                        final cafe = cafesCercanos[index];

                                        final distanciaKm =
                                            Geolocator.distanceBetween(
                                                posicionActual!.latitude,
                                                posicionActual!.longitude,
                                                cafe.latitude ??
                                                    posicionActual!.latitude,
                                                cafe.longitude ??
                                                    posicionActual!.longitude,
                                            ) /
                                                1000;
                                        String? estadoCafe;

                                if (AppState.quieroIr.any((c) => c.nombre == cafe.nombre)) {
                                estadoCafe = '☕ Quiero ir';
                                } else if (AppState.quieroVolver.any((c) => c.nombre == cafe.nombre)) {
                                estadoCafe = '❤️ Quiero volver';
                                } else if (AppState.yaFui.any((c) => c.nombre == cafe.nombre)) {
                                estadoCafe = '✔️ Ya fui';
                                }        

                            return ListTile(
                                leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(cafe.foto),
                                ),
                                    title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(cafe.nombre),

                                            if (estadoCafe != null) ...[
                                            const SizedBox(height: 4),

                                            Chip(
                                                label: Text(
                                                estadoCafe,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                ),
                                                ),
                                                visualDensity: VisualDensity.compact,
                                            ),
                                            ],
                                        ],
                                        ),

                                    subtitle: Text(
                                    cafe.rating == '0.0'
                                        ? '${cafe.zona} · ${distanciaKm.toStringAsFixed(1)} km'
                                        : '⭐ ${cafe.rating} · ${cafe.zona} · ${distanciaKm.toStringAsFixed(1)} km',
                                    ),
                                onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                CafeDetailScreen(
                                            nombre: cafe.nombre,
                                            zona: cafe.zona,
                                            rating: cafe.rating,
                                            foto: cafe.foto,
                                            foto2: cafe.foto2,
                                            foto3: cafe.foto3,
                                            direccion: cafe.direccion,
                                            latitude: cafe.latitude,
                                            longitude: cafe.longitude,
                                            tieneWifi: cafe.tieneWifi,
                                            petFriendly:cafe.petFriendly,
                                            veganFriendly:cafe.veganFriendly,
                                            tags: cafe.tags,
                                            enchufes: cafe.enchufes,
                                            cafeEspecialidad: cafe.cafeEspecialidad,
                                            brunch: cafe.brunch,
                                            laptopFriendly: cafe.laptopFriendly,
                                            espacioTranquilo: cafe.espacioTranquilo,
                                        ),
                                    ),
                                );
                            },
                        );
                    },
                ),
            ),
        ],
    ),
    );
  }
}