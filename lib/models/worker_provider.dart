import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foreman/viewModel/worker_adapter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


class WorkerProvider with ChangeNotifier {
  late Box<GroupModel> _groupsBox;
  final _auth = FirebaseAuth.instance.currentUser;
  final _firestore =  FirebaseFirestore.instance;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WorkerModelAdapter());
    Hive.registerAdapter(GroupModelAdapter());
    _groupsBox = await Hive.openBox<GroupModel>('groups_box');
  }

  GroupModel? getGroup(String groupName) {
    return _groupsBox.get(groupName);
  }

  Future<void> addGroup(GroupModel group) async {
    await _groupsBox.put(group.groupName, group);
    notifyListeners();
  }

  Future<void> addWorker(String groupName, WorkerModel worker) async {
    final group = _groupsBox.get(groupName);
    if (group != null) {
      group.workers.add(worker);
      await group.save();
      notifyListeners();
    }
  }

  Future<void> updateWorker(String groupName, WorkerModel worker) async {
    await worker.save();
    notifyListeners();
  }

  Future<void> removeWorker(String groupName, WorkerModel worker) async {
    final group = _groupsBox.get(groupName);
    if (group != null) {
      group.workers.remove(worker);
      await group.save();
      notifyListeners();
    }
  }

  Future<void> addPayment(String groupName, String payment) async {
    final group = _groupsBox.get(groupName);
    if (group != null) {
      group.paymentHistory.add(payment);
      await group.save();
      notifyListeners();
    }
  }

  Future<void> close() async {
    await _groupsBox.close();
  }

  //getting totals for a group of workers
  Future<double> getGroupTotal(String groupName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;
    
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('groups')
        .doc(groupName)
        .collection('workers')
        .get();
    
    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      total += double.tryParse(data['total']?.toString() ?? '0') ?? 0;
    }
    return total;
  }

  //method for all group totals
  
Future<double> getAllGroupsTotal() async {
  try {
    
    if (_auth == null) return 0;
    
    final groupsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.uid)
        .collection('groups')
        .get();
    
    double grandTotal = 0;
    
    for (var groupDoc in groupsSnapshot.docs) {
      final workersSnapshot = await groupDoc.reference
          .collection('workers')
          .get();
      
      for (var workerDoc in workersSnapshot.docs) {
        final data = workerDoc.data();
        grandTotal += double.tryParse(data['total']?.toString() ?? '0') ?? 0;
      }
    }
    
    return grandTotal;
  } catch (e) {
    debugPrint('Error getting all groups total: $e');
    return 0;
  }
}
}