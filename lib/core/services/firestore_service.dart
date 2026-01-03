import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/vehicle.dart';
import '../../models/maintenance_record.dart';
import '../../models/modification.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(String uid, String email, String displayName) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'displayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUser(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  CollectionReference<Map<String, dynamic>> get _vehiclesCollection =>
      _db.collection('vehicles');

  Stream<List<Vehicle>> getVehiclesStream(String userId) {
    return _vehiclesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList(),
        );
  }

  Future<List<Vehicle>> getVehicles(String userId) async {
    final snapshot = await _vehiclesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList();
  }

  Future<Vehicle?> getVehicle(String vehicleId) async {
    final doc = await _vehiclesCollection.doc(vehicleId).get();
    if (!doc.exists) return null;
    return Vehicle.fromFirestore(doc);
  }

  Future<String> addVehicle(Vehicle vehicle) async {
    final docRef = await _vehiclesCollection.add(vehicle.toFirestore());
    return docRef.id;
  }

  Future<void> updateVehicle(String vehicleId, Vehicle vehicle) async {
    await _vehiclesCollection.doc(vehicleId).update(vehicle.toFirestore());
  }

  Future<void> deleteVehicle(String vehicleId) async {
    final maintenanceSnapshot = await _db
        .collection('maintenance')
        .where('vehicleId', isEqualTo: vehicleId)
        .get();
    for (var doc in maintenanceSnapshot.docs) {
      await doc.reference.delete();
    }

    final modsSnapshot = await _db
        .collection('modifications')
        .where('vehicleId', isEqualTo: vehicleId)
        .get();
    for (var doc in modsSnapshot.docs) {
      await doc.reference.delete();
    }

    await _vehiclesCollection.doc(vehicleId).delete();
  }

  CollectionReference<Map<String, dynamic>> get _maintenanceCollection =>
      _db.collection('maintenance');

  Stream<List<MaintenanceRecord>> getMaintenanceStream(String vehicleId) {
    return _maintenanceCollection
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MaintenanceRecord.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<MaintenanceRecord>> getAllMaintenanceStream(String userId) {
    return _maintenanceCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MaintenanceRecord.fromFirestore(doc))
              .toList(),
        );
  }

  Future<String> addMaintenance(MaintenanceRecord record) async {
    final docRef = await _maintenanceCollection.add(record.toFirestore());
    return docRef.id;
  }

  Future<void> updateMaintenance(
    String recordId,
    MaintenanceRecord record,
  ) async {
    await _maintenanceCollection.doc(recordId).update(record.toFirestore());
  }

  Future<void> deleteMaintenance(String recordId) async {
    await _maintenanceCollection.doc(recordId).delete();
  }

  CollectionReference<Map<String, dynamic>> get _modificationsCollection =>
      _db.collection('modifications');

  Stream<List<Modification>> getModificationsStream(String vehicleId) {
    return _modificationsCollection
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Modification.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<Modification>> getAllModificationsStream(String userId) {
    return _modificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Modification.fromFirestore(doc))
              .toList(),
        );
  }

  Future<String> addModification(Modification mod) async {
    final docRef = await _modificationsCollection.add(mod.toFirestore());
    return docRef.id;
  }

  Future<void> updateModification(String modId, Modification mod) async {
    await _modificationsCollection.doc(modId).update(mod.toFirestore());
  }

  Future<void> deleteModification(String modId) async {
    await _modificationsCollection.doc(modId).delete();
  }

  Future<Map<String, dynamic>> getVehicleStats(String vehicleId) async {
    final maintenanceSnapshot = await _maintenanceCollection
        .where('vehicleId', isEqualTo: vehicleId)
        .get();
    final modsSnapshot = await _modificationsCollection
        .where('vehicleId', isEqualTo: vehicleId)
        .get();

    double totalMaintenanceCost = 0;
    double totalModsCost = 0;

    for (var doc in maintenanceSnapshot.docs) {
      totalMaintenanceCost += (doc.data()['cost'] ?? 0).toDouble();
    }

    for (var doc in modsSnapshot.docs) {
      totalModsCost += (doc.data()['cost'] ?? 0).toDouble();
    }

    return {
      'maintenanceCount': maintenanceSnapshot.docs.length,
      'modsCount': modsSnapshot.docs.length,
      'totalMaintenanceCost': totalMaintenanceCost,
      'totalModsCost': totalModsCost,
      'totalCost': totalMaintenanceCost + totalModsCost,
    };
  }
}
