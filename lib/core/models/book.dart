enum BookCondition {
  likeNew,
  veryGood,
  good,
  acceptable,
}

extension BookConditionExtension on BookCondition {
  String get label {
    switch (this) {
      case BookCondition.likeNew:
        return 'Seperti Baru';
      case BookCondition.veryGood:
        return 'Sangat Baik';
      case BookCondition.good:
        return 'Baik';
      case BookCondition.acceptable:
        return 'Cukup';
    }
  }

  String localizedLabel(bool isId) {
    switch (this) {
      case BookCondition.likeNew:
        return isId ? 'Seperti Baru' : 'Like New';
      case BookCondition.veryGood:
        return isId ? 'Sangat Baik' : 'Very Good';
      case BookCondition.good:
        return isId ? 'Baik' : 'Good';
      case BookCondition.acceptable:
        return isId ? 'Cukup' : 'Acceptable';
    }
  }

  String get description {
    switch (this) {
      case BookCondition.likeNew:
        return 'Kondisi mulus, tanpa tanda pemakaian';
      case BookCondition.veryGood:
        return 'Sedikit tanda pemakaian, halaman utuh';
      case BookCondition.good:
        return 'Ada tanda pemakaian, semua halaman lengkap';
      case BookCondition.acceptable:
        return 'Masih bisa dibaca dengan tanda pemakaian terlihat';
    }
  }

  String localizedDescription(bool isId) {
    switch (this) {
      case BookCondition.likeNew:
        return isId ? 'Kondisi mulus, tanpa tanda pemakaian' : 'Perfect condition, no signs of use';
      case BookCondition.veryGood:
        return isId ? 'Sedikit tanda pemakaian, halaman utuh' : 'Minimal signs of use, pages intact';
      case BookCondition.good:
        return isId ? 'Ada tanda pemakaian, semua halaman lengkap' : 'Some signs of use, all pages complete';
      case BookCondition.acceptable:
        return isId ? 'Masih bisa dibaca dengan tanda pemakaian terlihat' : 'Readable with visible signs of use';
    }
  }

  /// Convert to Supabase database value
  String toSupabaseValue() {
    switch (this) {
      case BookCondition.likeNew:
        return 'like_new';
      case BookCondition.veryGood:
        return 'very_good';
      case BookCondition.good:
        return 'good';
      case BookCondition.acceptable:
        return 'acceptable';
    }
  }

  /// Create from Supabase database value
  static BookCondition fromSupabaseValue(String value) {
    switch (value) {
      case 'like_new':
        return BookCondition.likeNew;
      case 'very_good':
        return BookCondition.veryGood;
      case 'good':
        return BookCondition.good;
      case 'acceptable':
        return BookCondition.acceptable;
      default:
        return BookCondition.good;
    }
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final double price;
  final double originalPrice;
  final String category;
  final String imageUrl;
  final BookCondition condition;
  final String isbn;
  final int stock;
  final double rating;
  final int reviewCount;
  final String publisher;
  final int year;
  final int pages;
  final String language;
  final DateTime addedDate;
  final String? sellerName;
  final String? sellerLocation;
  final String? sellerId;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.category,
    required this.imageUrl,
    required this.condition,
    required this.isbn,
    this.stock = 1,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.publisher = '',
    this.year = 2020,
    this.pages = 0,
    this.language = 'English',
    DateTime? addedDate,
    this.sellerName,
    this.sellerLocation,
    this.sellerId,
  }) : addedDate = addedDate ?? DateTime.now();

  /// Empty book constructor for fallback
  factory Book.empty() {
    return Book(
      id: '',
      title: '',
      author: '',
      description: '',
      price: 0,
      originalPrice: 0,
      category: '',
      imageUrl: '',
      condition: BookCondition.good,
      isbn: '',
    );
  }

  double get discountPercentage {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - price) / originalPrice * 100).roundToDouble();
  }

  bool get hasDiscount => price < originalPrice;

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    double? price,
    double? originalPrice,
    String? category,
    String? imageUrl,
    BookCondition? condition,
    String? isbn,
    int? stock,
    double? rating,
    int? reviewCount,
    String? publisher,
    int? year,
    int? pages,
    String? language,
    DateTime? addedDate,
    String? sellerName,
    String? sellerLocation,
    String? sellerId,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      condition: condition ?? this.condition,
      isbn: isbn ?? this.isbn,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      publisher: publisher ?? this.publisher,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      language: language ?? this.language,
      addedDate: addedDate ?? this.addedDate,
      sellerName: sellerName ?? this.sellerName,
      sellerLocation: sellerLocation ?? this.sellerLocation,
      sellerId: sellerId ?? this.sellerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'category': category,
      'imageUrl': imageUrl,
      'condition': condition.index,
      'isbn': isbn,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'publisher': publisher,
      'year': year,
      'pages': pages,
      'language': language,
      'addedDate': addedDate.toIso8601String(),
      'sellerName': sellerName,
      'sellerLocation': sellerLocation,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      category: json['category'],
      imageUrl: json['imageUrl'],
      condition: BookCondition.values[json['condition']],
      isbn: json['isbn'],
      stock: json['stock'] ?? 1,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      publisher: json['publisher'] ?? '',
      year: json['year'] ?? 2020,
      pages: json['pages'] ?? 0,
      language: json['language'] ?? 'English',
      addedDate: json['addedDate'] != null ? DateTime.parse(json['addedDate']) : null,
      sellerName: json['sellerName'],
      sellerLocation: json['sellerLocation'],
    );
  }

  /// Factory constructor for Supabase data
  factory Book.fromSupabase(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0,
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? '',
      condition: BookConditionExtension.fromSupabaseValue(json['condition'] ?? 'good'),
      isbn: json['isbn'] ?? '',
      stock: json['stock'] ?? 1,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['sold_count'] ?? 0,
      publisher: json['publisher'] ?? '',
      year: json['publish_year'] ?? 2020,
      pages: json['pages'] ?? 0,
      language: json['language'] ?? 'Indonesian',
      addedDate: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      sellerName: profiles?['full_name'],
      sellerLocation: null,
      sellerId: json['seller_id'],
    );
  }

  /// Get weight property (not in constructor but needed for Supabase)
  int get weight => pages ~/ 2; // Approximate weight
  int get publishYear => year;
}
