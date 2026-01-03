import 'package:cloud_firestore/cloud_firestore.dart';

enum ModCategory {
  turbo,
  exhaust,
  suspension,
  intake,
  ecu,
  wheels,
  brakes,
  exterior,
  interior,
  audio,
  other,
}

extension ModCategoryExtension on ModCategory {
  String get displayName {
    switch (this) {
      case ModCategory.turbo:
        return 'Turbo/Supercharger';
      case ModCategory.exhaust:
        return 'Exhaust System';
      case ModCategory.suspension:
        return 'Suspension';
      case ModCategory.intake:
        return 'Cold Air Intake';
      case ModCategory.ecu:
        return 'ECU Tune';
      case ModCategory.wheels:
        return 'Wheels & Tires';
      case ModCategory.brakes:
        return 'Performance Brakes';
      case ModCategory.exterior:
        return 'Exterior';
      case ModCategory.interior:
        return 'Interior';
      case ModCategory.audio:
        return 'Audio System';
      case ModCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ModCategory.turbo:
        return '🌀';
      case ModCategory.exhaust:
        return '💨';
      case ModCategory.suspension:
        return '🔩';
      case ModCategory.intake:
        return '🌬️';
      case ModCategory.ecu:
        return '💻';
      case ModCategory.wheels:
        return '🛞';
      case ModCategory.brakes:
        return '🛑';
      case ModCategory.exterior:
        return '🎨';
      case ModCategory.interior:
        return '💺';
      case ModCategory.audio:
        return '🔊';
      case ModCategory.other:
        return '🔧';
    }
  }
}

class Modification {
  final String? id;
  final String vehicleId;
  final String userId;
  final String name;
  final ModCategory category;
  final DateTime date;
  final double cost;
  final String notes;
  final DateTime createdAt;

  Modification({
    this.id,
    required this.vehicleId,
    required this.userId,
    required this.name,
    required this.category,
    required this.date,
    required this.cost,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Modification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Modification(
      id: doc.id,
      vehicleId: data['vehicleId'] ?? '',
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      category: ModCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => ModCategory.other,
      ),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cost: (data['cost'] ?? 0).toDouble(),
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vehicleId': vehicleId,
      'userId': userId,
      'name': name,
      'category': category.name,
      'date': Timestamp.fromDate(date),
      'cost': cost,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Modification copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    String? name,
    ModCategory? category,
    DateTime? date,
    double? cost,
    String? notes,
    DateTime? createdAt,
  }) {
    return Modification(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
