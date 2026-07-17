class CafeRelationship {
  final int cafeId;
  final String cafeName;
  final String cafeLocation;
  final String cafeAddress;
  final String cafePhoto;
  final String averageRating;
  final String status;
  final String? collection;
  final String? privateNote;
  final String? secondImpression;
  final DateTime? updatedAt;

  CafeRelationship({
    required this.cafeId,
    required this.cafeName,
    required this.cafeLocation,
    required this.cafeAddress,
    required this.cafePhoto,
    required this.averageRating,
    required this.status,
    this.collection,
    this.privateNote,
    this.secondImpression,
    this.updatedAt,
  });

  factory CafeRelationship.fromJson(
    Map<String, dynamic> json,
  ) {
    return CafeRelationship(
      cafeId: json['cafe_id'],
      cafeName: json['cafe_name'] ?? '',
      cafeLocation: json['cafe_location'] ?? '',
      cafeAddress: json['cafe_address'] ?? '',
      cafePhoto:
          json['cafe_photo'] ??
          'https://picsum.photos/300',
      averageRating:
          json['average_rating']?.toString() ??
          '0.0',
      status: json['status'] ?? '',
      collection: json['collection'],
      privateNote: json['private_note'],
      secondImpression:
          json['second_impression']?.toString(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
}