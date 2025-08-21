import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foreman/views/home/bottom_navigation.dart';
import 'package:foreman/views/home/textStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Tools extends StatefulWidget {
  const Tools({super.key});

  @override
  State<Tools> createState() => _ToolsState();
}

class _ToolsState extends State<Tools> {
  final TextEditingController toolController = TextEditingController();
  final TextEditingController workerController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _toolsCollection = FirebaseFirestore.instance.collection('tools');

  String? selectedTool;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track your Tools', style: reusableStyle2()),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightBlue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              _toolsButton(),
              _searchField(),
              const SizedBox(height: 10),
              _showBorrowedTools(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(currentIndex: 1),
    );
  }

  Widget _toolsButton() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Card(
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: GestureDetector(
            onTap: () {
              _showToolDialog();
            },
            child: Card(
              elevation: 4,
              color: Colors.blue,
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.add, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Add Tool name', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Search tools or workers...",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _workerButton(String toolId, String toolName) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Card(
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: GestureDetector(
            onTap: () {
              selectedTool = toolId;
              _enterWorkerDialog();
            },
            child: Card(
              elevation: 4,
              color: Colors.blue,
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.add, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Add Worker name',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showToolDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter Tool name'),
        content: TextField(
          controller: toolController,
          decoration: InputDecoration(
            hintText: 'Enter name of tool',
            hintStyle: reusableStyle1(),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              toolController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (toolController.text.trim().isNotEmpty) {
                try {
                  await _toolsCollection.add({
                    'name': toolController.text.trim(),
                    'workers': [],
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                  toolController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding tool: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _enterWorkerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter worker name'),
        content: TextField(
          controller: workerController,
          decoration: InputDecoration(
            hintText: 'Enter name of worker',
            hintStyle: reusableStyle1(),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              workerController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (workerController.text.trim().isNotEmpty && selectedTool != null) {
                try {
                  await _toolsCollection.doc(selectedTool).update({
                    'workers': FieldValue.arrayUnion([workerController.text.trim()])
                  });
                  Navigator.pop(context);
                  workerController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding worker: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeWorker(String toolId, String workerName) async {
    try {
      await _toolsCollection.doc(toolId).update({
        'workers': FieldValue.arrayRemove([workerName])
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing worker: $e')),
      );
    }
  }

  Future<void> _deleteTool(String toolId, String toolName) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Tool'),
          content: Text('Are you sure you want to delete "$toolName"? This will also remove all workers associated with this tool.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first
                try {
                  await _toolsCollection.doc(toolId).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"$toolName" has been deleted')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting tool: $e')),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _showBorrowedTools() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<QuerySnapshot>(
          stream: _toolsCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tools = snapshot.data!.docs;
            
            // Calculate total borrowed count
            int totalBorrowed = tools.fold(0, (sum, doc) {
              final workers = List<String>.from(doc['workers'] ?? []);
              return sum + workers.length;
            });

            // Filter tools based on search query
            final filteredTools = tools.where((doc) {
              final toolName = doc['name'].toString().toLowerCase();
              final workers = List<String>.from(doc['workers'] ?? []);
              
              final matchesTool = toolName.contains(searchQuery);
              final matchesWorker = workers.any((worker) => 
                  worker.toLowerCase().contains(searchQuery));
              
              return matchesTool || matchesWorker;
            }).toList();

            return Column(
              children: [
                Text(
                  'Total: $totalBorrowed borrowed',
                  style: reusableStyle1(),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTools.length,
                    itemBuilder: (context, index) {
                      final doc = filteredTools[index];
                      final toolId = doc.id;
                      final toolName = doc['name'];
                      final workers = List<String>.from(doc['workers'] ?? []);
                      
                      // Filter workers for this tool based on search
                      final filteredWorkers = workers.where((worker) => 
                          worker.toLowerCase().contains(searchQuery)).toList();

                      return Card(
                        elevation: 4,
                        color: Colors.white,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tool header row with delete button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(toolName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        radius: 14,
                                        child: Text(
                                          workers.length.toString(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          _deleteTool(toolId, toolName);
                                        },
                                        tooltip: 'Delete Tool',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _workerButton(toolId, toolName),
                              const SizedBox(height: 10),
                              ...filteredWorkers.map(
                                (worker) => Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 4),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(worker),
                                        ElevatedButton(
                                          onPressed: () {
                                            _removeWorker(toolId, worker);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white),
                                          child: const Text('Returned'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}