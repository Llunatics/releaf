import 'cart_item.dart';
import 'book.dart';

enum TransactionStatus {
  pending,
  processing,
  shipped,
  completed,
  cancelled,
}

extension TransactionStatusExtension on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.shipped:
        return 'Shipped';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get description {
    switch (this) {
      case TransactionStatus.pending:
        return 'Waiting for payment confirmation';
      case TransactionStatus.processing:
        return 'Order is being prepared';
      case TransactionStatus.shipped:
        return 'Order has been shipped';
      case TransactionStatus.completed:
        return 'Order delivered successfully';
      case TransactionStatus.cancelled:
        return 'Order has been cancelled';
    }
  }
}

class BookTransaction {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime date;
  final TransactionStatus status;
  final String? shippingAddress;
  final String? notes;
  final String? trackingNumber;

  BookTransaction({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.date,
    this.status = TransactionStatus.pending,
    this.shippingAddress,
    this.notes,
    this.trackingNumber,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  BookTransaction copyWith({
    String? id,
    List<CartItem>? items,
    double? totalAmount,
    DateTime? date,
    TransactionStatus? status,
    String? shippingAddress,
    String? notes,
    String? trackingNumber,
  }) {
    return BookTransaction(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      date: date ?? this.date,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      notes: notes ?? this.notes,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'status': status.index,
      'shippingAddress': shippingAddress,
      'notes': notes,
      'trackingNumber': trackingNumber,
    };
  }

  factory BookTransaction.fromJson(Map<String, dynamic> json) {
    return BookTransaction(
      id: json['id'],
      items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      status: TransactionStatus.values[json['status']],
      shippingAddress: json['shippingAddress'],
      notes: json['notes'],
      trackingNumber: json['trackingNumber'],
    );
  }

  /// Factory constructor for Supabase data
  factory BookTransaction.fromSupabase(Map<String, dynamic> json) {
    final items = json['transaction_items'] as List?;
    
    return BookTransaction(
      id: json['id'] ?? '',
      items: items?.map((item) {
        // Create a minimal Book from transaction_items
        final book = Book(
          id: item['book_id'] ?? '',
          title: item['book_title'] ?? '',
          author: item['book_author'] ?? '',
          description: '',
          price: (item['book_price'] as num?)?.toDouble() ?? 0,
          originalPrice: (item['book_price'] as num?)?.toDouble() ?? 0,
          category: '',
          imageUrl: '',
          condition: BookCondition.good,
          isbn: '',
        );
        return CartItem(
          book: book,
          quantity: item['quantity'] ?? 1,
        );
      }).toList() ?? [],
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      date: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      status: _parseStatus(json['status']),
      shippingAddress: json['shipping_address'],
      notes: json['notes'],
      trackingNumber: json['tracking_number'],
    );
  }

  static TransactionStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return TransactionStatus.pending;
      case 'processing':
        return TransactionStatus.processing;
      case 'shipped':
        return TransactionStatus.shipped;
      case 'completed':
        return TransactionStatus.completed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }
}
