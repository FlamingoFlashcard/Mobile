import 'dart:io';
import 'dart:math' as math;
import '../config/api_client.dart';
import '../services/location_weather_service.dart';
import '../services/badge_service.dart' as badge_service;
import '../features/auth/data/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  static final ApiClient _apiClient = ApiClient();

  static Future<AIResult?> classifyImageAndGetInfo(File imageFile) async {
    try {
      // First, get user location for landmark detection
      final position = await LocationWeatherService.getCurrentLocation();
      
      // Try landmark detection first if we have location
      if (position != null) {
        final landmarkResult = await _classifyLandmark(imageFile, position.latitude, position.longitude);
        if (landmarkResult != null) {
          // Check for badge award after landmark identification
          final awardedBadge = await _checkAndAwardBadge(landmarkResult.name);
          if (awardedBadge != null) {
            landmarkResult.awardedBadge = awardedBadge;
          }
          
          final chatbotInfo = await _getChatbotInfo("what is ${landmarkResult.name}?");
          return AIResult(
            type: 'landmark',
            name: landmarkResult.name,
            confidence: landmarkResult.confidence,
            description: chatbotInfo ?? 'Information not available',
            distance: landmarkResult.distance,
            awardedBadge: landmarkResult.awardedBadge,
          );
        }
      }
      
      // If landmark detection fails, try object detection
      final objectResult = await _classifyObject(imageFile);
      if (objectResult != null) {
        final chatbotInfo = await _getChatbotInfo("what is ${objectResult.name}?");
        return AIResult(
          type: 'object',
          name: objectResult.name,
          confidence: objectResult.confidence,
          description: chatbotInfo ?? 'Information not available',
        );
      }
      
      return null;
    } catch (e) {
      print('Error in AI classification: $e');
      return null;
    }
  }

  static Future<LandmarkResult?> _classifyLandmark(File imageFile, double latitude, double longitude) async {
    try {
      final response = await _apiClient.postMultipart(
        '/classify/landmark',
        {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
        [MapEntry('image', imageFile)],
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        
        // Handle new response format with landmarks and badge info
        if (data is Map<String, dynamic> && data['landmarks'] != null) {
          final landmarks = data['landmarks'] as List;
          if (landmarks.isNotEmpty) {
            final landmark = landmarks.first as Map<String, dynamic>;
            final landmarkResult = LandmarkResult(
              name: landmark['name']?.toString() ?? 'Unknown Landmark',
              confidence: landmark['confidence']?.toString() ?? 'N/A',
              distance: landmark['distance']?.toString() ?? 'N/A',
            );
            
            // Check for awarded badge
            if (data['awardedBadge'] != null) {
              final badgeData = data['awardedBadge'] as Map<String, dynamic>;
              landmarkResult.awardedBadge = BadgeInfo(
                id: badgeData['id']?.toString() ?? '',
                name: badgeData['name']?.toString() ?? '',
                iconUrl: badgeData['iconUrl']?.toString() ?? '',
              );
            }
            
            return landmarkResult;
          }
        }
        // Handle legacy formats...
        else if (data is List && data.isNotEmpty) {
          // Handle array format
          final landmark = data.first as Map<String, dynamic>;
          return LandmarkResult(
            name: landmark['name']?.toString() ?? 'Unknown Landmark',
            confidence: landmark['confidence']?.toString() ?? 'N/A',
            distance: landmark['distance']?.toString() ?? 'N/A',
          );
        } else if (data is Map<String, dynamic>) {
          // Handle single landmark object format (Google Vision API response)
          final description = data['description']?.toString() ?? 'Unknown Landmark';
          final score = data['score'];
          final confidence = score != null ? '${(score * 100).toStringAsFixed(1)}%' : 'N/A';
          
          // Calculate distance if location data is available
          String distance = 'N/A';
          if (data['locations'] != null && data['locations'] is List) {
            final locations = data['locations'] as List;
            if (locations.isNotEmpty && locations.first['latLng'] != null) {
              final latLng = locations.first['latLng'];
              final landmarkLat = latLng['latitude']?.toDouble();
              final landmarkLng = latLng['longitude']?.toDouble();
              
              if (landmarkLat != null && landmarkLng != null) {
                final calculatedDistance = _calculateDistance(latitude, longitude, landmarkLat, landmarkLng);
                distance = '${calculatedDistance.toStringAsFixed(2)} km';
              }
            }
          }
          
          return LandmarkResult(
            name: description,
            confidence: confidence,
            distance: distance,
          );
        }
      }
      return null;
    } catch (e) {
      print('Error classifying landmark: $e');
      return null;
    }
  }

  static Future<ObjectResult?> _classifyObject(File imageFile) async {
    try {
      final response = await _apiClient.postMultipart(
        '/classify/objects',
        {},
        [MapEntry('image', imageFile)],
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        return ObjectResult(
          name: data['object'],
          confidence: data['confidence'],
        );
      }
      return null;
    } catch (e) {
      print('Error classifying object: $e');
      return null;
    }
  }

  static Future<String?> _getChatbotInfo(String prompt) async {
    try {
      // Get current user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(AuthDataConstants.userIdKey);

      if (userId == null) {
        print('No userId found in SharedPreferences');
        return null;
      }

      final response = await _apiClient.post('/chatbot', {
        'prompt': prompt,
        'userId': userId,
      });

      if (response['success'] == true) {
        return response['data'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting chatbot info: $e');
      return null;
    }
  }

  static Future<BadgeInfo?> _checkAndAwardBadge(String landmarkName) async {
    try {
      // Get all available badges
      final allBadges = await badge_service.BadgeService.getAllBadges();
      
      // Check if any badge name matches the landmark name
      badge_service.Badge? matchingBadge;
      
      // Try exact match first
      matchingBadge = allBadges.firstWhere(
        (badge) => badge.name.toLowerCase() == landmarkName.toLowerCase(),
        orElse: () => badge_service.Badge(id: '', name: '', iconUrl: ''),
      );
      
      // If no exact match, try partial match
      if (matchingBadge?.id.isEmpty ?? true) {
        matchingBadge = allBadges.firstWhere(
          (badge) => badge.name.toLowerCase().contains(landmarkName.toLowerCase()) ||
                    landmarkName.toLowerCase().contains(badge.name.toLowerCase()),
          orElse: () => badge_service.Badge(id: '', name: '', iconUrl: ''),
        );
      }
      
      // If no partial match, try keyword matching
      if (matchingBadge?.id.isEmpty ?? true) {
        final landmarkKeywords = _extractKeywords(landmarkName);
        for (final badge in allBadges) {
          final badgeKeywords = _extractKeywords(badge.name);
          if (_hasKeywordMatch(landmarkKeywords, badgeKeywords)) {
            matchingBadge = badge;
            break;
          }
        }
      }
      
      // If we found a matching badge, try to award it
      if (matchingBadge != null && matchingBadge.id.isNotEmpty) {
        final success = await _awardBadgeToUser(matchingBadge.id);
        if (success) {
          return BadgeInfo(
            id: matchingBadge.id,
            name: matchingBadge.name,
            iconUrl: matchingBadge.iconUrl,
          );
        }
      }
      
      return null;
    } catch (e) {
      print('Error checking and awarding badge: $e');
      return null;
    }
  }

  static Future<bool> _awardBadgeToUser(String badgeId) async {
    try {
      final response = await _apiClient.post('/badge/$badgeId/award', {});
      return response['success'] == true;
    } catch (e) {
      print('Error awarding badge: $e');
      return false;
    }
  }

  static List<String> _extractKeywords(String text) {
    // Common stop words to ignore
    const stopWords = {
      'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 
      'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
      'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 
      'should', 'may', 'might', 'can', 'must', 'shall'
    };
    
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .split(RegExp(r'\s+')) // Split by whitespace
        .where((word) => word.length > 2 && !stopWords.contains(word))
        .toList();
  }

  static bool _hasKeywordMatch(List<String> keywords1, List<String> keywords2) {
    for (final keyword1 in keywords1) {
      for (final keyword2 in keywords2) {
        if (keyword1.contains(keyword2) || keyword2.contains(keyword1)) {
          return true;
        }
      }
    }
    return false;
  }

  // Haversine formula to calculate distance between two coordinates in kilometers
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of the Earth in km
    final double dLat = (lat2 - lat1) * (math.pi / 180);
    final double dLon = (lon2 - lon1) * (math.pi / 180);
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180)) * math.cos(lat2 * (math.pi / 180)) * 
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = R * c; // Distance in km
    return distance;
  }
}

class AIResult {
  final String type; // 'landmark' or 'object'
  final String name;
  final String confidence;
  final String description;
  final String? distance; // Only for landmarks
  final BadgeInfo? awardedBadge; // Badge info if awarded

  AIResult({
    required this.type,
    required this.name,
    required this.confidence,
    required this.description,
    this.distance,
    this.awardedBadge,
  });
}

class LandmarkResult {
  final String name;
  final String confidence;
  final String distance;
  BadgeInfo? awardedBadge;

  LandmarkResult({
    required this.name,
    required this.confidence,
    required this.distance,
    this.awardedBadge,
  });
}

class ObjectResult {
  final String name;
  final String confidence;

  ObjectResult({
    required this.name,
    required this.confidence,
  });
}

class BadgeInfo {
  final String id;
  final String name;
  final String iconUrl;

  BadgeInfo({
    required this.id,
    required this.name,
    required this.iconUrl,
  });
} 