import 'package:flutter/material.dart';
import 'package:foreman/viewModel/data_structure.dart';
import 'package:foreman/views/home/bottom_navigation.dart';
import 'package:foreman/models/calculator_operations.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String result = "0";

  @override
  Widget build(BuildContext context) {
    // Correct button arrangement from DataStructure
    final allButtons = DataStructure.buttonsLayout;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display section
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Input display
                  Text(
                    CalculatorOperations.myInput.isEmpty
                        ? '0'
                        : CalculatorOperations.myInput,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Result display
                  Text(
                    result,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Buttons section fills rest of screen
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4 buttons per row
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: allButtons.length,
                  itemBuilder: (context, index) {
                    final btn = allButtons[index];
                    final bgColor = DataStructure.specialButtons.contains(btn)
                        ? Colors.orangeAccent
                        : DataStructure.symbolButtons.contains(btn)
                            ? Colors.blue[100]!
                            : Colors.grey[200]!;

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        String newResult =
                            CalculatorOperations.calculator(btn, setState);
                        if (newResult.isNotEmpty) {
                          setState(() {
                            result = newResult;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            btn,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 3),
    );
  }
}
