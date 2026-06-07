import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cafe.dart';

class AppState {
  static List<Cafe> quieroIr = [];
  static List<Cafe> quieroVolver = [];
  static List<Cafe> yaFui = [];

  static Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();

    final quieroIrJson =
        prefs.getStringList('quiero_ir') ?? [];

    quieroIr = quieroIrJson
        .map(
          (item) => Cafe.fromJson(
            jsonDecode(item),
          ),
        )
        .toList();

    final quieroVolverJson =
        prefs.getStringList('quiero_volver') ?? [];

    quieroVolver = quieroVolverJson
        .map(
          (item) => Cafe.fromJson(
            jsonDecode(item),
          ),
        )
        .toList();

    final yaFuiJson =
        prefs.getStringList('ya_fui') ?? [];

    yaFui = yaFuiJson
        .map(
          (item) => Cafe.fromJson(
            jsonDecode(item),
          ),
        )
        .toList();
  }

  static Future<void> guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();

    final quieroIrJson =
        quieroIr.map((cafe) => jsonEncode(cafe.toJson())).toList();

    await prefs.setStringList(
      'quiero_ir',
      quieroIrJson,
    );

    final quieroVolverJson =
        quieroVolver.map((cafe) => jsonEncode(cafe.toJson())).toList();

    await prefs.setStringList(
      'quiero_volver',
      quieroVolverJson,
    );

    final yaFuiJson =
        yaFui.map((cafe) => jsonEncode(cafe.toJson())).toList();

    await prefs.setStringList(
      'ya_fui',
      yaFuiJson,
    );
  }
}