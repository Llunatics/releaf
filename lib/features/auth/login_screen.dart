import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/supabase_service.dart';
import '../../core/providers/app_state.dart';
import '../../core/utils/page_transitions.dart';
import 'register_screen.dart';
import '../home/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await SupabaseService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response.user != null) {
        // Initialize user session in AppState
        final appState = AppStateProvider.of(context);
        await appState.initUserSession(response.user!);
        
        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          PageTransitions.fade(const MainScreen()),
        );
      }
    } catch (e) {
      final appState = AppStateProvider.of(context);
      final isId = appState.language == 'id';
      setState(() {
        _errorMessage = _parseError(e.toString(), isId);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _parseError(String error, bool isId) {
    if (error.contains('Invalid login credentials')) {
      return isId ? 'Email atau password salah' : 'Invalid email or password';
    } else if (error.contains('Email not confirmed')) {
      return isId ? 'Silakan verifikasi email Anda terlebih dahulu' : 'Please verify your email first';
    } else if (error.contains('Too many requests')) {
      return isId ? 'Terlalu banyak percobaan. Coba lagi nanti.' : 'Too many attempts. Try again later.';
    }
    return isId ? 'Terjadi kesalahan. Silakan coba lagi.' : 'An error occurred. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;
    final isId = appState.language == 'id';
    
    final backgroundColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final inputFillColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final inputBorderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  
                  // Logo & Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E3A5F).withOpacity(0.3),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.auto_stories_rounded,
                                size: 44,
                                color: Color(0xFF1E3A5F),
                              ),
                              Positioned(
                                top: 18,
                                right: 18,
                                child: Icon(
                                  Icons.eco_rounded,
                                  size: 18,
                                  color: const Color(0xFF4ADE80),
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                        
                        const SizedBox(height: 32),
                        
                        Text(
                          isId ? 'Selamat Datang' : 'Welcome',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          isId ? 'Masuk untuk melanjutkan ke Releaf' : 'Sign in to continue to Releaf',
                          style: TextStyle(
                            fontSize: 16,
                            color: textSecondary,
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFEF4444),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().shake(duration: 400.ms),

                  // Email Field
                  _buildLabel('Email', textPrimary),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _emailController,
                    hint: isId ? 'Masukkan email Anda' : 'Enter your email',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    isDark: isDark,
                    fillColor: inputFillColor,
                    borderColor: inputBorderColor,
                    textColor: textPrimary,
                    hintColor: textSecondary,
                    validator: (value) {
                      if (value == null || value.isEmpty) return isId ? 'Email wajib diisi' : 'Email is required';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return isId ? 'Masukkan alamat email yang valid' : 'Enter a valid email address';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                  const SizedBox(height: 20),

                  // Password Field
                  _buildLabel(isId ? 'Kata Sandi' : 'Password', textPrimary),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _passwordController,
                    hint: isId ? 'Masukkan kata sandi Anda' : 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    isDark: isDark,
                    fillColor: inputFillColor,
                    borderColor: inputBorderColor,
                    textColor: textPrimary,
                    hintColor: textSecondary,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: textSecondary,
                        size: 22,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return isId ? 'Kata sandi wajib diisi' : 'Password is required';
                      if (value.length < 6) return isId ? 'Kata sandi minimal 6 karakter' : 'Password must be at least 6 characters';
                      return null;
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                  const SizedBox(height: 14),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _showForgotPasswordDialog(isDark, textPrimary, textSecondary, inputFillColor, inputBorderColor),
                      child: Text(
                        isId ? 'Lupa Kata Sandi?' : 'Forgot Password?',
                        style: const TextStyle(
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                  const SizedBox(height: 32),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF3B82F6).withOpacity(0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              isId ? 'Masuk' : 'Sign In',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 700.ms),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: inputBorderColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(isId ? 'atau' : 'or', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w500)),
                      ),
                      Expanded(child: Divider(color: inputBorderColor)),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 800.ms),

                  const SizedBox(height: 24),

                  // Continue as Guest
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageTransitions.fade(const MainScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: inputBorderColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.transparent,
                      ),
                      child: Text(
                        isId ? 'Lanjutkan sebagai Tamu' : 'Continue as Guest',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 900.ms),

                  const SizedBox(height: 40),

                  // Sign Up Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isId ? 'Belum punya akun? ' : "Don't have an account? ",
                          style: TextStyle(color: textSecondary, fontSize: 15),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransitions.slideFromRight(const RegisterScreen()),
                            );
                          },
                          child: Text(
                            isId ? 'Daftar' : 'Sign Up',
                            style: const TextStyle(
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 1000.ms),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
    required Color hintColor,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: textColor, fontSize: 16),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor.withOpacity(0.6), fontSize: 15),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(icon, color: hintColor, size: 22),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        errorStyle: TextStyle(
          color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
          fontSize: 12,
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(bool isDark, Color textPrimary, Color textSecondary, Color inputFillColor, Color inputBorderColor) {
    final appState = AppStateProvider.of(context);
    final isId = appState.language == 'id';
    final emailController = TextEditingController();
    final bgColor = isDark ? const Color(0xFF161B22) : Colors.white;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF3B82F6), size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              isId ? 'Reset Kata Sandi' : 'Reset Password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isId 
                  ? 'Masukkan alamat email Anda untuk menerima link reset kata sandi.'
                  : 'Enter your email address to receive a password reset link.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: isId ? 'Alamat email' : 'Email address',
                hintStyle: TextStyle(color: textSecondary.withOpacity(0.6)),
                filled: true,
                fillColor: inputFillColor,
                prefixIcon: Icon(Icons.mail_outline_rounded, color: textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(isId ? 'Batal' : 'Cancel', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (emailController.text.isNotEmpty) {
                        try {
                          await SupabaseService.instance.resetPassword(emailController.text.trim());
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isId ? 'Link reset terkirim! Cek email Anda.' : 'Reset link sent! Check your email.'),
                                backgroundColor: const Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${isId ? 'Kesalahan' : 'Error'}: ${e.toString()}'),
                                backgroundColor: const Color(0xFFEF4444),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(isId ? 'Kirim Link' : 'Send Link', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
