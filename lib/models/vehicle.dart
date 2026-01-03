import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String? id;
  final String userId;
  final String make;
  final String model;
  final int year;
  final String nickname;
  final DateTime createdAt;

  Vehicle({
    this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    required this.nickname,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      userId: data['userId'] ?? '',
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? 0,
      nickname: data['nickname'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'make': make,
      'model': model,
      'year': year,
      'nickname': nickname,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Vehicle copyWith({
    String? id,
    String? userId,
    String? make,
    String? model,
    int? year,
    String? nickname,
    DateTime? createdAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      nickname: nickname ?? this.nickname,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displayName =>
      nickname.isNotEmpty ? nickname : '$year $make $model';
}
