import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'https://gogota.ar/api/mobile';

  static const String tokenKey = 'auth_token';

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 400) {
        return false;
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Error del servidor (${response.statusCode})',
        );
      }

      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is! Map<String, dynamic>) {
        return false;
      }

      final token = decodedData['token'];

      debugPrint(
        'TOKEN LOGIN: $token',
      );

      if (token is! String || token.isEmpty) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        tokenKey,
        token,
      );

      return true;
    } catch (_) {
      rethrow;
    }
  }

  static Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is! Map<String, dynamic>) {
        return 'La respuesta del servidor no es válida.';
      }

      if (response.statusCode == 400) {
        final message = decodedData['message'];

        if (message is String && message.isNotEmpty) {
          return message;
        }

        return 'No pudimos crear la cuenta.';
      }

      if (response.statusCode != 201) {
        throw Exception(
          'Error del servidor (${response.statusCode})',
        );
      }

      final token = decodedData['token'];

      if (token is! String || token.isEmpty) {
        return 'La cuenta fue creada, pero no se recibió una sesión válida.';
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        tokenKey,
        token,
      );

      return null;
    } catch (_) {
      rethrow;
    }
  }

  static Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(tokenKey);
  }

  static Future<bool> estaLogueado() async {
    final token = await obtenerToken();

    return token != null && token.isNotEmpty;
  }

  static Future<bool> convertirEnDueno() async {
    final token = await obtenerToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/become-owner/'),
            headers: {
              'Authorization': 'Token $token',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode != 200) {
        return false;
      }

      final dynamic decodedData =
          jsonDecode(response.body);

      if (decodedData is! Map<String, dynamic>) {
        return false;
      }

      return decodedData['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> logout() async {
    final token = await obtenerToken();

    if (token != null) {
      try {
        await http
            .post(
              Uri.parse('$baseUrl/logout/'),
              headers: {
                'Authorization': 'Token $token',
                'Accept': 'application/json',
              },
            )
            .timeout(
              const Duration(seconds: 15),
            );
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);
  }

  static Future<User?> obtenerUsuarioActual() async {
    final token = await obtenerToken();
    
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/me/'),
            headers: {
                'Authorization': 'Token $token',
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode != 200) {
        return null;
      }

      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is! Map<String, dynamic>) {
        return null;
      }

      return User.fromJson(decodedData);
    } catch (_) {
      return null;
    }
  }
}