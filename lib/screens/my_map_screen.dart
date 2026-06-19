import 'package:flutter/material.dart';
import '../services/app_state.dart';
import 'cafe_detail_screen.dart';

class MyMapScreen extends StatefulWidget {
  const MyMapScreen({super.key});

  @override
  State<MyMapScreen> createState() => _MyMapScreenState();
}

class _MyMapScreenState extends State<MyMapScreen> {

  String? filtroColeccion;

  @override
  Widget build(BuildContext context) {
    final todasLasColecciones = {
    ...AppState.quieroIr,
    ...AppState.quieroVolver,
    ...AppState.yaFui,
  }
      .where((cafe) => cafe.collection != null)
      .map((cafe) => cafe.collection!)
      .toSet()
      .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi mapa cafetero'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        label: const Text('☕ Todo mi recorrido'),
                        selected: filtroColeccion == null,
                        onSelected: (_) {
                          setState(() {
                            filtroColeccion = null;
                          });
                        },
                      ),

                      ...todasLasColecciones.map(
                        (coleccion) {

                          final cantidad = [
                            ...AppState.quieroIr,
                            ...AppState.quieroVolver,
                            ...AppState.yaFui,
                          ]
                              .where(
                                (cafe) => cafe.collection == coleccion,
                              )
                              .length;

                          return FilterChip(
                            label: Text(
                              '$coleccion ($cantidad)',
                            ),
                            selected: filtroColeccion == coleccion,
                            onSelected: (_) {
                              setState(() {
                                filtroColeccion = coleccion;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                ],
              ),
            ),
          ),
          Text(
            '☕ Quiero ir (${AppState.quieroIr.length})',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (AppState.quieroIr.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Todavía no guardaste cafeterías aquí.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

          ...AppState.quieroIr
            .where(
              (cafe) =>
                  filtroColeccion == null ||
                  cafe.collection == filtroColeccion,
            )
            .map(
            (cafe) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                minVerticalPadding: 12,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CafeDetailScreen(
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
                        petFriendly: cafe.petFriendly,
                        veganFriendly: cafe.veganFriendly,
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
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    cafe.foto,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cafe.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (cafe.collection != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          cafe.collection!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    if (cafe.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '🏷️ ${cafe.tags.first}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  cafe.rating == '0.0'
                      ? cafe.zona
                      : '⭐ ${cafe.rating} · ${cafe.zona}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    AppState.quieroIr.remove(cafe);

                    await AppState.guardarDatos();

                    setState(() {});
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            '❤️ Quiero volver (${AppState.quieroVolver.length})',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (AppState.quieroVolver.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Todavía no guardaste cafeterías aquí.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

          ...AppState.quieroVolver
            .where(
              (cafe) =>
                  filtroColeccion == null ||
                  cafe.collection == filtroColeccion,
            )
            .map(
            (cafe) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12), 
                minVerticalPadding: 12,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CafeDetailScreen(
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
                        petFriendly: cafe.petFriendly,
                        veganFriendly: cafe.veganFriendly,
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
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    cafe.foto,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cafe.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (cafe.collection != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          cafe.collection!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    if (cafe.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '🏷️ ${cafe.tags.first}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  cafe.rating == '0.0'
                      ? cafe.zona
                      : '⭐ ${cafe.rating} · ${cafe.zona}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    AppState.quieroVolver.remove(cafe);

                    await AppState.guardarDatos();

                    setState(() {});
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            '✔️ Ya fui (${AppState.yaFui.length})',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (AppState.yaFui.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Todavía no guardaste cafeterías aquí.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

          ...AppState.yaFui
            .where(
              (cafe) =>
                  filtroColeccion == null ||
                  cafe.collection == filtroColeccion,
            )
            .map(
            (cafe) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                minVerticalPadding: 12,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CafeDetailScreen(
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
                        petFriendly: cafe.petFriendly,
                        veganFriendly: cafe.veganFriendly,
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
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    cafe.foto,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cafe.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (cafe.collection != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          cafe.collection!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    if (cafe.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '🏷️ ${cafe.tags.first}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  cafe.rating == '0.0'
                      ? cafe.zona
                      : '⭐ ${cafe.rating} · ${cafe.zona}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    AppState.yaFui.remove(cafe);

                    await AppState.guardarDatos();

                    setState(() {});
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}