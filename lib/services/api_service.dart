import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cafe.dart';

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
}