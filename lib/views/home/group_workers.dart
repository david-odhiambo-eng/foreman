import 'package:flutter/material.dart';
import 'package:foreman/models/worker_provider.dart';
import 'package:foreman/viewModel/days.dart';
import 'package:foreman/views/home/textStyle.dart';
import'package:provider/provider.dart';

class GroupMembers extends StatefulWidget {
  const GroupMembers({super.key, required this.groupName, required this.date, required this.day});
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
  List<Map<String, dynamic>> filteredWorkers = [];
  bool isSearching = false;
  
  final List<String> _payment = [];

  @override
  void dispose() {
    workereController.dispose();
    deductionsController.dispose();
    paymentController.dispose();
    searchController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerProvider>(builder: (context, value, child){
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Center(
                            child: Text(
                              _payment.isNotEmpty ? 'Ksh ${_payment.last}' : 'Ksh 0',
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
                      borderRadius: BorderRadiusGeometry.circular(12)
                    ),
                    child: SizedBox(
                      height: 40,
                      width: 90,
                      child:employees.isNotEmpty ? Center(
                        child: Text(employees.length.toString(), style: reusableStyle2(),)) 
                        : Center(child:Text('0', style: reusableStyle2(),))
                    )
                  ),
                  const SizedBox(width: 0),
                  Text('${widget.groupName} worker(s)', style: reusableStyle1(),),
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
    );
    });
    
  }
  //helper function for determining if a checkbox is clickable
  bool _isDayEnabled(String day, String currentDay) {
  // Get the index of the current day and the day in question
  final daysOfWeek = DaysOfTheWeek.days;
  final currentDayIndex = daysOfWeek.indexOf(currentDay);
  final dayIndex = daysOfWeek.indexOf(day);
  
  // Enable only if it's the current day or a future day
  return dayIndex >= currentDayIndex;
}
  // date range function
String getCurrentWeekRange() {
  DateTime now = DateTime.now();
  
  // Find the most recent Monday
  DateTime monday = now.subtract(Duration(days: now.weekday - 1));
  
  // Find the coming Sunday
  DateTime sunday = monday.add(const Duration(days: 6));
  
  // Format the dates
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  return '${formatDate(monday)} - ${formatDate(sunday)}';
}

  void _calculateEarnings(int index) {
    int dailyPay = _payment.isNotEmpty ? int.tryParse(_payment.last) ?? 0 : 0;
    int selectedDaysCount = workers[index]['selectedDays'].length;
    int earnings = dailyPay * selectedDaysCount;
    
    int deductions = int.tryParse(workers[index]['deductions']) ?? 0;
    int total = earnings - deductions;
    
    setState(() {
      workers[index]['earnings'] = earnings.toString();
      workers[index]['total'] = total.toString();
    });
  }

  void _filterWorkers(String query) {
    setState(() {
      filteredWorkers = workers.where((worker) {
        return worker['name'].toLowerCase().contains(query.toLowerCase());
      }).toList();
      isSearching = query.isNotEmpty;
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
              setState(() {
                workers[index]['deductions'] = deductionsController.text.trim();
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
                setState(() {
                  _payment.add(paymentController.text.trim());
                  for (int i = 0; i < workers.length; i++) {
                    _calculateEarnings(i);
                  }
                  paymentController.clear();
                  Navigator.pop(context);
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

  Widget _searchField() {
    return TextField(
      controller: searchController,
      onChanged: _filterWorkers,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue.shade700.withOpacity(0.85),
        hintText: 'Search Worker...',
        hintStyle: reusableStyle().copyWith(color: Colors.white.withOpacity(0.7)),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7)),
          onPressed: () {
            setState(() {
              searchController.clear();
              isSearching = false;
              filteredWorkers.clear();
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide.none
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      cursorColor: Colors.white,
    );
  }

  Widget _createWorkers() {
    final workersToDisplay = isSearching ? filteredWorkers : workers;
    
    if (workersToDisplay.isEmpty) {
      return Center(
        child: Text(
          isSearching ? 'No workers found' : 'No Worker Added under this Group',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: workersToDisplay.length,
      itemBuilder: (context, index) {
        final worker = workersToDisplay[index];
        final originalIndex = workers.indexWhere((w) => w['name'] == worker['name']);
        
        return Card(
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
                    Text(worker['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(worker['weekRange'] ?? 'Week Range', 
                    style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  children: DaysOfTheWeek.days.map((day) {
                    bool isSelected = worker['selectedDays'].contains(day);
                    bool isEnabled = _isDayEnabled(day, widget.date);
                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          Card(
                            elevation: 1,
                            color: isEnabled ? Colors.white : Colors.grey[20],
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(day, 
                              style: TextStyle(
                                fontSize: 12,
                                color: isEnabled ? Colors.green : Colors.black
                                )),
                            ),
                          ),
                          Checkbox(
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            value: isSelected,
                            onChanged: isEnabled ?(bool? newValue) {
                              setState(() {
                                if (newValue == true) {
                                  workers[originalIndex]['selectedDays'].add(day);
                                } else {
                                  workers[originalIndex]['selectedDays'].remove(day);
                                }
                                _calculateEarnings(originalIndex);
                              });
                            } : null,
                          )
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
                          borderRadius: BorderRadius.circular(12)
                        )
                      ),
                      child: Text('Deduct'),
                    ),
                    IconButton(
                      onPressed: () => _deleteWorker(originalIndex),
                      icon: const Icon(Icons.delete, color: Colors.red)),
                  ],
                )
              ],
            ),
          ),
        );
      },
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Future<void> _showWorkerDialog() async {
    final weekRange = getCurrentWeekRange();
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
              foregroundColor: Colors.white),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (workereController.text.trim().isNotEmpty) {
                setState(() {
                  workers.add({
                    'name': workereController.text.trim(),
                    'deductions': '0',
                    'selectedDays': [],
                    'earnings': '0',
                    'total': '0',
                    'weekRange': weekRange,
                  });
                  workereController.clear();
                  Navigator.pop(context);
                });
              }
              employees.add(
                workereController.text.trim(),
                );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white),
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
              setState(() {
                workers.removeAt(index);
                Navigator.pop(context);
                employees.removeAt(index);
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
}

