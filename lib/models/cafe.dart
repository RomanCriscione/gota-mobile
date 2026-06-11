class Cafe {
  final int? id;
  final String nombre;
  final String zona;
  final String rating;
  final String foto;
  final String foto2;
  final String foto3;

  final String direccion;
  final bool tieneWifi;
  final bool petFriendly;
  final bool veganFriendly;

  final List<String> tags;

  Cafe({
    this.id,
    required this.nombre,
    required this.zona,
    required this.rating,
    required this.foto,
    this.foto2 = '',
    this.foto3 = '',
    this.direccion = '',
    this.tieneWifi = false,
    this.petFriendly = false,
    this.veganFriendly = false,
    this.tags = const [],
  });

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
      'veganFriendly': veganFriendly,
      'tags': tags,
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

      tieneWifi: json['has_wifi'] ?? false,

      petFriendly: json['is_pet_friendly'] ?? false,

      veganFriendly: json['is_vegan_friendly'] ?? false,

      tags: json['top_tags'] != null
          ? List<String>.from(json['top_tags'])
          : [],
    );
  }
}