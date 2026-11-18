class ApiBook {
  final int id;
  final int? categoryId;
  final String? isbn;
  final String title;
  final String author;
  final String? publisher;
  final int? year;
  final String? synopsis;
  final String? coverUrl;
  final String? rackLocation;
  final int stockTotal;
  final int stockAvailable;
  final bool isAvailable;
  final Map<String, dynamic>? category;

  ApiBook({
    required this.id,
    this.categoryId,
    this.isbn,
    required this.title,
    required this.author,
    this.publisher,
    this.year,
    this.synopsis,
    this.coverUrl,
    this.rackLocation,
    required this.stockTotal,
    required this.stockAvailable,
    required this.isAvailable,
    this.category,
  });

  factory ApiBook.fromJson(Map<String, dynamic> json) => ApiBook(
        id: json['id'] as int,
        categoryId: json['category_id'] as int?,
        isbn: json['isbn'] as String?,
        title: json['title'] as String,
        author: json['author'] as String,
        publisher: json['publisher'] as String?,
        year: json['year'] as int?,
        synopsis: json['synopsis'] as String?,
        coverUrl: json['cover_url'] as String?,
        rackLocation: json['rack_location'] as String?,
        stockTotal: (json['stock_total'] as num).toInt(),
        stockAvailable: (json['stock_available'] as num).toInt(),
        isAvailable: json['is_available'] as bool? ?? false,
        category: json['category'] as Map<String, dynamic>?,
      );
}