import 'package:cloud_firestore/cloud_firestore.dart';

enum MaintenanceType {
  oilChange,
  tireRotation,
  brakeService,
  transmission,
  coolant,
  airFilter,
  sparkPlugs,
  battery,
  alignment,
  inspection,
  other,
}

extension MaintenanceTypeExtension on MaintenanceType {
  String get displayName {
    switch (this) {
      case MaintenanceType.oilChange:
        return 'Oil Change';
      case MaintenanceType.tireRotation:
        return 'Tire Rotation';
      case MaintenanceType.brakeService:
        return 'Brake Service';
      case MaintenanceType.transmission:
        return 'Transmission Service';
      case MaintenanceType.coolant:
        return 'Coolant Flush';
      case MaintenanceType.airFilter:
        return 'Air Filter';
      case MaintenanceType.sparkPlugs:
        return 'Spark Plugs';
      case MaintenanceType.battery:
        return 'Battery';
      case MaintenanceType.alignment:
        return 'Wheel Alignment';
      case MaintenanceType.inspection:
        return 'Inspection';
      case MaintenanceType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case MaintenanceType.oilChange:
        return '🛢️';
      case MaintenanceType.tireRotation:
        return '🔄';
      case MaintenanceType.brakeService:
        return '🛑';
      case MaintenanceType.transmission:
        return '⚙️';
      case MaintenanceType.coolant:
        return '❄️';
      case MaintenanceType.airFilter:
        return '💨';
      case MaintenanceType.sparkPlugs:
        return '⚡';
      case MaintenanceType.battery:
        return '🔋';
      case MaintenanceType.alignment:
        return '🎯';
      case MaintenanceType.inspection:
        return '🔍';
      case MaintenanceType.other:
        return '🔧';
    }
  }
}

class MaintenanceRecord {
  final String? id;
  final String vehicleId;
  final String userId;
  final MaintenanceType type;
  final DateTime date;
  final int mileage;
  final double cost;
  final String notes;
  final DateTime createdAt;

  MaintenanceRecord({
    this.id,
    required this.vehicleId,
    required this.userId,
    required this.type,
    required this.date,
    required this.mileage,
    required this.cost,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MaintenanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MaintenanceRecord(
      id: doc.id,
      vehicleId: data['vehicleId'] ?? '',
      userId: data['userId'] ?? '',
      type: MaintenanceType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MaintenanceType.other,
      ),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mileage: data['mileage'] ?? 0,
      cost: (data['cost'] ?? 0).toDouble(),
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vehicleId': vehicleId,
      'userId': userId,
      'type': type.name,
      'date': Timestamp.fromDate(date),
      'mileage': mileage,
      'cost': cost,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MaintenanceRecord copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    MaintenanceType? type,
    DateTime? date,
    int? mileage,
    double? cost,
    String? notes,
    DateTime? createdAt,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
