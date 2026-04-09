import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/club.dart';

class BesttimeService {
  final String apiKey;
  static const _baseUrl = 'https://besttime.app/api/v1';

  BesttimeService({required this.apiKey});

  /// Create a foot traffic forecast for a venue
  Future<Map<String, dynamic>> createForecast({
    required String venueName,
    required String venueAddress,
  }) async {
    final url = Uri.parse('$_baseUrl/forecasts');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'api_key_private': apiKey,
        'venue_name': venueName,
        'venue_address': venueAddress,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Besttime forecast error: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  /// Get live foot traffic for a venue
  Future<Map<String, dynamic>> getLiveCrowd({
    required String venueId,
  }) async {
    final url = Uri.parse('$_baseUrl/forecasts/live?api_key_public=$apiKey&venue_id=$venueId');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Besttime live error: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  /// Parse Besttime response into crowd data for a club
  static CrowdData parseForecastResponse(Map<String, dynamic> response) {
    final analysis = response['analysis'] as Map<String, dynamic>?;
    if (analysis == null) {
      return CrowdData(currentCrowd: 0, crowdLevel: 'unknown', hourlyData: []);
    }

    // Get current day's data
    final now = DateTime.now();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final todayName = dayNames[now.weekday - 1];

    final dayInfo = (analysis['day_info'] as List?)?.firstWhere(
      (d) => d['day_text'] == todayName,
      orElse: () => null,
    );

    int currentCrowd = 0;
    List<CrowdSnapshot> hourlyData = [];

    if (dayInfo != null) {
      // Get hourly analysis
      final hourAnalysis = dayInfo['day_raw'] as List? ?? [];
      for (int i = 0; i < hourAnalysis.length && i < 24; i++) {
        final crowd = (hourAnalysis[i] as num?)?.toInt() ?? 0;
        hourlyData.add(CrowdSnapshot(
          hour: DateTime(now.year, now.month, now.day, i),
          crowd: crowd.clamp(0, 100),
          source: 'besttime',
        ));
      }

      // Current hour crowd
      if (now.hour < hourAnalysis.length) {
        currentCrowd = ((hourAnalysis[now.hour] as num?)?.toInt() ?? 0).clamp(0, 100);
      }
    }

    return CrowdData(
      currentCrowd: currentCrowd,
      crowdLevel: crowdLevelFromPercent(currentCrowd),
      hourlyData: hourlyData,
      venueId: response['venue_info']?['venue_id'],
    );
  }

  /// Parse live crowd response
  static int parseLiveResponse(Map<String, dynamic> response) {
    final liveData = response['analysis']?['venue_live_busyness'];
    if (liveData != null) {
      return (liveData as num).toInt().clamp(0, 100);
    }
    return 0;
  }
}

class CrowdData {
  final int currentCrowd;
  final String crowdLevel;
  final List<CrowdSnapshot> hourlyData;
  final String? venueId;

  CrowdData({
    required this.currentCrowd,
    required this.crowdLevel,
    required this.hourlyData,
    this.venueId,
  });
}
