import 'package:flutter/material.dart';
import 'package:foreman/views/home/textStyle.dart';

class CreatedJobs extends StatefulWidget {
  const CreatedJobs({super.key, required this.worker});
  final String worker;

  @override
  State<CreatedJobs> createState() => _DetailsState();
}

class _DetailsState extends State<CreatedJobs> {
  String? selectedWorkDays;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('${widget.worker} job group'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Provide Job Details',
                        style: reusableStyle1().copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      

                      _buildTextField('Number of workers needed', 'Workers Needed'),
                      const SizedBox(height: 14),

                      _buildTextField('Amount per worker', 'Pay per Worker'),
                      const SizedBox(height: 14),

                      _showWorkingHours(),
                      const SizedBox(height: 20),
                      _buildButton('Location Details')
                    ],
                  ),
                ),
              ),

              // Button stays fixed at bottom
              _buildButton('Post Job')
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text){
    return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              );
  }

  Widget _showWorkingHours() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Work Days',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            DropdownButton<String>(
              value: selectedWorkDays,
              hint: const Text("Select"),
              underline: const SizedBox(),
              items: ["1 Day", "2 Days", "3 Days", 'Undetermined', "Full Week"]
                  .map((day) => DropdownMenuItem(
                        value: day,
                        child: Text(day),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedWorkDays = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: reusableStyle2(),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
