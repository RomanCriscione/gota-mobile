import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'auth_service.dart';

class CafeService {
  static const String baseUrl =
      'https://gogota.ar/api/mobile';

  static Future<Map<String, dynamic>> crearCafe({
    required String nombre,
    required String direccion,
    required String localidad,
    required String provincia,
    required String descripcion,
    required String telefono,
    required String instagram,
    required String googleMapsUrl,
    required double latitude,
    required double longitude,
    required XFile fotoPrincipal,
    XFile? foto2,
    XFile? foto3,

    required bool tieneWifi,
    required bool aireAcondicionado,
    required bool enchufes,
    required bool mesasAlAireLibre,
    required bool estacionamiento,
    required bool accesible,
    required bool cambiadorBebes,
    required bool petFriendly,
    required bool kidsFriendly,

    required bool cafeEspecialidad,
    required bool brunch,
    required bool desayuno,
    required bool alcohol,
    required bool pasteleriaArtesanal,

    required bool veganFriendly,
    required bool vegetariano,
    required bool sinTacc,
    required bool opcionesSaludables,
    required bool sinAzucar,
    required bool lechesVegetales,

    required bool jardin,
    required bool vistaAgua,
    required bool vistaMontanas,
    required bool rodeadoNaturaleza,
    required bool terrazaRooftop,
    required bool ventanalesGrandes,
    required bool casaAntigua,
    required bool edificioHistorico,
    required bool dentroLibreria,
    required bool espacioCultural,

    required bool librosOJuegos,
  }) async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión activa.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$baseUrl/cafes/create/',
      ),
    );

    request.headers.addAll({
      'Authorization': 'Token $token',
      'Accept': 'application/json',
    });

    request.fields.addAll({
      'name': nombre,
      'address': direccion,
      'location': localidad,
      'province': provincia,
      'description': descripcion,
      'phone': telefono,
      'instagram': instagram,
      'google_maps_url': googleMapsUrl,

      'latitude': latitude.toString(),
      'longitude': longitude.toString(),

      'has_wifi': tieneWifi.toString(),
      'has_air_conditioning':
          aireAcondicionado.toString(),
      'has_power_outlets': enchufes.toString(),
      'has_outdoor_seating':
          mesasAlAireLibre.toString(),
      'has_parking': estacionamiento.toString(),
      'is_accessible': accesible.toString(),
      'has_baby_changing':
          cambiadorBebes.toString(),

      'is_pet_friendly': petFriendly.toString(),
      'is_kids_friendly': kidsFriendly.toString(),

      'has_specialty_coffee':
          cafeEspecialidad.toString(),
      'serves_brunch': brunch.toString(),
      'serves_breakfast': desayuno.toString(),
      'serves_alcohol': alcohol.toString(),
      'has_artisanal_pastries':
          pasteleriaArtesanal.toString(),

      'is_vegan_friendly':
          veganFriendly.toString(),
      'has_vegetarian_options':
          vegetariano.toString(),
      'has_gluten_free_options':
          sinTacc.toString(),

      'has_healthy_options':
          opcionesSaludables.toString(),
      'has_sugar_free_options':
          sinAzucar.toString(),
      'has_plant_based_milk':
          lechesVegetales.toString(),

      'has_garden':
          jardin.toString(),
      'has_water_view':
          vistaAgua.toString(),
      'has_mountain_view':
          vistaMontanas.toString(),
      'surrounded_by_nature':
          rodeadoNaturaleza.toString(),
      'has_rooftop':
          terrazaRooftop.toString(),
      'has_large_windows':
          ventanalesGrandes.toString(),
      'is_old_house':
          casaAntigua.toString(),
      'is_historic_building':
          edificioHistorico.toString(),
      'inside_bookstore':
          dentroLibreria.toString(),
      'inside_cultural_space':
          espacioCultural.toString(),

      'has_books_or_games':
          librosOJuegos.toString(),
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'photo1',
        fotoPrincipal.path,
      ),
    );

    if (foto2 != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo2',
          foto2.path,
        ),
      );
    }

    if (foto3 != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo3',
          foto3.path,
        ),
      );
    }

    final streamedResponse = await request
        .send()
        .timeout(
          const Duration(seconds: 30),
        );

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    final dynamic decodedData =
        jsonDecode(response.body);

    if (decodedData
        is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta del servidor no es válida.',
      );
    }

    if (response.statusCode != 201) {
      final message =
          decodedData['message'];

      if (message is String &&
          message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception(
        'No pudimos agregar la cafetería.',
      );
    }

    return decodedData;
  }

  static Future<void> actualizarCafe({
    required int cafeId,
    required String nombre,
    required String direccion,
    required String localidad,
    required String provincia,
    required String descripcion,
    required String telefono,
    required String instagram,
    required String googleMapsUrl,
    required double latitude,
    required double longitude,
    XFile? fotoPrincipal,
    XFile? foto2,
    XFile? foto3,
    required bool tieneWifi,
    required bool aireAcondicionado,
    required bool enchufes,
    required bool mesasAlAireLibre,
    required bool estacionamiento,
    required bool accesible,
    required bool cambiadorBebes,
    required bool petFriendly,
    required bool kidsFriendly,
    required bool cafeEspecialidad,
    required bool brunch,
    required bool desayuno,
    required bool alcohol,
    required bool pasteleriaArtesanal,
    required bool veganFriendly,
    required bool vegetariano,
    required bool sinTacc,
    required bool opcionesSaludables,
    required bool sinAzucar,
    required bool lechesVegetales,
    required bool jardin,
    required bool vistaAgua,
    required bool vistaMontanas,
    required bool rodeadoNaturaleza,
    required bool terrazaRooftop,
    required bool ventanalesGrandes,
    required bool casaAntigua,
    required bool edificioHistorico,
    required bool dentroLibreria,
    required bool espacioCultural,
    required bool librosOJuegos,
  }) async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión activa.',
      );
    }

    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse(
        '$baseUrl/cafes/$cafeId/update/',
      ),
    );

    request.headers.addAll({
      'Authorization': 'Token $token',
      'Accept': 'application/json',
    });

    request.fields.addAll({
      'name': nombre,
      'address': direccion,
      'location': localidad,
      'province': provincia,
      'description': descripcion,
      'phone': telefono,
      'instagram': instagram,
      'google_maps_url': googleMapsUrl,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),

      'has_wifi': tieneWifi.toString(),
      'has_air_conditioning':
          aireAcondicionado.toString(),
      'has_power_outlets':
          enchufes.toString(),
      'has_outdoor_seating':
          mesasAlAireLibre.toString(),
      'has_parking':
          estacionamiento.toString(),
      'is_accessible':
          accesible.toString(),
      'has_baby_changing':
          cambiadorBebes.toString(),
      'is_pet_friendly':
          petFriendly.toString(),
      'is_kids_friendly':
          kidsFriendly.toString(),

      'has_specialty_coffee':
          cafeEspecialidad.toString(),
      'serves_brunch':
          brunch.toString(),
      'serves_breakfast':
          desayuno.toString(),
      'serves_alcohol':
          alcohol.toString(),
      'has_artisanal_pastries':
          pasteleriaArtesanal.toString(),

      'is_vegan_friendly':
          veganFriendly.toString(),
      'has_vegetarian_options':
          vegetariano.toString(),
      'has_gluten_free_options':
          sinTacc.toString(),
      'has_healthy_options':
          opcionesSaludables.toString(),
      'has_sugar_free_options':
          sinAzucar.toString(),
      'has_plant_based_milk':
          lechesVegetales.toString(),

      'has_garden':
          jardin.toString(),
      'has_water_view':
          vistaAgua.toString(),
      'has_mountain_view':
          vistaMontanas.toString(),
      'surrounded_by_nature':
          rodeadoNaturaleza.toString(),
      'has_rooftop':
          terrazaRooftop.toString(),
      'has_large_windows':
          ventanalesGrandes.toString(),
      'is_old_house':
          casaAntigua.toString(),
      'is_historic_building':
          edificioHistorico.toString(),
      'inside_bookstore':
          dentroLibreria.toString(),
      'inside_cultural_space':
          espacioCultural.toString(),

      'has_books_or_games':
          librosOJuegos.toString(),
    });

    if (fotoPrincipal != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo1',
          fotoPrincipal.path,
        ),
      );
    }

    if (foto2 != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo2',
          foto2.path,
        ),
      );
    }

    if (foto3 != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo3',
          foto3.path,
        ),
      );
    }

    final streamedResponse = await request
        .send()
        .timeout(
          const Duration(seconds: 30),
        );

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode != 200) {
      String mensaje =
          'No pudimos actualizar la cafetería.';

      try {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> &&
            data['message'] != null) {
          mensaje =
              data['message'].toString();
        }
      } catch (_) {}

      throw Exception(mensaje);
    }
  }

  static Future<Map<String, dynamic>>
      obtenerCafeDetalle(int cafeId) async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión activa.',
      );
    }

    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/cafes/$cafeId/',
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
        'No pudimos cargar la cafetería.',
      );
    }

    final dynamic decodedData =
        jsonDecode(response.body);

    if (decodedData
        is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta del servidor no es válida.',
      );
    }

    return decodedData;
  }

  static Future<List<Map<String, dynamic>>>
      obtenerMisCafeterias() async {
    final token = await AuthService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión activa.',
      );
    }

    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/cafes/mine/',
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
        'No pudimos cargar tus cafeterías.',
      );
    }

    final dynamic decodedData =
        jsonDecode(response.body);

    if (decodedData is! List) {
      throw Exception(
        'La respuesta del servidor no es válida.',
      );
    }

    return decodedData
        .whereType<Map<String, dynamic>>()
        .toList();
  }
}