import 'package:flutter/material.dart';
import '../core/services/firestore_service.dart';
import '../models/vehicle.dart';

class VehicleProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  bool _isLoading = false;
  String? _error;

  List<Vehicle> get vehicles => _vehicles;
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void selectVehicle(Vehicle? vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  Stream<List<Vehicle>> getVehiclesStream(String userId) {
    return _firestoreService.getVehiclesStream(userId);
  }

  Future<void> loadVehicles(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicles = await _firestoreService.getVehicles(userId);
      if (_vehicles.isNotEmpty && _selectedVehicle == null) {
        _selectedVehicle = _vehicles.first;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load vehicles';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addVehicle(Vehicle vehicle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _firestoreService.addVehicle(vehicle);
      final newVehicle = vehicle.copyWith(id: id);
      _vehicles.insert(0, newVehicle);
      _selectedVehicle ??= newVehicle;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add vehicle';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVehicle(String vehicleId, Vehicle vehicle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.updateVehicle(vehicleId, vehicle);
      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        _vehicles[index] = vehicle.copyWith(id: vehicleId);
      }
      if (_selectedVehicle?.id == vehicleId) {
        _selectedVehicle = vehicle.copyWith(id: vehicleId);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update vehicle';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.deleteVehicle(vehicleId);
      _vehicles.removeWhere((v) => v.id == vehicleId);
      if (_selectedVehicle?.id == vehicleId) {
        _selectedVehicle = _vehicles.isNotEmpty ? _vehicles.first : null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete vehicle';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> getVehicleStats(String vehicleId) async {
    try {
      return await _firestoreService.getVehicleStats(vehicleId);
    } catch (e) {
      return null;
    }
  }
}
