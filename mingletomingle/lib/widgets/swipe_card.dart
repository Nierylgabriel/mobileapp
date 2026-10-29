import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';

enum SwipeDirection { left, right, up }

class SwipeCard extends StatefulWidget {
  final UserProfile profile;
  final bool isTopCard;
  final Function(SwipeDirection direction)? onSwiped;
  final VoidCallback? onInfoTap;

  const SwipeCard({
    super.key,
    required this.profile,
    this.isTopCard = false,
    this.onSwiped,
    this.onInfoTap,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  int _currentPhotoIndex = 0;
  late AnimationController _animController;
  late Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextPhoto() {
    if (_currentPhotoIndex < widget.profile.images.length - 1) {
      setState(() {
        _currentPhotoIndex++;
      });
    }
  }

  void _prevPhoto() {
    if (_currentPhotoIndex > 0) {
      setState(() {
        _currentPhotoIndex--;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isTopCard) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isTopCard) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.35;

    if (_dragOffset.dx > threshold) {
      _completeSwipe(SwipeDirection.right);
    } else if (_dragOffset.dx < -threshold) {
      _completeSwipe(SwipeDirection.left);
    } else if (_dragOffset.dy < -120) {
      _completeSwipe(SwipeDirection.up);
    } else {
      _animateBack();
    }
  }

  void _animateBack() {
    _offsetAnim = Tween<Offset>(begin: _dragOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _dragOffset = _offsetAnim.value;
        });
      });
    _animController.forward(from: 0.0);
  }

  void _completeSwipe(SwipeDirection direction) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    Offset target;
    switch (direction) {
      case SwipeDirection.right:
        target = Offset(screenWidth * 1.5, _dragOffset.dy);
        break;
      case SwipeDirection.left:
        target = Offset(-screenWidth * 1.5, _dragOffset.dy);
        break;
      case SwipeDirection.up:
        target = Offset(_dragOffset.dx, -screenHeight * 1.2);
        break;
    }

    _offsetAnim = Tween<Offset>(begin: _dragOffset, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    )..addListener(() {
        setState(() {
          _dragOffset = _offsetAnim.value;
        });
      });

    _animController.forward(from: 0.0).then((_) {
      widget.onSwiped?.call(direction);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final angle = (_dragOffset.dx / size.width) * (math.pi / 12);

    final likeOpacity = (_dragOffset.dx / 120).clamp(0.0, 1.0);
    final nopeOpacity = (-_dragOffset.dx / 120).clamp(0.0, 1.0);
    final superLikeOpacity = (-_dragOffset.dy / 100).clamp(0.0, 1.0);

    return GestureDetector(
      onPanUpdate: widget.isTopCard ? _onPanUpdate : null,
      onPanEnd: widget.isTopCard ? _onPanEnd : null,
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: angle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                const BoxShadow(
                  color: Color(0x185B21B6),
                  blurRadius: 28,
                  spreadRadius: 0,
                  offset: Offset(0, 10),
                ),
                const BoxShadow(
                  color: Color(0x0C1F1933),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Photo background
                  Image.network(
                    widget.profile.images[_currentPhotoIndex],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppTheme.bgSecondary,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryPurple,
                            strokeWidth: 2.5,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.bgSecondary,
                        child: const Icon(
                          Icons.person,
                          size: 80,
                          color: AppTheme.textMuted,
                        ),
                      );
                    },
                  ),

                  // Tap areas for photo carousel
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _prevPhoto,
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _nextPhoto,
                        ),
                      ),
                    ],
                  ),

                  // Subtle purple-tinted gradient overlay for legibility at bottom
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0x0D1F1933),
                            Color(0x754C1D95),
                            Color(0xDD1F1933),
                          ],
                          stops: [0.0, 0.45, 0.72, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Photo Pagination Indicators at Top
                  Positioned(
                    top: 14,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: List.generate(
                        widget.profile.images.length,
                        (index) => Expanded(
                          child: Container(
                            height: 3.5,
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            decoration: BoxDecoration(
                              color: index == _currentPhotoIndex
                                  ? Colors.white
                                  : Colors.white.withAlpha(90),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Match % Badge at Top-Right
                  Positioned(
                    top: 26,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: AppTheme.brandGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withAlpha(80),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            '${widget.profile.matchPercentage}% Match',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Profile Details at Bottom
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name, Age, Verified badge
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${widget.profile.name}, ${widget.profile.age}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.profile.isVerified) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified_rounded,
                                  color: AppTheme.primaryPurple,
                                  size: 20,
                                ),
                              ),
                            ],
                            const Spacer(),
                            // Info / Expand button
                            IconButton(
                              onPressed: widget.onInfoTap,
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(50),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Occupation & Location
                        Row(
                          children: [
                            const Icon(
                              Icons.work_outline_rounded,
                              color: Colors.white70,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                widget.profile.occupation,
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withAlpha(220),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // Location & Distance Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: AppTheme.softPurple,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${widget.profile.city} • ${widget.profile.distanceKm} km away',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Bio Preview
                        Text(
                          widget.profile.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withAlpha(235),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Passion tags with Pale Lavender and Purple styling
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.profile.passions.take(4).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(210),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                tag,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.deepPurple,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Swipe Stamp: LIKE (Vibrant Purple/Green)
                  if (likeOpacity > 0.05)
                    Positioned(
                      top: 40,
                      left: 30,
                      child: Opacity(
                        opacity: likeOpacity,
                        child: Transform.rotate(
                          angle: -0.2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple.withAlpha(220),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryPurple.withAlpha(100),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'LIKE',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Swipe Stamp: NOPE (Soft Red)
                  if (nopeOpacity > 0.05)
                    Positioned(
                      top: 40,
                      right: 30,
                      child: Opacity(
                        opacity: nopeOpacity,
                        child: Transform.rotate(
                          angle: 0.2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withAlpha(220),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x66EF4444),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                                const SizedBox(width: 6),
                                Text(
                                  'NOPE',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Swipe Stamp: SUPER LIKE (Soft Violet)
                  if (superLikeOpacity > 0.1 && _dragOffset.dy < 0)
                    Positioned(
                      bottom: 120,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Opacity(
                          opacity: superLikeOpacity,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppTheme.brandGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryPurple.withAlpha(120),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'SUPER LIKE',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
}
