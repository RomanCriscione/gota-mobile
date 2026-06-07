class Cafe {
  final String nombre;
  final String zona;
  final String rating;
  final String foto;

  Cafe({
    required this.nombre,
    required this.zona,
    required this.rating,
    required this.foto,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'zona': zona,
      'rating': rating,
      'foto': foto,
    };
  }

  factory Cafe.fromJson(Map<String, dynamic> json) {
    return Cafe(
      nombre: json['nombre'],
      zona: json['zona'],
      rating: json['rating'],
      foto: json['foto'],
    );
  }
}