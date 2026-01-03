import 'package:flutter/material.dart';
import '../core/services/firestore_service.dart';
import '../models/modification.dart';

class ModsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Modification> _mods = [];
  bool _isLoading = false;
  String? _error;

  List<Modification> get mods => _mods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Stream<List<Modification>> getModificationsStream(String vehicleId) {
    return _firestoreService.getModificationsStream(vehicleId);
  }

  Stream<List<Modification>> getAllModificationsStream(String userId) {
    return _firestoreService.getAllModificationsStream(userId);
  }

  Future<bool> addModification(Modification mod) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _firestoreService.addModification(mod);
      _mods.insert(0, mod.copyWith(id: id));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add modification';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateModification(String modId, Modification mod) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.updateModification(modId, mod);
      final index = _mods.indexWhere((m) => m.id == modId);
      if (index != -1) {
        _mods[index] = mod.copyWith(id: modId);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update modification';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteModification(String modId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.deleteModification(modId);
      _mods.removeWhere((m) => m.id == modId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete modification';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setMods(List<Modification> mods) {
    _mods = mods;
    notifyListeners();
  }
}
