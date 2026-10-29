import '../models/profile_model.dart';

class SampleData {
  static final List<UserProfile> profiles = [
    const UserProfile(
      id: 'p1',
      name: 'Sophia Chen',
      age: 24,
      occupation: 'UI/UX Designer & Ceramist',
      city: 'Downtown Arts District',
      distanceKm: 3,
      bio: 'Designing apps by day, getting messy with clay by night ✨ Big fan of oat cortados, flea markets, and live indie concerts. Let’s talk about your favorite album or share a playlist!',
      images: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1000&q=80',
      ],
      passions: ['Design', 'Pottery', 'Indie Rock', 'Coffee', 'Baking', 'Museums'],
      isVerified: true,
      relationshipIntent: 'Long-term relationship',
      zodiac: 'Libra ♎',
      height: '165 cm',
      prompts: [
        ProfilePrompt(
          question: 'My simple pleasures...',
          answer: 'Sunday morning coffee while vinyl plays in the background, fresh sourdough bread, and golden hour light.',
        ),
        ProfilePrompt(
          question: 'The key to my heart is...',
          answer: 'Bringing me weird vintage findings or teaching me a new cooking technique.',
        ),
      ],
    ),
    const UserProfile(
      id: 'p2',
      name: 'Liam Vance',
      age: 26,
      occupation: 'Architectural Photographer',
      city: 'Marina Bay',
      distanceKm: 5,
      bio: 'Always carrying at least two 35mm cameras. Traveling through cities discovering hidden brutalist architecture. Looking for someone to explore hidden food gems and rooftop viewpoints with.',
      images: [
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1000&q=80',
      ],
      passions: ['Photography', 'Architecture', 'Travel', 'Cycling', 'Espresso', 'Cinema'],
      isVerified: true,
      relationshipIntent: 'Open to long-term',
      zodiac: 'Scorpio ♏',
      height: '182 cm',
      prompts: [
        ProfilePrompt(
          question: 'I’m convinced that...',
          answer: 'Early morning city walks are 100x better than staying up late at clubs.',
        ),
        ProfilePrompt(
          question: 'A boundary of mine is...',
          answer: 'No phone during dinner! Let’s actually talk and vibe.',
        ),
      ],
    ),
    const UserProfile(
      id: 'p3',
      name: 'Aria Montgomery',
      age: 23,
      occupation: 'Botanist & Plant Shop Owner',
      city: 'Garden Hills',
      distanceKm: 2,
      bio: 'My apartment has 84 plants and counting 🌿 Golden retriever mom. If we match, you must be ready to judge potted plants and debate whether iced matcha is superior to iced chai.',
      images: [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=1000&q=80',
      ],
      passions: ['Houseplants', 'Dogs', 'Hiking', 'Matcha', 'Vintage Style', 'Farmer Markets'],
      isVerified: true,
      relationshipIntent: 'Looking for the One',
      zodiac: 'Taurus ♉',
      height: '162 cm',
      prompts: [
        ProfilePrompt(
          question: 'Best travel story...',
          answer: 'Got lost in Kyoto looking for a bonsai garden, ended up dining with a local family who showed me secret bamboo trails.',
        ),
      ],
    ),
    const UserProfile(
      id: 'p4',
      name: 'Marcus Brody',
      age: 27,
      occupation: 'Creative Director & Foodie',
      city: 'Old Town Square',
      distanceKm: 7,
      bio: 'Food is my love language. I cook a mean handmade tagliatelle al ragù. When I’m not sketching campaigns, you’ll find me bouldering or digging through jazz records.',
      images: [
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=1000&q=80',
      ],
      passions: ['Cooking', 'Bouldering', 'Jazz', 'Cocktails', 'Art', 'Typography'],
      isVerified: true,
      relationshipIntent: 'Long-term relationship',
      zodiac: 'Leo ♌',
      height: '185 cm',
      prompts: [
        ProfilePrompt(
          question: 'Together we could...',
          answer: 'Cook an ambitious 5-course dinner from scratch while drinking Italian red wine.',
        ),
      ],
    ),
    const UserProfile(
      id: 'p5',
      name: 'Elena Rostova',
      age: 25,
      occupation: 'Neuroscience Researcher & Violinist',
      city: 'University Quarter',
      distanceKm: 4,
      bio: 'Fascinated by how brains fall in love! Playing classical violin in a local chamber quartet. Seeking curious conversations, book swaps, and stargazing evenings.',
      images: [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=1000&q=80',
      ],
      passions: ['Neuroscience', 'Violin', 'Philosophy', 'Board Games', 'Astronomy', 'Tea'],
      isVerified: true,
      relationshipIntent: 'Soulmate hunt',
      zodiac: 'Aquarius ♒',
      height: '170 cm',
      prompts: [
        ProfilePrompt(
          question: 'We’ll get along if...',
          answer: 'You enjoy late-night debates about whether consciousness can be simulated or just love cozy tea times.',
        ),
      ],
    ),
    const UserProfile(
      id: 'p6',
      name: 'Julian Hayes',
      age: 28,
      occupation: 'Startup Founder & Surfer',
      city: 'Coastal Ridge',
      distanceKm: 8,
      bio: 'Catching morning sunrise waves before heading into product meetings. I believe life is too short for bad coffee and boring weekends.',
      images: [
        'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=1000&q=80',
      ],
      passions: ['Surfing', 'Tech', 'Yoga', 'Podcasts', 'Camping', 'Sustainability'],
      isVerified: true,
      relationshipIntent: 'Looking for a connection',
      zodiac: 'Sagittarius ♐',
      height: '180 cm',
      prompts: [
        ProfilePrompt(
          question: 'A spontaneous thing we should do...',
          answer: 'Pack a tent in the car Friday night and wake up next to the ocean on Saturday.',
        ),
      ],
    ),
  ];

  static List<MatchItem> getInitialMatches() {
    return [
      MatchItem(
        profile: profiles[0], // Sophia Chen
        matchedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        lastMessage: 'Hey! I love your music taste, that album is phenomenal 🎶',
        hasUnread: true,
      ),
      MatchItem(
        profile: profiles[2], // Aria Montgomery
        matchedAt: DateTime.now().subtract(const Duration(hours: 2)),
        lastMessage: 'Haha yes! My Monstera is growing a new leaf today 🌿',
        hasUnread: false,
      ),
      MatchItem(
        profile: profiles[1], // Liam Vance
        matchedAt: DateTime.now().subtract(const Duration(days: 1)),
        lastMessage: 'Know any good rooftop spots around the marina?',
        hasUnread: false,
        isSuperLike: true,
      ),
      MatchItem(
        profile: profiles[4], // Elena Rostova
        matchedAt: DateTime.now().subtract(const Duration(days: 2)),
        lastMessage: 'Matched with you! Looking forward to chatting ✨',
        hasUnread: false,
      ),
    ];
  }

  static List<ChatMessage> getInitialConversation(String profileId) {
    if (profileId == 'p1') {
      return [
        ChatMessage(
          id: 'm1',
          text: 'Hey Sophia! Loved your ceramics photos, they look gorgeous!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
          isMine: true,
        ),
        ChatMessage(
          id: 'm2',
          text: 'Thank you so much! It’s my favorite way to unwind after designing all day 😊',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isMine: false,
        ),
        ChatMessage(
          id: 'm3',
          text: 'Also I saw you love indie concerts, have you been to the Sunset Stage recently?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          isMine: true,
        ),
        ChatMessage(
          id: 'm4',
          text: 'Hey! I love your music taste, that album is phenomenal 🎶',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          isMine: false,
        ),
      ];
    } else if (profileId == 'p3') {
      return [
        ChatMessage(
          id: 'm1',
          text: '84 plants?! That is seriously impressive 🌿',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          isMine: true,
        ),
        ChatMessage(
          id: 'm2',
          text: 'Haha yes! My Monstera is growing a new leaf today 🌿',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isMine: false,
        ),
      ];
    }
    return [
      ChatMessage(
        id: 'm1',
        text: 'Hey there! Nice to match with you on Mingle to Mingle! ✨',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isMine: false,
      ),
    ];
  }

  // Curated explore categories
  static const List<Map<String, dynamic>> exploreCategories = [
    {
      'title': 'Nearby Singles',
      'subtitle': 'Within 5 km radius',
      'icon': 'location_on',
      'tag': 'Nearby',
    },
    {
      'title': 'Coffee Date ☕',
      'subtitle': 'Looking for casual cozy vibes',
      'icon': 'coffee',
      'tag': 'Coffee',
    },
    {
      'title': 'Creative Souls 🎨',
      'subtitle': 'Designers, artists & musicians',
      'icon': 'palette',
      'tag': 'Design',
    },
    {
      'title': 'Outdoor Adventurers 🏔️',
      'subtitle': 'Hiking, camping, beach days',
      'icon': 'terrain',
      'tag': 'Hiking',
    },
    {
      'title': 'Foodies & Chefs 🍝',
      'subtitle': 'Ready to try new recipes',
      'icon': 'restaurant',
      'tag': 'Cooking',
    },
    {
      'title': 'Verified Only ⭐',
      'subtitle': '100% photo verified accounts',
      'icon': 'verified',
      'tag': 'Verified',
    },
  ];

  static String getAutoReply(String name) {
    final replies = [
      'Hey there! Love your vibe ✨',
      'That sounds amazing! When are you free?',
      'Haha absolutely! ☕ Coffee date soon?',
      'So glad we matched! Tell me more about your favorite weekend plan.',
    ];
    return replies[DateTime.now().millisecond % replies.length];
  }
}
