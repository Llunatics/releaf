import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Supabase Service - Singleton untuk akses Supabase client
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient get client => Supabase.instance.client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase - panggil di main.dart
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  // ==================== AUTH ====================
  
  /// Get current user
  User? get currentUser => client.auth.currentUser;
  
  /// Get current session
  Session? get currentSession => client.auth.currentSession;
  
  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ==================== PROFILES ====================

  /// Get user profile
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  /// Update user profile
  Future<void> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    String? phone,
    String? address,
    String? avatarUrl,
  }) async {
    await client.from('profiles').update({
      if (username != null) 'username': username,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    }).eq('id', userId);
  }

  // ==================== BOOKS ====================

  /// Get all books
  Future<List<Map<String, dynamic>>> getBooks({
    String? category,
    String? searchQuery,
    String orderBy = 'created_at',
    bool ascending = false,
    int? limit,
  }) async {
    var query = client
        .from('books')
        .select('*, profiles!books_seller_id_fkey(full_name, avatar_url)')
        .eq('is_active', true);

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title.ilike.%$searchQuery%,author.ilike.%$searchQuery%,isbn.ilike.%$searchQuery%');
    }

    final response = await query.order(orderBy, ascending: ascending).limit(limit ?? 100);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get single book by ID
  Future<Map<String, dynamic>?> getBook(String bookId) async {
    final response = await client
        .from('books')
        .select('*, profiles!books_seller_id_fkey(full_name, avatar_url)')
        .eq('id', bookId)
        .single();
    return response;
  }

  /// Get featured books
  Future<List<Map<String, dynamic>>> getFeaturedBooks({int limit = 10}) async {
    final response = await client
        .from('books')
        .select()
        .eq('is_active', true)
        .eq('is_featured', true)
        .order('sold_count', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get books with discount
  Future<List<Map<String, dynamic>>> getDiscountedBooks({int limit = 10}) async {
    final response = await client
        .from('books')
        .select()
        .eq('is_active', true)
        .not('original_price', 'is', null)
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get new arrivals
  Future<List<Map<String, dynamic>>> getNewArrivals({int limit = 10}) async {
    final response = await client
        .from('books')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Add new book
  Future<Map<String, dynamic>> addBook({
    required String title,
    required String author,
    required String category,
    required String condition,
    required double price,
    String? isbn,
    String? description,
    double? originalPrice,
    int stock = 1,
    String? imageUrl,
    String? publisher,
    int? publishYear,
    String? language,
    int? pages,
    int? weight,
  }) async {
    final userId = currentUser?.id;
    
    final response = await client.from('books').insert({
      'seller_id': userId,
      'title': title,
      'author': author,
      'isbn': isbn,
      'description': description,
      'category': category,
      'condition': condition,
      'price': price,
      'original_price': originalPrice,
      'stock': stock,
      'image_url': imageUrl,
      'publisher': publisher,
      'publish_year': publishYear,
      'language': language ?? 'Indonesian',
      'pages': pages,
      'weight': weight,
    }).select().single();
    
    return response;
  }

  /// Update book
  Future<void> updateBook({
    required String bookId,
    String? title,
    String? author,
    String? isbn,
    String? description,
    String? category,
    String? condition,
    double? price,
    double? originalPrice,
    int? stock,
    String? imageUrl,
    String? publisher,
    int? publishYear,
    String? language,
    int? pages,
    int? weight,
    bool? isActive,
    bool? isFeatured,
  }) async {
    await client.from('books').update({
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (isbn != null) 'isbn': isbn,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (condition != null) 'condition': condition,
      if (price != null) 'price': price,
      if (originalPrice != null) 'original_price': originalPrice,
      if (stock != null) 'stock': stock,
      if (imageUrl != null) 'image_url': imageUrl,
      if (publisher != null) 'publisher': publisher,
      if (publishYear != null) 'publish_year': publishYear,
      if (language != null) 'language': language,
      if (pages != null) 'pages': pages,
      if (weight != null) 'weight': weight,
      if (isActive != null) 'is_active': isActive,
      if (isFeatured != null) 'is_featured': isFeatured,
    }).eq('id', bookId);
  }

  /// Delete book (soft delete)
  Future<void> deleteBook(String bookId) async {
    await client.from('books').update({
      'is_active': false,
    }).eq('id', bookId);
  }

  // ==================== WISHLIST ====================

  /// Get user's wishlist
  Future<List<Map<String, dynamic>>> getWishlist() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    final response = await client
        .from('wishlists')
        .select('*, books(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Add to wishlist
  Future<void> addToWishlist(String bookId) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await client.from('wishlists').upsert({
      'user_id': userId,
      'book_id': bookId,
    });
  }

  /// Remove from wishlist
  Future<void> removeFromWishlist(String bookId) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await client
        .from('wishlists')
        .delete()
        .eq('user_id', userId)
        .eq('book_id', bookId);
  }

  /// Check if book is in wishlist
  Future<bool> isInWishlist(String bookId) async {
    final userId = currentUser?.id;
    if (userId == null) return false;

    final response = await client
        .from('wishlists')
        .select('id')
        .eq('user_id', userId)
        .eq('book_id', bookId)
        .maybeSingle();
    return response != null;
  }

  // ==================== CART ====================

  /// Get user's cart
  Future<List<Map<String, dynamic>>> getCart() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    final response = await client
        .from('cart_items')
        .select('*, books(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Add to cart
  Future<void> addToCart(String bookId, {int quantity = 1}) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    // Check if already in cart
    final existing = await client
        .from('cart_items')
        .select('id, quantity')
        .eq('user_id', userId)
        .eq('book_id', bookId)
        .maybeSingle();

    if (existing != null) {
      // Update quantity
      await client.from('cart_items').update({
        'quantity': existing['quantity'] + quantity,
      }).eq('id', existing['id']);
    } else {
      // Insert new
      await client.from('cart_items').insert({
        'user_id': userId,
        'book_id': bookId,
        'quantity': quantity,
      });
    }
  }

  /// Update cart item quantity
  Future<void> updateCartQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
    } else {
      await client.from('cart_items').update({
        'quantity': quantity,
      }).eq('id', cartItemId);
    }
  }

  /// Remove from cart
  Future<void> removeFromCart(String cartItemId) async {
    await client.from('cart_items').delete().eq('id', cartItemId);
  }

  /// Clear cart
  Future<void> clearCart() async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await client.from('cart_items').delete().eq('user_id', userId);
  }

  // ==================== TRANSACTIONS ====================

  /// Get user's transactions
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    final response = await client
        .from('transactions')
        .select('*, transaction_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get single transaction
  Future<Map<String, dynamic>?> getTransaction(String transactionId) async {
    final response = await client
        .from('transactions')
        .select('*, transaction_items(*)')
        .eq('id', transactionId)
        .single();
    return response;
  }

  /// Create transaction from cart
  Future<Map<String, dynamic>> createTransaction({
    required double totalAmount,
    required String shippingAddress,
    required String shippingName,
    required String shippingPhone,
    String? paymentMethod,
    String? notes,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    // Get cart items
    final cartItems = await getCart();
    if (cartItems.isEmpty) throw Exception('Cart is empty');

    // Create transaction
    final transaction = await client.from('transactions').insert({
      'user_id': userId,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'shipping_name': shippingName,
      'shipping_phone': shippingPhone,
      'payment_method': paymentMethod,
      'notes': notes,
    }).select().single();

    // Create transaction items
    for (final cartItem in cartItems) {
      final book = cartItem['books'] as Map<String, dynamic>;
      await client.from('transaction_items').insert({
        'transaction_id': transaction['id'],
        'book_id': book['id'],
        'book_title': book['title'],
        'book_author': book['author'],
        'book_price': book['price'],
        'quantity': cartItem['quantity'],
      });

      // Update book stock and sold count
      await client.from('books').update({
        'stock': book['stock'] - cartItem['quantity'],
        'sold_count': book['sold_count'] + cartItem['quantity'],
      }).eq('id', book['id']);
    }

    // Clear cart
    await clearCart();

    return transaction;
  }

  // ==================== STORAGE ====================

  /// Upload book image
  Future<String> uploadBookImage(String filePath, String fileName) async {
    final userId = currentUser?.id ?? 'public';
    final path = '$userId/$fileName';
    
    final file = File(filePath);
    await client.storage
        .from(SupabaseConfig.bookImagesBucket)
        .upload(path, file);
    
    return client.storage
        .from(SupabaseConfig.bookImagesBucket)
        .getPublicUrl(path);
  }

  /// Get public URL for book image
  String getBookImageUrl(String path) {
    return client.storage
        .from(SupabaseConfig.bookImagesBucket)
        .getPublicUrl(path);
  }

  // ==================== DASHBOARD ANALYTICS ====================

  /// Get ALL platform transactions for dashboard (not filtered by user)
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final response = await client
        .from('transactions')
        .select('*, transaction_items(*)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get total sales for current user's books
  Future<Map<String, dynamic>> getDashboardStats() async {
    final userId = currentUser?.id;
    
    // Total sales
    final salesResponse = await client
        .from('transaction_items')
        .select('book_price, quantity, books!inner(seller_id)')
        .eq('books.seller_id', userId ?? '');
    
    double totalSales = 0;
    int totalItemsSold = 0;
    for (final item in salesResponse) {
      totalSales += (item['book_price'] as num) * (item['quantity'] as num);
      totalItemsSold += item['quantity'] as int;
    }

    // Total books listed
    final booksCount = await client
        .from('books')
        .select('id')
        .eq('seller_id', userId ?? '')
        .eq('is_active', true);

    // Get transactions count
    final transactionsCount = await client
        .from('transactions')
        .select('id')
        .eq('user_id', userId ?? '');

    return {
      'total_sales': totalSales,
      'total_items_sold': totalItemsSold,
      'total_books': booksCount.length,
      'total_transactions': transactionsCount.length,
    };
  }

  /// Get sales by category
  Future<Map<String, double>> getSalesByCategory() async {
    final response = await client
        .from('transaction_items')
        .select('book_price, quantity, books!inner(category)');
    
    final Map<String, double> salesByCategory = {};
    
    for (final item in response) {
      final category = item['books']['category'] as String;
      final amount = (item['book_price'] as num) * (item['quantity'] as num);
      salesByCategory[category] = (salesByCategory[category] ?? 0) + amount.toDouble();
    }
    
    return salesByCategory;
  }

  /// Get sales trend for last 7 days
  Future<List<Map<String, dynamic>>> getSalesTrend({int days = 7}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    final response = await client
        .from('transactions')
        .select('total_amount, created_at')
        .gte('created_at', startDate.toIso8601String())
        .order('created_at');
    
    // Group by date
    final Map<String, double> dailySales = {};
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: days - 1 - i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      dailySales[dateStr] = 0;
    }
    
    for (final item in response) {
      final date = DateTime.parse(item['created_at']);
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      if (dailySales.containsKey(dateStr)) {
        dailySales[dateStr] = dailySales[dateStr]! + (item['total_amount'] as num).toDouble();
      }
    }
    
    return dailySales.entries.map((e) => {
      'date': e.key,
      'amount': e.value,
    }).toList();
  }

  /// Get best selling book
  Future<Map<String, dynamic>?> getBestSellingBook() async {
    final response = await client
        .from('books')
        .select()
        .eq('is_active', true)
        .order('sold_count', ascending: false)
        .limit(1)
        .maybeSingle();
    return response;
  }
}
