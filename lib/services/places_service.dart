import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/club.dart';

class PlacesService {
  final String apiKey;

  PlacesService({required this.apiKey});

  /// Fetch nearby clubs/bars/nightclubs using Google Places API (New)
  Future<List<Club>> getNearbyClubs({
    required double lat,
    required double lng,
    double radiusMeters = 5000,
  }) async {
    final url = Uri.parse(
      'https://places.googleapis.com/v1/places:searchNearby',
    );

    final body = jsonEncode({
      'includedTypes': ['night_club', 'bar', 'restaurant'],
      'maxResultCount': 20,
      'locationRestriction': {
        'circle': {
          'center': {'latitude': lat, 'longitude': lng},
          'radius': radiusMeters,
        },
      },
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'places.id,places.displayName,places.formattedAddress,'
                'places.shortFormattedAddress,places.location,places.rating,'
                'places.userRatingCount,places.types,places.photos,'
                'places.currentOpeningHours,places.regularOpeningHours',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Google Places API error: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body);
    final places = data['places'] as List? ?? [];

    return places.map((p) => Club.fromGooglePlace(p, apiKey: apiKey)).toList();
  }

  /// Get detailed info for a single place
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://places.googleapis.com/v1/places/$placeId',
    );

    final response = await http.get(
      url,
      headers: {
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'id,displayName,formattedAddress,location,rating,'
                'userRatingCount,types,photos,currentOpeningHours,'
                'regularOpeningHours,reviews,websiteUri,nationalPhoneNumber',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Place details error: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  /// Get photo URL from photo resource name
  String getPhotoUrl(String photoName, {int maxHeight = 400}) {
    return 'https://places.googleapis.com/v1/$photoName/media?maxHeightPx=$maxHeight&key=$apiKey';
  }
}
