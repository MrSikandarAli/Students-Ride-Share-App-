import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/ride_model.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';

/// Holds ride search/list state so [SearchRideScreen] and [HomeScreen]
/// share consistent loading/error handling instead of each managing
/// their own StreamBuilder plumbing ad hoc.
class RideProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final LocationService _locationService;

  RideProvider(this._firestoreService, this._locationService);

  List<RideModel> results = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> search({
    String? destinationQuery,
    DateTime? afterTime,
    double? radiusKm,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      var rides = await _firestoreService.searchRides(
        destinationQuery: destinationQuery,
        afterTime: afterTime,
      );

      if (radiusKm != null) {
        final position = await _locationService.getCurrentPosition();
        rides = _locationService.filterByRadius(
          rides: rides,
          origin: GeoPoint(position.latitude, position.longitude),
          radiusKm: radiusKm,
        );
      }

      results = rides;
    } catch (e) {
      errorMessage = e.toString();
      results = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinRide(String rideId, String passengerId) async {
    try {
      await _firestoreService.joinRide(rideId, passengerId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

}
