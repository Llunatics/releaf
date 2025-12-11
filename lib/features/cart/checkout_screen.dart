import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_state.dart';
import '../home/main_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedPayment = 'transfer';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  children: [
                    ...appState.cart.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 65,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.book.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  ),
                                ),
                                Text(
                                  '${item.quantity}x ${currencyFormat.format(item.book.price)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            currencyFormat.format(item.totalPrice),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal'),
                        Text(currencyFormat.format(appState.cartTotal)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shipping'),
                        Text(currencyFormat.format(15000)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          currencyFormat.format(appState.cartTotal + 15000),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

              const SizedBox(height: 24),

              // Shipping Information
              Text(
                'Shipping Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outlined,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
                isDark: isDark,
              ).animate().fadeIn(duration: 300.ms, delay: 250.ms),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your phone' : null,
                isDark: isDark,
              ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Shipping Address',
                hint: 'Enter your complete address',
                icon: Icons.location_on_outlined,
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your address' : null,
                isDark: isDark,
              ).animate().fadeIn(duration: 300.ms, delay: 350.ms),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'Any special instructions',
                icon: Icons.note_outlined,
                maxLines: 2,
                isDark: isDark,
              ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

              const SizedBox(height: 24),

              // Payment Method
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 450.ms),
              const SizedBox(height: 16),
              _buildPaymentOption(
                'Bank Transfer',
                'transfer',
                Icons.account_balance_outlined,
                isDark,
              ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
              const SizedBox(height: 12),
              _buildPaymentOption(
                'E-Wallet',
                'ewallet',
                Icons.account_balance_wallet_outlined,
                isDark,
              ).animate().fadeIn(duration: 300.ms, delay: 550.ms),
              const SizedBox(height: 12),
              _buildPaymentOption(
                'Cash on Delivery',
                'cod',
                Icons.local_shipping_outlined,
                isDark,
              ).animate().fadeIn(duration: 300.ms, delay: 600.ms),

              const SizedBox(height: 32),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _placeOrder(context, appState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Place Order',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 650.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimaryLight,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark 
              ? AppColors.textTertiaryDark.withValues(alpha: 0.2)
              : AppColors.textTertiaryLight.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark 
              ? AppColors.textTertiaryDark.withValues(alpha: 0.2)
              : AppColors.textTertiaryLight.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String value, IconData icon, bool isDark) {
    final isSelected = _selectedPayment == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? AppColors.primaryBlue.withValues(alpha: 0.2)
                : AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                  ? AppColors.primaryBlue.withValues(alpha: 0.1)
                  : (isDark ? AppColors.surfaceDark : AppColors.backgroundLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primaryBlue : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected 
                    ? AppColors.primaryBlue
                    : (isDark ? Colors.white : AppColors.textPrimaryLight),
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primaryBlue : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, AppState appState) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // Simulate processing
    await Future.delayed(const Duration(seconds: 2));

    final transaction = appState.createOrderFromCart();

    if (!context.mounted || transaction == null) return;
    
    setState(() => _isProcessing = false);
    
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: appState.isDarkMode ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 64,
              ),
            ).animate().scale(duration: 400.ms),
            const SizedBox(height: 24),
            const Text(
              'Order Placed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              'Order #${transaction.id}',
              style: TextStyle(
                color: appState.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
            const SizedBox(height: 8),
            const Text(
              'Thank you for your purchase!\nYou will receive a confirmation shortly.',
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
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
                  'Continue Shopping',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
          ],
        ),
      ),
    );
  }
}