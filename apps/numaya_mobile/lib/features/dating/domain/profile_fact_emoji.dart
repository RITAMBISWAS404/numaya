import '../../profile/domain/profile_details.dart';

/// UI-019: the emoji that leads each profile-detail pill. One mapping for every place a person's
/// details show as pills (Discover, liked and opened profiles, the member's own preview).
///
/// This is an explicit exception to the Lucide icon convention: profile-detail pills use emoji;
/// navigation, toolbar, safety and every other app icon keep the Lucide family. Each emoji is
/// decorative (the pill's text label is what is announced).
abstract final class ProfileFactEmoji {
  /// Gender and pronouns ("Woman · she/her").
  static const String identity = '🙂';

  /// Relationship intention ("Long-term").
  static const String lookingFor = '💞';
  static const String height = '📏';
  static const String languages = '🗣️';

  /// "Lives in Hackney".
  static const String livesIn = '🏠';

  static String detail(DetailKey key, String value) => switch (key) {
    DetailKey.exercise => '🏃',
    DetailKey.education => '🎓',
    DetailKey.drinking => '🍷',
    DetailKey.smoking => '🚬',
    DetailKey.starSign => _zodiac[value] ?? '✨',
    DetailKey.familyPlans => '👶',
    DetailKey.kids => '🧸',
    DetailKey.religion => '🙏',
    DetailKey.politics => '🗳️',
  };

  static const Map<String, String> _zodiac = {
    'Aries': '♈',
    'Taurus': '♉',
    'Gemini': '♊',
    'Cancer': '♋',
    'Leo': '♌',
    'Virgo': '♍',
    'Libra': '♎',
    'Scorpio': '♏',
    'Sagittarius': '♐',
    'Capricorn': '♑',
    'Aquarius': '♒',
    'Pisces': '♓',
  };
}
