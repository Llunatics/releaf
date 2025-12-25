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
    final isId = appState.language == 'id';
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
      body: CustomScrollView(
        slivers: [
          // Clean White App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  isId ? 'Checkout' : 'Checkout',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '${appState.cart.length} ${isId ? 'item' : 'item${appState.cart.length > 1 ? 's' : ''}'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary Section
                    _buildSectionTitle(
                        isId ? 'Ringkasan Pesanan' : 'Order Summary',
                        Icons.shopping_bag_outlined,
                        isDark),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ...appState.cart.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final isLast = index == appState.cart.length - 1;
                            return Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: 60,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors.surfaceDark
                                                : const Color(0xFFF5F5F5),
                                          ),
                                          child: Image.network(
                                            item.book.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.menu_book_rounded,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.book.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF1A1A2E),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.book.author,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF667EEA)
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isId
                                                    ? 'Jml: ${item.quantity}'
                                                    : 'Qty: ${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF667EEA),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        currencyFormat.format(item.totalPrice),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF667EEA),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isLast)
                                  Divider(
                                      height: 1,
                                      color: isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade100),
                              ],
                            );
                          }),
                          Divider(
                              height: 32,
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade200),
                          _buildPriceRow(
                              isId ? 'Subtotal' : 'Subtotal',
                              currencyFormat.format(appState.cartTotal),
                              isDark),
                          const SizedBox(height: 8),
                          _buildPriceRow(isId ? 'Ongkos Kirim' : 'Shipping',
                              currencyFormat.format(15000), isDark),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isId ? 'Total' : 'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                ),
                              ),
                              Text(
                                currencyFormat
                                    .format(appState.cartTotal + 15000),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Color(0xFF667EEA),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: 28),

                    // Shipping Information
                    _buildSectionTitle(
                        isId ? 'Informasi Pengiriman' : 'Shipping Information',
                        Icons.local_shipping_outlined,
                        isDark),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildModernTextField(
                            controller: _nameController,
                            label: isId ? 'Nama Penerima' : 'Recipient Name',
                            icon: Icons.person_outline,
                            validator: (value) => value?.isEmpty ?? true
                                ? (isId
                                    ? 'Nama wajib diisi'
                                    : 'Name is required')
                                : null,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildModernTextField(
                            controller: _phoneController,
                            label: isId ? 'Nomor Telepon' : 'Phone Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) => value?.isEmpty ?? true
                                ? (isId
                                    ? 'Nomor telepon wajib diisi'
                                    : 'Phone is required')
                                : null,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildModernTextField(
                            controller: _addressController,
                            label: isId ? 'Alamat Lengkap' : 'Full Address',
                            icon: Icons.location_on_outlined,
                            maxLines: 3,
                            validator: (value) => value?.isEmpty ?? true
                                ? (isId
                                    ? 'Alamat wajib diisi'
                                    : 'Address is required')
                                : null,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildModernTextField(
                            controller: _notesController,
                            label: isId
                                ? 'Catatan (Opsional)'
                                : 'Notes (Optional)',
                            icon: Icons.note_outlined,
                            maxLines: 2,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                    const SizedBox(height: 28),

                    // Payment Method
                    _buildSectionTitle(
                        isId ? 'Metode Pembayaran' : 'Payment Method',
                        Icons.payment_outlined,
                        isDark),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildModernPaymentOption(
                            isId ? 'Transfer Bank' : 'Bank Transfer',
                            isId
                                ? 'Transfer ke rekening bank'
                                : 'Transfer to bank account',
                            'transfer',
                            Icons.account_balance_outlined,
                            isDark,
                            isFirst: true,
                          ),
                          Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100),
                          _buildModernPaymentOption(
                            'E-Wallet',
                            isId
                                ? 'GoPay, OVO, DANA, dll'
                                : 'GoPay, OVO, DANA, etc.',
                            'ewallet',
                            Icons.wallet_outlined,
                            isDark,
                          ),
                          Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100),
                          _buildModernPaymentOption(
                            isId ? 'Bayar di Tempat' : 'Cash on Delivery',
                            isId
                                ? 'Bayar saat barang diterima'
                                : 'Pay when goods are received',
                            'cod',
                            Icons.local_shipping_outlined,
                            isDark,
                            isLast: true,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed:
                  _isProcessing ? null : () => _placeOrder(context, appState),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_checkout, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          isId ? 'Buat Pesanan' : 'Place Order',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF667EEA), size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
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
        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF667EEA), size: 22),
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : const Color(0xFFF8F9FE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildModernPaymentOption(
      String title, String desc, String value, IconData icon, bool isDark,
      {bool isFirst = false, bool isLast = false}) {
    final isSelected = _selectedPayment == value;

    return InkWell(
      onTap: () => setState(() => _selectedPayment = value),
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667EEA).withValues(alpha: 0.05)
              : null,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(20) : Radius.zero,
            bottom: isLast ? const Radius.circular(20) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF667EEA).withValues(alpha: 0.1)
                    : (isDark ? AppColors.surfaceDark : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color:
                    isSelected ? const Color(0xFF667EEA) : Colors.grey.shade500,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected
                          ? const Color(0xFF667EEA)
                          : (isDark ? Colors.white : const Color(0xFF1A1A2E)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF667EEA)
                      : Colors.grey.shade300,
                  width: 2,
                ),
                color:
                    isSelected ? const Color(0xFF667EEA) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, AppState appState) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // Create order with shipping info and sync to Supabase
    final transaction = await appState.createOrderFromCart(
      shippingAddress: _addressController.text,
      shippingName: _nameController.text,
      shippingPhone: _phoneController.text,
      paymentMethod: _selectedPayment,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (!context.mounted || transaction == null) return;

    setState(() => _isProcessing = false);

    // Show modern success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isId = appState.language == 'id';
        return Dialog(
          backgroundColor:
              appState.isDarkMode ? AppColors.surfaceDark : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 48),
                ).animate().scale(duration: 400.ms),
                const SizedBox(height: 24),
                Text(
                  isId ? 'Pesanan Berhasil!' : 'Order Successful!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: appState.isDarkMode
                        ? Colors.white
                        : const Color(0xFF1A1A2E),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                const SizedBox(height: 8),
                Text(
                  'Order #${transaction.id.substring(0, 8).toUpperCase()}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
                const SizedBox(height: 12),
                Text(
                  isId
                      ? 'Terima kasih telah berbelanja!\nAnda akan segera menerima konfirmasi.'
                      : 'Thank you for shopping!\nYou will receive a confirmation soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const MainScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isId ? 'Kembali ke Beranda' : 'Back to Home',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
              ],
            ),
          ),
        );
      },
    );
  }
}
