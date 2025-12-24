import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';
import '../models/transaction.dart';
import '../models/cart_item.dart';
import '../data/dummy_data.dart';
import '../services/supabase_service.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  List<Book> _books = [];
  List<Book> _wishlist = [];
  List<CartItem> _cart = [];
  List<BookTransaction> _transactions = []; // User's own transactions
  List<BookTransaction> _allTransactions =
      []; // All platform transactions for dashboard
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isLoading = false;
  String? _error;
  String _language = 'id'; // Default to Indonesian
  User? _currentUser;
  Map<String, dynamic>? _userProfile;

  ThemeMode get themeMode => _themeMode;
  List<Book> get books => _books;
  List<Book> get wishlist => _wishlist;
  List<CartItem> get cart => _cart;
  List<BookTransaction> get transactions => _transactions;
  List<BookTransaction> get allTransactions => _allTransactions;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get language => _language;
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoggedIn => _currentUser != null;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  double get cartTotal =>
      _cart.fold(0, (sum, item) => sum + (item.book.price * item.quantity));
  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  /// Get books listed by current user
  List<Book> get myListedBooks {
    if (_currentUser == null) return [];
    return _books.where((book) => book.sellerId == _currentUser!.id).toList();
  }

  List<Book> get filteredBooks {
    List<Book> result = _books;

    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      result =
          result.where((book) => book.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((book) =>
              book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query) ||
              book.category.toLowerCase().contains(query))
          .toList();
    }

    return result;
  }

  AppState() {
    _initializeData();
  }

  void _initializeData() {
    // Check current auth state
    _currentUser = SupabaseService.instance.currentUser;

    // Start with empty data, load from Supabase
    _books = [];
    _transactions = [];

    // Load from Supabase (will use dummy as fallback only if Supabase fails)
    _loadFromSupabase();

    // Load saved preferences
    _loadLanguage();

    // If user already logged in (session restored), load their data
    if (_currentUser != null) {
      _loadUserDataOnStartup();
    }
  }

  /// Load user data when app starts with existing session
  Future<void> _loadUserDataOnStartup() async {
    // Ensure profile exists first
    await _ensureUserProfile();

    // Then load other data
    await Future.wait([
      _loadUserWishlist(),
      _loadUserCart(),
      _loadUserTransactions(),
    ]);
    notifyListeners();
  }

  /// Initialize user session after login
  Future<void> initUserSession(User user) async {
    _currentUser = user;
    notifyListeners();

    // IMPORTANT: Ensure profile exists in database first
    await _ensureUserProfile();

    // Then load user's data from Supabase
    await Future.wait([
      _loadUserWishlist(),
      _loadUserCart(),
      _loadUserTransactions(),
    ]);

    notifyListeners();
  }

  /// Clear user session on logout
  void clearUserSession() {
    _currentUser = null;
    _userProfile = null;
    _wishlist = [];
    _cart = [];
    _transactions = []; // Clear transactions - don't show other user's orders
    notifyListeners();
  }

  /// Ensure user profile exists in database
  Future<void> _ensureUserProfile() async {
    if (_currentUser == null) return;
    try {
      _userProfile = await SupabaseService.instance.ensureProfile(
        userId: _currentUser!.id,
        email: _currentUser!.email,
        fullName: _currentUser!.userMetadata?['full_name'] as String?,
      );
      debugPrint('Profile ensured for user: ${_currentUser!.id}');
    } catch (e) {
      debugPrint('Error ensuring profile: $e');
    }
  }

  Future<void> _loadUserWishlist() async {
    if (_currentUser == null) return;
    try {
      final wishlistData = await SupabaseService.instance.getWishlist();
      _wishlist = wishlistData.map((item) {
        final bookData = item['books'] as Map<String, dynamic>;
        return Book.fromSupabase(bookData);
      }).toList();
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  Future<void> _loadUserCart() async {
    if (_currentUser == null) return;
    try {
      final cartData = await SupabaseService.instance.getCart();
      _cart = cartData.map((item) {
        final bookData = item['books'] as Map<String, dynamic>;
        return CartItem(
          book: Book.fromSupabase(bookData),
          quantity: item['quantity'] as int,
          cartItemId: item['id'] as String,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _loadUserTransactions() async {
    if (_currentUser == null) return;
    try {
      final transData = await SupabaseService.instance.getTransactions();
      if (transData.isNotEmpty) {
        _transactions = transData
            .map((data) => BookTransaction.fromSupabase(data))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }
  }

  /// Load ALL platform transactions for dashboard
  Future<void> loadAllTransactions() async {
    try {
      final transData = await SupabaseService.instance.getAllTransactions();
      if (transData.isNotEmpty) {
        _allTransactions = transData
            .map((data) => BookTransaction.fromSupabase(data))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading all transactions: $e');
    }
  }

  Future<void> _loadFromSupabase() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load from Supabase - this is the source of truth
      final booksData = await SupabaseService.instance.getBooks();
      _books = booksData.map((data) => Book.fromSupabase(data)).toList();
      // If Supabase returns empty, that's fine - no books in database
    } catch (e) {
      debugPrint('Error loading books from Supabase: $e');
      // Only use dummy data as fallback when Supabase connection fails
      if (_books.isEmpty) {
        _books = DummyData.books;
      }
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh books from Supabase
  Future<void> refreshBooks() async {
    await _loadFromSupabase();
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // Language operations
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('language') ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  // Localized strings
  String tr(String key) {
    final Map<String, Map<String, String>> translations = {
      'home': {'en': 'Home', 'id': 'Beranda'},
      'books': {'en': 'Books', 'id': 'Buku'},
      'dashboard': {'en': 'Dashboard', 'id': 'Dasbor'},
      'cart': {'en': 'Cart', 'id': 'Keranjang'},
      'profile': {'en': 'Profile', 'id': 'Profil'},
      'search': {'en': 'Search books...', 'id': 'Cari buku...'},
      'featured': {'en': 'Featured Books', 'id': 'Buku Pilihan'},
      'new_arrivals': {'en': 'New Arrivals', 'id': 'Baru Datang'},
      'categories': {'en': 'Categories', 'id': 'Kategori'},
      'all_books': {'en': 'All Books', 'id': 'Semua Buku'},
      'add_book': {'en': 'Add Book', 'id': 'Tambah Buku'},
      'edit_book': {'en': 'Edit Book', 'id': 'Edit Buku'},
      'delete_book': {'en': 'Delete Book', 'id': 'Hapus Buku'},
      'wishlist': {'en': 'Wishlist', 'id': 'Favorit'},
      'orders': {'en': 'Orders', 'id': 'Pesanan'},
      'settings': {'en': 'Settings', 'id': 'Pengaturan'},
      'language': {'en': 'Language', 'id': 'Bahasa'},
      'dark_mode': {'en': 'Dark Mode', 'id': 'Mode Gelap'},
      'logout': {'en': 'Logout', 'id': 'Keluar'},
      'login': {'en': 'Login', 'id': 'Masuk'},
      'register': {'en': 'Register', 'id': 'Daftar'},
      'email': {'en': 'Email', 'id': 'Email'},
      'password': {'en': 'Password', 'id': 'Kata Sandi'},
      'welcome_back': {'en': 'Welcome Back', 'id': 'Selamat Datang'},
      'sign_in': {'en': 'Sign In', 'id': 'Masuk'},
      'sign_up': {'en': 'Sign Up', 'id': 'Daftar'},
      'continue_guest': {
        'en': 'Continue as Guest',
        'id': 'Lanjut sebagai Tamu'
      },
      'no_account': {'en': "Don't have an account?", 'id': 'Belum punya akun?'},
      'have_account': {
        'en': 'Already have an account?',
        'id': 'Sudah punya akun?'
      },
      'forgot_password': {'en': 'Forgot Password?', 'id': 'Lupa Kata Sandi?'},
      'price': {'en': 'Price', 'id': 'Harga'},
      'condition': {'en': 'Condition', 'id': 'Kondisi'},
      'author': {'en': 'Author', 'id': 'Penulis'},
      'description': {'en': 'Description', 'id': 'Deskripsi'},
      'add_to_cart': {'en': 'Add to Cart', 'id': 'Tambah ke Keranjang'},
      'buy_now': {'en': 'Buy Now', 'id': 'Beli Sekarang'},
      'checkout': {'en': 'Checkout', 'id': 'Bayar'},
      'total': {'en': 'Total', 'id': 'Total'},
      'empty_cart': {'en': 'Your cart is empty', 'id': 'Keranjang kosong'},
      'empty_wishlist': {
        'en': 'Your wishlist is empty',
        'id': 'Favorit kosong'
      },
      'my_books': {'en': 'My Books', 'id': 'Buku Saya'},
      'preferences': {'en': 'Preferences', 'id': 'Preferensi'},
      'notifications': {'en': 'Notifications', 'id': 'Notifikasi'},
      'account': {'en': 'Account', 'id': 'Akun'},
      'edit_profile': {'en': 'Edit Profile', 'id': 'Edit Profil'},
      'help_center': {'en': 'Help Center', 'id': 'Pusat Bantuan'},
      'about': {'en': 'About', 'id': 'Tentang'},
      'version': {'en': 'Version', 'id': 'Versi'},
      'save_changes': {'en': 'Save Changes', 'id': 'Simpan Perubahan'},
      'cancel': {'en': 'Cancel', 'id': 'Batal'},
      'delete': {'en': 'Delete', 'id': 'Hapus'},
      'confirm': {'en': 'Confirm', 'id': 'Konfirmasi'},
      'success': {'en': 'Success', 'id': 'Berhasil'},
      'error': {'en': 'Error', 'id': 'Kesalahan'},
      'loading': {'en': 'Loading...', 'id': 'Memuat...'},
      'book_added': {
        'en': 'Book added successfully',
        'id': 'Buku berhasil ditambahkan'
      },
      'book_updated': {
        'en': 'Book updated successfully',
        'id': 'Buku berhasil diperbarui'
      },
      'book_deleted': {
        'en': 'Book deleted successfully',
        'id': 'Buku berhasil dihapus'
      },
      'select_language': {'en': 'Select Language', 'id': 'Pilih Bahasa'},
      'english': {'en': 'English', 'id': 'Inggris'},
      'indonesian': {'en': 'Indonesian', 'id': 'Indonesia'},
      'guest_user': {'en': 'Guest User', 'id': 'Pengguna Tamu'},
      'best_deals': {'en': 'Best Deals', 'id': 'Penawaran Terbaik'},
      'see_all': {'en': 'See All', 'id': 'Lihat Semua'},
      'search_preloved': {
        'en': 'Search preloved books...',
        'id': 'Cari buku bekas...'
      },
      'all': {'en': 'All', 'id': 'Semua'},
      'view_details': {'en': 'View Details', 'id': 'Lihat Detail'},
      'in_cart': {'en': 'In Cart', 'id': 'Di Keranjang'},
      'out_of_stock': {'en': 'Out of Stock', 'id': 'Stok Habis'},
      'added_to_cart': {
        'en': 'Added to cart',
        'id': 'Ditambahkan ke keranjang'
      },
    };

    return translations[key]?[_language] ?? translations[key]?['en'] ?? key;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  // Wishlist operations with Supabase sync
  Future<void> toggleWishlist(Book book) async {
    final isInList = _wishlist.any((b) => b.id == book.id);

    if (isInList) {
      _wishlist.removeWhere((b) => b.id == book.id);
      notifyListeners();

      // Sync with Supabase if logged in
      if (_currentUser != null) {
        try {
          await SupabaseService.instance.removeFromWishlist(book.id);
        } catch (e) {
          debugPrint('Error removing from wishlist: $e');
        }
      }
    } else {
      _wishlist.add(book);
      notifyListeners();

      // Sync with Supabase if logged in
      if (_currentUser != null) {
        try {
          await SupabaseService.instance.addToWishlist(book.id);
        } catch (e) {
          debugPrint('Error adding to wishlist: $e');
        }
      }
    }
  }

  bool isInWishlist(String bookId) {
    return _wishlist.any((book) => book.id == bookId);
  }

  // Cart operations with Supabase sync
  Future<void> addToCart(Book book, {int quantity = 1}) async {
    final existingIndex = _cart.indexWhere((item) => item.book.id == book.id);
    String? cartItemId;

    if (existingIndex != -1) {
      cartItemId = _cart[existingIndex].cartItemId;
      _cart[existingIndex] = CartItem(
        book: book,
        quantity: _cart[existingIndex].quantity + quantity,
        cartItemId: cartItemId,
      );
    } else {
      _cart.add(CartItem(book: book, quantity: quantity));
    }
    notifyListeners();

    // Sync with Supabase if logged in
    if (_currentUser != null) {
      try {
        final newCartItemId = await SupabaseService.instance
            .addToCart(book.id, quantity: quantity);
        // Update local cart with the id from Supabase
        if (existingIndex == -1 && newCartItemId != null) {
          final idx = _cart.indexWhere((item) => item.book.id == book.id);
          if (idx != -1) {
            _cart[idx] = CartItem(
              book: _cart[idx].book,
              quantity: _cart[idx].quantity,
              cartItemId: newCartItemId,
            );
          }
        }
      } catch (e) {
        debugPrint('Error adding to cart: $e');
      }
    }
  }

  Future<void> removeFromCart(String bookId) async {
    final item = _cart.firstWhere((item) => item.book.id == bookId,
        orElse: () => CartItem(book: Book.empty(), quantity: 0));
    _cart.removeWhere((item) => item.book.id == bookId);
    notifyListeners();

    // Sync with Supabase if logged in
    if (_currentUser != null && item.cartItemId != null) {
      try {
        await SupabaseService.instance.removeFromCart(item.cartItemId!);
      } catch (e) {
        debugPrint('Error removing from cart: $e');
      }
    }
  }

  Future<void> updateCartItemQuantity(String bookId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(bookId);
      return;
    }
    final index = _cart.indexWhere((item) => item.book.id == bookId);
    if (index != -1) {
      final cartItemId = _cart[index].cartItemId;
      _cart[index] = CartItem(
          book: _cart[index].book, quantity: quantity, cartItemId: cartItemId);
      notifyListeners();

      // Sync with Supabase if logged in
      if (_currentUser != null && cartItemId != null) {
        try {
          await SupabaseService.instance
              .updateCartQuantity(cartItemId, quantity);
        } catch (e) {
          debugPrint('Error updating cart: $e');
        }
      }
    }
  }

  Future<void> clearCart() async {
    _cart.clear();
    notifyListeners();

    // Sync with Supabase if logged in
    if (_currentUser != null) {
      try {
        await SupabaseService.instance.clearCart();
      } catch (e) {
        debugPrint('Error clearing cart: $e');
      }
    }
  }

  bool isInCart(String bookId) {
    return _cart.any((item) => item.book.id == bookId);
  }

  // Transaction operations
  void addTransaction(BookTransaction transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  /// Accept/Confirm order delivery
  Future<void> acceptOrder(String transactionId,
      {String? review, double? rating}) async {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index == -1) return;

    final transaction = _transactions[index];

    _transactions[index] = _transactions[index].copyWith(
      status: TransactionStatus.completed,
      review: review,
      rating: rating,
    );
    notifyListeners();

    if (_currentUser != null) {
      try {
        // Update transaction status in Supabase
        await SupabaseService.instance.updateTransactionStatus(
          transactionId: transactionId,
          status: 'completed',
          review: review,
          rating: rating,
        );

        // Add review to the book if rating and comment provided
        if (rating != null && review != null && review.isNotEmpty) {
          for (var item in transaction.items) {
            await SupabaseService.instance.addBookReview(
              bookId: item.book.id,
              rating: rating,
              comment: review,
            );
          }

          // Reload books to get updated reviews
          await refreshBooks();
        }
      } catch (e) {
        debugPrint('Error updating transaction: $e');
      }
    }
  }

  /// Update order status (for seller/admin)
  Future<void> updateOrderStatus(
      String transactionId, TransactionStatus newStatus) async {
    // Find in user transactions
    int index = _transactions.indexWhere((t) => t.id == transactionId);

    // Also check all transactions for dashboard
    int allIndex = _allTransactions.indexWhere((t) => t.id == transactionId);

    if (index == -1 && allIndex == -1) return;

    // Handle delivered status with auto-accept date
    DateTime? deliveredDate;
    DateTime? autoAcceptDate;
    if (newStatus == TransactionStatus.delivered) {
      deliveredDate = DateTime.now();
      autoAcceptDate = deliveredDate.add(const Duration(days: 1));
    }

    // Update in user transactions
    if (index != -1) {
      _transactions[index] = _transactions[index].copyWith(
        status: newStatus,
        deliveredDate: deliveredDate,
        autoAcceptDate: autoAcceptDate,
      );
    }

    // Update in all transactions
    if (allIndex != -1) {
      _allTransactions[allIndex] = _allTransactions[allIndex].copyWith(
        status: newStatus,
        deliveredDate: deliveredDate,
        autoAcceptDate: autoAcceptDate,
      );
    }

    notifyListeners();

    // Sync with Supabase
    if (_currentUser != null) {
      try {
        await SupabaseService.instance.updateTransactionStatus(
          transactionId: transactionId,
          status: _statusToString(newStatus),
          deliveredDate: deliveredDate,
          autoAcceptDate: autoAcceptDate,
        );
      } catch (e) {
        debugPrint('Error updating order status: $e');
      }
    }
  }

  /// Convert TransactionStatus to string for Supabase
  String _statusToString(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.processing:
        return 'processing';
      case TransactionStatus.shipped:
        return 'shipped';
      case TransactionStatus.delivered:
        return 'delivered';
      case TransactionStatus.completed:
        return 'completed';
      case TransactionStatus.cancelled:
        return 'cancelled';
    }
  }

  /// Mark order as delivered (for testing or manual update)
  Future<void> markAsDelivered(String transactionId) async {
    await updateOrderStatus(transactionId, TransactionStatus.delivered);
  }

  /// Check and auto-accept orders that are past auto-accept date
  Future<void> checkAutoAcceptOrders() async {
    bool hasChanges = false;

    for (int i = 0; i < _transactions.length; i++) {
      final transaction = _transactions[i];
      if (transaction.canAutoAccept) {
        _transactions[i] = transaction.copyWith(
          status: TransactionStatus.completed,
        );
        hasChanges = true;

        // Sync with Supabase
        if (_currentUser != null) {
          try {
            await SupabaseService.instance.updateTransactionStatus(
              transactionId: transaction.id,
              status: 'completed',
            );
          } catch (e) {
            debugPrint('Error auto-accepting order: $e');
          }
        }
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  Future<BookTransaction?> createOrderFromCart({
    String? shippingAddress,
    String? shippingName,
    String? shippingPhone,
    String? paymentMethod,
    String? notes,
  }) async {
    if (_cart.isEmpty) return null;

    // Create local transaction first for immediate UI feedback
    final transaction = BookTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(_cart),
      totalAmount: cartTotal,
      date: DateTime.now(),
      status: TransactionStatus.pending,
      shippingAddress: shippingAddress,
      notes: notes,
    );

    // Add to local transactions
    _transactions.insert(0, transaction);

    // Sync with Supabase if logged in
    if (_currentUser != null) {
      try {
        final result = await SupabaseService.instance.createTransaction(
          totalAmount: cartTotal,
          shippingAddress: shippingAddress ?? '',
          shippingName: shippingName ?? '',
          shippingPhone: shippingPhone ?? '',
          paymentMethod: paymentMethod,
          notes: notes,
        );

        // Update local transaction with Supabase ID
        final idx = _transactions.indexWhere((t) => t.id == transaction.id);
        if (idx != -1) {
          _transactions[idx] = BookTransaction(
            id: result['id'],
            items: transaction.items,
            totalAmount: transaction.totalAmount,
            date: transaction.date,
            status: transaction.status,
            shippingAddress: transaction.shippingAddress,
            notes: transaction.notes,
          );
        }
      } catch (e) {
        debugPrint('Error creating transaction in Supabase: $e');
      }
    }

    // Clear cart (already cleared in Supabase by createTransaction)
    _cart.clear();
    notifyListeners();

    return transaction;
  }

  // Book CRUD operations with Supabase sync
  Future<void> addBook(Book book) async {
    _books.insert(0, book);
    notifyListeners();

    // Sync with Supabase if logged in
    if (_currentUser != null) {
      try {
        await SupabaseService.instance.addBook(
          title: book.title,
          author: book.author,
          category: book.category,
          condition: book.condition.toSupabaseValue(),
          price: book.price,
          isbn: book.isbn,
          description: book.description,
          originalPrice: book.originalPrice,
          stock: book.stock,
          imageUrl: book.imageUrl,
          publisher: book.publisher,
          publishYear: book.year,
          language: book.language,
          pages: book.pages,
        );
        // Refresh to get the actual ID from Supabase
        await refreshBooks();
      } catch (e) {
        debugPrint('Error adding book to Supabase: $e');
      }
    }
  }

  Future<void> updateBook(Book updatedBook) async {
    final index = _books.indexWhere((book) => book.id == updatedBook.id);
    if (index != -1) {
      _books[index] = updatedBook;
      notifyListeners();

      // Sync with Supabase if logged in
      if (_currentUser != null) {
        try {
          await SupabaseService.instance.updateBook(
            bookId: updatedBook.id,
            title: updatedBook.title,
            author: updatedBook.author,
            category: updatedBook.category,
            condition: updatedBook.condition.toSupabaseValue(),
            price: updatedBook.price,
            isbn: updatedBook.isbn,
            description: updatedBook.description,
            originalPrice: updatedBook.originalPrice,
            stock: updatedBook.stock,
            imageUrl: updatedBook.imageUrl,
            publisher: updatedBook.publisher,
            publishYear: updatedBook.year,
            language: updatedBook.language,
            pages: updatedBook.pages,
          );
        } catch (e) {
          debugPrint('Error updating book in Supabase: $e');
        }
      }
    }
  }

  Future<void> deleteBook(String bookId) async {
    _books.removeWhere((book) => book.id == bookId);
    _wishlist.removeWhere((book) => book.id == bookId);
    _cart.removeWhere((item) => item.book.id == bookId);
    notifyListeners();

    // Sync with Supabase if logged in
    if (_currentUser != null) {
      try {
        await SupabaseService.instance.deleteBook(bookId);
      } catch (e) {
        debugPrint('Error deleting book from Supabase: $e');
      }
    }
  }

  Book? getBookById(String id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  // Dashboard data - uses ALL platform transactions
  double get totalSales => _allTransactions
      .where((t) => t.status == TransactionStatus.completed)
      .fold(0, (sum, t) => sum + t.totalAmount);

  Map<String, double> get salesByCategory {
    final Map<String, double> result = {};
    for (final transaction in _allTransactions
        .where((t) => t.status == TransactionStatus.completed)) {
      for (final item in transaction.items) {
        result[item.book.category] = (result[item.book.category] ?? 0) +
            (item.book.price * item.quantity);
      }
    }
    return result;
  }

  Book? get bestSellingBook {
    final Map<String, int> salesCount = {};
    for (final transaction in _allTransactions
        .where((t) => t.status == TransactionStatus.completed)) {
      for (final item in transaction.items) {
        salesCount[item.book.id] =
            (salesCount[item.book.id] ?? 0) + item.quantity;
      }
    }
    if (salesCount.isEmpty) return null;
    final bestId =
        salesCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return getBookById(bestId);
  }

  List<MapEntry<DateTime, double>> get last7DaysSales {
    final now = DateTime.now();
    final List<MapEntry<DateTime, double>> result = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dailyTotal = _allTransactions
          .where((t) =>
              t.status == TransactionStatus.completed &&
              t.date.year == date.year &&
              t.date.month == date.month &&
              t.date.day == date.day)
          .fold(0.0, (sum, t) => sum + t.totalAmount);
      result.add(MapEntry(date, dailyTotal));
    }

    return result;
  }

  int get totalTransactions => _allTransactions.length;
  int get completedTransactions => _allTransactions
      .where((t) => t.status == TransactionStatus.completed)
      .length;
  int get pendingTransactions => _allTransactions
      .where((t) => t.status == TransactionStatus.pending)
      .length;
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>()!
        .notifier!;
  }

  static AppState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>()
        ?.notifier;
  }
}
