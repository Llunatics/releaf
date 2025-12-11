import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../home/main_screen.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlueDark,
              Color(0xFF1E40AF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.eco_rounded,
                      size: 64,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 400.ms),
                
                const SizedBox(height: 32),
                
                // App Name
                Text(
                  'Releaf',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 8),
                
                // Tagline
                Text(
                  'Preloved Books, New Stories',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: 1,
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 60),
                
                // Loading Indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                )
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.5, 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
