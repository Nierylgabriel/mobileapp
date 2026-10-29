class ProfilePrompt {
  final String question;
  final String answer;

  const ProfilePrompt({
    required this.question,
    required this.answer,
  });
}

class UserProfile {
  final String id;
  final String name;
  final int age;
  final String occupation;
  final String city;
  final int distanceKm;
  final String bio;
  final List<String> images;
  final List<String> passions;
  final List<ProfilePrompt> prompts;
  final bool isVerified;
  final String relationshipIntent;
  final String zodiac;
  final String height;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.occupation,
    required this.city,
    required this.distanceKm,
    required this.bio,
    required this.images,
    required this.passions,
    this.prompts = const [],
    this.isVerified = true,
    this.relationshipIntent = 'Long-term partner',
    this.zodiac = 'Gemini',
    this.height = '168 cm',
  });

  int get matchPercentage => 86 + (id.hashCode.abs() % 13);
}

class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isMine;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isMine,
  });
}

class MatchItem {
  final UserProfile profile;
  final DateTime matchedAt;
  final String lastMessage;
  final bool hasUnread;
  final bool isSuperLike;

  const MatchItem({
    required this.profile,
    required this.matchedAt,
    required this.lastMessage,
    this.hasUnread = false,
    this.isSuperLike = false,
  });
}
