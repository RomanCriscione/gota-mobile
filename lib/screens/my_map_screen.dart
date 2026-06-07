import 'package:flutter/material.dart';
import '../services/app_state.dart';
import 'cafe_detail_screen.dart';

class MyMapScreen extends StatefulWidget {
  const MyMapScreen({super.key});

  @override
  State<MyMapScreen> createState() => _MyMapScreenState();
}

class _MyMapScreenState extends State<MyMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi mapa cafetero'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '☕ Quiero ir (${AppState.quieroIr.length})',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          ...AppState.quieroIr.map(
            (cafe) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CafeDetailScreen(
                        nombre: cafe.nombre,
                        zona: cafe.zona,
                        rating: cafe.rating,
                        foto: cafe.foto,
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
                title: Text(cafe.nombre),
                subtitle: Text(cafe.zona),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      AppState.quieroIr.remove(cafe);
                    });
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

          ...AppState.quieroVolver.map(
            (cafe) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CafeDetailScreen(
                        nombre: cafe.nombre,
                        zona: cafe.zona,
                        rating: cafe.rating,
                        foto: cafe.foto,
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
                title: Text(cafe.nombre),
                subtitle: Text(cafe.zona),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      AppState.quieroVolver.remove(cafe);
                    });
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

          ...AppState.yaFui.map(
            (cafe) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CafeDetailScreen(
                        nombre: cafe.nombre,
                        zona: cafe.zona,
                        rating: cafe.rating,
                        foto: cafe.foto,
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
                title: Text(cafe.nombre),
                subtitle: Text(cafe.zona),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      AppState.yaFui.remove(cafe);
                    });
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