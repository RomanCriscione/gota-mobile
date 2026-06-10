class Cafe {
  final int? id;
  final String nombre;
  final String zona;
  final String rating;
  final String foto;

  Cafe({
    this.id,
    required this.nombre,
    required this.zona,
    required this.rating,
    required this.foto,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'zona': zona,
      'rating': rating,
      'foto': foto,
    };
  }

  factory Cafe.fromJson(Map<String, dynamic> json) {
    return Cafe(
      id: json['id'],

      // API Django
      nombre: json['name'] ?? json['nombre'] ?? '',

      zona: json['location'] ?? json['zona'] ?? '',

      rating: json['average_rating']?.toString() ??
          json['rating']?.toString() ??
          '0.0',


      foto: json['photo1_url'] ??
        json['foto'] ??
        'https://picsum.photos/300',
    );
  }
}