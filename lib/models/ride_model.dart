import 'package:cloud_firestore/cloud_firestore.dart';

enum RideStatus { active, full, completed, cancelled }

/// Represents a document in the `rides` Firestore collection.
class RideModel {
  final String id;
  final String driverId;
  final String driverName;
  final String? driverPhotoUrl;
  final double driverRating;

  final String startAddress;
  final GeoPoint startPoint;
  final String destinationAddress;
  final GeoPoint destinationPoint;

  final DateTime departureTime;
  final int totalSeats;
  final int seatsBooked;
  final double costPerSeat;
  final List<String> passengerIds;
  final RideStatus status;
  final DateTime createdAt;

  const RideModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    this.driverPhotoUrl,
    this.driverRating = 0.0,
    required this.startAddress,
    required this.startPoint,
    required this.destinationAddress,
    required this.destinationPoint,
    required this.departureTime,
    required this.totalSeats,
    this.seatsBooked = 0,
    required this.costPerSeat,
    this.passengerIds = const [],
    this.status = RideStatus.active,
    required this.createdAt,
  });

  int get seatsAvailable => totalSeats - seatsBooked;
  bool get isFull => seatsAvailable <= 0;

  factory RideModel.fromMap(Map<String, dynamic> map, String id) {
    return RideModel(
      id: id,
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? '',
      driverPhotoUrl: map['driverPhotoUrl'],
      driverRating: (map['driverRating'] ?? 0.0).toDouble(),
      startAddress: map['startAddress'] ?? '',
      startPoint: map['startPoint'] ?? const GeoPoint(0, 0),
      destinationAddress: map['destinationAddress'] ?? '',
      destinationPoint: map['destinationPoint'] ?? const GeoPoint(0, 0),
      departureTime: (map['departureTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalSeats: map['totalSeats'] ?? 1,
      seatsBooked: map['seatsBooked'] ?? 0,
      costPerSeat: (map['costPerSeat'] ?? 0.0).toDouble(),
      passengerIds: List<String>.from(map['passengerIds'] ?? const []),
      status: RideStatus.values.firstWhere(
            (s) => s.name == (map['status'] ?? 'active'),
        orElse: () => RideStatus.active,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory RideModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return RideModel.fromMap(doc.data() ?? {}, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'driverPhotoUrl': driverPhotoUrl,
      'driverRating': driverRating,
      'startAddress': startAddress,
      'startPoint': startPoint,
      'destinationAddress': destinationAddress,
      'destinationPoint': destinationPoint,
      'departureTime': Timestamp.fromDate(departureTime),
      'totalSeats': totalSeats,
      'seatsBooked': seatsBooked,
      'costPerSeat': costPerSeat,
      'passengerIds': passengerIds,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
