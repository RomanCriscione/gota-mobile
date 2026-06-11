import 'package:flutter/material.dart';
import 'cafe_detail_screen.dart';
import '../models/cafe.dart';
import '../services/api_service.dart';

class CafesScreen extends StatefulWidget {
  const CafesScreen({super.key});

  @override
  State<CafesScreen> createState() => _CafesScreenState();
}

class _CafesScreenState extends State<CafesScreen> {
  late Future<List<Cafe>> cafesFuture;

  String busqueda = '';

  @override
  void initState() {
    super.initState();
    cafesFuture = ApiService.obtenerCafes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafeterías'),
      ),
      body: FutureBuilder<List<Cafe>>(
        future: cafesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          final cafes = snapshot.data ?? [];

          final cafesFiltrados = cafes.where((cafe) {
            return cafe.nombre
                .toLowerCase()
                .contains(busqueda.toLowerCase());
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar cafetería...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      busqueda = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cafesFiltrados.length,
                  itemBuilder: (context, index) {
                    final cafe = cafesFiltrados[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        onTap: () {
                            print(cafe.tags);
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
                                tieneWifi: cafe.tieneWifi,
                                petFriendly: cafe.petFriendly,
                                veganFriendly: cafe.veganFriendly,
                                tags: cafe.tags,
                              ),
                            ),
                          );
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            cafe.foto,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          cafe.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(cafe.zona),
                        trailing: Text(
                          '⭐ ${cafe.rating}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}