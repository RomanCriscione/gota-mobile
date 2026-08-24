import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cafe.dart';
import '../models/cafe_relationship.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://gogota.ar/api';

  static List<Cafe>? _cafesCache;
  static Future<List<Cafe>>? _cafesRequest;

  static Future<List<Cafe>> obtenerCafes({
    bool forzarActualizacion = false,
  }) async {
    if (!forzarActualizacion && _cafesCache != null) {
      return _cafesCache!;
    }

    if (!forzarActualizacion && _cafesRequest != null) {
      return _cafesRequest!;
    }

    final request = _descargarCafes();

    _cafesRequest = request;

    try {
      final cafes = await request;

      _cafesCache = cafes;

      return cafes;
    } finally {
      if (identical(_cafesRequest, request)) {
        _cafesRequest = null;
      }
    }
  }

  static Future<List<Cafe>> _descargarCafes() async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/cafes/'),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al cargar cafeterías',
      );
    }

    final dynamic decodedData = jsonDecode(
      response.body,
    );

    if (decodedData is! List) {
      throw Exception(
        'La respuesta de cafeterías no es válida',
      );
    }

    return decodedData
        .map(
          (item) => Cafe.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  static Future<List<Cafe>> obtenerCafesRelacionados(
    int cafeId,
  ) async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión iniciada',
      );
    }

    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/mobile/cafes/$cafeId/related/',
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
        'Error al cargar cafeterías relacionadas',
      );
    }

    final dynamic decodedData =
        jsonDecode(response.body);

    if (decodedData is! List) {
      throw Exception(
        'La respuesta de cafeterías relacionadas no es válida',
      );
    }

    return decodedData
        .map(
          (item) => Cafe.fromJson(
            item as Map<String, dynamic>,
          ),
        )

        .toList();
  }

  static List<CafeRelationship>? _miMapaCache;
  static Future<List<CafeRelationship>>? _miMapaRequest;
  static String? _miMapaToken;

  static Future<List<CafeRelationship>> obtenerMiMapa({
    bool forzarActualizacion = false,
  }) async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión iniciada',
      );
    }

    final cambioDeUsuario = _miMapaToken != token;

    if (cambioDeUsuario) {
      _miMapaCache = null;
      _miMapaRequest = null;
      _miMapaToken = token;
    }

    if (!forzarActualizacion &&
        _miMapaCache != null) {
      return _miMapaCache!;
    }

    if (!forzarActualizacion &&
        _miMapaRequest != null) {
      return _miMapaRequest!;
    }

    final request = _descargarMiMapa(token);

    _miMapaRequest = request;

    try {
      final relaciones = await request;

      _miMapaCache = relaciones;

      return relaciones;
    } finally {
      if (identical(_miMapaRequest, request)) {
        _miMapaRequest = null;
      }
    }
  }

  static Future<List<CafeRelationship>>
      _descargarMiMapa(
    String token,
  ) async {

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

  static Future<Map<String, dynamic>> setCafeStatus({
    required int cafeId,
    required String status,
  }) async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión iniciada',
      );
    }

    final response = await http
        .post(
          Uri.parse(
            '$baseUrl/mobile/cafes/$cafeId/set-status/',
          ),
          headers: {
            'Authorization': 'Token $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'status': status,
          }),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al guardar el estado',
      );
    }

    final resultado = jsonDecode(
      response.body,
    ) as Map<String, dynamic>;

    _miMapaCache = null;
    _miMapaRequest = null;

    return resultado;
  }

  static Future<Map<String, dynamic>> setCafeCollection({
    required int cafeId,
    required String collection,
  }) async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión iniciada',
      );
    }

    final response = await http
        .post(
          Uri.parse(
            '$baseUrl/mobile/cafes/$cafeId/set-collection/',
          ),
          headers: {
            'Authorization': 'Token $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'collection': collection,
          }),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al guardar la colección',
      );
    }

    final resultado = jsonDecode(
      response.body,
    ) as Map<String, dynamic>;

    _miMapaCache = null;
    _miMapaRequest = null;

    return resultado;
  }

  static Future<Map<String, dynamic>> obtenerDetalleCafe(
    int cafeId,
  ) async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión iniciada',
      );
    }

    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/mobile/cafes/$cafeId/',
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
        'Error al cargar el detalle del café',
      );
    }

    final dynamic decodedData =
        jsonDecode(response.body);

    if (decodedData is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta del detalle no es válida',
      );
    }

    return decodedData;
  }

  static Future<List<Map<String, dynamic>>> obtenerHuellas(
    int cafeId,
  ) async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión iniciada',
      );
    }

    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/mobile/cafes/$cafeId/whispers/',
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
        'No pudimos cargar las huellas.',
      );
    }

    final dynamic decodedData =
        jsonDecode(response.body);

    if (decodedData is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta de huellas no es válida.',
      );
    }

    final dynamic whispersData =
        decodedData['whispers'];

    if (whispersData is! List) {
      return [];
    }

    return whispersData
        .whereType<Map>()
        .map(
          (whisper) =>
              Map<String, dynamic>.from(whisper),
        )
        .toList();
  }

  static Future<Map<String, dynamic>> crearHuella({
    required int cafeId,
    required String text,
  }) async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión iniciada',
      );
    }

    final response = await http
        .post(
          Uri.parse(
            '$baseUrl/mobile/cafes/$cafeId/whispers/',
          ),
          headers: {
            'Authorization': 'Token $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'text': text,
          }),
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
        'No pudimos guardar tu huella.',
      );
    }

    if (decodedData == null) {
      throw Exception(
        'La respuesta de huellas no es válida.',
      );
    }

    return decodedData;
  }

  static Future<Map<String, dynamic>> reportarResena({
    required int reviewId,
    required String reason,
    String? message,
  }) async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión iniciada',
      );
    }

    final response = await http
        .post(
          Uri.parse(
            '$baseUrl/mobile/reviews/$reviewId/report/',
          ),
          headers: {
            'Authorization': 'Token $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'reason': reason,
            'message': message?.trim() ?? '',
          }),
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
        'No pudimos enviar el reporte.',
      );
    }

    if (decodedData == null) {
      throw Exception(
        'La respuesta del reporte no es válida.',
      );
    }

    return decodedData;
  }
}