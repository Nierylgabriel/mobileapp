import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'widgets/brand_logo.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final bool startWithSignIn;

  const LoginPage({super.key, this.startWithSignIn = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _showSignInForm = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _orbitAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _showSignInForm = widget.startWithSignIn;
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email.trim());
  }

  String _deriveDisplayName(String email) {
    final prefix = email.split('@').first;
    final parts = prefix.split(RegExp(r'[._-]'));
    return parts
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
        .join(' ');
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your email address');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(
        () => _emailError = 'Please enter a valid email (e.g. name@domain.com)',
      );
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Please enter your password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _handleAuthError(e, email, password);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Unable to sign in. Please check your connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleAuthError(
    FirebaseAuthException e,
    String email,
    String password,
  ) {
    String message;
    bool offerSignUp = false;

    switch (e.code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        message = 'Incorrect email or password, or no account exists yet.';
        offerSignUp = true;
        break;
      case 'invalid-email':
        setState(() => _emailError = 'Invalid email format');
        return;
      case 'user-disabled':
        message = 'This account has been disabled. Contact support.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Wait a moment or reset your password.';
        break;
      case 'network-request-failed':
        message = 'Network error. Check your internet connection.';
        break;
      default:
        message = e.message ?? 'Authentication failed.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderDefault),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 13),
        ),
        action: offerSignUp
            ? SnackBarAction(
                label: 'Sign Up',
                textColor: AppTheme.primaryPurple,
                onPressed: () => _navigateToRegister(email, password),
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );

    if (offerSignUp) _showAccountNotFoundSheet(email, password);
  }

  void _showAccountNotFoundSheet(String email, String password) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x181F1933),
              blurRadius: 30,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: AppTheme.primaryPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Not Found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'No account exists for this email',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderDefault),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 18,
                    color: AppTheme.primaryPurple,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Would you like to create a new account with this email, or re-check your credentials?',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: AppTheme.borderDefault),
                    ),
                    child: Text(
                      'Try Again',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withAlpha(70),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _autoRegisterAccount(email, password);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Create Account',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _autoRegisterAccount(String email, String password) async {
    setState(() => _isLoading = true);
    try {
      final creds = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final displayName = _deriveDisplayName(email);
      await creds.user?.updateDisplayName(displayName);
      if (!mounted) return;
      _showSnack('Welcome, $displayName! Account created ❤️', isGood: true);
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnack('Registration failed: ${e.message ?? e.code}');
    } catch (_) {
      if (!mounted) return;
      _showSnack('Registration error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToRegister([String? email, String? password]) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(
          initialEmail: email ?? _emailController.text.trim(),
          initialPassword: password ?? _passwordController.text.trim(),
        ),
      ),
    );
  }

  void _quickDemoSignIn() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_isValidEmail(email)) {
      _showSnack('Enter a valid email first to receive reset instructions.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _showSnack('Reset link sent to $email.', isGood: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: ${e.toString().split(']').last.trim()}');
    }
  }

  void _showSnack(String msg, {bool isGood = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isGood ? AppTheme.likeGreen : Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isGood
              ? BorderSide.none
              : const BorderSide(color: AppTheme.borderDefault),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        content: Text(
          msg,
          style: GoogleFonts.poppins(
            color: isGood ? Colors.white : AppTheme.textPrimary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: Stack(
        children: [
          // Background soft lavender gradient wash
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
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
              child: _showSignInForm
                  ? _buildSignInView()
                  : _buildWelcomeOnboardingView(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 2: Welcome / Onboarding Screen ──────────────────────────────────
  Widget _buildWelcomeOnboardingView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Top Mini Brand
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Mingle to Mingle',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Central Profile Image surrounded by Thin Purple Radar Circles
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 290,
                height: 290,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer radar circle
                    Container(
                      width: 280 * _pulseAnimation.value,
                      height: 280 * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryPurple.withAlpha(35),
                          width: 1.2,
                        ),
                      ),
                    ),
                    // Middle radar circle
                    Container(
                      width: 215,
                      height: 215,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryPurple.withAlpha(60),
                          width: 1.2,
                        ),
                      ),
                    ),
                    // Inner radar circle
                    Container(
                      width: 155,
                      height: 155,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryPurple.withAlpha(85),
                          width: 1.4,
                        ),
                      ),
                    ),

                    // Central Hero Profile Image
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.brandGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withAlpha(90),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3.5),
                      child: ClipOval(
                        child: Image.network(
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: AppTheme.bgSecondary,
                                child: const Icon(
                                  Icons.person,
                                  color: AppTheme.primaryPurple,
                                  size: 48,
                                ),
                              ),
                        ),
                      ),
                    ),

                    // Floating Satellite Profile 1 (Top-Left)
                    Positioned(
                      top: 18,
                      left: 28,
                      child: _buildSatelliteAvatar(
                        _orbitAvatars[0],
                        46,
                        AppTheme.primaryPurple,
                      ),
                    ),

                    // Floating Satellite Profile 2 (Top-Right)
                    Positioned(
                      top: 36,
                      right: 18,
                      child: _buildSatelliteAvatar(
                        _orbitAvatars[1],
                        50,
                        AppTheme.softPurple,
                      ),
                    ),

                    // Floating Satellite Profile 3 (Bottom-Left)
                    Positioned(
                      bottom: 30,
                      left: 20,
                      child: _buildSatelliteAvatar(
                        _orbitAvatars[2],
                        52,
                        AppTheme.deepPurple,
                      ),
                    ),

                    // Floating Satellite Profile 4 (Bottom-Right)
                    Positioned(
                      bottom: 24,
                      right: 32,
                      child: _buildSatelliteAvatar(
                        _orbitAvatars[3],
                        44,
                        AppTheme.primaryPurple,
                      ),
                    ),

                    // Small Floating Heart Tag
                    Positioned(
                      top: 100,
                      right: 50,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withAlpha(40),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppTheme.primaryPurple,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // Bold Headline
          Text(
            'Meet people who match\nyour vibe today.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.25,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle in Muted Gray-Purple
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Discover meaningful connections nearby and chat with singles who share your energy, interests, and passions.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 34),

          // Large Rounded Purple Gradient "Get Started" Button
          _buildPrimaryButton(
            label: 'Get Started',
            icon: Icons.arrow_forward_rounded,
            onTap: () => setState(() => _showSignInForm = true),
          ),

          const SizedBox(height: 14),

          // Instant Demo Explore Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _quickDemoSignIn,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(
                  color: AppTheme.borderDefault,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppTheme.primaryPurple,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Demo Explore (Instant Access)',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sign-up Link with Purple Highlighted Text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\u2019t have an account? ',
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToRegister(),
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSatelliteAvatar(String url, double size, Color ringColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: ringColor.withAlpha(160), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0x181F1933),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppTheme.bgSecondary,
            child: const Icon(
              Icons.person,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  // ── Section 2B: Sign In Form View ──────────────────────────────────────────
  Widget _buildSignInView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back to Onboarding
          IconButton(
            onPressed: () => setState(() => _showSignInForm = false),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppTheme.textPrimary,
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),

          const SizedBox(height: 16),

          Center(child: const BrandLogoWidget(size: 130, showTagline: false)),

          const SizedBox(height: 24),

          Text(
            'Welcome back',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to meet matches who share your vibe',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 28),

          // Email Field
          _buildField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            errorText: _emailError,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_emailError != null) setState(() => _emailError = null);
            },
          ),

          const SizedBox(height: 16),

          // Password Field
          _buildField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            hint: 'Enter your password',
            icon: Icons.lock_outline_rounded,
            errorText: _passwordError,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _signIn(),
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

          const SizedBox(height: 10),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _sendPasswordReset,
              child: Text(
                'Forgot password?',
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryPurple,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Sign In Button
          _buildPrimaryButton(
            label: 'Sign In',
            icon: Icons.login_rounded,
            onTap: _isLoading ? null : _signIn,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 14),

          // Quick Demo
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _quickDemoSignIn,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(
                  color: AppTheme.borderDefault,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppTheme.primaryPurple,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Demo Explore (Instant Access)',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Sign Up Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\u2019t have an account? ',
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToRegister(),
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
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
            autocorrect: false,
            enableSuggestions: false,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  icon,
                  color: isFocused
                      ? AppTheme.primaryPurple
                      : AppTheme.textMuted,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              suffixIcon: suffix,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
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

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: onTap != null ? AppTheme.brandGradient : null,
          color: onTap == null ? AppTheme.borderDefault : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withAlpha(80),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: isLoading
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
                      label,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, color: Colors.white, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}
