import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/supabase_service.dart';
import '../../core/providers/app_state.dart';
import '../home/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreedToTerms) {
      setState(() => _errorMessage = 'Please agree to Terms & Conditions');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await SupabaseService.instance.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );

      if (!mounted) return;

      if (response.user != null) {
        // Initialize user session in AppState
        final appState = AppStateProvider.of(context);
        await appState.initUserSession(response.user!);
        
        if (!mounted) return;
        
        // Go directly to main screen without email confirmation
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created successfully! Welcome to Releaf.'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = _parseError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseError(String error) {
    if (error.contains('User already registered')) {
      return 'This email is already registered. Please sign in.';
    } else if (error.contains('Password should be')) {
      return 'Password is too weak. Use letters and numbers.';
    } else if (error.contains('Invalid email')) {
      return 'Please enter a valid email address.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;
    
    final backgroundColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final inputFillColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final inputBorderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: inputBorderColor),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textPrimary,
              size: 18,
            ),
          ),
        ),
      ),
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
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Join Releaf and start your book journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                  const SizedBox(height: 36),

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

                  // Full Name Field
                  _buildLabel('Full Name', textPrimary),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Enter your full name',
                    icon: Icons.person_outline_rounded,
                    isDark: isDark,
                    fillColor: inputFillColor,
                    borderColor: inputBorderColor,
                    textColor: textPrimary,
                    hintColor: textSecondary,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Name is required';
                      if (value.length < 3) return 'Name must be at least 3 characters';
                      return null;
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: 18),

                  // Email Field
                  _buildLabel('Email', textPrimary),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Enter your email',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    isDark: isDark,
                    fillColor: inputFillColor,
                    borderColor: inputBorderColor,
                    textColor: textPrimary,
                    hintColor: textSecondary,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email is required';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                  const SizedBox(height: 18),

                  // Password Field
                  _buildLabel('Password', textPrimary),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Create a password',
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
                      if (value == null || value.isEmpty) return 'Password is required';
                      if (value.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                  const SizedBox(height: 18),

                  // Confirm Password Field
                  _buildLabel('Confirm Password', textPrimary),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hint: 'Confirm your password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscureConfirmPassword,
                    isDark: isDark,
                    fillColor: inputFillColor,
                    borderColor: inputBorderColor,
                    textColor: textPrimary,
                    hintColor: textSecondary,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: textSecondary,
                        size: 22,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please confirm your password';
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                  const SizedBox(height: 20),

                  // Terms & Conditions
                  GestureDetector(
                    onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: _agreedToTerms 
                                ? const Color(0xFF3B82F6) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _agreedToTerms 
                                  ? const Color(0xFF3B82F6) 
                                  : inputBorderColor,
                              width: 1.5,
                            ),
                          ),
                          child: _agreedToTerms
                              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                                height: 1.4,
                              ),
                              children: const [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: Color(0xFF3B82F6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFF3B82F6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                  const SizedBox(height: 32),

                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
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
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 700.ms),

                  const SizedBox(height: 28),

                  // Sign In Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(color: textSecondary, fontSize: 15),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
                  
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
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
}
