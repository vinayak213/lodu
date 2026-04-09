import 'dart:math';
import '../models/club.dart';
import 'places_service.dart';
import 'besttime_service.dart';
import 'groq_service.dart';
import 'location_service.dart';

/// Orchestrator service that combines all APIs to produce final club data
class ClubService {
  final PlacesService? placesService;
  final BesttimeService? besttimeService;
  final GroqService? groqService;

  ClubService({
    this.placesService,
    this.besttimeService,
    this.groqService,
  });

  bool get hasPlacesApi => placesService != null;
  bool get hasBesttimeApi => besttimeService != null;
  bool get hasGroqApi => groqService != null;

  /// Fetch nearby clubs with crowd data — uses real APIs if keys available, else dummy data
  Future<List<Club>> getNearbyClubs({
    required double lat,
    required double lng,
    double radiusMeters = 5000,
  }) async {
    List<Club> clubs;

    // Step 1: Get clubs from Google Places or fallback to dummy
    if (hasPlacesApi) {
      try {
        clubs = await placesService!.getNearbyClubs(
          lat: lat,
          lng: lng,
          radiusMeters: radiusMeters,
        );
      } catch (e) {
        clubs = _getDummyClubs(lat, lng);
      }
    } else {
      clubs = _getDummyClubs(lat, lng);
    }

    // Step 2: Enrich each club with crowd data
    List<Club> enrichedClubs = [];
    for (final club in clubs) {
      var enriched = club;

      // Calculate distance
      final dist = LocationService.distanceBetween(lat, lng, club.lat, club.lng);
      enriched = enriched.copyWith(distanceKm: dist);

      // Get crowd data from Besttime
      if (hasBesttimeApi) {
        try {
          final forecast = await besttimeService!.createForecast(
            venueName: club.name,
            venueAddress: club.address,
          );
          final crowdData = BesttimeService.parseForecastResponse(forecast);
          enriched = enriched.copyWith(
            currentCrowd: crowdData.currentCrowd,
            crowdLevel: crowdData.crowdLevel,
            crowdHistory: crowdData.hourlyData,
          );
        } catch (_) {
          enriched = _addDummyCrowdData(enriched);
        }
      } else {
        enriched = _addDummyCrowdData(enriched);
      }

      // Get AI insight from Groq
      if (hasGroqApi) {
        try {
          final prediction = await groqService!.getCrowdPrediction(
            clubName: enriched.name,
            clubType: enriched.type,
            currentCrowd: enriched.currentCrowd,
            recentHourlyCrowds: enriched.crowdHistory
                .take(6)
                .map((s) => s.crowd)
                .toList(),
            dayOfWeek: _getDayName(DateTime.now().weekday),
            currentHour: DateTime.now().hour,
          );
          enriched = enriched.copyWith(
            aiInsight: prediction.insightHindi,
          );
        } catch (_) {
          enriched = _addDummyInsight(enriched);
        }
      } else {
        enriched = _addDummyInsight(enriched);
      }

      enrichedClubs.add(enriched);
    }

    // Sort by distance
    enrichedClubs.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return enrichedClubs;
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  Club _addDummyCrowdData(Club club) {
    final rng = Random(club.name.hashCode);
    final hour = DateTime.now().hour;
    final isNightTime = hour >= 20 || hour <= 3;
    final baseCrowd = isNightTime ? 40 + rng.nextInt(50) : 10 + rng.nextInt(30);

    final history = List.generate(24, (i) {
      int crowd;
      if (i >= 20 || i <= 2) {
        crowd = 30 + rng.nextInt(60);
      } else if (i >= 17) {
        crowd = 15 + rng.nextInt(40);
      } else {
        crowd = 5 + rng.nextInt(20);
      }
      return CrowdSnapshot(
        hour: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, i),
        crowd: crowd,
        source: 'estimated',
      );
    });

    return club.copyWith(
      currentCrowd: baseCrowd,
      crowdLevel: crowdLevelFromPercent(baseCrowd),
      crowdHistory: history,
    );
  }

  Club _addDummyInsight(Club club) {
    final insights = [
      'Abhi chill hai, 11 baje se crowd badhega 🔥',
      'Weekend hai toh packed hone wala hai — jaldi aa!',
      'Kal se zyada rush hai aaj, entry jaldi le lo',
      'Abhi perfect time hai jaane ka — moderate crowd',
      'Dead hai abhi, 10:30 ke baad scene start hoga',
      'Friday night vibes! 12 baje tak packed hoga 🎉',
      'Couples crowd zyada hai aaj — chill vibe',
      'DJ set 11 baje se hai, uske baad packed for sure',
    ];
    final idx = club.name.hashCode.abs() % insights.length;
    return club.copyWith(aiInsight: insights[idx]);
  }

  List<Club> _getDummyClubs(double lat, double lng) {
    final rng = Random(42);
    final clubs = [
      {'name': 'Neon Nights', 'type': 'nightclub', 'music': 'EDM / House', 'cover': '₹1500'},
      {'name': 'The Blue Bar', 'type': 'bar', 'music': 'Jazz / Blues', 'cover': '₹500'},
      {'name': 'Club Venom', 'type': 'nightclub', 'music': 'Bollywood / Commercial', 'cover': '₹2000'},
      {'name': 'Tipsy Bull', 'type': 'pub', 'music': 'Indie / Rock', 'cover': 'No Cover'},
      {'name': 'Sky Lounge', 'type': 'lounge', 'music': 'Deep House / Chill', 'cover': '₹1000'},
      {'name': 'Decode Air Bar', 'type': 'bar', 'music': 'Commercial / Hip-Hop', 'cover': '₹800'},
      {'name': 'Toit Brewpub', 'type': 'pub', 'music': 'Live Band', 'cover': 'No Cover'},
      {'name': 'Loft 38', 'type': 'nightclub', 'music': 'Techno / Trance', 'cover': '₹1200'},
      {'name': 'Byg Brewski', 'type': 'pub', 'music': 'Bollywood / Pop', 'cover': 'No Cover'},
      {'name': 'Pebble Street', 'type': 'lounge', 'music': 'Lounge / Retro', 'cover': '₹600'},
    ];

    return clubs.asMap().entries.map((entry) {
      final i = entry.key;
      final c = entry.value;
      final dlat = (rng.nextDouble() - 0.5) * 0.04;
      final dlng = (rng.nextDouble() - 0.5) * 0.04;
      return Club(
        id: 'dummy_$i',
        placeId: 'place_dummy_$i',
        name: c['name']!,
        address: '${rng.nextInt(999) + 1}, MG Road, Bangalore',
        lat: lat + dlat,
        lng: lng + dlng,
        rating: 3.5 + rng.nextDouble() * 1.5,
        userRatingsTotal: 100 + rng.nextInt(4000),
        type: c['type']!,
        music: c['music'],
        cover: c['cover'],
        isOpen: rng.nextDouble() > 0.15,
      );
    }).toList();
  }
}
