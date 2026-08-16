import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ReviewService {
  static const String baseUrl =
      'https://gogota.ar/api/mobile';

  static Future<List<Map<String, dynamic>>> obtenerTags() async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión activa.',
      );
    }

    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/review-tags/',
          ),
          headers: {
            'Authorization': 'Token $token',
            'Accept': 'application/json',
          },
        )
        .timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'No pudimos cargar las etiquetas.',
      );
    }

    final dynamic decodedData =
        jsonDecode(response.body);

    if (decodedData is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta del servidor no es válida.',
      );
    }

    final dynamic tagsData =
        decodedData['tags'];

    if (tagsData is! List) {
      return [];
    }

    return tagsData
        .whereType<Map>()
        .map(
          (tag) => Map<String, dynamic>.from(tag),
        )
        .toList();
  }
}