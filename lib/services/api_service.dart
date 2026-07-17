import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cafe.dart';
import '../models/cafe_relationship.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://gogota.ar/api';

  static Future<List<Cafe>> obtenerCafes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cafes/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map(
            (item) => Cafe.fromJson(item),
          )
          .toList();
    }

    throw Exception(
      'Error al cargar cafeterías',
    );
  }
  static Future<List<CafeRelationship>>
      obtenerMiMapa() async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión iniciada',
      );
    }

    final response = await http
        .get(
          Uri.parse('$baseUrl/mobile/my-map/'),
          headers: {
            'Authorization': 'Token $token',
            'Accept': 'application/json',
          },
        )
        .timeout(
          const Duration(seconds: 15),
        );

    print(
      'Mi mapa status: ${response.statusCode}',
    );
    print(
      'Mi mapa body: ${response.body}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al cargar Mi mapa cafetero',
      );
    }

    final dynamic decodedData =
        jsonDecode(response.body);

    if (decodedData is! List) {
      throw Exception(
        'La respuesta de Mi mapa no es válida',
      );
    }

    return decodedData
        .map(
          (item) => CafeRelationship.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}