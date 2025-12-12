import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_state.dart';
import '../../core/models/book.dart';
import '../../core/utils/page_transitions.dart';
import '../products/product_detail_screen.dart';
import '../products/widgets/book_card.dart';
import '../search/search_screen.dart';
import '../scanner/scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;
    final books = appState.books;
    
    // Get featured books (top rated)
    final featuredBooks = List<Book>.from(books)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    
    // Get newest books
    final newestBooks = List<Book>.from(books)
      ..sort((a, b) => b.addedDate.compareTo(a.addedDate));
    
    // Get best deals (highest discount)
    final bestDeals = books.where((b) => b.hasDiscount).toList()
      ..sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar - Clean Design
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo & Title
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A5F),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E3A5F).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.auto_stories_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  Icons.eco_rounded,
                                  size: 12,
                                  color: const Color(0xFF4ADE80),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Releaf',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              appState.language == 'id' ? 'Buku Bekas Berkualitas' : 'Preloved Books',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Action buttons
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.qr_code_scanner_rounded,
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransitions.slideUp(const ScannerScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.notifications_outlined,
                          isDark: isDark,
                          onTap: () {
                            // Notification
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar - Clean Design
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransitions.fade(const SearchScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark 
                        ? const Color(0xFF30363D)
                        : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: isDark ? const Color(0xFF8B949E) : const Color(0xFF94A3B8),
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        appState.tr('search_preloved'),
                        style: TextStyle(
                          color: isDark ? const Color(0xFF8B949E) : const Color(0xFF94A3B8),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            ),
          ),

          // Featured Section
          SliverToBoxAdapter(
            child: _buildSection(
              context,
              appState.tr('featured'),
              appState.language == 'id' ? 'Pilihan terbaik pembaca' : 'Top rated by readers',
              featuredBooks.take(6).toList(),
              isDark,
              appState,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          ),

          // Best Deals Section
          if (bestDeals.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                appState.tr('best_deals'),
                appState.language == 'id' ? 'Hemat lebih banyak' : 'Save more on these',
                bestDeals.take(6).toList(),
                isDark,
                appState,
                showDiscount: true,
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            ),

          // New Arrivals Section
          SliverToBoxAdapter(
            child: _buildSection(
              context,
              appState.tr('new_arrivals'),
              appState.language == 'id' ? 'Baru ditambahkan' : 'Recently added',
              newestBooks.take(6).toList(),
              isDark,
              appState,
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark 
            ? const Color(0xFF161B22) 
            : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark 
              ? const Color(0xFF30363D)
              : const Color(0xFFE2E8F0),
          ),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : const Color(0xFF475569),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String subtitle,
    List<Book> books,
    bool isDark,
    AppState appState, {
    bool showDiscount = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to see all
                },
                child: Text(appState.tr('see_all')),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280, // Height for book cards
          child: AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: books.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: BookCard(
                          book: books[index],
                          showDiscount: showDiscount,
                          width: 150, // Portrait book width
                          height: 260, // Fixed height for horizontal scroll
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransitions.scaleUp(ProductDetailScreen(book: books[index])),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
