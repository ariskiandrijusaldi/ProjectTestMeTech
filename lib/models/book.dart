import 'package:flutter/material.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final int stock; // jumlah eksemplar tersedia
  final String description;
  final Color color; // warna sampul sementara (sebelum ada gambar)

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.stock,
    required this.description,
    required this.color,
  });
}
