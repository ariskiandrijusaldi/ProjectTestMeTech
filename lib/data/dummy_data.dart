import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/loan.dart';

// TODO: ganti dengan repository + API saat backend siap.
const dummyBooks = <Book>[
  Book(
      id: '1',
      title: 'Pemrograman Flutter',
      author: 'Andi Wijaya',
      category: 'Teknologi',
      stock: 10,
      description:
          'Panduan membangun aplikasi mobile lintas platform dengan Flutter dari dasar hingga mahir.',
      color: Color(0xFF1B4F84)),
  Book(
      id: '2',
      title: 'Basis Data Dasar',
      author: 'Siti Rahma',
      category: 'Teknologi',
      stock: 8,
      description:
          'Pengantar konsep basis data relasional, SQL, dan perancangan database.',
      color: Color(0xFF2E7D6B)),
  Book(
      id: '3',
      title: 'Fisika Dasar',
      author: 'Budi Santoso',
      category: 'Sains',
      stock: 5,
      description:
          'Materi fisika dasar untuk mahasiswa tahun pertama beserta contoh soal.',
      color: Color(0xFFB5651D)),
  Book(
      id: '4',
      title: 'Kumpulan Cerpen Kampus',
      author: 'Rina Maharani',
      category: 'Sastra',
      stock: 7,
      description: 'Kumpulan cerita pendek karya mahasiswa dan alumni.',
      color: Color(0xFF7B3FA0)),
];

const dummyLoans = <Loan>[
  Loan(
      code: '#PJ250701',
      bookTitle: 'Pemrograman Flutter',
      status: LoanStatus.pending,
      submittedAt: '1 Jul 2025, 10:00',
      dateLabel: 'Diajukan pada 1 Jul 2025'),
  Loan(
      code: '#PJ250702',
      bookTitle: 'Basis Data Dasar',
      status: LoanStatus.approved,
      submittedAt: '1 Jul 2025, 09:00',
      processedAt: '1 Jul 2025, 11:00',
      dateLabel: 'Disetujui pada 1 Jul 2025'),
  Loan(
      code: '#PJ250620',
      bookTitle: 'Fisika Dasar',
      status: LoanStatus.returned,
      submittedAt: '15 Jun 2025, 08:00',
      processedAt: '15 Jun 2025, 10:00',
      dateLabel: 'Dikembalikan pada 20 Jun 2025'),
  Loan(
      code: '#PJ250610',
      bookTitle: 'Kumpulan Cerpen Kampus',
      status: LoanStatus.rejected,
      submittedAt: '10 Jun 2025, 13:00',
      processedAt: '10 Jun 2025, 15:00',
      dateLabel: 'Ditolak pada 10 Jun 2025'),
];
