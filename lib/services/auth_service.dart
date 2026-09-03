import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'https://gogota.ar/api/mobile';

  static const String tokenKey = 'auth_token';

  static const String googleServerClientId =
      '322308910233-aktosf2nqa5gnhpc2mrpfktcsq5o8h48.apps.googleusercontent.com';

  static bool _googleInicializado = false;
  static const String googleLoginCancelado =
    '__google_login_cancelado__';

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

  static Future<String?> loginConGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      if (!_googleInicializado) {
        await googleSignIn.initialize(
          serverClientId: googleServerClientId,
        );

        _googleInicializado = true;
      }

      final account = await googleSignIn.authenticate();

      final authentication = account.authentication;
      final idToken = authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        return 'Google no devolvió una sesión válida.';
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/google-login/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'id_token': idToken,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is! Map<String, dynamic>) {
        return 'La respuesta del servidor no es válida.';
      }

      if (response.statusCode != 200) {
        final message = decodedData['message'];

        if (message is String && message.isNotEmpty) {
          return message;
        }

        return 'No pudimos iniciar sesión con Google.';
      }

      final token = decodedData['token'];

      if (token is! String || token.isEmpty) {
        return 'No se recibió una sesión válida.';
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        tokenKey,
        token,
      );

      return null;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return googleLoginCancelado;
      }

      return 'No pudimos iniciar sesión con Google.';
    } catch (_) {
      return 'No pudimos iniciar sesión con Google.';
    }
  }

  static String _generarNonce() {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';

    final random = Random.secure();

    return List.generate(
      32,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  static String _sha256(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

static Future<String?> loginConApple() async {
  try {
    final rawNonce = _generarNonce();
    final hashedNonce = _sha256(rawNonce);

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );
      final idToken = credential.identityToken;
      final authorizationCode = credential.authorizationCode;

      if (idToken == null || idToken.isEmpty) {
        return 'Apple no devolvió una sesión válida.';
      }

      final name = [
        credential.givenName,
        credential.familyName,
      ]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .join(' ')
          .trim();

      final response = await http
          .post(
            Uri.parse('$baseUrl/apple-login/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'id_token': idToken,
              'authorization_code': authorizationCode,
              'name': name,
              'nonce': rawNonce,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is! Map<String, dynamic>) {
        return 'La respuesta del servidor no es válida.';
      }

      if (response.statusCode != 200) {
        final message = decodedData['message'];

        if (message is String && message.isNotEmpty) {
          return message;
        }

        return 'No pudimos iniciar sesión con Apple.';
      }

      final token = decodedData['token'];

      if (token is! String || token.isEmpty) {
        return 'No se recibió una sesión válida.';
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        tokenKey,
        token,
      );

      return null;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return googleLoginCancelado;
      }

      return 'No pudimos iniciar sesión con Apple.';
    } catch (_) {
      return 'No pudimos iniciar sesión con Apple.';
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

  static Future<bool> eliminarCuenta() async {
    final token = await obtenerToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/delete-account/'),
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

      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(tokenKey);

      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> recuperarContrasena({
    required String email,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/password-reset/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is! Map<String, dynamic>) {
        return 'La respuesta del servidor no es válida.';
      }

      final message = decodedData['message'];

      if (response.statusCode != 200) {
        if (message is String && message.isNotEmpty) {
          return message;
        }

        return 'No pudimos enviar el correo de recuperación.';
      }

      return null;
    } catch (_) {
      return 'No pudimos enviar el correo de recuperación.';
    }
  }

  static Future<String?> cambiarContrasena({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await obtenerToken();

    if (token == null || token.isEmpty) {
      return 'No hay una sesión activa.';
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/change-password/'),
            headers: {
              'Authorization': 'Token $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'current_password': currentPassword,
              'new_password': newPassword,
              'confirm_password': confirmPassword,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is! Map<String, dynamic>) {
        return 'La respuesta del servidor no es válida.';
      }

      if (response.statusCode != 200) {
        final message = decodedData['message'];

        if (message is String && message.isNotEmpty) {
          return message;
        }

        return 'No pudimos cambiar tu contraseña.';
      }

      final newToken = decodedData['token'];

      if (newToken is! String || newToken.isEmpty) {
        return 'La contraseña cambió, pero no pudimos renovar tu sesión.';
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        tokenKey,
        newToken,
      );

      return null;
    } catch (_) {
      return 'No pudimos cambiar tu contraseña.';
    }
  }

  static Future<String?> actualizarPerfil({
    required String firstName,
    required String lastName,
  }) async {
    final token = await obtenerToken();

    if (token == null || token.isEmpty) {
      return 'No hay una sesión activa.';
    }

    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/me/'),
            headers: {
              'Authorization': 'Token $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'first_name': firstName.trim(),
              'last_name': lastName.trim(),
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is! Map<String, dynamic>) {
        return 'La respuesta del servidor no es válida.';
      }

      if (response.statusCode != 200) {
        final message = decodedData['message'];

        if (message is String && message.isNotEmpty) {
          return message;
        }

        return 'No pudimos actualizar tu perfil.';
      }

      return null;
    } catch (_) {
      return 'No pudimos actualizar tu perfil.';
    }
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