import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import '../data/sample_data.dart';
import '../widgets/swipe_card.dart';
import '../widgets/match_dialog.dart';
import 'chat_detail_screen.dart';
import 'catalog_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTabIndex = 0;

  late List<UserProfile> _cardDeck;
  final List<UserProfile> _swipedProfiles = [];

  late List<MatchItem> _matches;

  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _userLocation = 'San Francisco, CA';

  double _maxDistance = 25;
  RangeValues _ageRange = const RangeValues(21, 30);

  @override
  void initState() {
    super.initState();
    _cardDeck = List.from(SampleData.profiles);
    _matches = SampleData.getInitialMatches();
  }

  void _onSwipe(SwipeDirection direction) {
    if (_cardDeck.isEmpty) return;
    final swipedUser = _cardDeck.removeLast();
    _swipedProfiles.add(swipedUser);
    setState(() {});
    if (direction == SwipeDirection.right || direction == SwipeDirection.up) {
      _showMatchDialog(swipedUser);
    }
  }

  void _rewind() {
    if (_swipedProfiles.isEmpty) {
      _showToast('No previous profiles to rewind!');
      return;
    }
    setState(() => _cardDeck.add(_swipedProfiles.removeLast()));
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 13),
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderDefault),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMatchDialog(UserProfile user) {
    setState(() {
      _matches.insert(
        0,
        MatchItem(
          profile: user,
          matchedAt: DateTime.now(),
          lastMessage: 'You matched with ${user.name}! Say hi ✨',
          hasUnread: true,
        ),
      );
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x7A1F1933),
      builder: (ctx) => MatchDialog(
        matchedUser: user,
        onSendMessage: () {
          Navigator.pop(ctx);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatDetailScreen(user: user)),
          );
        },
        onKeepMingling: () => Navigator.pop(ctx),
      ),
    );
  }

  // ── 4. Profile Details Screen / Sheet ──────────────────────────────────────
  void _showProfileDetail(UserProfile user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F1F1933),
                    blurRadius: 30,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  // Drag handle
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

                  // Large portrait image with rounded corners
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          user.images.first,
                          height: 360,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 360,
                            color: AppTheme.bgSecondary,
                            child: const Icon(
                              Icons.person,
                              size: 80,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ),

                      // Purple match-percentage badge over image
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.brandGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryPurple.withAlpha(90),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt_rounded, color: Colors.white, size: 15),
                              const SizedBox(width: 4),
                              Text(
                                '${user.matchPercentage}% Match',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Header: Profile Name, Location, Verification Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${user.name}, ${user.age}',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Location and Occupation
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppTheme.primaryPurple,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.city} • ${user.distanceKm} km away',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('•', style: TextStyle(color: AppTheme.borderDefault)),
                      const SizedBox(width: 10),
                      Text(
                        user.occupation,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Soft lavender section: Detail Badges
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.borderDefault),
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildDetailBadge(Icons.favorite_border_rounded, user.relationshipIntent),
                        _buildDetailBadge(Icons.auto_awesome_rounded, user.zodiac),
                        _buildDetailBadge(Icons.height_rounded, user.height),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // About Section with Bold Heading & Readable Description
                  Text(
                    'About',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.bio,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Interests: Rounded chips with pale lavender backgrounds & purple text
                  Text(
                    'Interests',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.passions.map((passion) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.bgElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderDefault),
                        ),
                        child: Text(
                          passion,
                          style: GoogleFonts.poppins(
                            color: AppTheme.deepPurple,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Prompts (if any)
                  if (user.prompts.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    ...user.prompts.map((prompt) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSecondary,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.borderDefault),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prompt.question,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              prompt.answer,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 24),

                  // Action Button Inside Sheet
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _onSwipe(SwipeDirection.left);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            side: const BorderSide(color: AppTheme.borderDefault),
                          ),
                          child: const Icon(Icons.close_rounded, color: Color(0xFFEF4444)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.brandGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryPurple.withAlpha(80),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _onSwipe(SwipeDirection.right);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            icon: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                            label: Text(
                              'Like Profile',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTheme.primaryPurple),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: SafeArea(
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildDiscoverTab(),
            _buildExploreTab(),
            _buildLikesTab(),
            _buildMatchesTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── 3. Bottom Navigation Bar ───────────────────────────────────────────────
  Widget _buildBottomNav() {
    const items = [
      (icon: Icons.favorite_border_rounded, activeIcon: Icons.favorite_rounded, label: 'Home'),
      (icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Explore'),
      (icon: Icons.star_outline_rounded, activeIcon: Icons.star_rounded, label: 'Likes'),
      (icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Messages'),
      (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bottomNavBg,
        border: Border(top: BorderSide(color: AppTheme.borderDefault, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A5B21B6),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = _currentTabIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _currentTabIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            selected ? item.activeIcon : item.icon,
                            key: ValueKey(selected),
                            color: selected ? AppTheme.primaryPurple : AppTheme.textSecondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (selected)
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryPurple,
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          Text(
                            item.label,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── 3. Discover / Swipe Screen ─────────────────────────────────────────────
  Widget _buildDiscoverTab() {
    return Column(
      children: [
        // Top Header: User Location and Purple Filter Icon
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User Location Pill
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openLocationPicker(),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderDefault),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppTheme.primaryPurple,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LOCATION',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _userLocation,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.textSecondary,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Header Actions
              Row(
                children: [
                  // Service Catalog Store Button
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderDefault),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: IconButton(
                      tooltip: 'Service Catalog',
                      icon: const Icon(
                        Icons.storefront_rounded,
                        color: AppTheme.primaryPurple,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CatalogScreen()),
                        );
                      },
                    ),
                  ),
                  // Purple Filter Icon Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderDefault),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: AppTheme.primaryPurple,
                        size: 20,
                      ),
                      onPressed: () => _openFilterDialog(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Horizontal Row of Suggested Profile Avatars
        _buildSuggestedAvatarsRow(),

        const SizedBox(height: 4),

        // Card Deck
        Expanded(
          child: _cardDeck.isEmpty
              ? _buildEmptyDeckState()
              : Stack(
                  children: [
                    if (_cardDeck.length > 1)
                      Transform.scale(
                        scale: 0.95,
                        child: SwipeCard(
                          key: ValueKey(_cardDeck[_cardDeck.length - 2].id),
                          profile: _cardDeck[_cardDeck.length - 2],
                          isTopCard: false,
                        ),
                      ),
                    SwipeCard(
                      key: ValueKey(_cardDeck.last.id),
                      profile: _cardDeck.last,
                      isTopCard: true,
                      onSwiped: _onSwipe,
                      onInfoTap: () => _showProfileDetail(_cardDeck.last),
                    ),
                  ],
                ),
        ),

        // 3 Circular Action Buttons: Dislike, Super-like, Like (+ subtle rewind)
        _buildActionRow(),
      ],
    );
  }

  // Horizontal Row of Suggested Profile Avatars
  Widget _buildSuggestedAvatarsRow() {
    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: SampleData.profiles.length,
        itemBuilder: (context, index) {
          final profile = SampleData.profiles[index];
          return GestureDetector(
            onTap: () => _showProfileDetail(profile),
            child: Container(
              width: 66,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryPurple.withAlpha(index % 2 == 0 ? 180 : 90),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: ClipOval(
                          child: Image.network(
                            profile.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppTheme.bgSecondary,
                              child: const Icon(Icons.person, color: AppTheme.primaryPurple, size: 24),
                            ),
                          ),
                        ),
                      ),
                      // Online dot
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.name.split(' ').first,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 3 Action Buttons: Dislike, Super-like, Like
  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Optional Rewind Button
          if (_swipedProfiles.isNotEmpty)
            _buildRoundActionButton(
              icon: Icons.replay_rounded,
              color: AppTheme.accentAmber,
              size: 46,
              iconSize: 22,
              onTap: _rewind,
            ),

          // 1. Dislike (Circular button)
          _buildRoundActionButton(
            icon: Icons.close_rounded,
            color: const Color(0xFFEF4444),
            size: 58,
            iconSize: 28,
            onTap: () => _onSwipe(SwipeDirection.left),
          ),

          // 2. Super-like (Circular button)
          _buildRoundActionButton(
            icon: Icons.star_rounded,
            color: AppTheme.primaryPurple,
            size: 52,
            iconSize: 26,
            hasBorderGlow: true,
            onTap: () => _onSwipe(SwipeDirection.up),
          ),

          // 3. Like (Large purple gradient button)
          GestureDetector(
            onTap: () => _onSwipe(SwipeDirection.right),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withAlpha(90),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required double iconSize,
    required VoidCallback onTap,
    bool hasBorderGlow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: hasBorderGlow ? AppTheme.primaryPurple.withAlpha(120) : AppTheme.borderDefault,
            width: hasBorderGlow ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(hasBorderGlow ? 40 : 20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: color, size: iconSize),
        ),
      ),
    );
  }

  Widget _buildEmptyDeckState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderDefault),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 64,
                color: AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "You're all caught up!",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'No new profiles nearby right now. Try expanding your discovery distance.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () {
                setState(() {
                  _cardDeck = List.from(SampleData.profiles);
                  _swipedProfiles.clear();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withAlpha(70),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Reload Profiles',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB 2: EXPLORE (Grid Screen) ───────────────────────────────────────────
  Widget _buildExploreTab() {
    final filtered = SampleData.profiles.where((p) {
      final matchesQuery =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.passions.any((pass) => pass.toLowerCase().contains(_searchQuery.toLowerCase()));

      if (!matchesQuery) return false;
      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Nearby') return p.distanceKm <= 5;
      if (_selectedCategory == 'Verified') return p.isVerified;
      return p.passions.contains(_selectedCategory);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Text(
            'Explore',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderDefault),
            ),
            child: TextField(
              style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by name, city, passions...',
                hintStyle: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryPurple, size: 22),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Category Pills
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildCategoryChip('All'),
              _buildCategoryChip('Nearby'),
              _buildCategoryChip('Verified'),
              _buildCategoryChip('Design'),
              _buildCategoryChip('Coffee'),
              _buildCategoryChip('Music'),
              _buildCategoryChip('Travel'),
              _buildCategoryChip('Fitness'),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Grid of Profiles
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No profiles found',
                    style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.76,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final profile = filtered[index];
                    return GestureDetector(
                      onTap: () => _showProfileDetail(profile),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.softShadow,
                          border: Border.all(color: AppTheme.borderDefault),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                profile.images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: AppTheme.bgSecondary,
                                  child: const Icon(Icons.person, size: 48, color: AppTheme.textMuted),
                                ),
                              ),
                              // Scrim overlay
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.transparent, Color(0xB81F1933)],
                                    stops: [0.45, 1.0],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              // Distance badge
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(220),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${profile.distanceKm} km',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.deepPurple,
                                    ),
                                  ),
                                ),
                              ),
                              // Profile Info at Bottom
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${profile.name}, ${profile.age}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (profile.isVerified)
                                          const Icon(
                                            Icons.verified_rounded,
                                            color: AppTheme.softPurple,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    Text(
                                      profile.occupation,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.white70,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.brandGradient : null,
            color: isSelected ? null : AppTheme.bgSecondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppTheme.borderDefault,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withAlpha(60),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Text(
            category,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ── TAB 3: LIKES SCREEN ────────────────────────────────────────────────────
  Widget _buildLikesTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Likes & Crushes',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'People who matched your vibe',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${SampleData.profiles.length} Likes',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Grid of Likes
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.74,
          ),
          itemCount: SampleData.profiles.length,
          itemBuilder: (context, index) {
            final profile = SampleData.profiles[index];
            return GestureDetector(
              onTap: () => _showProfileDetail(profile),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.softShadow,
                  border: Border.all(color: AppTheme.borderDefault),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(profile.images.first, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Color(0xB81F1933)],
                            stops: [0.45, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt_rounded, color: Colors.white, size: 12),
                              Text(
                                '${profile.matchPercentage}%',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${profile.name}, ${profile.age}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    profile.city,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showMatchDialog(profile),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  gradient: AppTheme.brandGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── TAB 4: MATCHES & MESSAGES ──────────────────────────────────────────────
  Widget _buildMatchesTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 14),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Messages',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_matches.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'New Matches',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // New Matches Story Avatars Row
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _matches.length,
            itemBuilder: (context, index) {
              final match = _matches[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatDetailScreen(user: match.profile)),
                ),
                child: Container(
                  width: 76,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.brandGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withAlpha(50),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(match.profile.images.first),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        match.profile.name.split(' ').first,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recent Conversations',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Conversation List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _matches.length,
          separatorBuilder: (context, index) => const Padding(
            padding: EdgeInsets.only(left: 84),
            child: Divider(color: AppTheme.borderDefault, height: 1, thickness: 0.8),
          ),
          itemBuilder: (context, index) {
            final match = _matches[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatDetailScreen(user: match.profile)),
              ),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(match.profile.images.first),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      match.profile.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${match.matchedAt.hour}:${match.matchedAt.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                match.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: match.hasUnread ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontWeight: match.hasUnread ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: match.hasUnread
                  ? Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            );
          },
        ),
      ],
    );
  }

  // ── TAB 5: PROFILE & SETTINGS ──────────────────────────────────────────────
  Widget _buildProfileTab() {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'mingler@app.com';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.brandGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withAlpha(70),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 54,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Alex Vance, 25',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                userEmail,
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary),
              ),

              const SizedBox(height: 18),

              // Profile completion card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderDefault),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: 0.85,
                            strokeWidth: 4,
                            color: AppTheme.primaryPurple,
                            backgroundColor: Color(0xFFE9E3F5),
                          ),
                        ),
                        Text(
                          '85%',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Complete',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Add 1 more photo to get 3x more connections!',
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
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        Text(
          'Discovery Preferences',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Distance slider card
        _buildSliderCard(
          title: 'Maximum Distance',
          value: '${_maxDistance.toInt()} km',
          child: Slider(
            value: _maxDistance,
            min: 5,
            max: 100,
            activeColor: AppTheme.primaryPurple,
            inactiveColor: AppTheme.borderDefault,
            thumbColor: AppTheme.primaryPurple,
            onChanged: (val) => setState(() => _maxDistance = val),
          ),
        ),

        const SizedBox(height: 10),

        // Age range slider card
        _buildSliderCard(
          title: 'Age Preference',
          value: '${_ageRange.start.toInt()} - ${_ageRange.end.toInt()}',
          child: RangeSlider(
            values: _ageRange,
            min: 18,
            max: 60,
            activeColor: AppTheme.primaryPurple,
            inactiveColor: AppTheme.borderDefault,
            onChanged: (val) => setState(() => _ageRange = val),
          ),
        ),

        const SizedBox(height: 28),

        Text(
          'Account & Settings',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        _buildSettingTile(
          icon: Icons.storefront_rounded,
          title: 'Data & Service Catalog',
          subtitle: 'Products, VIP passes, gifts, and API controller',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CatalogScreen()),
            );
          },
        ),
        _buildSettingTile(
          icon: Icons.verified_user_outlined,
          title: 'Photo Verification',
          subtitle: 'Get the verified profile badge',
          onTap: () => _showToast('Verification request submitted!'),
        ),
        _buildSettingTile(
          icon: Icons.notifications_outlined,
          title: 'Push Notifications',
          subtitle: 'Matches, messages, and vibes',
          onTap: () {},
        ),
        _buildSettingTile(
          icon: Icons.security_outlined,
          title: 'Privacy & Safety',
          subtitle: 'Incognito mode, blocked profiles',
          onTap: () {},
        ),

        const SizedBox(height: 24),

        // Sign Out Button
        GestureDetector(
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderDefault),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                const SizedBox(width: 10),
                Text(
                  'Sign Out',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String value,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderDefault),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDefault),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.bgSecondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryPurple, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
      ),
    );
  }

  void _openLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final cities = [
          'San Francisco, CA',
          'New York, NY',
          'Los Angeles, CA',
          'Austin, TX',
          'Seattle, WA',
          'Chicago, IL',
        ];
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppTheme.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Select Your Location',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...cities.map((city) {
                final isSelected = _userLocation == city;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.location_on_rounded,
                    color: isSelected ? AppTheme.primaryPurple : AppTheme.textMuted,
                  ),
                  title: Text(
                    city,
                    style: GoogleFonts.poppins(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppTheme.primaryPurple : AppTheme.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: AppTheme.primaryPurple)
                      : null,
                  onTap: () {
                    setState(() => _userLocation = city);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _openFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppTheme.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Filter Matches',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.verified_user_outlined, color: AppTheme.primaryPurple, size: 20),
                ),
                title: Text(
                  'Verified Profiles Only',
                  style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
                ),
                trailing: Switch(
                  value: true,
                  activeThumbColor: AppTheme.primaryPurple,
                  onChanged: (val) {},
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: AppTheme.primaryPurple, size: 20),
                ),
                title: Text(
                  'Profiles with 3+ Photos',
                  style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
                ),
                trailing: Switch(
                  value: true,
                  activeThumbColor: AppTheme.primaryPurple,
                  onChanged: (val) {},
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withAlpha(70),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
