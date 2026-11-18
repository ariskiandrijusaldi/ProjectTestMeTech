import 'package:flutter/material.dart';

/// Ikon tampilan untuk tiap jenis kategori barang.
/// Hanya untuk kebutuhan visual; tidak memengaruhi data/logic.
IconData categoryIcon(String? name) {
  final n = (name ?? '').trim().toLowerCase();

  if (n.contains('elektronik') || n.contains('electronic')) {
    return Icons.devices_other;
  }
  if (n.contains('peralatan') || n.contains('equipment') || n.contains('alat')) {
    return Icons.handyman_outlined;
  }
  if (n.contains('sains') || n.contains('science')) {
    return Icons.science_outlined;
  }
  if (n.contains('sastra') || n.contains('literature') || n.contains('buku')) {
    return Icons.auto_stories_outlined;
  }
  if (n.contains('teknologi') || n.contains('technology') || n.contains('komputer')) {
    return Icons.memory;
  }
  if (n.contains('olahraga') || n.contains('sport')) {
    return Icons.sports_basketball_outlined;
  }
  if (n.contains('seni') || n.contains('art')) {
    return Icons.palette_outlined;
  }
  if (n.contains('musik') || n.contains('music')) {
    return Icons.music_note_outlined;
  }

  return Icons.inventory_2_outlined;
}
