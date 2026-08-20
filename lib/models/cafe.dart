class Cafe {
  final int? id;
  final String nombre;
  final String zona;
  final String rating;
  final String foto;
  final String foto2;
  final String foto3;

  final String direccion;
  final double? latitude;
  final double? longitude;

  final bool tieneWifi;
  final bool petFriendly;
  final bool kidsFriendly;
  final bool veganFriendly;
  final bool aireAcondicionado;
  final bool enchufes;
  final bool mesasAlAireLibre;
  final bool estacionamiento;
  final bool accesible;
  final bool cambiadorBebes;

  final bool cafeEspecialidad;
  final bool brunch;
  final bool desayuno;
  final bool alcohol;
  final bool pasteleriaArtesanal;

  final bool vegetariano;
  final bool sinTacc;
  final bool opcionesSaludables;
  final bool sinAzucar;
  final bool lechesVegetales;

  final bool jardin;
  final bool vistaAgua;
  final bool vistaMontanas;
  final bool rodeadoNaturaleza;
  final bool terrazaRooftop;
  final bool ventanalesGrandes;
  final bool casaAntigua;
  final bool edificioHistorico;
  final bool dentroLibreria;
  final bool espacioCultural;

  final bool laptopFriendly;
  final bool espacioTranquilo;

  final bool librosOJuegos;

  final List<String> tags;
  final String? collection;

  Cafe({
    this.id,
    required this.nombre,
    required this.zona,
    required this.rating,
    required this.foto,
    this.foto2 = '',
    this.foto3 = '',
    this.direccion = '',
    this.latitude,
    this.longitude,
    this.tieneWifi = false,
    this.petFriendly = false,
    this.kidsFriendly = false,
    this.veganFriendly = false,
    this.aireAcondicionado = false,
    this.enchufes = false,
    this.mesasAlAireLibre = false,
    this.estacionamiento = false,
    this.accesible = false,
    this.cambiadorBebes = false,

    this.cafeEspecialidad = false,
    this.brunch = false,
    this.desayuno = false,
    this.alcohol = false,
    this.pasteleriaArtesanal = false,

    this.vegetariano = false,
    this.sinTacc = false,
    this.opcionesSaludables = false,
    this.sinAzucar = false,
    this.lechesVegetales = false,

    this.jardin = false,
    this.vistaAgua = false,
    this.vistaMontanas = false,
    this.rodeadoNaturaleza = false,
    this.terrazaRooftop = false,
    this.ventanalesGrandes = false,
    this.casaAntigua = false,
    this.edificioHistorico = false,
    this.dentroLibreria = false,
    this.espacioCultural = false,

    this.laptopFriendly = false,
    this.espacioTranquilo = false,

    this.librosOJuegos = false,
    this.tags = const [],
    this.collection,
  });

  Cafe copyWith({
    String? collection,
    }) {
    return Cafe(
        id: id,
        nombre: nombre,
        zona: zona,
        rating: rating,
        foto: foto,
        foto2: foto2,
        foto3: foto3,
        direccion: direccion,
        latitude: latitude,
        longitude: longitude,
        tieneWifi: tieneWifi,
        petFriendly: petFriendly,
        kidsFriendly: kidsFriendly,
        veganFriendly: veganFriendly,
        aireAcondicionado: aireAcondicionado,
        enchufes: enchufes,
        mesasAlAireLibre: mesasAlAireLibre,
        estacionamiento: estacionamiento,
        accesible: accesible,
        cambiadorBebes: cambiadorBebes,
        cafeEspecialidad: cafeEspecialidad,
        brunch: brunch,
        desayuno: desayuno,
        alcohol: alcohol,
        pasteleriaArtesanal: pasteleriaArtesanal,
        vegetariano: vegetariano,
        sinTacc: sinTacc,
        opcionesSaludables: opcionesSaludables,
        sinAzucar: sinAzucar,
        lechesVegetales: lechesVegetales,

        jardin: jardin,
        vistaAgua: vistaAgua,
        vistaMontanas: vistaMontanas,
        rodeadoNaturaleza: rodeadoNaturaleza,
        terrazaRooftop: terrazaRooftop,
        ventanalesGrandes: ventanalesGrandes,
        casaAntigua: casaAntigua,
        edificioHistorico: edificioHistorico,
        dentroLibreria: dentroLibreria,
        espacioCultural: espacioCultural,

        laptopFriendly: laptopFriendly,
        espacioTranquilo: espacioTranquilo,
        librosOJuegos: librosOJuegos,
        tags: tags,
        collection: collection ?? this.collection,
    );
    }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'zona': zona,
      'rating': rating,
      'foto': foto,
      'foto2': foto2,
      'foto3': foto3,
      'direccion': direccion,
      'tieneWifi': tieneWifi,
      'petFriendly': petFriendly,
      'kidsFriendly': kidsFriendly,
      'veganFriendly': veganFriendly,
      'aireAcondicionado': aireAcondicionado,
      'enchufes': enchufes,
      'mesasAlAireLibre': mesasAlAireLibre,
      'estacionamiento': estacionamiento,
      'accesible': accesible,
      'cambiadorBebes': cambiadorBebes,

      'cafeEspecialidad': cafeEspecialidad,
      'brunch': brunch,
      'desayuno': desayuno,
      'alcohol': alcohol,
      'pasteleriaArtesanal': pasteleriaArtesanal,

      'vegetariano': vegetariano,
      'sinTacc': sinTacc,
      'opcionesSaludables': opcionesSaludables,
      'sinAzucar': sinAzucar,
      'lechesVegetales': lechesVegetales,

      'jardin': jardin,
      'vistaAgua': vistaAgua,
      'vistaMontanas': vistaMontanas,
      'rodeadoNaturaleza': rodeadoNaturaleza,
      'terrazaRooftop': terrazaRooftop,
      'ventanalesGrandes': ventanalesGrandes,
      'casaAntigua': casaAntigua,
      'edificioHistorico': edificioHistorico,
      'dentroLibreria': dentroLibreria,
      'espacioCultural': espacioCultural,

      'laptopFriendly': laptopFriendly,
      'espacioTranquilo': espacioTranquilo,

      'librosOJuegos': librosOJuegos,
      'tags': tags,
      'collection': collection,
    };
  }

  factory Cafe.fromJson(Map<String, dynamic> json) {
    return Cafe(
      id: json['id'],

      nombre: json['name'] ?? json['nombre'] ?? '',

      zona: json['location'] ?? json['zona'] ?? '',

      rating: json['average_rating']?.toString() ??
          json['rating']?.toString() ??
          '0.0',

      foto: json['photo1_url'] ??
          json['foto'] ??
          'https://picsum.photos/300',
      foto2: json['photo2_url'] ?? '',
      foto3: json['photo3_url'] ?? '',

      direccion: json['address'] ??
          json['direccion'] ??
          '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),

      tieneWifi: json['has_wifi'] ?? false,

      petFriendly: json['is_pet_friendly'] ?? false,
      kidsFriendly: json['is_kids_friendly'] ?? false,

      veganFriendly: json['is_vegan_friendly'] ?? false,

      aireAcondicionado:
          json['has_air_conditioning'] ?? false,

      enchufes:
          json['has_power_outlets'] ?? false,

      mesasAlAireLibre:
          json['has_outdoor_seating'] ?? false,

      estacionamiento:
          json['has_parking'] ?? false,

      accesible:
          json['is_accessible'] ?? false,

      cambiadorBebes:
          json['has_baby_changing'] ?? false,

      cafeEspecialidad:
          json['has_specialty_coffee'] ?? false,

      brunch:
          json['serves_brunch'] ?? false,

      desayuno:
          json['serves_breakfast'] ?? false,

      alcohol:
          json['serves_alcohol'] ?? false,

      pasteleriaArtesanal:
          json['has_artisanal_pastries'] ?? false,

      vegetariano:
          json['has_vegetarian_options'] ?? false,

      sinTacc:
          json['has_gluten_free_options'] ?? false,

      opcionesSaludables:
          json['has_healthy_options'] ?? false,

      sinAzucar:
          json['has_sugar_free_options'] ?? false,

      lechesVegetales:
          json['has_plant_based_milk'] ?? false,

      jardin:
          json['has_garden'] ?? false,

      vistaAgua:
          json['has_water_view'] ?? false,

      vistaMontanas:
          json['has_mountain_view'] ?? false,

      rodeadoNaturaleza:
          json['surrounded_by_nature'] ?? false,

      terrazaRooftop:
          json['has_rooftop'] ?? false,

      ventanalesGrandes:
          json['has_large_windows'] ?? false,

      casaAntigua:
          json['is_old_house'] ?? false,

      edificioHistorico:
          json['is_historic_building'] ?? false,

      dentroLibreria:
          json['inside_bookstore'] ?? false,

      espacioCultural:
          json['inside_cultural_space'] ?? false,

      laptopFriendly:
          json['laptop_friendly'] ?? false,

      espacioTranquilo:
          json['quiet_space'] ?? false,

      librosOJuegos:
          json['has_books_or_games'] ?? false,

        tags: json['top_tags'] != null
            ? List<String>.from(json['top_tags'])
            : (json['tags'] != null
                ? List<String>.from(json['tags'])
                : []),

        collection: json['collection'],
    );
  }
}