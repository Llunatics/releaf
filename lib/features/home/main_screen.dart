import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_state.dart';
import '../home/home_screen.dart';
import '../products/products_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductsScreen(),
    const DashboardScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;
    
    // Localized labels
    final labels = [
      appState.tr('home'),
      appState.tr('books'),
      appState.tr('dashboard'),
      appState.tr('cart'),
      appState.tr('profile'),
    ];
    
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2128) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDark 
                ? const Color(0xFF30363D) 
                : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, labels[0], isDark),
              _buildNavItem(1, Icons.menu_book_rounded, Icons.menu_book_outlined, labels[1], isDark),
              _buildNavItem(2, Icons.analytics_rounded, Icons.analytics_outlined, labels[2], isDark),
              _buildNavItem(3, Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, labels[3], isDark, badge: AppStateProvider.of(context).cartItemCount),
              _buildNavItem(4, Icons.person_rounded, Icons.person_outlined, labels[4], isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, bool isDark, {int badge = 0}) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected 
            ? LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.15),
                  AppColors.primaryBlue.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isSelected 
            ? Border.all(
                color: AppColors.primaryBlue.withOpacity(0.2),
                width: 1,
              )
            : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    color: isSelected 
                      ? AppColors.primaryBlue 
                      : (isDark ? const Color(0xFF8B949E) : const Color(0xFF9CA3AF)),
                    size: isSelected ? 26 : 24,
                  ),
                ),
                if (badge > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        badge > 99 ? '99+' : badge.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.2),
            ],
          ],
        ),
      ),
    );
  }
}
