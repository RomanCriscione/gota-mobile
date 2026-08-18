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

    Map<String, dynamic>? decodedData;

    try {
      final dynamic decoded =
          jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        decodedData = decoded;
      }
    } catch (_) {}

    if (decodedData == null) {
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

  static Future<Map<String, dynamic>> crearReview({
    required int cafeId,
    required int rating,
    required String comment,
    required String bestForPlan,
    required String? precioCapuccino,
    required List<int> tagIds,
  }) async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión activa.',
      );
    }

    final body = <String, dynamic>{
      'rating': rating,
      'comment': comment,
      'best_for_plan': bestForPlan,
      'tags': tagIds,
    };

    if (precioCapuccino != null &&
        precioCapuccino.trim().isNotEmpty) {
      body['precio_capuccino'] =
          int.parse(precioCapuccino);
    }

    final response = await http
        .post(
          Uri.parse(
            '$baseUrl/cafes/$cafeId/reviews/create/',
          ),
          headers: {
            'Authorization': 'Token $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    Map<String, dynamic>? decodedData;

    try {
      final dynamic decoded =
          jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        decodedData = decoded;
      }
    } catch (_) {}

    if (response.statusCode != 201) {
      final message =
          decodedData?['message'];

      if (message is String &&
          message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception(
        'No pudimos publicar la reseña.',
      );
    }

    if (decodedData == null) {
      throw Exception(
        'La respuesta del servidor no es válida.',
      );
    }

    return decodedData;
  }

  static Future<Map<String, dynamic>> actualizarReview({
    required int reviewId,
    required int rating,
    required String comment,
    required String bestForPlan,
    required String? precioCapuccino,
    required List<int> tagIds,
  }) async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión activa.',
      );
    }

    final body = <String, dynamic>{
      'rating': rating,
      'comment': comment,
      'best_for_plan': bestForPlan,
      'tags': tagIds,
    };

    if (precioCapuccino != null &&
        precioCapuccino.trim().isNotEmpty) {
      body['precio_capuccino'] =
          int.parse(precioCapuccino);
    }

    final response = await http
        .put(
          Uri.parse(
            '$baseUrl/reviews/$reviewId/',
          ),
          headers: {
            'Authorization': 'Token $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    Map<String, dynamic>? decodedData;

    try {
      final dynamic decoded =
          jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        decodedData = decoded;
      }
    } catch (_) {}

    if (response.statusCode != 200) {
      final message =
          decodedData?['message'];

      if (message is String &&
          message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception(
        'No pudimos actualizar la reseña.',
      );
    }

    if (decodedData == null) {
      throw Exception(
        'La respuesta del servidor no es válida.',
      );
    }

    return decodedData;
  }
}