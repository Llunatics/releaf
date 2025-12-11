import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/book.dart';
import '../../../core/providers/app_state.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final bool showDiscount;
  final double? width; // Optional fixed width for horizontal scrolling
  final double? height; // Optional fixed height for horizontal scrolling

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.showDiscount = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;
    final isWishlisted = appState.isInWishlist(book.id);

    // If width/height provided, use SizedBox wrapper (for horizontal scroll)
    // Otherwise, let parent control size (for grid)
    Widget card = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.2)
              : AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container - Takes 60% of the space
          Expanded(
            flex: 6,
            child: _buildImageSection(isDark, isWishlisted, appState),
          ),
          // Content Section - Takes 40% of the space
          Expanded(
            flex: 4,
            child: _buildContentSection(isDark),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }

  Widget _buildImageSection(bool isDark, bool isWishlisted, AppState appState) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Book Cover Image
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            color: isDark 
              ? AppColors.surfaceDark 
              : AppColors.primaryBlue.withOpacity(0.05),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: book.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: isDark ? AppColors.surfaceDark : Colors.grey[300]!,
                highlightColor: isDark ? AppColors.cardDark : Colors.grey[100]!,
                child: Container(color: Colors.white),
              ),
              errorWidget: (context, url, error) => Center(
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 40,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
        ),
        // Wishlist Button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => appState.toggleWishlist(book),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: isWishlisted ? AppColors.error : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
        // Discount Badge
        if (showDiscount && book.hasDiscount)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '-${book.discountPercentage.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        // Condition Badge
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: _getConditionColor(book.condition),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              book.condition.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          // Author
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const Spacer(),
          // Rating Row
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: 14,
                color: AppColors.warning,
              ),
              const SizedBox(width: 2),
              Text(
                book.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              if (book.hasDiscount)
                Text(
                  'Rp ${_formatPrice(book.originalPrice.toInt())}',
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          // Price
          Text(
            'Rp ${_formatPrice(book.price.toInt())}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
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
}
