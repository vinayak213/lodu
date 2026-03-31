class Club {
  final String id;
  final String placeId;
  final String name;
  final String address;
  final String? vicinity;
  final double lat;
  final double lng;
  final double rating;
  final int userRatingsTotal;
  final String? photoUrl;
  final List<String> photos;
  final String type; // nightclub, bar, lounge, pub
  final String? music;
  final String? cover;
  final bool isOpen;
  final String? openingHours;
  final int currentCrowd; // 0-100
  final String crowdLevel; // dead, chill, moderate, busy, packed
  final String? aiInsight; // Groq AI generated Hindi insight
  final List<CrowdSnapshot> crowdHistory;
  final double distanceKm;

  Club({
    required this.id,
    required this.placeId,
    required this.name,
    required this.address,
    this.vicinity,
    required this.lat,
    required this.lng,
    this.rating = 0,
    this.userRatingsTotal = 0,
    this.photoUrl,
    this.photos = const [],
    this.type = 'nightclub',
    this.music,
    this.cover,
    this.isOpen = true,
    this.openingHours,
    this.currentCrowd = 0,
    this.crowdLevel = 'unknown',
    this.aiInsight,
    this.crowdHistory = const [],
    this.distanceKm = 0,
  });

  factory Club.fromGooglePlace(Map<String, dynamic> place, {String? apiKey}) {
    final location = place['location'] ?? place['geometry']?['location'] ?? {};
    final lat = (location['latitude'] ?? location['lat'] ?? 0).toDouble();
    final lng = (location['longitude'] ?? location['lng'] ?? 0).toDouble();

    String? photoUrl;
    List<String> photos = [];
    final photoList = place['photos'] as List?;
    if (photoList != null && photoList.isNotEmpty && apiKey != null) {
      for (final photo in photoList) {
        final ref = photo['name'] ?? photo['photo_reference'];
        if (ref != null) {
          final url =
              'https://places.googleapis.com/v1/$ref/media?maxHeightPx=400&key=$apiKey';
          photos.add(url);
        }
      }
      if (photos.isNotEmpty) photoUrl = photos.first;
    }

    return Club(
      id: place['id'] ?? place['place_id'] ?? '',
      placeId: place['id'] ?? place['place_id'] ?? '',
      name: place['displayName']?['text'] ?? place['name'] ?? 'Unknown',
      address: place['formattedAddress'] ?? place['formatted_address'] ?? '',
      vicinity: place['shortFormattedAddress'] ?? place['vicinity'],
      lat: lat,
      lng: lng,
      rating: (place['rating'] ?? 0).toDouble(),
      userRatingsTotal: place['userRatingCount'] ?? place['user_ratings_total'] ?? 0,
      photoUrl: photoUrl,
      photos: photos,
      isOpen: place['currentOpeningHours']?['openNow'] ??
          place['opening_hours']?['open_now'] ??
          true,
      type: _inferType(place),
    );
  }

  static String _inferType(Map<String, dynamic> place) {
    final types = (place['types'] as List?)?.cast<String>() ?? [];
    if (types.contains('night_club') || types.contains('nightclub')) {
      return 'nightclub';
    }
    if (types.contains('bar')) return 'bar';
    if (types.contains('cafe')) return 'lounge';
    return 'pub';
  }

  Club copyWith({
    int? currentCrowd,
    String? crowdLevel,
    String? aiInsight,
    List<CrowdSnapshot>? crowdHistory,
    double? distanceKm,
    String? music,
    String? cover,
  }) {
    return Club(
      id: id,
      placeId: placeId,
      name: name,
      address: address,
      vicinity: vicinity,
      lat: lat,
      lng: lng,
      rating: rating,
      userRatingsTotal: userRatingsTotal,
      photoUrl: photoUrl,
      photos: photos,
      type: type,
      music: music ?? this.music,
      cover: cover ?? this.cover,
      isOpen: isOpen,
      openingHours: openingHours,
      currentCrowd: currentCrowd ?? this.currentCrowd,
      crowdLevel: crowdLevel ?? this.crowdLevel,
      aiInsight: aiInsight ?? this.aiInsight,
      crowdHistory: crowdHistory ?? this.crowdHistory,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

class CrowdSnapshot {
  final DateTime hour;
  final int crowd; // 0-100
  final String source; // besttime, checkin, popular_times

  CrowdSnapshot({
    required this.hour,
    required this.crowd,
    this.source = 'besttime',
  });

  factory CrowdSnapshot.fromJson(Map<String, dynamic> json) {
    return CrowdSnapshot(
      hour: DateTime.parse(json['hour']),
      crowd: json['crowd'] ?? 0,
      source: json['source'] ?? 'besttime',
    );
  }
}

String crowdLevelFromPercent(int percent) {
  if (percent < 15) return 'dead';
  if (percent < 35) return 'chill';
  if (percent < 55) return 'moderate';
  if (percent < 75) return 'busy';
  return 'packed';
}
