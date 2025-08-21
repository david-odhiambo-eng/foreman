import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ToolsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _toolsCollection;

  ToolsProvider() {
    _toolsCollection = _firestore.collection('tools');
    _setupListener();
  }

  int _totalBorrowed = 0;
  int get totalBorrowed => _totalBorrowed;

  void _setupListener() {
    _toolsCollection.snapshots().listen((snapshot) {
      _totalBorrowed = snapshot.docs.fold(0, (sum, doc) {
        final workers = List<String>.from(doc['workers'] ?? []);
        return sum + workers.length;
      });
      notifyListeners();
    });
  }

  Future<int> fetchTotalBorrowed() async {
    try {
      final snapshot = await _toolsCollection.get();
      _totalBorrowed = snapshot.docs.fold(0, (sum, doc) {
        final workers = List<String>.from(doc['workers'] ?? []);
        return sum + workers.length;
      });
      notifyListeners();
      return _totalBorrowed;
    } catch (e) {
      
      return _totalBorrowed;
    }
  }
}
