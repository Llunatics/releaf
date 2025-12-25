import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_state.dart';
import '../../core/models/book.dart';
import '../../core/utils/page_transitions.dart';
import '../products/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Book> _searchResults = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query, AppState appState) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final results = appState.books.where((book) {
      return book.title.toLowerCase().contains(lowercaseQuery) ||
          book.author.toLowerCase().contains(lowercaseQuery) ||
          book.category.toLowerCase().contains(lowercaseQuery) ||
          book.isbn.toLowerCase().contains(lowercaseQuery);
    }).toList();

    setState(() {
      _searchResults = results;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (value) => _performSearch(value, appState),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: appState.language == 'id'
                ? 'Cari buku, penulis, ISBN...'
                : 'Search books, authors, ISBN...',
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('', appState);
                    },
                    icon: const Icon(Icons.clear_rounded),
                  )
                : null,
          ),
        ),
      ),
      body: _buildBody(context, appState, isDark),
    );
  }

  Widget _buildBody(BuildContext context, AppState appState, bool isDark) {
    if (!_hasSearched) {
      return _buildSuggestions(context, appState, isDark);
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults(context, isDark, appState);
    }

    return _buildResults(context, isDark, appState);
  }

  Widget _buildSuggestions(
      BuildContext context, AppState appState, bool isDark) {
    final isId = appState.language == 'id';
    final recentSearches = isId
        ? ['Fiksi', 'Self-Help', 'Atomic Habits', 'Romansa']
        : ['Fiction', 'Self-Help', 'Atomic Habits', 'Romance'];
    final popularCategories = isId
        ? ['Fiksi', 'Non-Fiksi', 'Pendidikan', 'Self-Help', 'Biografi']
        : ['Fiction', 'Non-Fiction', 'Education', 'Self-Help', 'Biography'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appState.language == 'id'
                ? 'Pencarian Terakhir'
                : 'Recent Searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches.map((search) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search, appState);
                },
                child: Chip(
                  label: Text(search),
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  deleteIcon: Icon(
                    Icons.close,
                    size: 16,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                  onDeleted: () {},
                  backgroundColor:
                      isDark ? AppColors.surfaceDark : Colors.white,
                  side: BorderSide(
                    color: isDark
                        ? AppColors.textTertiaryDark.withValues(alpha: 0.2)
                        : AppColors.textTertiaryLight.withValues(alpha: 0.3),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          const SizedBox(height: 32),
          Text(
            appState.language == 'id'
                ? 'Kategori Populer'
                : 'Popular Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
          const SizedBox(height: 12),
          ...popularCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return ListTile(
              onTap: () {
                _searchController.text = category;
                _performSearch(category, appState);
              },
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors
                      .categoryColors[index % AppColors.categoryColors.length]
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.category_rounded,
                  color: AppColors
                      .categoryColors[index % AppColors.categoryColors.length],
                ),
              ),
              title: Text(category),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ).animate().fadeIn(
                duration: 300.ms,
                delay: Duration(milliseconds: 300 + (index * 50)));
          }),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, bool isDark, AppState appState) {
    final isId = appState.language == 'id';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.primaryBlue.withValues(alpha: 0.5),
            ),
          ).animate().scale(duration: 300.ms),
          const SizedBox(height: 16),
          Text(
            isId ? 'Tidak ditemukan' : 'No results found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          const SizedBox(height: 8),
          Text(
            isId
                ? 'Coba kata kunci lain atau periksa ejaan'
                : 'Try different keywords or check spelling',
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, bool isDark, AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            appState.language == 'id'
                ? '${_searchResults.length} hasil ditemukan'
                : '${_searchResults.length} results found',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final book = _searchResults[index];
              return _buildResultItem(context, book, isDark, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(
      BuildContext context, Book book, bool isDark, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransitions.scaleUp(ProductDetailScreen(book: book)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color:
                    isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          book.category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Rp ${_formatPrice(book.price.toInt())}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50))
        .slideX(begin: 0.1);
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
