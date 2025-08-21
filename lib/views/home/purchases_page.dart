import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foreman/models/providers/purchases_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:foreman/views/home/bottom_navigation.dart';
import 'package:foreman/views/home/textStyle.dart';


class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'Tools & Equipment',
    'Construction Materials',
    'Safety Gear',
    'Electrical Supplies',
    'Plumbing Supplies',
    'Office Supplies',
    'Vehicle Maintenance',
    'Fuel',
    'Labor Costs',
    'Other'
  ];
  
  final List<String> _paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Credit Card',
    'Debit Card',
    'Mobile Money',
    'Check'
  ];
  
  final List<String> _statusOptions = [
    'Pending',
    'Completed',
    'Delivered',
    'Cancelled',
    'Returned'
  ];

  String _searchQuery = "";
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchasesProvider = Provider.of<PurchasesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Purchase Records',
          style: reusableStyle2().copyWith(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddPurchaseDialog(context),
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
              children: [
                // Search and Filter Row
                _buildSearchFilterRow(),
                const SizedBox(height: 16),
                
                // Summary Cards
                _buildSummaryCards(purchasesProvider),
                const SizedBox(height: 16),
                
                // Purchases List
                Expanded(
                  child: _buildPurchasesList(purchasesProvider),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPurchaseDialog(context),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchFilterRow() {
    return Row(
      children: [
        // Search Field
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Search purchases...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Filter Dropdown
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                items: ['All', ..._statusOptions].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFilter = newValue!;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(PurchasesProvider provider) {
    return Container(
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
          _buildSummaryItem('Total Purchases', provider.totalPurchasesCount.toString(), Icons.shopping_cart),
          _buildSummaryItem('Total Spent', 'Ksh${provider.totalSpent.toStringAsFixed(2)}', FontAwesomeIcons.coins),
          _buildSummaryItem('Categories', provider.uniqueCategories.length.toString(), Icons.category),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
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

  Widget _buildPurchasesList(PurchasesProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    var filteredPurchases = _selectedFilter == 'All' 
        ? provider.purchases 
        : provider.getPurchasesByStatus(_selectedFilter);
    
    if (_searchQuery.isNotEmpty) {
      filteredPurchases = provider.searchPurchases(_searchQuery);
    }

    if (filteredPurchases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No purchases yet' : 'No purchases found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty 
                ? 'Tap + to add your first purchase'
                : 'Try a different search term',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredPurchases.length,
      itemBuilder: (context, index) {
        final purchase = filteredPurchases[index];
        return _buildPurchaseCard(purchase);
      },
    );
  }

  Widget _buildPurchaseCard(Map<String, dynamic> purchase) {
    final itemName = purchase['itemName'] ?? 'Unnamed Item';
    final quantity = purchase['quantity'] ?? 0;
    final unitPrice = purchase['unitPrice'] ?? 0.0;
    final totalPrice = purchase['totalPrice'] ?? 0.0;
    final supplier = purchase['supplier'] ?? 'Unknown Supplier';
    final category = purchase['category'] ?? 'Uncategorized';
    final status = purchase['status'] ?? 'Pending';
    final purchaseDate = purchase['purchaseDate'] != null 
        ? (purchase['purchaseDate'] as Timestamp).toDate() 
        : DateTime.now();

    final statusColor = _getStatusColor(status);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
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
            onTap: () => _showViewPurchaseDialog(context, purchase),
            onLongPress: () => _showDeleteDialog(context, purchase),
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
                          itemName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Supplier: $supplier',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category: $category',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${quantity}x @ Ksh${unitPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Total: Ksh${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Purchased: ${DateFormat('MMM dd, yyyy').format(purchaseDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'returned':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddPurchaseDialog(BuildContext context) {
    _showPurchaseDialog(context, null);
  }

  void _showViewPurchaseDialog(BuildContext context, Map<String, dynamic> purchase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Item:', purchase['itemName'] ?? ''),
              _buildDetailRow('Supplier:', purchase['supplier'] ?? ''),
              _buildDetailRow('Category:', purchase['category'] ?? ''),
              _buildDetailRow('Quantity:', purchase['quantity']?.toString() ?? ''),
              _buildDetailRow('Unit Price:', 'Ksh${purchase['unitPrice']?.toStringAsFixed(2) ?? '0.00'}'),
              _buildDetailRow('Total Price:', 'Ksh${purchase['totalPrice']?.toStringAsFixed(2) ?? '0.00'}'),
              _buildDetailRow('Payment Method:', purchase['paymentMethod'] ?? ''),
              _buildDetailRow('Status:', purchase['status'] ?? ''),
              _buildDetailRow('Notes:', purchase['notes'] ?? 'None'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, Map<String, dynamic>? purchase) {
    final itemNameController = TextEditingController(text: purchase?['itemName'] ?? '');
    final supplierController = TextEditingController(text: purchase?['supplier'] ?? '');
    final quantityController = TextEditingController(text: purchase?['quantity']?.toString() ?? '');
    final unitPriceController = TextEditingController(text: purchase?['unitPrice']?.toStringAsFixed(2) ?? '');
    final notesController = TextEditingController(text: purchase?['notes'] ?? '');
    
    String selectedCategory = purchase?['category'] ?? _categories.first;
    String selectedPaymentMethod = purchase?['paymentMethod'] ?? _paymentMethods.first;
    String selectedStatus = purchase?['status'] ?? _statusOptions.first;
    DateTime selectedDate = purchase?['purchaseDate'] != null 
        ? (purchase?['purchaseDate'] as Timestamp).toDate()
        : DateTime.now();

    final purchasesProvider = Provider.of<PurchasesProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(purchase == null ? 'Add New Purchase' : 'Edit Purchase'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: itemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: supplierController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity*',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: unitPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Unit Price*',
                            border: OutlineInputBorder(),
                            prefixText: '\$',
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedPaymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                    items: _paymentMethods.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPaymentMethod = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: _statusOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStatus = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text('Purchase Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}'),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (itemNameController.text.trim().isNotEmpty &&
                      supplierController.text.trim().isNotEmpty &&
                      quantityController.text.trim().isNotEmpty &&
                      unitPriceController.text.trim().isNotEmpty) {
                    try {
                      final quantity = int.tryParse(quantityController.text) ?? 0;
                      final unitPrice = double.tryParse(unitPriceController.text) ?? 0.0;
                      final totalPrice = quantity * unitPrice;

                      final purchaseData = {
                        'itemName': itemNameController.text.trim(),
                        'supplier': supplierController.text.trim(),
                        'category': selectedCategory,
                        'quantity': quantity,
                        'unitPrice': unitPrice,
                        'totalPrice': totalPrice,
                        'paymentMethod': selectedPaymentMethod,
                        'status': selectedStatus,
                        'purchaseDate': Timestamp.fromDate(selectedDate),
                        'notes': notesController.text.trim(),
                      };

                      if (purchase == null) {
                        await purchasesProvider.addPurchase(purchaseData);
                      } else {
                        await purchasesProvider.updatePurchase(purchase['id'], purchaseData);
                      }
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: Text(purchase == null ? 'Add' : 'Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> purchase) {
    final purchasesProvider = Provider.of<PurchasesProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchase'),
        content: Text('Are you sure you want to delete "${purchase['itemName']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await purchasesProvider.deletePurchase(purchase['id']);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Purchase deleted')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting purchase: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}