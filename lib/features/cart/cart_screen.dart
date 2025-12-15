import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_state.dart';
import '../../core/models/cart_item.dart';
import '../../core/utils/page_transitions.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;
    final cart = appState.cart;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              appState.language == 'id' ? 'Keranjang' : 'Cart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            if (cart.isNotEmpty)
              Text(
                '${cart.length} item',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
          ],
        ),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              onPressed: () {
                _showClearCartDialog(context, appState);
              },
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: Colors.red[400],
              ),
              tooltip: appState.language == 'id' ? 'Hapus semua' : 'Clear all',
            ),
        ],
      ),
      body: cart.isEmpty
        ? _buildEmptyCart(context, isDark, appState)
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    return _buildCartItem(context, item, appState, isDark, currencyFormat, index)
                        .animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 100))
                        .slideX(begin: 0.1);
                  },
                ),
              ),
              _buildBottomSection(context, appState, isDark, currencyFormat),
            ],
          ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, bool isDark, AppState appState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF1E3A5F).withValues(alpha: 0.3)
                  : const Color(0xFF3B82F6).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 70,
              color: isDark 
                  ? const Color(0xFF60A5FA)
                  : const Color(0xFF3B82F6).withValues(alpha: 0.6),
            ),
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: 32),
          Text(
            appState.language == 'id' ? 'Keranjang Kosong' : 'Your Cart is Empty',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
          const SizedBox(height: 10),
          Text(
            appState.language == 'id' 
                ? 'Yuk, tambahkan buku ke keranjangmu'
                : 'Add some books to your cart',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to products
            },
            icon: const Icon(Icons.explore_outlined, color: Colors.white, size: 20),
            label: Text(
              appState.language == 'id' ? 'Jelajahi Buku' : 'Browse Books',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, AppState appState, bool isDark, NumberFormat currencyFormat, int index) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              appState.removeFromCart(item.book.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appState.language == 'id' 
                      ? '${item.book.title} dihapus dari keranjang'
                      : '${item.book.title} removed from cart'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: appState.language == 'id' ? 'Hapus' : 'Remove',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Book Image
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.book.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Book Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.book.author,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(item.book.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ),
            // Quantity Controls
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF252525) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: item.quantity > 1
                      ? () => appState.updateCartItemQuantity(item.book.id, item.quantity - 1)
                      : () => appState.removeFromCart(item.book.id),
                    icon: Icon(
                      item.quantity > 1 ? Icons.remove : Icons.delete_outline_rounded,
                      size: 18,
                      color: item.quantity > 1 
                          ? (isDark ? Colors.white : const Color(0xFF1E293B))
                          : Colors.red[400],
                    ),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                  Container(
                    width: 32,
                    alignment: Alignment.center,
                    child: Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: item.quantity < item.book.stock
                      ? () => appState.updateCartItemQuantity(item.book.id, item.quantity + 1)
                      : null,
                    icon: Icon(
                      Icons.add,
                      size: 18,
                      color: item.quantity < item.book.stock
                        ? (isDark ? Colors.white : const Color(0xFF1E293B))
                        : Colors.grey[400],
                    ),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, AppState appState, bool isDark, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${appState.cartItemCount} item)',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  currencyFormat.format(appState.cartTotal),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransitions.sharedAxis(const CheckoutScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      appState.language == 'id' ? 'Lanjutkan ke Checkout' : 'Proceed to Checkout',
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
    );
  }

  void _showClearCartDialog(BuildContext context, AppState appState) {
    final isDark = appState.isDarkMode;
    final isId = appState.language == 'id';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isId ? 'Kosongkan Keranjang' : 'Clear Cart'),
        content: Text(isId 
            ? 'Apakah Anda yakin ingin menghapus semua item dari keranjang?'
            : 'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isId ? 'Batal' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isId ? 'Keranjang dikosongkan' : 'Cart cleared'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(isId ? 'Hapus' : 'Clear', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
