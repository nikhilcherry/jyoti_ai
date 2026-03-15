// All data models for Jyoti AI

// ── Rashi (Zodiac Sign) ──
enum Rashi {
  mesha(
    label: 'Mesha',
    english: 'Aries',
    symbol: '♈',
    emoji: '🐏',
    color: 0xFFEF4444,
  ),
  vrishabha(
    label: 'Vrishabha',
    english: 'Taurus',
    symbol: '♉',
    emoji: '🐂',
    color: 0xFF22C55E,
  ),
  mithuna(
    label: 'Mithuna',
    english: 'Gemini',
    symbol: '♊',
    emoji: '👯',
    color: 0xFFFBBF24,
  ),
  karka(
    label: 'Karka',
    english: 'Cancer',
    symbol: '♋',
    emoji: '🦀',
    color: 0xFFC0C0C0,
  ),
  simha(
    label: 'Simha',
    english: 'Leo',
    symbol: '♌',
    emoji: '🦁',
    color: 0xFFFF8C00,
  ),
  kanya(
    label: 'Kanya',
    english: 'Virgo',
    symbol: '♍',
    emoji: '👧',
    color: 0xFF10B981,
  ),
  tula(
    label: 'Tula',
    english: 'Libra',
    symbol: '♎',
    emoji: '⚖️',
    color: 0xFF60A5FA,
  ),
  vrishchika(
    label: 'Vrishchika',
    english: 'Scorpio',
    symbol: '♏',
    emoji: '🦂',
    color: 0xFFDC2626,
  ),
  dhanu(
    label: 'Dhanu',
    english: 'Sagittarius',
    symbol: '♐',
    emoji: '🏹',
    color: 0xFF8B5CF6,
  ),
  makara(
    label: 'Makara',
    english: 'Capricorn',
    symbol: '♑',
    emoji: '🐐',
    color: 0xFF6B7280,
  ),
  kumbha(
    label: 'Kumbha',
    english: 'Aquarius',
    symbol: '♒',
    emoji: '🫗',
    color: 0xFF06B6D4,
  ),
  meena(
    label: 'Meena',
    english: 'Pisces',
    symbol: '♓',
    emoji: '🐟',
    color: 0xFF818CF8,
  );

  final String label;
  final String english;
  final String symbol;
  final String emoji;
  final int color;

  const Rashi({
    required this.label,
    required this.english,
    required this.symbol,
    required this.emoji,
    required this.color,
  });
}

// ── User Tier ──
enum UserTier {
  moon(label: 'Moon', emoji: '🌙', minPoints: 0, color: 0xFFC0C0C0),
  star(label: 'Star', emoji: '⭐', minPoints: 1000, color: 0xFFFBBF24),
  sun(label: 'Sun', emoji: '☀️', minPoints: 5000, color: 0xFFFF8C00),
  nakshatra(
    label: 'Nakshatra',
    emoji: '✨',
    minPoints: 15000,
    color: 0xFFA78BFA,
  );

  final String label;
  final String emoji;
  final int minPoints;
  final int color;

  const UserTier({
    required this.label,
    required this.emoji,
    required this.minPoints,
    required this.color,
  });

  static UserTier fromPoints(int lifetimePoints) {
    if (lifetimePoints >= 15000) return UserTier.nakshatra;
    if (lifetimePoints >= 5000) return UserTier.sun;
    if (lifetimePoints >= 1000) return UserTier.star;
    return UserTier.moon;
  }
}

// ── Points Pack ──
class PointsPack {
  final String id;
  final String name;
  final int priceRs;
  final int points;
  final String talkTime;
  final bool isBestValue;

  const PointsPack({
    required this.id,
    required this.name,
    required this.priceRs,
    required this.points,
    required this.talkTime,
    this.isBestValue = false,
  });

  static const List<PointsPack> packs = [
    PointsPack(
      id: 'starter',
      name: 'Starter',
      priceRs: 19,
      points: 500,
      talkTime: '~25 min',
    ),
    PointsPack(
      id: 'value',
      name: 'Value',
      priceRs: 49,
      points: 1500,
      talkTime: '~75 min',
    ),
    PointsPack(
      id: 'popular',
      name: 'Popular',
      priceRs: 99,
      points: 3500,
      talkTime: '~175 min',
      isBestValue: true,
    ),
    PointsPack(
      id: 'super',
      name: 'Super',
      priceRs: 199,
      points: 8000,
      talkTime: '~400 min',
    ),
  ];
}

// ── Chat Message ──
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? remedy;
  final int? totalTokens;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.remedy,
    this.totalTokens,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'remedy': remedy,
        'totalTokens': totalTokens,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      remedy: json['remedy'] as String?,
      totalTokens: json['totalTokens'] as int?,
    );
  }
}

// ── Daily Reading ──
class DailyReading {
  final Rashi rashi;
  final String summary;
  final String luckyColor;
  final int luckyNumber;
  final String remedy;
  final String favorableTime;
  final DateTime date;
  final double overallScore; // 0.0 to 5.0

  const DailyReading({
    required this.rashi,
    required this.summary,
    required this.luckyColor,
    required this.luckyNumber,
    required this.remedy,
    required this.favorableTime,
    required this.date,
    required this.overallScore,
  });
}

// ── Panchang Data ──
class PanchangData {
  final String tithi;
  final String nakshatra;
  final String yoga;
  final String karana;
  final String rahuKaal;
  final String gulikaKaal;
  final String sunrise;
  final String sunset;
  final DateTime date;

  const PanchangData({
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.rahuKaal,
    required this.gulikaKaal,
    required this.sunrise,
    required this.sunset,
    required this.date,
  });
}

// ── User Profile ──
class UserProfile {
  final String name;
  final DateTime dateOfBirth;
  final String timeOfBirth;
  final String placeOfBirth;
  final Rashi rashi;
  final String nakshatra;
  final int points;
  final int lifetimePoints;
  final int loginStreak;
  final String language;

  const UserProfile({
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.rashi,
    required this.nakshatra,
    required this.points,
    required this.lifetimePoints,
    required this.loginStreak,
    required this.language,
  });

  UserTier get tier => UserTier.fromPoints(lifetimePoints);

  UserProfile copyWith({
    String? name,
    DateTime? dateOfBirth,
    String? timeOfBirth,
    String? placeOfBirth,
    Rashi? rashi,
    String? nakshatra,
    int? points,
    int? lifetimePoints,
    int? loginStreak,
    String? language,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      rashi: rashi ?? this.rashi,
      nakshatra: nakshatra ?? this.nakshatra,
      points: points ?? this.points,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      loginStreak: loginStreak ?? this.loginStreak,
      language: language ?? this.language,
    );
  }
}
