import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PurchasesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  CollectionReference get _purchasesCollection => _firestore
      .collection('users')
      .doc(_auth.currentUser?.uid)
      .collection('purchases');

  List<Map<String, dynamic>> _purchases = [];
  List<Map<String, dynamic>> get purchases => _purchases;
  
  int get totalPurchasesCount => _purchases.length;
  double get totalSpent => _purchases.fold(0, (sum, purchase) => sum + (purchase['totalPrice'] ?? 0.0));

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PurchasesProvider() {
    _setupListener();
  }

  void _setupListener() {
    _purchasesCollection
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      _purchases = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      notifyListeners();
    });
  }

  Future<void> addPurchase(Map<String, dynamic> purchaseData) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _purchasesCollection.add({
        ...purchaseData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add purchase: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePurchase(String purchaseId, Map<String, dynamic> purchaseData) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _purchasesCollection.doc(purchaseId).update({
        ...purchaseData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update purchase: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePurchase(String purchaseId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _purchasesCollection.doc(purchaseId).delete();
    } catch (e) {
      throw Exception('Failed to delete purchase: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> searchPurchases(String query) {
    if (query.isEmpty) return _purchases;
    
    final lowercaseQuery = query.toLowerCase();
    return _purchases.where((purchase) {
      final itemName = (purchase['itemName'] ?? '').toString().toLowerCase();
      final supplier = (purchase['supplier'] ?? '').toString().toLowerCase();
      final category = (purchase['category'] ?? '').toString().toLowerCase();
      return itemName.contains(lowercaseQuery) || 
             supplier.contains(lowercaseQuery) ||
             category.contains(lowercaseQuery);
    }).toList();
  }

  double getTotalSpentByCategory(String category) {
    return _purchases
        .where((purchase) => purchase['category'] == category)
        .fold(0, (sum, purchase) => sum + (purchase['totalPrice'] ?? 0.0));
  }

  List<Map<String, dynamic>> getPurchasesByStatus(String status) {
    return _purchases.where((purchase) => purchase['status'] == status).toList();
  }

  List<String> get uniqueCategories {
    return _purchases
        .map((purchase) => purchase['category']?.toString() ?? 'Uncategorized')
        .toSet()
        .toList();
  }

  List<String> get uniqueSuppliers {
    return _purchases
        .map((purchase) => purchase['supplier']?.toString() ?? 'Unknown')
        .toSet()
        .toList();
  }
}