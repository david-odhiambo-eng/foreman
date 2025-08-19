

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foreman/models/worker_provider.dart';
import 'package:foreman/viewModel/group_adapter.dart';
import 'package:foreman/views/home/group_workers.dart';
import 'package:foreman/views/home/textStyle.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class BodyPage extends StatefulWidget {
  const BodyPage({super.key});

  @override
  State<BodyPage> createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  final TextEditingController groupController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  
  List<Group> groups = [];
  List<Group> _searchedGroups = [];
  DateTime now = DateTime.now();
  late String formatedDate;
  late String formatedDay;

  // Firebase references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late StreamSubscription<QuerySnapshot> _groupsSubscription;

  // typing text
  final String _fullText =
      'No groups created yet, press the button "Add Group" to add a worker group';
  String _displayText = '';
  int _currentIndex = 0;
  Timer? _typingTimer;

  @override
  void initState() {
    formatedDate = DateFormat('MMMM d, yyyy').format(now);
    formatedDay = DateFormat('EEEE').format(now);
    _startTyping();
    _setupGroupsListener();
    super.initState();
  }

  void _setupGroupsListener() {
    final user = _auth.currentUser;
    if (user != null) {
      _groupsSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('groups')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          groups = snapshot.docs.map((doc) {
            final data = doc.data();
            return Group(
              data['name'] ?? '',
              (data['createdAt'] as Timestamp).toDate(),
            );
          }).toList();
          _searchedGroups = groups;
        });
      });
    }
  }

  @override
  void dispose() {
    groupController.dispose();
    searchController.dispose();
    _typingTimer?.cancel();
    _groupsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date + Add Group row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatedDay,
                      style: reusableStyle1().copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatedDate,
                      style: reusableStyle1().copyWith(
                        color: Colors.grey[700],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                // Add Group button
                ElevatedButton.icon(
                  onPressed: _showGroupNameDialog,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Group'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Search field
            searchField(),
            const SizedBox(height: 14),

            // Group List
            Expanded(child: _buildGroupList()),
          ],
        ),
      ),
    );
  }

  // Typing animation
  void _startTyping() {
    _typingTimer =
        Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayText += _fullText[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Widget searchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (String value) {
              _searchGroupName(value);
            },
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.blue.shade600,
              hintText: 'Search groups...',
              hintStyle: reusableStyle().copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: IconButton(
                icon: Icon(Icons.close,
                    color: Colors.white.withOpacity(0.7)),
                onPressed: () {
                  searchController.clear();
                  _searchGroupName('');
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 16),
            ),
            cursorColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            Text(groups.length.toString(),
                style: reusableStyle2().copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                )),
            const SizedBox(width: 4),
            Text('Groups',
                style: reusableStyle1().copyWith(color: Colors.grey[700])),
          ],
        ),
      ],
    );
  }

  void _searchGroupName(String value) {
    if (groups.isNotEmpty) {
      setState(() {
        _searchedGroups = groups
            .where((group) =>
                group.name.toLowerCase().contains(value.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> _showGroupNameDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Enter Group Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: groupController,
          decoration: InputDecoration(
            hintText: 'e.g. Plumbers',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  groupController.clear();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (groupController.text.trim().isNotEmpty) {
                    final user = _auth.currentUser;
                    if (user != null) {
                      final groupName = groupController.text.trim();
                      final newGroup = {
                        'name': groupName,
                        'createdAt': DateTime.now(),
                        'checkedWorkers': 0,
                        'totalWorkers': 0,
                      };
                      
                      await _firestore
                          .collection('users')
                          .doc(user.uid)
                          .collection('groups')
                          .doc(groupName)
                          .set(newGroup);
                      
                      groupController.clear();
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editGroup(int index) {
  final group = _searchedGroups[index];
  final originalGroupName = group.name;
  groupController.text = group.name;
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      title: const Text("Edit Group"),
      content: TextField(
        controller: groupController,
        decoration: const InputDecoration(
          hintText: "Enter new group name",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel",
              style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () async {
            if (groupController.text.isNotEmpty) {
              final user = _auth.currentUser;
              if (user != null) {
                final newGroupName = groupController.text;
                
                // Get the old group data
                final oldGroupDoc = await _firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection('groups')
                    .doc(originalGroupName)
                    .get();
                
                if (oldGroupDoc.exists) {
                  // Create new group with ALL existing data but new name
                  final oldData = oldGroupDoc.data() as Map<String, dynamic>;
                  await _firestore
                      .collection('users')
                      .doc(user.uid)
                      .collection('groups')
                      .doc(newGroupName)
                      .set({
                    ...oldData, // Spread all existing data
                    'name': newGroupName, // Update the name field
                  });
                  
                  // Copy all workers from old group to new group
                  final workersSnapshot = await _firestore
                      .collection('users')
                      .doc(user.uid)
                      .collection('groups')
                      .doc(originalGroupName)
                      .collection('workers')
                      .get();
                  
                  // Batch write for efficiency
                  final batch = _firestore.batch();
                  
                  for (var workerDoc in workersSnapshot.docs) {
                    final newWorkerRef = _firestore
                        .collection('users')
                        .doc(user.uid)
                        .collection('groups')
                        .doc(newGroupName)
                        .collection('workers')
                        .doc(workerDoc.id);
                    
                    batch.set(newWorkerRef, workerDoc.data());
                  }
                  
                  await batch.commit();
                  
                  // Delete old group and its workers
                  final deleteBatch = _firestore.batch();
                  
                  // Delete all workers in old group
                  for (var workerDoc in workersSnapshot.docs) {
                    deleteBatch.delete(workerDoc.reference);
                  }
                  
                  // Delete the old group document
                  deleteBatch.delete(oldGroupDoc.reference);
                  
                  await deleteBatch.commit();
                  
                  groupController.clear();
                  Navigator.pop(context);
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
          ),
          child: const Text("Save"),
        ),
      ],
    ),
  );
}

  void _deleteGroup(int index) {
    final group = _searchedGroups[index];
    final groupName = group.name;
    final user = _auth.currentUser;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Delete Group"),
        content: Text("Are you sure you want to delete the group '$groupName' and all its data?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (user != null) {
                final groupRef = _firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection('groups')
                    .doc(groupName);

                // Delete all workers inside this group
                final workersSnap = await groupRef.collection('workers').get();
                for (var doc in workersSnap.docs) {
                  await doc.reference.delete();
                }

                // Finally delete the group doc itself
                await groupRef.delete();
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList() {
    if (groups.isEmpty) {
      return Center(
        child: Text(
          _displayText,
          textAlign: TextAlign.center,
          style: reusableStyle1().copyWith(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
            fontSize: 15,
          ),
        ),
      );
    }

    if (_searchedGroups.isEmpty && searchController.text.isNotEmpty) {
      return Center(
        child: Text(
          'No groups found matching "${searchController.text}"',
          style: reusableStyle1().copyWith(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchedGroups.length,
      itemBuilder: (context, index) {
        final groupName = _searchedGroups[index].name;
        final user = _auth.currentUser;
        
        if (user == null) {
          return const SizedBox();
        }

        DocumentReference groupDocRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('groups')
            .doc(groupName);

        return StreamBuilder<DocumentSnapshot>(
          stream: groupDocRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildGroupCard(
                groupName: groupName,
                checkedWorkers: 0,
                totalWorkers: 0,
                index: index,
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final checkedWorkers = data['checkedWorkers'] ?? 0;
            final totalWorkers = data['totalWorkers'] ?? 0;
            final progress = totalWorkers > 0 ? (checkedWorkers / totalWorkers).toDouble() : 0.0;

            return _buildGroupCard(
              groupName: groupName,
              checkedWorkers: checkedWorkers,
              totalWorkers: totalWorkers,
              progress: progress,
              index: index,
            );
          },
        );
      },
    );
  }

  Widget _buildGroupCard({
    required String groupName,
    required int checkedWorkers,
    required int totalWorkers,
    double progress = 0,
    required int index,
  }) {
    return FutureBuilder<double>(
      future: Provider.of<WorkerProvider>(context, listen: false)
          .getGroupTotal(groupName),
      builder: (context, snapshot) {
        final total = snapshot.data ?? 0;
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => GroupMembers(
                  groupName: groupName,
                  day: formatedDate,
                  date: formatedDay,
                ),
              ),
            );
          },
          child: Card(
            elevation: 5,
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group title + edit/delete
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$groupName Group',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            color: Colors.blue.shade600,
                            onPressed: () => _editGroup(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            color: Colors.red.shade600,
                            onPressed: () => _deleteGroup(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue.shade100,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  '$checkedWorkers/$totalWorkers',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Workers marked today',
                              style: reusableStyle1(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress.toDouble(),
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Displaying totals for the group
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Text(
                              'Group Totals:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 50),
                            Text(
                              'Ksh ${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
