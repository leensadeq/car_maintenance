import 'package:flutter/material.dart';
import '../core/services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _service;

  UserProvider(this._service);

  Map<String, dynamic>? userData;

  Future<void> loadUser(String uid) async {
    final doc = await _service.getUser(uid);
    userData = doc.data() as Map<String, dynamic>?;
    notifyListeners();
  }
}
