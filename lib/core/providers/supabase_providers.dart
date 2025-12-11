import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/book.dart';
import '../models/cart_item.dart';
import '../models/transaction.dart';

/// Auth State Provider - manages authentication state with Supabase
class AuthStateProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService.instance;
  
  User? _user;
  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  String get userName => _profile?['full_name'] ?? _user?.email?.split('@').first ?? 'Guest';
  String get userEmail => _user?.email ?? 'guest@releaf.com';
  String? get userAvatar => _profile?['avatar_url'];

  AuthStateProvider() {
    _init();
  }

  void _init() {
    _user = _supabase.currentUser;
    if (_user != null) {
      _loadProfile();
    }

    // Listen to auth changes
    _supabase.authStateChanges.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _user = data.session?.user;
        _loadProfile();
        notifyListeners();
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _profile = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;
    try {
      _profile = await _supabase.getProfile(_user!.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user != null) {
        _user = response.user;
        await _loadProfile();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        await _loadProfile();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.signOut();
      _user = null;
      _profile = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? username,
    String? fullName,
    String? phone,
    String? address,
  }) async {
    if (_user == null) return false;
    
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.updateProfile(
        userId: _user!.id,
        username: username,
        fullName: fullName,
        phone: phone,
        address: address,
      );

      await _loadProfile();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Book Data Provider - manages books data with Supabase
class BookDataProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService.instance;
  
  List<Book> _books = [];
  List<Book> _featuredBooks = [];
  List<Book> _discountedBooks = [];
  List<Book> _newArrivals = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get books => _books;
  List<Book> get featuredBooks => _featuredBooks;
  List<Book> get discountedBooks => _discountedBooks;
  List<Book> get newArrivals => _newArrivals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBooks({String? category, String? searchQuery}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _supabase.getBooks(
        category: category,
        searchQuery: searchQuery,
      );
      
      _books = data.map((json) => Book.fromSupabase(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeaturedBooks() async {
    try {
      final data = await _supabase.getFeaturedBooks();
      _featuredBooks = data.map((json) => Book.fromSupabase(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> loadDiscountedBooks() async {
    try {
      final data = await _supabase.getDiscountedBooks();
      _discountedBooks = data.map((json) => Book.fromSupabase(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> loadNewArrivals() async {
    try {
      final data = await _supabase.getNewArrivals();
      _newArrivals = data.map((json) => Book.fromSupabase(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> loadAllHomeData() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.wait([
      loadFeaturedBooks(),
      loadDiscountedBooks(),
      loadNewArrivals(),
    ]);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<Book?> getBook(String bookId) async {
    try {
      final data = await _supabase.getBook(bookId);
      if (data != null) {
        return Book.fromSupabase(data);
      }
    } catch (e) {
      _error = e.toString();
    }
    return null;
  }

  Future<bool> addBook(Book book) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.addBook(
        title: book.title,
        author: book.author,
        category: book.category,
        condition: book.condition.toSupabaseValue(),
        price: book.price,
        isbn: book.isbn,
        description: book.description,
        originalPrice: book.hasDiscount ? book.originalPrice : null,
        stock: book.stock,
        imageUrl: book.imageUrl,
        publisher: book.publisher,
        publishYear: book.publishYear,
        language: book.language,
        pages: book.pages,
        weight: book.weight,
      );

      await loadBooks();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBook(Book book) async {
    try {
      await _supabase.updateBook(
        bookId: book.id,
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
        publishYear: book.publishYear,
        language: book.language,
        pages: book.pages,
        weight: book.weight,
      );

      await loadBooks();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteBook(String bookId) async {
    try {
      await _supabase.deleteBook(bookId);
      _books.removeWhere((b) => b.id == bookId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}

/// Cart Provider - manages cart with Supabase
class CartProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService.instance;
  
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get total => _items.fold(0, (sum, item) => sum + (item.book.price * item.quantity));

  Future<void> loadCart() async {
    if (!_supabase.isLoggedIn) {
      _items = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final data = await _supabase.getCart();
      _items = data.map((json) {
        final book = Book.fromSupabase(json['books']);
        return CartItem(
          id: json['id'],
          book: book,
          quantity: json['quantity'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Book book, {int quantity = 1}) async {
    try {
      await _supabase.addToCart(book.id, quantity: quantity);
      await loadCart();
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      await _supabase.updateCartQuantity(cartItemId, quantity);
      await loadCart();
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _supabase.removeFromCart(cartItemId);
      _items.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _supabase.clearCart();
      _items = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }
}

/// Wishlist Provider - manages wishlist with Supabase
class WishlistProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService.instance;
  
  List<Book> _items = [];
  final Set<String> _wishlistIds = {};
  bool _isLoading = false;

  List<Book> get items => _items;
  bool get isLoading => _isLoading;
  
  bool isInWishlist(String bookId) => _wishlistIds.contains(bookId);

  Future<void> loadWishlist() async {
    if (!_supabase.isLoggedIn) {
      _items = [];
      _wishlistIds.clear();
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final data = await _supabase.getWishlist();
      _items = data.map((json) => Book.fromSupabase(json['books'])).toList();
      _wishlistIds.clear();
      _wishlistIds.addAll(_items.map((b) => b.id));
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(Book book) async {
    try {
      if (_wishlistIds.contains(book.id)) {
        await _supabase.removeFromWishlist(book.id);
        _wishlistIds.remove(book.id);
        _items.removeWhere((b) => b.id == book.id);
      } else {
        await _supabase.addToWishlist(book.id);
        _wishlistIds.add(book.id);
        _items.add(book);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
    }
  }
}

/// Transaction Provider - manages transactions with Supabase
class TransactionProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService.instance;
  
  List<BookTransaction> _transactions = [];
  bool _isLoading = false;

  List<BookTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions() async {
    if (!_supabase.isLoggedIn) {
      _transactions = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final data = await _supabase.getTransactions();
      _transactions = data.map((json) => BookTransaction.fromSupabase(json)).toList();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BookTransaction?> createTransaction({
    required double totalAmount,
    required String shippingAddress,
    required String shippingName,
    required String shippingPhone,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _supabase.createTransaction(
        totalAmount: totalAmount,
        shippingAddress: shippingAddress,
        shippingName: shippingName,
        shippingPhone: shippingPhone,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      final transaction = BookTransaction.fromSupabase(data);
      _transactions.insert(0, transaction);
      notifyListeners();
      return transaction;
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Dashboard Provider - manages dashboard analytics with Supabase
class DashboardProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService.instance;
  
  Map<String, dynamic> _stats = {};
  Map<String, double> _salesByCategory = {};
  List<Map<String, dynamic>> _salesTrend = [];
  Book? _bestSeller;
  bool _isLoading = false;

  Map<String, dynamic> get stats => _stats;
  Map<String, double> get salesByCategory => _salesByCategory;
  List<Map<String, dynamic>> get salesTrend => _salesTrend;
  Book? get bestSeller => _bestSeller;
  bool get isLoading => _isLoading;

  double get totalSales => (_stats['total_sales'] ?? 0).toDouble();
  int get totalItemsSold => _stats['total_items_sold'] ?? 0;
  int get totalBooks => _stats['total_books'] ?? 0;
  int get totalTransactions => _stats['total_transactions'] ?? 0;

  Future<void> loadDashboard() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.wait([
        _loadStats(),
        _loadSalesByCategory(),
        _loadSalesTrend(),
        _loadBestSeller(),
      ]);
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadStats() async {
    _stats = await _supabase.getDashboardStats();
  }

  Future<void> _loadSalesByCategory() async {
    _salesByCategory = await _supabase.getSalesByCategory();
  }

  Future<void> _loadSalesTrend() async {
    _salesTrend = await _supabase.getSalesTrend();
  }

  Future<void> _loadBestSeller() async {
    final data = await _supabase.getBestSellingBook();
    if (data != null) {
      _bestSeller = Book.fromSupabase(data);
    }
  }
}
