import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/ride_model.dart';

/// Wraps GPS + geocoding + radius filtering so screens never touch
/// the `geolocator`/`geocoding` packages directly.
class LocationService {
  /// Ensures location services + permissions are available, requesting
  /// permission if needed. Throws if the user permanently denies access.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Enable it in settings.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Converts a free-text address into a `GeoPoint`, used when a
  /// driver posts a ride with a typed start/destination address.
  Future<GeoPoint> geocodeAddress(String address) async {
    final locations = await locationFromAddress(address);
    if (locations.isEmpty) throw Exception('Address not found: $address');
    final loc = locations.first;
    return GeoPoint(loc.latitude, loc.longitude);
  }

  Future<String> reverseGeocode(double lat, double lng) async {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isEmpty) return '$lat, $lng';
    final p = placemarks.first;
    return [p.street, p.locality, p.administrativeArea]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
  }

  double distanceInKm(GeoPoint a, GeoPoint b) {
    final meters = Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
    return meters / 1000;
  }

  /// Filters a list of rides to those whose start point lies within
  /// [radiusKm] of the given origin — used for "nearby rides" search.
  List<RideModel> filterByRadius({
    required List<RideModel> rides,
    required GeoPoint origin,
    required double radiusKm,
  }) {
    return rides.where((ride) => distanceInKm(origin, ride.startPoint) <= radiusKm).toList()
      ..sort((a, b) => distanceInKm(origin, a.startPoint)
          .compareTo(distanceInKm(origin, b.startPoint)));
  }
}
