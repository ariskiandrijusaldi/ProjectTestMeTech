import 'package:flutter/material.dart';
import '../../models/book.dart';

// Sampul sementara. TODO: ganti dengan Image.asset / Image.network.
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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: book.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.menu_book, color: Colors.white, size: width * 0.5),
    );
  }
}
