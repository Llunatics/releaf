import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_state.dart';
import '../../core/models/book.dart';
import 'add_book_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Book book;

  const ProductDetailScreen({super.key, required this.book});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;
    final isWishlisted = appState.isInWishlist(widget.book.id);
    final isInCart = appState.isInCart(widget.book.id);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ),
            actions: [
              // Edit button (only if user owns this book)
              if (widget.book.sellerId == appState.currentUser?.id)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBookScreen(bookToEdit: widget.book),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
              // Delete button (only if user owns this book)
              if (widget.book.sellerId == appState.currentUser?.id)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => _showDeleteDialog(context, appState),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => appState.toggleWishlist(widget.book),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? AppColors.error : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    // Share functionality
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.share_rounded,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'book_${widget.book.id}',
                    child: CachedNetworkImage(
                      imageUrl: widget.book.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 80,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                  // Discount badge
                  if (widget.book.hasDiscount)
                    Positioned(
                      top: 100,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.error, Color(0xFFDC2626)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${widget.book.discountPercentage.toInt()}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category & Condition
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.book.category,
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getConditionColor(widget.book.condition).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.book.condition.label,
                                style: TextStyle(
                                  color: _getConditionColor(widget.book.condition),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),

                        const SizedBox(height: 16),

                        // Title
                        Text(
                          widget.book.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                        const SizedBox(height: 8),

                        // Author
                        Text(
                          'by ${widget.book.author}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

                        const SizedBox(height: 16),

                        // Rating & Reviews
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < widget.book.rating.floor()
                                  ? Icons.star_rounded
                                  : (index < widget.book.rating ? Icons.star_half_rounded : Icons.star_border_rounded),
                                color: AppColors.warning,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.book.rating}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${widget.book.reviewCount} reviews)',
                              style: TextStyle(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

                        const SizedBox(height: 20),

                        // Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rp ${_formatPrice(widget.book.price.toInt())}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            if (widget.book.hasDiscount) ...[
                              const SizedBox(width: 12),
                              Text(
                                'Rp ${_formatPrice(widget.book.originalPrice.toInt())}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

                        const SizedBox(height: 24),

                        // Book Details
                        _buildDetailsSection(isDark).animate().fadeIn(duration: 300.ms, delay: 300.ms),

                        const SizedBox(height: 24),

                        // Description
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.book.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 350.ms),

                        const SizedBox(height: 24),

                        // Seller Info
                        if (widget.book.sellerName != null)
                          _buildSellerSection(isDark).animate().fadeIn(duration: 300.ms, delay: 400.ms),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      icon: Icon(
                        Icons.remove_rounded,
                        color: _quantity > 1 ? AppColors.primaryBlue : AppColors.textTertiaryLight,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _quantity < widget.book.stock ? () => setState(() => _quantity++) : null,
                      icon: Icon(
                        Icons.add_rounded,
                        color: _quantity < widget.book.stock ? AppColors.primaryBlue : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Add to Cart Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    appState.addToCart(widget.book, quantity: _quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white),
                            const SizedBox(width: 12),
                            Text('${widget.book.title} added to cart'),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInCart ? AppColors.success : AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInCart ? Icons.check_rounded : Icons.shopping_bag_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isInCart ? 'In Cart' : 'Add to Cart',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('ISBN', widget.book.isbn, isDark),
          _buildDivider(isDark),
          _buildDetailRow('Publisher', widget.book.publisher, isDark),
          _buildDivider(isDark),
          _buildDetailRow('Year', widget.book.year.toString(), isDark),
          _buildDivider(isDark),
          _buildDetailRow('Pages', '${widget.book.pages} pages', isDark),
          _buildDivider(isDark),
          _buildDetailRow('Language', widget.book.language, isDark),
          _buildDivider(isDark),
          _buildDetailRow('Stock', '${widget.book.stock} available', isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark 
        ? AppColors.textTertiaryDark.withValues(alpha: 0.2)
        : AppColors.textTertiaryLight.withValues(alpha: 0.2),
    );
  }

  Widget _buildSellerSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.store_rounded,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.sellerName ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.book.sellerLocation ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Visit Store'),
          ),
        ],
      ),
    );
  }

  Color _getConditionColor(BookCondition condition) {
    switch (condition) {
      case BookCondition.likeNew:
        return AppColors.success;
      case BookCondition.veryGood:
        return AppColors.info;
      case BookCondition.good:
        return AppColors.warning;
      case BookCondition.acceptable:
        return AppColors.textSecondaryLight;
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showDeleteDialog(BuildContext context, AppState appState) {
    final isDark = appState.isDarkMode;
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_rounded, color: AppColors.error, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              appState.tr('delete_book'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              appState.language == 'id' 
                  ? 'Apakah Anda yakin ingin menghapus "${widget.book.title}"?'
                  : 'Are you sure you want to delete "${widget.book.title}"?',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(appState.tr('cancel'), style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await appState.deleteBook(widget.book.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white),
                                const SizedBox(width: 12),
                                Text(appState.tr('book_deleted')),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(appState.tr('delete'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
