import 'package:flutter/material.dart';
import '../models/cafe.dart';

class CafeCard extends StatelessWidget {
  final Cafe cafe;

  const CafeCard({
    super.key,
    required this.cafe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            cafe.foto,
            width: 82,
            height: 82,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          cafe.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          cafe.zona,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '⭐ ${cafe.rating}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}