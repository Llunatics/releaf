import 'package:flutter/material.dart';
import '../../core/models/book.dart';
import '../../core/models/transaction.dart';
import '../../core/providers/app_state.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/page_transitions.dart';
import '../auth/login_screen.dart';
import '../products/add_book_screen.dart';
import 'purchased_books_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Check for auto-accept orders when profile is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = AppStateProvider.of(context);
      appState.checkAutoAcceptOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;

    final backgroundColor =
        isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary =
        isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final borderColor =
        isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Clean Profile Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: isDark ? const Color(0xFF121212) : Colors.white,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar - Clean circle with subtle border
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E3A5F).withValues(alpha: 0.3)
                              : const Color(0xFF3B82F6).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                                : const Color(0xFF3B82F6)
                                    .withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 44,
                          color: isDark
                              ? const Color(0xFF60A5FA)
                              : const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        appState.isLoggedIn
                            ? (appState.userProfile?['full_name'] ??
                                appState.currentUser?.email?.split('@').first ??
                                'User')
                            : appState.tr('guest_user'),
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF1E293B),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Email
                      Text(
                        appState.isLoggedIn
                            ? (appState.currentUser?.email ?? '-')
                            : 'guest@releaf.com',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards - only for logged in users
                  if (appState.isLoggedIn) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            appState.tr('wishlist'),
                            appState.wishlist.length.toString(),
                            Icons.favorite_rounded,
                            const Color(0xFFEF4444),
                            cardColor,
                            textPrimary,
                            textSecondary,
                            borderColor,
                            onTap: () =>
                                _showWishlistSheet(context, appState, isDark),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            appState.tr('orders'),
                            appState.transactions.length.toString(),
                            Icons.receipt_long_rounded,
                            const Color(0xFF3B82F6),
                            cardColor,
                            textPrimary,
                            textSecondary,
                            borderColor,
                            onTap: () =>
                                _showOrdersSheet(context, appState, isDark),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            appState.tr('my_books'),
                            appState.myListedBooks.length.toString(),
                            Icons.menu_book_rounded,
                            const Color(0xFF10B981),
                            cardColor,
                            textPrimary,
                            textSecondary,
                            borderColor,
                            onTap: () =>
                                _showMyBooksSheet(context, appState, isDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Quick Access Section
                  _buildSectionTitle('Akses Cepat', textPrimary),
                  const SizedBox(height: 14),

                  _buildSettingsCard([
                    _buildNavigationItem(
                      icon: Icons.shopping_bag_rounded,
                      title: 'Buku yang Dibeli',
                      subtitle: appState.language == 'id'
                          ? 'Lihat semua buku yang sudah Anda beli'
                          : 'View all books you have purchased',
                      cardColor: cardColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      iconColor: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransitions.slideUp(const PurchasedBooksScreen()),
                        );
                      },
                    ),
                  ], cardColor, borderColor),

                  const SizedBox(height: 28),

                  // Preferences Section
                  _buildSectionTitle(appState.tr('preferences'), textPrimary),
                  const SizedBox(height: 14),

                  _buildSettingsCard([
                    _buildToggleItem(
                      icon: Icons.dark_mode_rounded,
                      title: appState.tr('dark_mode'),
                      subtitle: appState.language == 'id'
                          ? 'Ganti tema terang/gelap'
                          : 'Switch between light and dark theme',
                      value: isDark,
                      onChanged: (value) => appState.toggleTheme(),
                      cardColor: cardColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _buildDivider(borderColor),
                    _buildNavigationItem(
                      icon: Icons.notifications_outlined,
                      title: appState.tr('notifications'),
                      subtitle: appState.language == 'id'
                          ? 'Kelola pengaturan notifikasi'
                          : 'Manage notification settings',
                      cardColor: cardColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => _showNotificationSettings(context, isDark,
                          textPrimary, textSecondary, cardColor, borderColor),
                    ),
                    _buildDivider(borderColor),
                    _buildNavigationItem(
                      icon: Icons.language_rounded,
                      title: appState.tr('language'),
                      subtitle: appState.language == 'id'
                          ? 'Bahasa Indonesia'
                          : 'English',
                      cardColor: cardColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => _showLanguageOptions(context, isDark,
                          textPrimary, textSecondary, cardColor),
                    ),
                  ], cardColor, borderColor),

                  const SizedBox(height: 24),

                  // Account Section - only for logged in users
                  if (appState.isLoggedIn) ...[
                    _buildSectionTitle(appState.tr('account'), textPrimary),
                    const SizedBox(height: 14),
                    _buildSettingsCard([
                      _buildNavigationItem(
                        icon: Icons.person_outline_rounded,
                        title: appState.tr('edit_profile'),
                        subtitle: appState.language == 'id'
                            ? 'Ubah info pribadi'
                            : 'Update your personal info',
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () => _showEditProfile(
                            context,
                            isDark,
                            textPrimary,
                            textSecondary,
                            cardColor,
                            borderColor,
                            appState),
                      ),
                      _buildDivider(borderColor),
                      _buildNavigationItem(
                        icon: Icons.location_on_outlined,
                        title:
                            appState.language == 'id' ? 'Alamat' : 'Addresses',
                        subtitle: appState.language == 'id'
                            ? 'Kelola alamat pengiriman'
                            : 'Manage shipping addresses',
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () => _showAddresses(context, isDark,
                            textPrimary, textSecondary, cardColor, borderColor),
                      ),
                      _buildDivider(borderColor),
                      _buildNavigationItem(
                        icon: Icons.payment_rounded,
                        title: appState.language == 'id'
                            ? 'Metode Pembayaran'
                            : 'Payment Methods',
                        subtitle: appState.language == 'id'
                            ? 'Kelola opsi pembayaran'
                            : 'Manage payment options',
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () => _showPaymentMethods(context, isDark,
                            textPrimary, textSecondary, cardColor),
                      ),
                    ], cardColor, borderColor),
                    const SizedBox(height: 24),
                  ],

                  // Support Section
                  _buildSectionTitle(
                      appState.language == 'id' ? 'Bantuan' : 'Support',
                      textPrimary),
                  const SizedBox(height: 14),

                  _buildSettingsCard([
                    _buildNavigationItem(
                      icon: Icons.help_outline_rounded,
                      title: appState.tr('help_center'),
                      subtitle: appState.language == 'id'
                          ? 'Dapatkan bantuan & dukungan'
                          : 'Get help and support',
                      cardColor: cardColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => _showHelpCenter(context, isDark, textPrimary,
                          textSecondary, cardColor),
                    ),
                    _buildDivider(borderColor),
                    _buildNavigationItem(
                      icon: Icons.policy_outlined,
                      title: appState.language == 'id'
                          ? 'Kebijakan Privasi'
                          : 'Privacy Policy',
                      subtitle: appState.language == 'id'
                          ? 'Baca kebijakan privasi kami'
                          : 'Read our privacy policy',
                      cardColor: cardColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => _showPrivacyPolicy(
                          context, isDark, textPrimary, cardColor),
                    ),
                    _buildDivider(borderColor),
                    _buildNavigationItem(
                      icon: Icons.info_outline_rounded,
                      title: appState.language == 'id'
                          ? 'Tentang Releaf'
                          : 'About Releaf',
                      subtitle: '${appState.tr('version')} 1.0.0',
                      cardColor: cardColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => _showAboutDialog(context, isDark,
                          textPrimary, textSecondary, cardColor),
                    ),
                  ], cardColor, borderColor),

                  const SizedBox(height: 32),

                  // Login/Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: appState.isLoggedIn
                        ? OutlinedButton.icon(
                            onPressed: () => _showLogoutDialog(
                                context,
                                isDark,
                                textPrimary,
                                textSecondary,
                                cardColor,
                                appState),
                            icon: const Icon(Icons.logout_rounded,
                                color: Color(0xFFEF4444)),
                            label: Text(
                              appState.tr('logout'),
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFFEF4444), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                PageTransitions.fade(const LoginScreen()),
                              );
                            },
                            icon: const Icon(Icons.login_rounded,
                                color: Colors.white),
                            label: Text(
                              appState.language == 'id' ? 'Masuk' : 'Sign In',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textPrimary) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    );
  }

  Widget _buildSettingsCard(
      List<Widget> children, Color cardColor, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(height: 1, color: borderColor);
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF3B82F6),
            activeTrackColor: const Color(0xFF3B82F6).withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final finalIconColor = iconColor ?? const Color(0xFF3B82F6);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: finalIconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: finalIconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Methods
  void _showNotificationSettings(
      BuildContext context,
      bool isDark,
      Color textPrimary,
      Color textSecondary,
      Color cardColor,
      Color borderColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool pushNotif = true;
          bool emailNotif = true;
          bool orderUpdates = true;
          bool promotions = false;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Notification Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildNotificationToggle('Push Notifications', pushNotif,
                    (v) => setState(() => pushNotif = v), textPrimary),
                _buildNotificationToggle('Email Notifications', emailNotif,
                    (v) => setState(() => emailNotif = v), textPrimary),
                _buildNotificationToggle('Order Updates', orderUpdates,
                    (v) => setState(() => orderUpdates = v), textPrimary),
                _buildNotificationToggle('Promotions', promotions,
                    (v) => setState(() => promotions = v), textPrimary),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationToggle(
      String title, bool value, Function(bool) onChanged, Color textColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF3B82F6),
      ),
    );
  }

  void _showLanguageOptions(BuildContext context, bool isDark,
      Color textPrimary, Color textSecondary, Color cardColor) {
    final appState = AppStateProvider.of(context);
    final currentLang = appState.language;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                appState.tr('select_language'),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(
                'English',
                '🇺🇸',
                currentLang == 'en',
                textPrimary,
                () {
                  appState.setLanguage('en');
                  Navigator.pop(ctx);
                },
              ),
              _buildLanguageOption(
                'Bahasa Indonesia',
                '🇮🇩',
                currentLang == 'id',
                textPrimary,
                () {
                  appState.setLanguage('id');
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, String flag, bool isSelected,
      Color textColor, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(language,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF3B82F6))
          : Icon(Icons.circle_outlined,
              color: textColor.withValues(alpha: 0.3)),
      onTap: onTap,
    );
  }

  void _showEditProfile(
      BuildContext context,
      bool isDark,
      Color textPrimary,
      Color textSecondary,
      Color cardColor,
      Color borderColor,
      AppState appState) {
    final inputFillColor =
        isDark ? const Color(0xFF1E2430) : const Color(0xFFF8FAFC);
    final userName = appState.isLoggedIn
        ? (appState.userProfile?['full_name'] ??
            appState.currentUser?.email?.split('@').first ??
            '')
        : '';
    final userEmail =
        appState.isLoggedIn ? (appState.currentUser?.email ?? '') : '';
    final userPhone = appState.userProfile?['phone'] ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: borderColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text(appState.tr('edit_profile'),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
            const SizedBox(height: 24),
            _buildEditField(
                appState.language == 'id' ? 'Nama Lengkap' : 'Full Name',
                userName,
                inputFillColor,
                borderColor,
                textPrimary,
                textSecondary),
            const SizedBox(height: 16),
            _buildEditField('Email', userEmail, inputFillColor, borderColor,
                textPrimary, textSecondary),
            const SizedBox(height: 16),
            _buildEditField(
                appState.language == 'id' ? 'Telepon' : 'Phone',
                userPhone,
                inputFillColor,
                borderColor,
                textPrimary,
                textSecondary),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(appState.tr('save_changes'),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, String initialValue, Color fillColor,
      Color borderColor, Color textPrimary, Color textSecondary) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      style: TextStyle(color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textSecondary),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)),
      ),
    );
  }

  void _showAddresses(BuildContext context, bool isDark, Color textPrimary,
      Color textSecondary, Color cardColor, Color borderColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 24),
            Text('Shipping Addresses',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
            const SizedBox(height: 24),
            _buildAddressCard('Home', 'Jl. Sudirman No. 123, Jakarta', true,
                cardColor, textPrimary, textSecondary, borderColor),
            const SizedBox(height: 12),
            _buildAddressCard('Office', 'Jl. Gatot Subroto No. 456, Jakarta',
                false, cardColor, textPrimary, textSecondary, borderColor),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, color: Color(0xFF3B82F6)),
                label: const Text('Add New Address',
                    style: TextStyle(
                        color: Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(
      String label,
      String address,
      bool isDefault,
      Color cardColor,
      Color textPrimary,
      Color textSecondary,
      Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDefault ? const Color(0xFF3B82F6) : borderColor,
            width: isDefault ? 2 : 1),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded,
              color: isDefault ? const Color(0xFF3B82F6) : textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: textPrimary)),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Default',
                            style: TextStyle(
                                color: Color(0xFF3B82F6),
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(address,
                    style: TextStyle(fontSize: 13, color: textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethods(BuildContext context, bool isDark, Color textPrimary,
      Color textSecondary, Color cardColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 24),
            Text('Payment Methods',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
            const SizedBox(height: 24),
            _buildPaymentOption('Credit Card', '•••• •••• •••• 4242',
                Icons.credit_card_rounded, textPrimary, textSecondary),
            const SizedBox(height: 12),
            _buildPaymentOption(
                'GoPay',
                'john.doe@email.com',
                Icons.account_balance_wallet_rounded,
                textPrimary,
                textSecondary),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, color: Color(0xFF3B82F6)),
                label: const Text('Add Payment Method',
                    style: TextStyle(
                        color: Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon,
      Color textPrimary, Color textSecondary) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF3B82F6)),
      ),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
      subtitle:
          Text(subtitle, style: TextStyle(fontSize: 13, color: textSecondary)),
      trailing: Icon(Icons.chevron_right_rounded, color: textSecondary),
    );
  }

  void _showHelpCenter(BuildContext context, bool isDark, Color textPrimary,
      Color textSecondary, Color cardColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 24),
            Text('Help Center',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
            const SizedBox(height: 24),
            _buildHelpOption(Icons.chat_bubble_outline_rounded, 'Chat with Us',
                'Get instant help', textPrimary, textSecondary),
            _buildHelpOption(Icons.email_outlined, 'Email Support',
                'support@releaf.com', textPrimary, textSecondary),
            _buildHelpOption(Icons.phone_outlined, 'Call Us',
                '+62 21 1234 5678', textPrimary, textSecondary),
            _buildHelpOption(Icons.help_outline_rounded, 'FAQs',
                'Find answers to common questions', textPrimary, textSecondary),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption(IconData icon, String title, String subtitle,
      Color textPrimary, Color textSecondary) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF3B82F6)),
      ),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
      subtitle:
          Text(subtitle, style: TextStyle(fontSize: 13, color: textSecondary)),
    );
  }

  void _showPrivacyPolicy(
      BuildContext context, bool isDark, Color textPrimary, Color cardColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: textPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 24),
              Text('Privacy Policy',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary)),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    '''Last updated: December 2024

Your privacy is important to us. This Privacy Policy explains how Releaf collects, uses, and protects your personal information.

1. Information We Collect
We collect information you provide directly to us, such as your name, email address, and payment information when you create an account or make a purchase.

2. How We Use Your Information
We use the information we collect to provide, maintain, and improve our services, process transactions, and send you related information.

3. Information Sharing
We do not sell, trade, or otherwise transfer your personal information to outside parties without your consent.

4. Data Security
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

5. Your Rights
You have the right to access, update, or delete your personal information at any time through your account settings.

6. Contact Us
If you have any questions about this Privacy Policy, please contact us at privacy@releaf.com.''',
                    style: TextStyle(
                        color: textPrimary.withValues(alpha: 0.8), height: 1.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark, Color textPrimary,
      Color textSecondary, Color cardColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.eco_rounded, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text('Releaf',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
            const SizedBox(height: 6),
            Text('Version 1.0.0',
                style: TextStyle(color: textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            Text(
              'Preloved Books Marketplace\nGive books a second life 📚',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Close',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDark, Color textPrimary,
      Color textSecondary, Color cardColor, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Color(0xFFEF4444), size: 32),
            ),
            const SizedBox(height: 20),
            Text(appState.tr('logout'),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
            const SizedBox(height: 8),
            Text(
              appState.language == 'id'
                  ? 'Apakah Anda yakin ingin keluar dari akun?'
                  : 'Are you sure you want to logout from your account?',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(appState.tr('cancel'),
                        style: TextStyle(
                            color: textSecondary, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        // Clear user session first
                        appState.clearUserSession();

                        await SupabaseService.instance.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: const Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(appState.tr('logout'),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWishlistSheet(
      BuildContext context, AppState appState, bool isDark) {
    final backgroundColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
    final textSecondary =
        isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);
    final borderColor =
        isDark ? const Color(0xFF30363D) : const Color(0xFFE5E7EB);
    final cardColor = isDark ? const Color(0xFF21262D) : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFEF4444),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Wishlist',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          '${appState.wishlist.length} books saved',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: textSecondary),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),
            // Content
            Expanded(
              child: appState.wishlist.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 64,
                            color: textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No books in wishlist',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Browse and save books you love!',
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: appState.wishlist.length,
                      itemBuilder: (context, index) {
                        final book = appState.wishlist[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              // Book Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: book.imageUrl.isNotEmpty
                                    ? Image.network(
                                        book.imageUrl,
                                        width: 70,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 70,
                                          height: 100,
                                          color: borderColor,
                                          child: Icon(
                                            Icons.book_rounded,
                                            color: textSecondary,
                                            size: 30,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 70,
                                        height: 100,
                                        color: borderColor,
                                        child: Icon(
                                          Icons.book_rounded,
                                          color: textSecondary,
                                          size: 30,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              // Book Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book.author,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Rp ${book.price.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getConditionColor(
                                                    book.condition)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            book.condition.label,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: _getConditionColor(
                                                  book.condition),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Remove button
                              IconButton(
                                onPressed: () {
                                  appState.toggleWishlist(book);
                                  if (appState.wishlist.isEmpty) {
                                    Navigator.pop(context);
                                  }
                                },
                                icon: const Icon(
                                  Icons.favorite_rounded,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrdersSheet(BuildContext context, AppState appState, bool isDark) {
    final backgroundColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
    final textSecondary =
        isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);
    final borderColor =
        isDark ? const Color(0xFF30363D) : const Color(0xFFE5E7EB);
    final cardColor = isDark ? const Color(0xFF21262D) : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFF3B82F6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Orders',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          '${appState.transactions.length} orders',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: textSecondary),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),
            // Content
            Expanded(
              child: appState.transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start shopping for preloved books!',
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: appState.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = appState.transactions[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order #${transaction.id.substring(0, 8)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(transaction.status)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      transaction.status.label.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            _getStatusColor(transaction.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${transaction.totalAmount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Date: ${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                              // Show status update button for non-completed orders
                              if (transaction.status !=
                                      TransactionStatus.completed &&
                                  transaction.status !=
                                      TransactionStatus.cancelled) ...[
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _showUpdateStatusDialog(
                                        context, appState, transaction, isDark);
                                  },
                                  icon: const Icon(Icons.update, size: 18),
                                  label: const Text('Update Status'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF3B82F6),
                                    side: const BorderSide(
                                        color: Color(0xFF3B82F6)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                              // Show "Mark as Delivered" button for shipped status (for testing)
                              if (transaction.status ==
                                  TransactionStatus.shipped) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          await appState
                                              .markAsDelivered(transaction.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Row(
                                                  children: [
                                                    Icon(Icons.local_shipping,
                                                        color: Colors.white),
                                                    SizedBox(width: 12),
                                                    Text(
                                                        'Pesanan ditandai sudah sampai'),
                                                  ],
                                                ),
                                                backgroundColor:
                                                    const Color(0xFF3B82F6),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.local_shipping,
                                            size: 18),
                                        label:
                                            const Text('Tandai Sudah Sampai'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFF3B82F6),
                                          side: const BorderSide(
                                              color: Color(0xFF3B82F6)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              // Show accept button for delivered status
                              if (transaction.status ==
                                  TransactionStatus.delivered) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          _showAcceptOrderDialog(context,
                                              appState, transaction, isDark);
                                        },
                                        icon: const Icon(
                                            Icons.check_circle_outline,
                                            size: 18),
                                        label: const Text('Terima Pesanan'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF10B981),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (transaction.autoAcceptDate != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Auto-accept: ${transaction.autoAcceptDate!.day}/${transaction.autoAcceptDate!.month}/${transaction.autoAcceptDate!.year}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                              // Show review if completed and has review
                              if (transaction.status ==
                                      TransactionStatus.completed &&
                                  transaction.review != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1A1F2E)
                                        : const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.rate_review,
                                              size: 16,
                                              color: Color(0xFFFBBF24)),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Your Review',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: textPrimary,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (transaction.rating != null)
                                            Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    size: 14,
                                                    color: Color(0xFFFBBF24)),
                                                const SizedBox(width: 2),
                                                Text(
                                                  transaction.rating!
                                                      .toStringAsFixed(1),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        transaction.review!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMyBooksSheet(BuildContext context, AppState appState, bool isDark) {
    final backgroundColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
    final textSecondary =
        isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);
    final borderColor =
        isDark ? const Color(0xFF30363D) : const Color(0xFFE5E7EB);
    final cardColor = isDark ? const Color(0xFF21262D) : Colors.white;

    // Show user's listed books
    final myBooks = appState.myListedBooks;

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (ctx, scrollController) => Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF10B981),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.tr('my_books'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            appState.language == 'id'
                                ? '${myBooks.length} buku dijual'
                                : '${myBooks.length} books for sale',
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add Book Button
                    IconButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          PageTransitions.slideUp(const AddBookScreen()),
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close_rounded, color: textSecondary),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: borderColor),
              // Content
              Expanded(
                child: myBooks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 64,
                              color: textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              appState.language == 'id'
                                  ? 'Belum ada buku'
                                  : 'No books listed',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              appState.language == 'id'
                                  ? 'Mulai jual buku bekas Anda!'
                                  : 'Start selling your preloved books!',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  PageTransitions.slideUp(
                                      const AddBookScreen()),
                                );
                              },
                              icon: const Icon(Icons.add_rounded,
                                  color: Colors.white),
                              label: Text(
                                appState.tr('add_book'),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: myBooks.length,
                        itemBuilder: (ctx, index) {
                          final book = myBooks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                // Book Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: book.imageUrl.isNotEmpty
                                      ? Image.network(
                                          book.imageUrl,
                                          width: 70,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            width: 70,
                                            height: 100,
                                            color: borderColor,
                                            child: Icon(
                                              Icons.book_rounded,
                                              color: textSecondary,
                                              size: 30,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 70,
                                          height: 100,
                                          color: borderColor,
                                          child: Icon(
                                            Icons.book_rounded,
                                            color: textSecondary,
                                            size: 30,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 14),
                                // Book Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        book.author,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981)
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Rp ${book.price.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF10B981),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: book.stock > 0
                                                  ? const Color(0xFF10B981)
                                                      .withValues(alpha: 0.1)
                                                  : const Color(0xFFEF4444)
                                                      .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              book.stock > 0
                                                  ? (appState.language == 'id'
                                                      ? 'TERSEDIA'
                                                      : 'AVAILABLE')
                                                  : (appState.language == 'id'
                                                      ? 'TERJUAL'
                                                      : 'SOLD'),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: book.stock > 0
                                                    ? const Color(0xFF10B981)
                                                    : const Color(0xFFEF4444),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Edit & Delete Buttons
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        Navigator.push(
                                          context,
                                          PageTransitions.slideUp(
                                              AddBookScreen(bookToEdit: book)),
                                        );
                                      },
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.edit_rounded,
                                          color: Color(0xFF3B82F6),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showDeleteBookDialog(
                                            context,
                                            book,
                                            appState,
                                            isDark,
                                            textPrimary,
                                            textSecondary,
                                            cardColor, () {
                                          setModalState(() {});
                                        });
                                      },
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.delete_rounded,
                                          color: Color(0xFFEF4444),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteBookDialog(
      BuildContext context,
      Book book,
      AppState appState,
      bool isDark,
      Color textPrimary,
      Color textSecondary,
      Color cardColor,
      VoidCallback onDeleted) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_rounded,
                  color: Color(0xFFEF4444), size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              appState.tr('delete_book'),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              appState.language == 'id'
                  ? 'Apakah Anda yakin ingin menghapus "${book.title}"?'
                  : 'Are you sure you want to delete "${book.title}"?',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(appState.tr('cancel'),
                        style: TextStyle(
                            color: textSecondary, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await appState.deleteBook(book.id);
                      onDeleted();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white),
                                const SizedBox(width: 12),
                                Text(appState.tr('book_deleted')),
                              ],
                            ),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(appState.tr('delete'),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getConditionColor(BookCondition condition) {
    switch (condition) {
      case BookCondition.likeNew:
        return const Color(0xFF10B981);
      case BookCondition.veryGood:
        return const Color(0xFF3B82F6);
      case BookCondition.good:
        return const Color(0xFFF59E0B);
      case BookCondition.acceptable:
        return const Color(0xFFEF4444);
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return const Color(0xFF10B981);
      case TransactionStatus.pending:
        return const Color(0xFFF59E0B);
      case TransactionStatus.cancelled:
        return const Color(0xFFEF4444);
      case TransactionStatus.delivered:
        return const Color(0xFF8B5CF6);
      case TransactionStatus.processing:
      case TransactionStatus.shipped:
        return const Color(0xFF3B82F6);
    }
  }

  void _showUpdateStatusDialog(BuildContext context, AppState appState,
      BookTransaction transaction, bool isDark) {
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
    final textSecondary =
        isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);

    // Available next statuses based on current status
    List<TransactionStatus> availableStatuses = [];
    switch (transaction.status) {
      case TransactionStatus.pending:
        availableStatuses = [
          TransactionStatus.processing,
          TransactionStatus.cancelled
        ];
        break;
      case TransactionStatus.processing:
        availableStatuses = [
          TransactionStatus.shipped,
          TransactionStatus.cancelled
        ];
        break;
      case TransactionStatus.shipped:
        availableStatuses = [TransactionStatus.delivered];
        break;
      case TransactionStatus.delivered:
        // Can only be completed by buyer through accept dialog
        availableStatuses = [];
        break;
      default:
        availableStatuses = [];
    }

    if (availableStatuses.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.update,
                      color: Color(0xFF3B82F6), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'Order #${transaction.id.substring(0, 8)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Current Status: ${transaction.status.label}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select New Status:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...availableStatuses.map((status) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () async {
                      await appState.updateOrderStatus(transaction.id, status);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white),
                                const SizedBox(width: 12),
                                Text('Status updated to ${status.label}'),
                              ],
                            ),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _getStatusColor(status),
                      side: BorderSide(color: _getStatusColor(status)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(_getStatusIcon(status), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                status.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(status),
                                ),
                              ),
                              Text(
                                status.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Icons.schedule;
      case TransactionStatus.processing:
        return Icons.inventory_2;
      case TransactionStatus.shipped:
        return Icons.local_shipping;
      case TransactionStatus.delivered:
        return Icons.home;
      case TransactionStatus.completed:
        return Icons.check_circle;
      case TransactionStatus.cancelled:
        return Icons.cancel;
    }
  }

  void _showAcceptOrderDialog(BuildContext context, AppState appState,
      BookTransaction transaction, bool isDark) {
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
    final textSecondary =
        isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);

    final reviewController = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle,
                          color: Color(0xFF10B981), size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Konfirmasi Penerimaan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            'Berikan review untuk pesanan ini',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Rating',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          rating = (index + 1).toDouble();
                        });
                      },
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: const Color(0xFFFBBF24),
                        size: 36,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  'Review (Opsional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reviewController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Bagaimana pengalaman Anda dengan produk ini?',
                    hintStyle:
                        TextStyle(color: textSecondary.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF0D1117)
                        : const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: textPrimary),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await appState.acceptOrder(
                            transaction.id,
                            review: reviewController.text.isNotEmpty
                                ? reviewController.text
                                : null,
                            rating: rating,
                          );
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: Colors.white),
                                    SizedBox(width: 12),
                                    Text('Pesanan berhasil dikonfirmasi!'),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Konfirmasi',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
