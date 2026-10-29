import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class BrandLogoWidget extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool isCompact;

  const BrandLogoWidget({
    super.key,
    this.size = 180,
    this.showTagline = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact logo mark
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withAlpha(70),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          ShaderMask(
            shaderCallback: (bounds) => AppTheme.brandGradient.createShader(bounds),
            child: Text(
              'Mingle to Mingle',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Brand logo container ───────────────────────────────────────────
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withAlpha(35),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              const BoxShadow(
                color: Color(0x0A1F1933),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppTheme.borderDefault, width: 1.2),
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (b) => AppTheme.brandGradient.createShader(b),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 72,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        if (showTagline) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, size: 14, color: AppTheme.primaryPurple),
              const SizedBox(width: 6),
              Text(
                'Find your connection.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.favorite, size: 14, color: AppTheme.primaryPurple),
            ],
          ),
        ],
      ],
    );
  }
}
