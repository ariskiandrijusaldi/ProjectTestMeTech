import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../theme/app_theme.dart';
import 'category_icon.dart';

// Sampul buku: tampilkan gambar dari coverUrl jika ada, fallback warna.
class BookCover extends StatelessWidget {
  final Book book;
  final double width;
  final double height;

  const BookCover({
    super.key,
    required this.book,
    this.width = 56,
    this.height = 76,
  });

  @override
  Widget build(BuildContext context) {
    final cover = book.coverUrl;
    if (cover != null && cover.isNotEmpty && cover.startsWith('http')) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.thumb,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          cover,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) => _fallback,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _fallback,
        ),
      );
    }
    return _fallback;
  }

  Widget get _fallback => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: book.color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          categoryIcon(book.category),
          color: Colors.white,
          size: width * 0.5,
        ),
      );
}