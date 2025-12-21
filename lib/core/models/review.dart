class BookReview {
  final String id;
  final String bookId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? userAvatar;

  BookReview({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userAvatar,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'user_avatar': userAvatar,
    };
  }

  factory BookReview.fromJson(Map<String, dynamic> json) {
    return BookReview(
      id: json['id'] ?? '',
      bookId: json['book_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      userAvatar: json['user_avatar'],
    );
  }

  factory BookReview.fromSupabase(Map<String, dynamic> json) {
    return BookReview(
      id: json['id'] ?? '',
      bookId: json['book_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ??
          json['users']?['email']?.split('@')[0] ??
          'Anonymous',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      userAvatar: json['user_avatar'],
    );
  }
}
