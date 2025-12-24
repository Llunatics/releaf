import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_state.dart';
import '../../core/models/book.dart';
import '../../core/utils/page_transitions.dart';
import '../../core/utils/toast_helper.dart';
import '../home/main_screen.dart';
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
    final isId = appState.language == 'id';
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
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ),
            actions: [
              // Edit & Delete for owner only - must be logged in AND be the seller
              if (appState.isLoggedIn && 
                  widget.book.sellerId != null && 
                  widget.book.sellerId == appState.currentUser?.id)
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        PageTransitions.slideUp(AddBookScreen(bookToEdit: widget.book)),
                      );
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, appState);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 20, color: AppColors.primaryBlue),
                          const SizedBox(width: 12),
                          Text(appState.tr('edit_book')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, size: 20, color: AppColors.error),
                          const SizedBox(width: 12),
                          Text(appState.tr('delete'), style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              // Cart button with badge
              IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageTransitions.fade(const MainScreen(initialTab: 3)),
                    (route) => false,
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 18,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                      if (appState.cartItemCount > 0)
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              appState.cartItemCount > 9 ? '9+' : '${appState.cartItemCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Wishlist button
              IconButton(
                onPressed: () {
                  if (appState.isLoggedIn) {
                    appState.toggleWishlist(widget.book);
                  } else {
                    ToastHelper.showWarning(
                      context,
                      appState.language == 'id' ? 'Login untuk menambah wishlist' : 'Login to add to wishlist',
                    );
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isWishlisted ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    size: 18,
                    color: isWishlisted ? AppColors.error : (isDark ? Colors.white : AppColors.textPrimaryLight),
                  ),
                ),
              ),
              const SizedBox(width: 4),
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
                                widget.book.condition.localizedLabel(isId),
                                style: TextStyle(
                                  color: _getConditionColor(widget.book.condition),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Title
                        Text(
                          widget.book.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Author
                        Text(
                          appState.language == 'id' 
                              ? 'oleh ${widget.book.author}'
                              : 'by ${widget.book.author}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),

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
                              appState.language == 'id'
                                  ? '(${widget.book.reviewCount} ulasan)'
                                  : '(${widget.book.reviewCount} reviews)',
                              style: TextStyle(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

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
                        ),

                        const SizedBox(height: 24),

                        // Book Details
                        _buildDetailsSection(isDark, appState),

                        const SizedBox(height: 24),

                        // Description
                        Text(
                          appState.language == 'id' ? 'Deskripsi' : 'Description',
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
                        ),

                        const SizedBox(height: 24),

                        // Seller Info
                        if (widget.book.sellerName != null)
                          _buildSellerSection(isDark, appState),

                        const SizedBox(height: 24),

                        // Reviews Section
                        _buildReviewsSection(isDark, appState).animate().fadeIn(duration: 300.ms, delay: 450.ms),

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
              // Quantity Selector - only show when not in cart
              if (!isInCart) ...[
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                    ),
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
                const SizedBox(width: 12),
              ],
              // Add to Cart / View Cart Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (isInCart) {
                      // Navigate to cart tab
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageTransitions.fade(const MainScreen(initialTab: 3)),
                        (route) => false,
                      );
                    } else {
                      if (!appState.isLoggedIn) {
                        ToastHelper.showWarning(
                          context,
                          appState.language == 'id' ? 'Login untuk memesan buku' : 'Login to order book',
                        );
                        return;
                      }
                      appState.addToCart(widget.book, quantity: _quantity);
                      ToastHelper.showSuccess(
                        context,
                        appState.language == 'id' 
                            ? '${widget.book.title} ditambahkan ke keranjang'
                            : '${widget.book.title} added to cart',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInCart ? const Color(0xFF10B981) : AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInCart ? Icons.shopping_bag_rounded : Icons.add_shopping_cart_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isInCart 
                            ? (appState.language == 'id' ? 'Lihat Keranjang' : 'View Cart')
                            : (appState.language == 'id' ? 'Tambah ke Keranjang' : 'Add to Cart'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
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

  Widget _buildDetailsSection(bool isDark, AppState appState) {
    final isId = appState.language == 'id';
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
          _buildDetailRow(isId ? 'Penerbit' : 'Publisher', widget.book.publisher, isDark),
          _buildDivider(isDark),
          _buildDetailRow(isId ? 'Tahun' : 'Year', widget.book.year.toString(), isDark),
          _buildDivider(isDark),
          _buildDetailRow(isId ? 'Halaman' : 'Pages', isId ? '${widget.book.pages} halaman' : '${widget.book.pages} pages', isDark),
          _buildDivider(isDark),
          _buildDetailRow(isId ? 'Bahasa' : 'Language', widget.book.language, isDark),
          _buildDivider(isDark),
          _buildDetailRow(isId ? 'Stok' : 'Stock', isId ? '${widget.book.stock} tersedia' : '${widget.book.stock} available', isDark),
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

  Widget _buildSellerSection(bool isDark, AppState appState) {
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
            child: Text(appState.language == 'id' ? 'Kunjungi Toko' : 'Visit Store'),
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

  Widget _buildReviewsSection(bool isDark, AppState appState) {
    final reviews = widget.book.reviews ?? [];
    final averageRating = widget.book.averageRating;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber[600], size: 24),
              const SizedBox(width: 8),
              Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              if (reviews.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada review',
                      style: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => Divider(
                height: 24,
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              ),
              itemBuilder: (context, index) {
                final review = reviews[index];
                final rating = (review['rating'] as num?)?.toDouble() ?? 0;
                final comment = review['comment'] as String? ?? '';
                final userName = review['user_name'] as String? ?? 'Anonymous';
                final createdAt = review['created_at'] != null
                    ? DateTime.parse(review['created_at'])
                    : DateTime.now();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                          child: Text(
                            userName[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                        size: 14,
                                        color: Colors.amber[600],
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDate(createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (comment.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        comment,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} minggu lalu';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} bulan lalu';
    } else {
      return '${(difference.inDays / 365).floor()} tahun lalu';
    }
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
                        ToastHelper.showSuccess(context, appState.tr('book_deleted'));
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
