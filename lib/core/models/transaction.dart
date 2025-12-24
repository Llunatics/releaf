import 'cart_item.dart';
import 'book.dart';

enum TransactionStatus {
  pending,
  processing,
  shipped,
  delivered,
  completed,
  cancelled,
}

extension TransactionStatusExtension on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.pending:
        return 'Menunggu';
      case TransactionStatus.processing:
        return 'Diproses';
      case TransactionStatus.shipped:
        return 'Dikirim';
      case TransactionStatus.delivered:
        return 'Diterima';
      case TransactionStatus.completed:
        return 'Selesai';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  String localizedLabel(bool isId) {
    switch (this) {
      case TransactionStatus.pending:
        return isId ? 'Menunggu' : 'Pending';
      case TransactionStatus.processing:
        return isId ? 'Diproses' : 'Processing';
      case TransactionStatus.shipped:
        return isId ? 'Dikirim' : 'Shipped';
      case TransactionStatus.delivered:
        return isId ? 'Diterima' : 'Delivered';
      case TransactionStatus.completed:
        return isId ? 'Selesai' : 'Completed';
      case TransactionStatus.cancelled:
        return isId ? 'Dibatalkan' : 'Cancelled';
    }
  }

  String get description {
    switch (this) {
      case TransactionStatus.pending:
        return 'Menunggu konfirmasi pembayaran';
      case TransactionStatus.processing:
        return 'Pesanan sedang disiapkan';
      case TransactionStatus.shipped:
        return 'Pesanan telah dikirim';
      case TransactionStatus.delivered:
        return 'Pesanan sudah sampai, menunggu konfirmasi';
      case TransactionStatus.completed:
        return 'Pesanan berhasil diterima';
      case TransactionStatus.cancelled:
        return 'Pesanan telah dibatalkan';
    }
  }

  String localizedDescription(bool isId) {
    switch (this) {
      case TransactionStatus.pending:
        return isId ? 'Menunggu konfirmasi pembayaran' : 'Waiting for payment confirmation';
      case TransactionStatus.processing:
        return isId ? 'Pesanan sedang disiapkan' : 'Order is being prepared';
      case TransactionStatus.shipped:
        return isId ? 'Pesanan telah dikirim' : 'Order has been shipped';
      case TransactionStatus.delivered:
        return isId ? 'Pesanan sudah sampai, menunggu konfirmasi' : 'Order has arrived, waiting for confirmation';
      case TransactionStatus.completed:
        return isId ? 'Pesanan berhasil diterima' : 'Order successfully received';
      case TransactionStatus.cancelled:
        return isId ? 'Pesanan telah dibatalkan' : 'Order has been cancelled';
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
  final DateTime? deliveredDate;
  final DateTime? autoAcceptDate;
  final String? review;
  final double? rating;

  BookTransaction({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.date,
    this.status = TransactionStatus.pending,
    this.shippingAddress,
    this.notes,
    this.trackingNumber,
    this.deliveredDate,
    this.autoAcceptDate,
    this.review,
    this.rating,
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
    DateTime? deliveredDate,
    DateTime? autoAcceptDate,
    String? review,
    double? rating,
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
      deliveredDate: deliveredDate ?? this.deliveredDate,
      autoAcceptDate: autoAcceptDate ?? this.autoAcceptDate,
      review: review ?? this.review,
      rating: rating ?? this.rating,
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
      'deliveredDate': deliveredDate?.toIso8601String(),
      'autoAcceptDate': autoAcceptDate?.toIso8601String(),
      'review': review,
      'rating': rating,
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
      deliveredDate: json['deliveredDate'] != null ? DateTime.parse(json['deliveredDate']) : null,
      autoAcceptDate: json['autoAcceptDate'] != null ? DateTime.parse(json['autoAcceptDate']) : null,
      review: json['review'],
      rating: json['rating']?.toDouble(),
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
      deliveredDate: json['delivered_date'] != null ? DateTime.parse(json['delivered_date']) : null,
      autoAcceptDate: json['auto_accept_date'] != null ? DateTime.parse(json['auto_accept_date']) : null,
      review: json['review'],
      rating: json['rating']?.toDouble(),
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
      case 'delivered':
        return TransactionStatus.delivered;
      case 'completed':
        return TransactionStatus.completed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }
  
  /// Check if transaction can be auto-accepted (1 day after delivered)
  bool get canAutoAccept {
    if (status != TransactionStatus.delivered || deliveredDate == null) {
      return false;
    }
    final daysSinceDelivered = DateTime.now().difference(deliveredDate!).inDays;
    return daysSinceDelivered >= 1;
  }
  
  /// Check if transaction needs confirmation
  bool get needsConfirmation {
    return status == TransactionStatus.delivered;
  }
}
