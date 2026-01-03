import 'package:flutter/material.dart';
import '../core/services/firestore_service.dart';
import '../models/maintenance_record.dart';

class MaintenanceProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<MaintenanceRecord> _records = [];
  bool _isLoading = false;
  String? _error;

  List<MaintenanceRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Stream<List<MaintenanceRecord>> getMaintenanceStream(String vehicleId) {
    return _firestoreService.getMaintenanceStream(vehicleId);
  }

  Stream<List<MaintenanceRecord>> getAllMaintenanceStream(String userId) {
    return _firestoreService.getAllMaintenanceStream(userId);
  }

  Future<bool> addMaintenance(MaintenanceRecord record) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _firestoreService.addMaintenance(record);
      _records.insert(0, record.copyWith(id: id));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add maintenance record';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMaintenance(
    String recordId,
    MaintenanceRecord record,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.updateMaintenance(recordId, record);
      final index = _records.indexWhere((r) => r.id == recordId);
      if (index != -1) {
        _records[index] = record.copyWith(id: recordId);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update maintenance record';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMaintenance(String recordId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.deleteMaintenance(recordId);
      _records.removeWhere((r) => r.id == recordId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete maintenance record';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setRecords(List<MaintenanceRecord> records) {
    _records = records;
    notifyListeners();
  }
}
