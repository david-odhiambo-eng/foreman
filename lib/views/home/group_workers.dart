

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foreman/models/worker_provider.dart';
import 'package:foreman/viewModel/data_structure.dart';
import 'package:foreman/views/home/bottom_navigation.dart';
import 'package:foreman/views/home/textStyle.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupMembers extends StatefulWidget {
  const GroupMembers({
    super.key,
    required this.groupName,
    required this.date,
    required this.day,
  });
  final String groupName;
  final String day;
  final String date;

  @override
  State<GroupMembers> createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  final TextEditingController workereController = TextEditingController();
  final TextEditingController deductionsController = TextEditingController();
  final TextEditingController paymentController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> workers = [];
  List<String> employees = [];
  final List<String> _payment = [];

  final _fullText =
      'No worker added under this group\nEnter worker name\nand set daily pay per worker';
  String _displayText = '';
  int _currentIndex = 0;
  Timer? _typingTimer;

  // Firebase references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late CollectionReference workersCollection;
  late DocumentReference groupDocRef;
  late StreamSubscription<QuerySnapshot> _workersSubscription;

  @override
  void initState() {
    _typeText();
    _initializeFirebase();
    super.initState();
  }

  void _initializeFirebase() {
    final user = _auth.currentUser;
    if (user != null) {
      workersCollection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('groups')
          .doc(widget.groupName)
          .collection('workers');

      groupDocRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('groups')
          .doc(widget.groupName);

      _workersSubscription = workersCollection.snapshots().listen((snapshot) {
        setState(() {
          workers = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'name': data['name'] ?? '',
              'deductions': data['deductions']?.toString() ?? '0',
              'selectedDays': List<String>.from(data['selectedDays'] ?? []),
              'earnings': data['earnings']?.toString() ?? '0',
              'total': data['total']?.toString() ?? '0',
              'weekRange': data['weekRange'] ?? '',
              'isChecked': data['isChecked'] ?? false,
            };
          }).toList();

          employees = workers.map((worker) => worker['name'] as String).toList();
          _updateCheckedCount();
        });
      });

      // Load daily payment if exists
      groupDocRef.get().then((doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['dailyPayment'] != null) {
            setState(() {
              _payment.add(data['dailyPayment'].toString());
            });
          }
        }
      });
    }
  }

  // Update checked workers count in Firebase
  Future<void> _updateCheckedCount() async {
    final checkedCount = workers.where((w) => w['isChecked'] == true).length;
    await groupDocRef.set({
      'checkedWorkers': checkedCount,
      'totalWorkers': workers.length,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Toggle worker checked status
  Future<void> _toggleWorkerChecked(String workerId, bool isChecked) async {
    await workersCollection.doc(workerId).update({
      'isChecked': isChecked,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    workereController.dispose();
    deductionsController.dispose();
    paymentController.dispose();
    searchController.dispose();
    _typingTimer?.cancel();
    _workersSubscription.cancel();
    super.dispose();
  }

  // typing text
  void _typeText() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerProvider>(builder: (context, value, child) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          title: Column(
            children: [
              Text(
                '${widget.groupName} group',
                style: reusableStyle1().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.day}, ${widget.date}",
                    style: reusableStyle1().copyWith(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 4,
                        child: _styledButton(
                          'Add Workers',
                          Icons.person_add,
                          _showWorkerDialog,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 4,
                        child: _styledButton(
                          'Daily Pay/Worker',
                          Icons.add,
                          _enterWorkerPay,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 3,
                        child: Card(
                          elevation: 4,
                          color: Colors.white,
                          shadowColor: Colors.black.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Center(
                              child: Text(
                                _payment.isNotEmpty
                                    ? 'Ksh ${_payment.last}'
                                    : 'Ksh 0',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 0),
                Row(
                  children: [
                    Card(
                      elevation: 4,
                      color: Colors.white,
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(
                        height: 40,
                        width: 90,
                        child: employees.isNotEmpty
                            ? Center(
                                child: Text(
                                  employees.length.toString(),
                                  style: reusableStyle2(),
                                ),
                              )
                            : Center(
                                child: Text('0', style: reusableStyle2()),
                              ),
                      ),
                    ),
                    const SizedBox(width: 0),
                    Text('${widget.groupName} worker(s)',
                        style: reusableStyle1()),
                  ],
                ),
                const SizedBox(height: 12),
                _searchField(),
                const SizedBox(height: 12),
                Expanded(child: _createWorkers()),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomBar(currentIndex: 0),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton(
                onPressed: _resetAllCheckedStatus,
                child: const Icon(FontAwesomeIcons.remove, color: Colors.black),
              ),
              FloatingActionButton(
                onPressed: _deleteAllWorkers,
                child: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ),
      );
    });
  }

  // === Helper functions ===

  // Only rebuild; filtering is done in _createWorkers using searchController.text
  void _filterWorkers(String query) {
    setState(() {});
  }

  Widget _searchField() {
    return TextField(
      controller: searchController,
      onChanged: _filterWorkers,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue.shade700.withOpacity(0.85),
        hintText: 'Search Worker...',
        hintStyle:
            reusableStyle().copyWith(color: Colors.white.withOpacity(0.7)),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7)),
          onPressed: () {
            setState(() {
              searchController.clear();
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      cursorColor: Colors.white,
    );
  }

  Widget _createWorkers() {
    final query = searchController.text.toLowerCase();
    final workersToDisplay = query.isEmpty
        ? workers
        : workers
            .where((w) => (w['name'] as String)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();

    if (workersToDisplay.isEmpty) {
      return Center(
        child: Text(
          query.isNotEmpty ? 'No workers found' : _displayText,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: workersToDisplay.length,
      itemBuilder: (context, index) {
        final worker = workersToDisplay[index];
        final originalIndex =
            workers.indexWhere((w) => w['id'] == worker['id']);
        return _buildWorkerCard(worker, originalIndex);
      },
    );
  }

  Widget _buildWorkerCard(Map<String, dynamic> worker, int originalIndex) {
    return GestureDetector(
      onTap: (){
        //Navigator.push(context, MaterialPageRoute(context) => )
      },
      child:Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: worker['isChecked'] ?? false,
                      onChanged: (bool? value) {
                        if (value != null) {
                          _toggleWorkerChecked(worker['id'], value)
                              .then((_) => _updateCheckedCount());
                        }
                      },
                    ),
                    Text(worker['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(worker['weekRange'] ?? 'Week Range',
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              children: DataStructure.days.map((day) {
                final isSelected =
                    (worker['selectedDays'] as List<String>).contains(day);
                final isEnabled = _isDayEnabled(day, widget.date);
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      Card(
                        elevation: 1,
                        color: isEnabled ? Colors.white : Colors.grey[20],
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 12,
                              color: isEnabled ? Colors.green : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Checkbox(
                        activeColor: Colors.green,
                        checkColor: Colors.white,
                        value: isSelected,
                        onChanged: isEnabled
                            ? (bool? newValue) {
                                final updatedDays =
                                    List<String>.from(worker['selectedDays']);
                                if (newValue == true) {
                                  if (!updatedDays.contains(day)) {
                                    updatedDays.add(day);
                                  }
                                } else {
                                  updatedDays.remove(day);
                                }

                                _updateWorker(worker['id'], {
                                  'selectedDays': updatedDays,
                                }).then((_) {
                                  _calculateEarnings(originalIndex);
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _showWworkerEarnings('Earnings', worker['earnings']),
                  _showWworkerEarnings('Deductions', worker['deductions']),
                  _showWworkerEarnings('Totals', worker['total']),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _deductions(originalIndex),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Deduct'),
                ),
                IconButton(
                  onPressed: () => _deleteWorker(originalIndex),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    )
    );
  }

  Widget _showWworkerEarnings(String type, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
          Card(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              height: 40,
              width: 90,
              child: Center(
                child: Text(amount, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== Firebase Ops (unchanged) ==========
  Future<void> _addWorker(String name) async {
    final weekRange = getCurrentWeekRange();
    await workersCollection.add({
      'name': name,
      'deductions': 0,
      'selectedDays': <String>[],
      'earnings': 0,
      'total': 0,
      'weekRange': weekRange,
      'isChecked': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateWorker(String id, Map<String, dynamic> updates) async {
    await workersCollection.doc(id).update(updates);
  }

  Future<void> _deleteWorkerFromFirebase(String id) async {
    await workersCollection.doc(id).delete();
  }

  Future<void> _deleteAllWorkersFromFirebase() async {
    try {
      final querySnapshot = await workersCollection.get();
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // You had a Text widget here; leaving silent to avoid setState in async method.
      // Handle as needed.
    }
  }

  Future<void> _updateDailyPayment(String amount) async {
    await groupDocRef.set({
      'dailyPayment': int.tryParse(amount) ?? 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  bool _isDayEnabled(String day, String currentDay) {
    final daysOfWeek = DataStructure.days;
    final currentDayIndex = daysOfWeek.indexOf(currentDay);
    final dayIndex = daysOfWeek.indexOf(day);
    return dayIndex >= currentDayIndex;
  }

  String getCurrentWeekRange() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    String formatDate(DateTime date) {
      return '${date.day}/${date.month}/${date.year}';
    }

    return '${formatDate(monday)} - ${formatDate(sunday)}';
  }

  void _calculateEarnings(int index) {
    final dailyPay = _payment.isNotEmpty ? int.tryParse(_payment.last) ?? 0 : 0;
    final selectedDaysCount = (workers[index]['selectedDays'] as List).length;
    final earnings = dailyPay * selectedDaysCount;
    final deductions = int.tryParse(workers[index]['deductions']) ?? 0;
    final total = earnings - deductions;

    _updateWorker(workers[index]['id'], {
      'earnings': earnings,
      'total': total,
    });
  }

  void _deductions(int index) {
    deductionsController.text = workers[index]['deductions'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Deductions"),
        content: TextField(
          controller: deductionsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter amount",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _updateWorker(workers[index]['id'], {
                'deductions': int.tryParse(deductionsController.text.trim()) ?? 0,
              }).then((_) {
                _calculateEarnings(index);
                deductionsController.clear();
                Navigator.pop(context);
              });
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _enterWorkerPay() {
    paymentController.text = _payment.isNotEmpty ? _payment.last : '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Daily Amount per worker"),
        content: TextField(
          controller: paymentController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter amount",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (paymentController.text.trim().isNotEmpty) {
                _updateDailyPayment(paymentController.text.trim()).then((_) {
                  setState(() {
                    _payment.add(paymentController.text.trim());
                    paymentController.clear();
                    Navigator.pop(context);
                  });
                });
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _styledButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }

  Future<void> _showWorkerDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Worker\'s name'),
        content: TextField(
          controller: workereController,
          decoration: InputDecoration(
            hintText: 'Enter Worker name',
            hintStyle: reusableStyle1(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (workereController.text.trim().isNotEmpty) {
                _addWorker(workereController.text.trim()).then((_) {
                  workereController.clear();
                  Navigator.pop(context);
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Worker'),
          ),
        ],
      ),
    );
  }

  void _deleteWorker(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Are you sure you want to delete this worker?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              _deleteWorkerFromFirebase(workers[index]['id']).then((_) {
                Navigator.pop(context);
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _deleteAllWorkers() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
            'This action will delete all the workers of ${widget.groupName} group?'),
        content: const Text(
            'We recommend that you do this at the end of every week to keep number of workers managaeble'),
        actions: [
          ElevatedButton(
            onPressed: () {
              _deleteAllWorkersFromFirebase();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllCheckedStatus() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reset all checked statuses?'),
        content: Text(
            'This will uncheck all workers in ${widget.groupName} group. We recommend doing this at the end of each workday.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close the confirm dialog

              // Show a loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                // Get all workers
                final querySnapshot = await workersCollection.get();

                // Create a batch operation for efficient updates
                final batch = _firestore.batch();

                // Update each worker's isChecked status to false
                for (final doc in querySnapshot.docs) {
                  batch.update(doc.reference, {
                    'isChecked': false,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                }

                // Commit the batch operation
                await batch.commit();

                // Close the loading indicator
                Navigator.pop(context);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All workers unchecked successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                // Close the loading indicator
                Navigator.pop(context);

                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Failed to reset statuses: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Reset All'),
          ),
        ],
      ),
    );
  }
}





