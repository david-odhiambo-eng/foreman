import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foreman/viewModel/group_adapter.dart';
import 'package:foreman/views/home/group_workers.dart';
import 'package:foreman/views/home/textStyle.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


class BodyPage extends StatefulWidget {
  const BodyPage({super.key});

  @override
  State<BodyPage> createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  final TextEditingController groupController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  late Box<Group> groupsBox;
  List<Group> groups = []; // Store groups names here
  List<Group> _searchedGroups = [];
  DateTime now = DateTime.now();
  late String formatedDate;
  late String formatedDay;

  //typing text
  final String _fullText = 'No groups created yet, press the button "Add Group" to add a worker group';
  String _displayText = '';
  int _currentIndex = 0;//index for the current character
  Timer? _typingTimer;


  @override
  void initState() {
    formatedDate = DateFormat('MMMM d, yyyy').format(now);
    formatedDay = DateFormat('EEEE').format(now);
    groupsBox = Hive.box<Group>('groups');
    _loadGroups();
    _startTyping();
    super.initState();
  }

  void _loadGroups() {
    setState(() {
      groups = groupsBox.values.toList();
      _searchedGroups = groups;
    });
  }

  @override
  void dispose() {
    groupController.dispose();
    searchController.dispose();
    _typingTimer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Add Group row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date information
                  Row(
                    children: [
                      Text(
                        formatedDay,
                        style: reusableStyle1().copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatedDate,
                        style: reusableStyle1().copyWith(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Add Group button
                  ElevatedButton(
                    onPressed: _showGroupNameDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Add Group'),
                        SizedBox(width: 4),
                        Icon(Icons.add, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            //show search field
            searchField(),
            const SizedBox(height: 10),

            // Display groups
            Expanded(
              child: _buildGroupList(),
            ),
          ],
        ),
      ),
    );
  }

  //typing timer
  void _startTyping(){
_typingTimer = Timer.periodic(Duration(milliseconds: 100),(timer){
      if(_currentIndex < _fullText.length){
        setState((){
          _displayText += _fullText[_currentIndex];
          _currentIndex++;
    

  });
      }else{
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
            style: TextStyle(color: Colors.white),  
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.blue.shade700.withOpacity(0.8),  
              hintText: 'Search Groups...',
              hintStyle: reusableStyle().copyWith(
                color: Colors.white.withOpacity(0.7), 
              ),
              prefixIcon: Icon(Icons.search, color: Colors.white),  
              suffixIcon: IconButton(  
                icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7)),
                onPressed: () {
                  searchController.clear();
                  _searchGroupName('');
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,  
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 14, 
                horizontal: 16
              ),
              focusedBorder: OutlineInputBorder(  
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.5), 
                  width: 1
                ),
              ),
            ),
            cursorColor: Colors.white,  
          ),
        ),
        SizedBox(width: 2,),
        Row(children: [
          Text(groups.length.toString(), style: reusableStyle2(),),
          SizedBox(width: 4,),
          Text('Group(s) created', style: reusableStyle1(),)
        ],)
      ],
    );
  }

  void _searchGroupName(String value) {
    if(groups.isNotEmpty) {
      setState(() {
        _searchedGroups = groups.where(
          (group) => group.name.toLowerCase().contains(value.toLowerCase())
        ).toList();
      });
    }
  }

  Future<void> _showGroupNameDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Group name'),
        content: TextField(
          controller: groupController,
          decoration: InputDecoration(
            hintText: 'Enter group name',
            hintStyle: reusableStyle1(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  groupController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (groupController.text.trim().isNotEmpty) {
                    final newGroup = Group(groupController.text.trim(), DateTime.now());
                    await groupsBox.add(newGroup);
                    _loadGroups();
                    groupController.clear();
                    Navigator.pop(context);
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
    groupController.text = group.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (groupController.text.isNotEmpty) {
                final updatedGroup = Group(
                  groupController.text, 
                  group.createdAt
                );
                await groupsBox.putAt(_getOriginalIndex(index), updatedGroup);
                _loadGroups();
                groupController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteGroup(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Group"),
        content: Text("Are you sure you want to delete this group?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await groupsBox.deleteAt(_getOriginalIndex(index));
              _loadGroups();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  int _getOriginalIndex(int searchedIndex) {
    final group = _searchedGroups[searchedIndex];
    return groups.indexWhere((g) => g!.name == group.name);
  }

  Widget _buildGroupList() {
    if (groups.isEmpty) {
      return Center(
        child: Text(
          _displayText,
          style: reusableStyle1().copyWith(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => GroupMembers(
                    groupName: _searchedGroups[index].name,
                    day: formatedDate,
                    date: formatedDay,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${_searchedGroups[index].name} group',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
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
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '21',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: 0.7,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}