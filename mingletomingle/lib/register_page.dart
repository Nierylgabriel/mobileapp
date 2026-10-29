import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'widgets/brand_logo.dart';

class RegisterPage extends StatefulWidget {
  final String? initialEmail;
  final String? initialPassword;

  const RegisterPage({super.key, this.initialEmail, this.initialPassword});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  final _nameFocusNode            = FocusNode();
  final _emailFocusNode           = FocusNode();
  final _passwordFocusNode        = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading              = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  late AnimationController _fadeController;
  late Animation<double>   _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _nameController            = TextEditingController();
    _emailController           = TextEditingController(text: widget.initialEmail ?? '');
    _passwordController        = TextEditingController(text: widget.initialPassword ?? '');
    _confirmPasswordController = TextEditingController(text: widget.initialPassword ?? '');

    for (final fn in [
      _nameFocusNode,
      _emailFocusNode,
      _passwordFocusNode,
      _confirmPasswordFocusNode,
    ]) {
      fn.addListener(() => setState(() {}));
    }

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(email.trim());

  Future<void> _register() async {
    final name     = _nameController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm  = _confirmPasswordController.text.trim();

    setState(() {
      _nameError     = null;
      _emailError    = null;
      _passwordError = null;
      _confirmError  = null;
    });

    bool valid = true;
    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter your name');
      valid = false;
    }
    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter an email');
      valid = false;
    } else if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Enter a valid email address');
      valid = false;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Please choose a password');
      valid = false;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      valid = false;
    }
    if (confirm.isEmpty) {
      setState(() => _confirmError = 'Please confirm your password');
      valid = false;
    } else if (confirm != password) {
      setState(() => _confirmError = 'Passwords do not match');
      valid = false;
    }

    if (!valid) return;

    setState(() => _isLoading = true);
    try {
      final creds = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await creds.user?.updateDisplayName(name);

      if (!mounted) return;
      _showSnack('Welcome, $name! Account created successfully', isGood: true);
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          msg = 'Invalid email address format.';
          break;
        case 'weak-password':
          msg = 'Password is too weak. Try adding numbers or symbols.';
          break;
        default:
          msg = e.message ?? 'Registration failed. Please try again.';
      }
      _showSnack(msg);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Registration error. Please check your connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isGood = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isGood ? AppTheme.likeGreen : Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isGood ? BorderSide.none : const BorderSide(color: AppTheme.borderDefault),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        content: Text(msg,
            style: GoogleFonts.poppins(
                color: isGood ? Colors.white : AppTheme.textPrimary,
                fontSize: 13)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppTheme.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Subtle top lavender glow
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF3EEFC), Color(0xFFFAF8FE), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: const BrandLogoWidget(size: 110, showTagline: false),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find people who truly match your vibe',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Full Name
                    _buildField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      hint: 'Full name',
                      icon: Icons.person_outline_rounded,
                      errorText: _nameError,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (_nameError != null) setState(() => _nameError = null);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email
                    _buildField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      hint: 'Email address',
                      icon: Icons.email_outlined,
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (_emailError != null) setState(() => _emailError = null);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password
                    _buildField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      hint: 'Password (min. 6 characters)',
                      icon: Icons.lock_outline_rounded,
                      errorText: _passwordError,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (_passwordError != null) setState(() => _passwordError = null);
                      },
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password
                    _buildField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      hint: 'Confirm password',
                      icon: Icons.lock_outline_rounded,
                      errorText: _confirmError,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _register(),
                      onChanged: (_) {
                        if (_confirmError != null) setState(() => _confirmError = null);
                      },
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Create Account Button
                    GestureDetector(
                      onTap: _isLoading ? null : _register,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        decoration: BoxDecoration(
                          gradient: AppTheme.brandGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withAlpha(80),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Create Account',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded,
                                        color: Colors.white, size: 20),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    String? errorText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffix,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
  }) {
    final isFocused = focusNode.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppTheme.bgSecondary,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: errorText != null
                  ? const Color(0xFFEF4444)
                  : isFocused
                      ? AppTheme.primaryPurple
                      : AppTheme.borderDefault,
              width: isFocused || errorText != null ? 1.6 : 1.0,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withAlpha(25),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  icon,
                  color: isFocused ? AppTheme.primaryPurple : AppTheme.textMuted,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              suffixIcon: suffix,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              errorText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
