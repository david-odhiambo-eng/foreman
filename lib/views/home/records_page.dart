import 'package:flutter/material.dart';
import 'package:foreman/models/providers/notes_provider.dart';
import 'package:foreman/models/providers/purchases_provider.dart';
import 'package:foreman/models/providers/totals_tools_provider.dart';
import 'package:foreman/views/home/notes_page.dart';
import 'package:foreman/views/home/purchases_page.dart';

import 'package:provider/provider.dart';
import 'package:foreman/views/home/bottom_navigation.dart';
import 'package:foreman/views/home/textStyle.dart';
import 'package:foreman/views/home/tools_page.dart';


class Records extends StatefulWidget {
  const Records({super.key});

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  @override
  void initState() {
    super.initState();
    // Optionally fetch data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final toolsProvider = Provider.of<ToolsProvider>(context, listen: false);
      toolsProvider.fetchTotalBorrowed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final toolsProvider = Provider.of<ToolsProvider>(context);
    final notesProvider = Provider.of<NotesProvider>(context);
    final totalPurchases = Provider.of<PurchasesProvider>(context).totalPurchasesCount;
        
    
    
    final notesCount = notesProvider.totalNotesCount;

    
    final Map<String, Map<String, dynamic>> recordsData = {
      'Tools': {
        'count': toolsProvider.totalBorrowed, 
        'icon': Icons.build,
        'color': Colors.blue,
        'recent': _getRecentToolsText(toolsProvider.totalBorrowed),
      },
      'Purchases': {
        'count': totalPurchases,
        'icon': Icons.shopping_cart,
        'color': Colors.green,
        'recent': '',
      },
      'Notes': {
        'count': notesCount,
        'icon': Icons.note,
        'color': Colors.amber,
        'recent': '',
      },
      'Reports': {
        'count': 0,
        'icon': Icons.bar_chart,
        'color': Colors.red,
        'recent': '',
      },
    };

    // Calculate total count for summary
    int totalCount = recordsData.values.fold(
      0,
      (sum, item) => sum + (item['count'] as int),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Records',
          style: reusableStyle2().copyWith(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Add search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              toolsProvider.fetchTotalBorrowed();
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        'Total Items',
                        totalCount.toString(),
                        Icons.inventory,
                      ),
                      _buildSummaryItem(
                        'Categories',
                        recordsData.length.toString(),
                        Icons.category,
                      ),
                      _buildSummaryItem(
                        'Tools Borrowed',
                        toolsProvider.totalBorrowed.toString(),
                        Icons.build,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Record Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),

                // Responsive grid that works for 4 items
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Adjust grid based on available width
                      final crossAxisCount = constraints.maxWidth > 600 ? 2 : 2;
                      final childAspectRatio =
                          constraints.maxWidth > 600 ? 1.3 : 1.1;

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
                            () {
                              if (key == "Tools") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Tools(),
                                  ),
                                );
                              } else if (key == "Purchases") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PurchasesPage(),
                                  ),
                                );
                              } else if (key == "Notes") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NotesPage(),
                                  ),
                                );
                              } else if (key == "Reports") {
                                // navigation
                              }
                            },
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
      bottomNavigationBar: const BottomBar(currentIndex: 1),
    );
  }

  String _getRecentToolsText(int totalBorrowed) {
    if (totalBorrowed == 0) return 'No tools borrowed';
    if (totalBorrowed == 1) return '1 tool currently borrowed';
    return '$totalBorrowed tools currently borrowed';
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _recordCard(
    String title,
    IconData icon,
    Color color,
    int count,
    String recent,
    VoidCallback onTap,
  ) {
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
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 26),
                      ),
                      Consumer<ToolsProvider>(
                        builder: (context, toolsProvider, child) {
                          // Only update the Tools card count in real-time
                          if (title == "Tools") {
                            return Text(
                              toolsProvider.totalBorrowed.toString(),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            );
                          }
                          return Text(
                            count.toString(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Consumer<ToolsProvider>(
                    builder: (context, toolsProvider, child) {
                      // Only update the Tools card recent text in real-time
                      if (title == "Tools") {
                        return Text(
                          _getRecentToolsText(toolsProvider!.totalBorrowed),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                      return Text(
                        recent,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
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