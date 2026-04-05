import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

// Web-specific imports
import 'dart:js_interop' if (dart.library.io) 'location_service_stub.dart';
import 'package:web/web.dart' if (dart.library.io) 'location_service_stub.dart' as web;

class LocationService {
  static Future<Position> getCurrentLocation() async {
    if (kIsWeb) {
      return _getWebLocation();
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<Position> _getWebLocation() async {
    final completer = Completer<Position>();

    web.window.navigator.geolocation.getCurrentPosition(
      ((web.GeolocationPosition pos) {
        final coords = pos.coords;
        completer.complete(Position(
          latitude: coords.latitude.toDouble(),
          longitude: coords.longitude.toDouble(),
          timestamp: DateTime.now(),
          accuracy: coords.accuracy.toDouble(),
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        ));
      }).toJS,
      ((web.GeolocationPositionError err) {
        completer.completeError(Exception('Web geolocation error: ${err.message}'));
      }).toJS,
    );

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Location timeout'),
    );
  }

  static double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;
  }
}
