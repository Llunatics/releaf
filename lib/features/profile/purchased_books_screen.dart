import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/models/transaction.dart';
import '../../core/providers/app_state.dart';
import '../../core/utils/page_transitions.dart';
import '../products/product_detail_screen.dart';

class PurchasedBooksScreen extends StatefulWidget {
  const PurchasedBooksScreen({super.key});

  @override
  State<PurchasedBooksScreen> createState() => _PurchasedBooksScreenState();
}

class _PurchasedBooksScreenState extends State<PurchasedBooksScreen> {
  String _filterStatus = 'all'; // all, completed, pending, shipped, cancelled

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final backgroundColor =
        isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary =
        isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final borderColor =
        isDark ? const Color(0xFF30363D) : const Color(0xFFE5E7EB);

    // Get all purchased books from transactions
    List<Map<String, dynamic>> purchasedBooks = [];
    for (var transaction in appState.transactions) {
      // Filter by status if needed
      if (_filterStatus == 'completed' &&
          transaction.status != TransactionStatus.completed) {
        continue;
      }
      if (_filterStatus == 'pending' &&
          (transaction.status == TransactionStatus.completed ||
              transaction.status == TransactionStatus.cancelled)) {
        continue;
      }
      if (_filterStatus == 'shipped' &&
          transaction.status != TransactionStatus.shipped) {
        continue;
      }
      if (_filterStatus == 'cancelled' &&
          transaction.status != TransactionStatus.cancelled) {
        continue;
      }

      for (var item in transaction.items) {
        purchasedBooks.add({
          'book': item.book,
          'quantity': item.quantity,
          'transaction': transaction,
          'purchaseDate': transaction.date,
        });
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buku yang Dibeli',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            Text(
              '${purchasedBooks.length} buku',
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Semua', 'all', purchasedBooks.length, isDark),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Selesai',
                  'completed',
                  appState.transactions
                      .where((t) => t.status == TransactionStatus.completed)
                      .fold(0, (sum, t) => sum + t.items.length),
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Dalam Proses',
                  'pending',
                  appState.transactions
                      .where((t) =>
                          t.status != TransactionStatus.completed &&
                          t.status != TransactionStatus.cancelled)
                      .fold(0, (sum, t) => sum + t.items.length),
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Dibatalkan',
                  'cancelled',
                  appState.transactions
                      .where((t) => t.status == TransactionStatus.cancelled)
                      .fold(0, (sum, t) => sum + t.items.length),
                  isDark,
                ),
              ],
            ),
          ),

          // Books List
          Expanded(
            child: purchasedBooks.isEmpty
                ? _buildEmptyState(isDark, textPrimary, textSecondary)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: purchasedBooks.length,
                    itemBuilder: (context, index) {
                      final data = purchasedBooks[index];
                      return _buildBookCard(
                        context,
                        data,
                        isDark,
                        cardColor,
                        textPrimary,
                        textSecondary,
                        borderColor,
                        currencyFormat,
                        index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count, bool isDark) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6)
              : (isDark ? const Color(0xFF161B22) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : (isDark ? const Color(0xFF30363D) : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF64748B)),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(
    BuildContext context,
    Map<String, dynamic> data,
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
    NumberFormat currencyFormat,
    int index,
  ) {
    final book = data['book'];
    final quantity = data['quantity'] as int;
    final transaction = data['transaction'] as BookTransaction;
    final purchaseDate = data['purchaseDate'] as DateTime;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransitions.slideUp(ProductDetailScreen(book: book)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 100,
                    color: isDark
                        ? const Color(0xFF0D1117)
                        : const Color(0xFFF3F4F6),
                    child: book.imageUrl.isNotEmpty
                        ? Image.network(
                            book.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.menu_book_rounded,
                              color: textSecondary,
                              size: 32,
                            ),
                          )
                        : Icon(
                            Icons.menu_book_rounded,
                            color: textSecondary,
                            size: 32,
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                // Book Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        book.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Author
                      Text(
                        book.author,
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Price & Quantity
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              currencyFormat.format(book.price),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'x$quantity',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: borderColor),
            const SizedBox(height: 12),

            // Transaction Info
            Row(
              children: [
                Icon(Icons.receipt_long, size: 16, color: textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Order #${transaction.id.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    transaction.status.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _getStatusColor(transaction.status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Purchase Date
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Dibeli: ${DateFormat('dd MMM yyyy, HH:mm').format(purchaseDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),

            // Review Section (if completed and has review)
            if (transaction.status == TransactionStatus.completed &&
                transaction.review != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0D1117)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.rate_review,
                            size: 16, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 6),
                        Text(
                          'Review Anda',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (transaction.rating != null)
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < transaction.rating!.floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 14,
                                color: const Color(0xFFFBBF24),
                              );
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transaction.review!,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50))
          .slideX(begin: 0.1, duration: 300.ms),
    );
  }

  Widget _buildEmptyState(bool isDark, Color textPrimary, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E3A5F).withValues(alpha: 0.3)
                  : const Color(0xFF3B82F6).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
            ),
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Pembelian',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Mulai jelajahi buku dan lakukan pembelian pertamamu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
        ],
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return const Color(0xFF10B981);
      case TransactionStatus.pending:
        return const Color(0xFFF59E0B);
      case TransactionStatus.cancelled:
        return const Color(0xFFEF4444);
      case TransactionStatus.delivered:
        return const Color(0xFF8B5CF6);
      case TransactionStatus.processing:
      case TransactionStatus.shipped:
        return const Color(0xFF3B82F6);
    }
  }
}
