import '../config/api_client.dart';
import '../features/auth/data/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BadgeService {
  static final ApiClient _apiClient = ApiClient();

  static Future<List<Badge>> getAllBadges() async {
    try {
      final response = await _apiClient.get('/badge');
      
      if (response['success'] == true && response['data'] != null) {
        final badgesData = response['data'] as List;
        return badgesData.map((badgeJson) => Badge.fromJson(badgeJson)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching all badges: $e');
      return [];
    }
  }

  static Future<List<String>> getUserBadgeIds() async {
    try {
      // Get current user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(AuthDataConstants.userIdKey);

      if (userId == null) {
        print('No userId found in SharedPreferences');
        return [];
      }

      // Get user profile to fetch badges
      final response = await _apiClient.get('/auth/profile');
      
      if (response['success'] == true && response['data'] != null) {
        final userData = response['data'];
        final badges = userData['badges'] as List?;
        return badges?.map((badge) => badge.toString()).toList() ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching user badges: $e');
      return [];
    }
  }

  static Future<BadgeCollection> getBadgeCollection() async {
    try {
      final allBadges = await getAllBadges();
      final userBadgeIds = await getUserBadgeIds();
      
      final earnedBadges = <Badge>[];
      final unearnedBadges = <Badge>[];
      
      for (final badge in allBadges) {
        if (userBadgeIds.contains(badge.id)) {
          earnedBadges.add(badge);
        } else {
          unearnedBadges.add(badge);
        }
      }
      
      return BadgeCollection(
        earnedBadges: earnedBadges,
        unearnedBadges: unearnedBadges,
        totalBadges: allBadges.length,
        earnedCount: earnedBadges.length,
      );
    } catch (e) {
      print('Error fetching badge collection: $e');
      return BadgeCollection(
        earnedBadges: [],
        unearnedBadges: [],
        totalBadges: 0,
        earnedCount: 0,
      );
    }
  }
}

class Badge {
  final String id;
  final String name;
  final String iconUrl;

  Badge({
    required this.id,
    required this.name,
    required this.iconUrl,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString() ?? '',
    );
  }
}

class BadgeCollection {
  final List<Badge> earnedBadges;
  final List<Badge> unearnedBadges;
  final int totalBadges;
  final int earnedCount;

  BadgeCollection({
    required this.earnedBadges,
    required this.unearnedBadges,
    required this.totalBadges,
    required this.earnedCount,
  });

  double get completionPercentage {
    if (totalBadges == 0) return 0.0;
    return (earnedCount / totalBadges) * 100;
  }
} 