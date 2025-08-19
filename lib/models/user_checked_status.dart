// Create a new file called group_stats_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class GroupStatsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  final String groupName;

  GroupStatsProvider({required this.userId, required this.groupName});

  DocumentReference get _groupDocRef => _firestore
      .collection('users')
      .doc(userId)
      .collection('groups')
      .doc(groupName);

  Stream<Map<String, dynamic>> get groupStats {
    return _groupDocRef.snapshots().map((snapshot) {
      return snapshot.data() as Map<String, dynamic>? ?? {};
    });
  }

  Future<int> getCheckedCount() async {
    final doc = await _groupDocRef.get();
    return doc.get('checkedWorkers') ?? 0;
  }

  Future<int> getTotalWorkers() async {
    final doc = await _groupDocRef.get();
    return doc.get('totalWorkers') ?? 0;
  }

  
}


