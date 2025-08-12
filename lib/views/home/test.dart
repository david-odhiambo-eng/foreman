// import 'package:flutter/material.dart';
// import 'package:foreman/views/home/group_workers.dart';
// import 'package:foreman/views/home/textStyle.dart';
// import 'package:intl/intl.dart';

// class BodyPage extends StatefulWidget {
//   const BodyPage({super.key});

//   @override
//   State<BodyPage> createState() => _BodyPageState();
// }

// class _BodyPageState extends State<BodyPage> {
//   final TextEditingController groupController = TextEditingController();
//   List<String> groupNames = []; // Store group names here
//   DateTime now = DateTime.now();
//   late String formatedDate;
//   late String formatedDay;

//   @override
//   void initState() {
//     formatedDate = DateFormat('MMMM d, yyyy').format(now);
//     formatedDay = DateFormat('EEEE').format(now);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     groupController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Date and Add Group row
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Date information
//                   Row(
//                     children: [
//                       Text(
//                         formatedDay,
//                         style: reusableStyle1().copyWith(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         formatedDate,
//                         style: reusableStyle1().copyWith(
//                           color: Colors.grey[700],
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(width: 16),
//                   // Add Group button
//                   ElevatedButton(
//                     onPressed: _showGroupNameDialog,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue.shade700,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                       elevation: 2,
//                     ),
//                     child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text('Add Group'),
//                         SizedBox(width: 4),
//                         Icon(Icons.add, size: 20),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 10),
//             //show search field
//             searchField(),
//             const SizedBox(height: 10),

//             // Display groups
//             Expanded(
//               child: _buildGroupList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   //function for search field
//   Widget searchField() {
//   return TextField(
//     style: TextStyle(color: Colors.white),  // White text for contrast
//     decoration: InputDecoration(
//       filled: true,
//       fillColor: Colors.blue.shade700.withOpacity(0.8),  // Slightly transparent
//       hintText: 'Search Groups...',
//       hintStyle: reusableStyle().copyWith(
//         color: Colors.white.withOpacity(0.7),  // Lighter hint text
//       ),
//       prefixIcon: Icon(Icons.search, color: Colors.white),  // Search icon
//       suffixIcon: IconButton(  // Clear button
//         icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7)),
//         onPressed: () {
//           // Add clear functionality
//         },
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,  // Remove default border
//       ),
//       contentPadding: EdgeInsets.symmetric(
//         vertical: 14, 
//         horizontal: 16
//       ),
//       focusedBorder: OutlineInputBorder(  // Focus state
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(
//           color: Colors.white.withOpacity(0.5), 
//           width: 1
//         ),
//       ),
//     ),
//     cursorColor: Colors.white,  // White cursor
//   );
// }

//   Future<void> _showGroupNameDialog() async {
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Enter Group name'),
//         content: TextField(
//           controller: groupController,
//           decoration: InputDecoration(
//             hintText: 'Enter group name',
//             hintStyle: reusableStyle1(),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//         actions: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   groupController.clear();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.brown.shade700,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (groupController.text.trim().isNotEmpty) {
//                     setState(() {
//                       groupNames.add(groupController.text.trim());
//                       groupController.clear();
//                     });
//                     Navigator.pop(context);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue.shade700,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text('Create'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Function for editing group name
//   void _editGroup(int index) {
//     groupController.text = groupNames[index];
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Edit Group"),
//         content: TextField(
//           controller: groupController,
//           decoration: const InputDecoration(
//             hintText: "Enter new group name",
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (groupController.text.isNotEmpty) {
//                 setState(() {
//                   groupNames[index] = groupController.text;
//                 });
//                 groupController.clear();
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }

//   // Function for deleting group name
//   void _deleteGroup(int index) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Delete Group"),
//         content: const Text("Are you sure you want to delete this group?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 groupNames.removeAt(index);
//               });
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//             ),
//             child: const Text("Delete"),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGroupList() {
//     if (groupNames.isEmpty) {
//       return Center(
//         child: Text(
//           'No groups created yet',
//           style: reusableStyle1().copyWith(
//             color: Colors.grey[600],
//             fontStyle: FontStyle.italic,
//           ),
//         ),
//       );
//     }

//     return ListView.builder(
//       itemCount: groupNames.length,
//       itemBuilder: (context, index) {
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: GestureDetector(
//             onTap:(){
//               Navigator.push(context, 
//               MaterialPageRoute(builder: (BuildContext context) => GroupMembers(
//                 groupName: groupNames[index],
//                 day:formatedDate,
//                 date:formatedDay
//               )));
//             },
//             child:Card(
//   elevation: 4,
//   margin: const EdgeInsets.only(bottom: 12),
//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(12),
//     side: BorderSide(color: Colors.grey.shade200, width: 1),
//   ),
//   child: Padding(
//     padding: const EdgeInsets.all(16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 groupNames[index],
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.blue.shade800,
//                 ),
//               ),
//             ),
//             Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.edit, size: 20),
//                   color: Colors.blue.shade600,
//                   onPressed: () => _editGroup(index),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, size: 20),
//                   color: Colors.red.shade600,
//                   onPressed: () => _deleteGroup(index),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade100,
//                 shape: BoxShape.circle,
//               ),
//               child: Text(
//                 '21',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue.shade800,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: LinearProgressIndicator(
//                 value: 0.7,
//                 backgroundColor: Colors.grey.shade200,
//                 valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
//                 minHeight: 8,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   ),
// )
//           )
//         );
//       },
//     );
//   }
// }