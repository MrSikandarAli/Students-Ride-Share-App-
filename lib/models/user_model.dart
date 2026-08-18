import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { driver, passenger, both }

/// Represents a document in the `users` Firestore collection.
class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String studentId;
  final String university;
  final String? photoUrl;
  final UserRole role;
  final bool isVerified;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.studentId,
    required this.university,
    this.photoUrl,
    this.role = UserRole.both,
    this.isVerified = false,
    this.rating = 0.0,
    this.ratingCount = 0,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      studentId: map['studentId'] ?? '',
      university: map['university'] ?? '',
      photoUrl: map['photoUrl'],
      role: UserRole.values.firstWhere(
            (r) => r.name == (map['role'] ?? 'both'),
        orElse: () => UserRole.both,
      ),
      isVerified: map['isVerified'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel.fromMap(doc.data() ?? {}, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'studentId': studentId,
      'university': university,
      'photoUrl': photoUrl,
      'role': role.name,
      'isVerified': isVerified,
      'rating': rating,
      'ratingCount': ratingCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? photoUrl,
    UserRole? role,
    bool? isVerified,
    double? rating,
    int? ratingCount,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      studentId: studentId,
      university: university,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt,
    );
  }
}
