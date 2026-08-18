import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a document in the `ratings` Firestore collection.
/// A rating is created after a ride is completed, by either the
/// driver (rating a passenger) or a passenger (rating the driver).
class RatingModel {
  final String id;
  final String rideId;
  final String raterId;
  final String ratedUserId;
  final double stars;
  final String? comment;
  final DateTime createdAt;

  const RatingModel({
    required this.id,
    required this.rideId,
    required this.raterId,
    required this.ratedUserId,
    required this.stars,
    this.comment,
    required this.createdAt,
  });

  factory RatingModel.fromMap(Map<String, dynamic> map, String id) {
    return RatingModel(
      id: id,
      rideId: map['rideId'] ?? '',
      raterId: map['raterId'] ?? '',
      ratedUserId: map['ratedUserId'] ?? '',
      stars: (map['stars'] ?? 0.0).toDouble(),
      comment: map['comment'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'raterId': raterId,
      'ratedUserId': ratedUserId,
      'stars': stars,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
