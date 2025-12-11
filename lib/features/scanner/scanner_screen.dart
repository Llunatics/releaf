import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_state.dart';
import '../products/product_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _hasScanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture, AppState appState) {
    if (!_isScanning || _hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && !_hasScanned) {
        setState(() {
          _hasScanned = true;
          _isScanning = false;
        });

        // Search for book by ISBN
        final book = appState.books.firstWhere(
          (b) => b.isbn.replaceAll('-', '').contains(code.replaceAll('-', '')),
          orElse: () => appState.books.first, // Fallback for demo
        );

        // Show result
        _showResult(context, code, book, appState);
      }
    }
  }

  void _showResult(BuildContext context, String code, book, AppState appState) {
    final isDark = appState.isDarkMode;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 48,
                ),
              ).animate().scale(duration: 300.ms),
              const SizedBox(height: 16),
              Text(
                'Book Found!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
              const SizedBox(height: 8),
              Text(
                'ISBN: $code',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
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
                    const SizedBox(width: 16),
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
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rp ${_formatPrice(book.price.toInt())}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _hasScanned = false;
                          _isScanning = true;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Scan Again'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(book: book),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
            ],
          ),
        );
      },
    ).then((_) {
      if (!_hasScanned) {
        setState(() {
          _isScanning = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    // ignore: unused_local_variable
    final isDark = appState.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Barcode/QR'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) => _handleBarcode(capture, appState),
          ),
          // Overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          // Scanner Frame
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryBlue, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // Corner indicators
                  Positioned(top: -3, left: -3, child: _buildCorner(true, true)),
                  Positioned(top: -3, right: -3, child: _buildCorner(true, false)),
                  Positioned(bottom: -3, left: -3, child: _buildCorner(false, true)),
                  Positioned(bottom: -3, right: -3, child: _buildCorner(false, false)),
                  // Scanning line animation
                  if (_isScanning)
                    AnimatedBuilder(
                      animation: AlwaysStoppedAnimation(1),
                      builder: (context, child) {
                        return Positioned(
                          top: 0,
                          left: 16,
                          right: 16,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.primaryBlue,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          )
                              .animate(onPlay: (controller) => controller.repeat())
                              .moveY(begin: 0, end: 260, duration: 2000.ms)
                              .fadeIn(duration: 300.ms)
                              .fadeOut(delay: 1700.ms, duration: 300.ms),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Point camera at barcode or QR code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => cameraController.toggleTorch(),
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flash_on_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      onPressed: () => cameraController.switchCamera(),
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flip_camera_ios_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: AppColors.primaryBlue, width: 4) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: AppColors.primaryBlue, width: 4) : BorderSide.none,
          left: isLeft ? const BorderSide(color: AppColors.primaryBlue, width: 4) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: AppColors.primaryBlue, width: 4) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(12) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(12) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(12) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(12) : Radius.zero,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
