import 'book.dart';

class CartItem {
  final String? id; // Cart item ID from Supabase
  final String? cartItemId; // Alias for id
  final Book book;
  final int quantity;

  CartItem({
    this.id,
    String? cartItemId,
    required this.book,
    this.quantity = 1,
  }) : cartItemId = cartItemId ?? id;

  double get totalPrice => book.price * quantity;

  CartItem copyWith({
    String? id,
    String? cartItemId,
    Book? book,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      cartItemId: cartItemId ?? this.cartItemId,
      book: book ?? this.book,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      book: Book.fromJson(json['book']),
      quantity: json['quantity'],
    );
  }
}
