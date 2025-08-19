import 'package:flutter/material.dart';
import 'package:foreman/views/home/bottom_navigation.dart';
import 'package:foreman/views/home/textStyle.dart';

class Records extends StatefulWidget {
  const Records({super.key});

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  // Sample data for demonstration
  final Map<String, Map<String, dynamic>> recordsData = {
    'Tools': {
      'count': 42,
      'icon': Icons.build,
      'color': Colors.blue,
      'recent': '5 new today',
    },
    'Purchases': {
      'count': 28,
      'icon': Icons.shopping_cart,
      'color': Colors.green,
      'recent': '2 pending',
    },
    'Notes': {
      'count': 156,
      'icon': Icons.note,
      'color': Colors.amber,
      'recent': '12 updated',
    },
    'Reports': {
      'count': 17,
      'icon': Icons.bar_chart,
      'color': Colors.red,
      'recent': 'Due tomorrow',
    },
  };

  @override
  Widget build(BuildContext context) {
    // Calculate total count for summary
    int totalCount = recordsData.values.fold(0, (sum, item) => sum + (item['count'] as int));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Records', style: reusableStyle2().copyWith(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Add search functionality
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Total Items', totalCount.toString(), Icons.inventory),
                      _buildSummaryItem('Categories', recordsData.length.toString(), Icons.category),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                Text(
                  'Record Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 12),
                
                // Responsive grid that works for 4 items
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Adjust grid based on available width
                      final crossAxisCount = constraints.maxWidth > 600 ? 2 : 2;
                      final childAspectRatio = constraints.maxWidth > 600 ? 1.3 : 1.1;
                      
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: recordsData.length,
                        itemBuilder: (context, index) {
                          String key = recordsData.keys.elementAt(index);
                          return _recordCard(
                            key,
                            recordsData[key]!['icon'],
                            recordsData[key]!['color'],
                            recordsData[key]!['count'],
                            recordsData[key]!['recent'],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(currentIndex: 1),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _recordCard(String title, IconData icon, Color color, int count, String recent) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Navigate to specific record category
              print('Tapped on $title');
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 26),
                      ),
                      Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    recent,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}