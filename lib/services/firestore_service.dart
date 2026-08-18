import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_model.dart';
import '../models/rating_model.dart';

/// Handles all ride- and rating-related Firestore reads/writes.
/// Location-radius filtering happens client-side after an initial
/// Firestore query narrows the candidate set (Firestore has no native
/// geo-radius query without a geohash index, which is a good future
/// enhancement noted in the README).
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _rides => _db.collection('rides');
  CollectionReference<Map<String, dynamic>> get _ratings => _db.collection('ratings');

  Future<String> createRide(RideModel ride) async {
    final doc = await _rides.add(ride.toMap());
    return doc.id;
  }

  Stream<List<RideModel>> streamActiveRides() {
    return _rides
        .where('status', isEqualTo: RideStatus.active.name)
        .where('departureTime', isGreaterThan: Timestamp.now())
        .orderBy('departureTime')
        .snapshots()
        .map((snap) => snap.docs.map(RideModel.fromDoc).toList());
  }

  /// Basic filter by destination text and a departure-time window.
  /// GPS radius narrowing is applied afterwards in [LocationService].
  Future<List<RideModel>> searchRides({
    String? destinationQuery,
    DateTime? afterTime,
  }) async {
    Query<Map<String, dynamic>> query = _rides
        .where('status', isEqualTo: RideStatus.active.name)
        .orderBy('departureTime');

    if (afterTime != null) {
      query = query.where('departureTime', isGreaterThan: Timestamp.fromDate(afterTime));
    }

    final snap = await query.get();
    var results = snap.docs.map(RideModel.fromDoc).toList();

    if (destinationQuery != null && destinationQuery.trim().isNotEmpty) {
      final q = destinationQuery.trim().toLowerCase();
      results = results
          .where((r) => r.destinationAddress.toLowerCase().contains(q))
          .toList();
    }

    return results;
  }

  Stream<RideModel> rideStream(String rideId) {
    return _rides.doc(rideId).snapshots().map(RideModel.fromDoc);
  }

  Future<void> joinRide(String rideId, String passengerId) {
    return _db.runTransaction((tx) async {
      final ref = _rides.doc(rideId);
      final snap = await tx.get(ref);
      final ride = RideModel.fromDoc(snap);

      if (ride.isFull) throw Exception('This ride is already full');
      if (ride.passengerIds.contains(passengerId)) return;

      final newBooked = ride.seatsBooked + 1;
      tx.update(ref, {
        'seatsBooked': newBooked,
        'passengerIds': FieldValue.arrayUnion([passengerId]),
        if (newBooked >= ride.totalSeats) 'status': RideStatus.full.name,
      });
    });
  }

  Future<void> leaveRide(String rideId, String passengerId) {
    return _db.runTransaction((tx) async {
      final ref = _rides.doc(rideId);
      final snap = await tx.get(ref);
      final ride = RideModel.fromDoc(snap);

      tx.update(ref, {
        'seatsBooked': (ride.seatsBooked - 1).clamp(0, ride.totalSeats),
        'passengerIds': FieldValue.arrayRemove([passengerId]),
        'status': RideStatus.active.name,
      });
    });
  }

  Future<void> cancelRide(String rideId) {
    return _rides.doc(rideId).update({'status': RideStatus.cancelled.name});
  }

  Stream<List<RideModel>> myPostedRides(String driverId) {
    return _rides
        .where('driverId', isEqualTo: driverId)
        .orderBy('departureTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(RideModel.fromDoc).toList());
  }

  Stream<List<RideModel>> myJoinedRides(String passengerId) {
    return _rides
        .where('passengerIds', arrayContains: passengerId)
        .orderBy('departureTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(RideModel.fromDoc).toList());
  }

  // --- Ratings ---

  Future<void> submitRating(RatingModel rating) async {
    await _ratings.add(rating.toMap());

    // Recompute the rated user's aggregate rating.
    final userRef = _db.collection('users').doc(rating.ratedUserId);
    await _db.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final data = userSnap.data() ?? {};
      final currentCount = (data['ratingCount'] ?? 0) as int;
      final currentAvg = (data['rating'] ?? 0.0).toDouble();

      final newCount = currentCount + 1;
      final newAvg = ((currentAvg * currentCount) + rating.stars) / newCount;

      tx.update(userRef, {'rating': newAvg, 'ratingCount': newCount});
    });
  }
}
