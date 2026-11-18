import 'package:flutter/material.dart';
import '../core/models/api_book.dart';
import '../core/theme/app_theme.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final int stock; // jumlah eksemplar tersedia
  final String description;
  final Color color; // warna sampul sementara (sebelum ada gambar)
  final String? coverUrl;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.stock,
    required this.description,
    required this.color,
    this.coverUrl,
  });

  factory Book.fromApi(ApiBook api) => Book(
        id: api.id.toString(),
        title: api.title,
        author: api.author,
        category: api.category?['name'] ?? '-',
        stock: api.stockAvailable,
        description: api.synopsis ?? '',
        color: AppColors.primary,
        coverUrl: api.coverUrl,
      );
}