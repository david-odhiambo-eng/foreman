import 'package:foreman/viewModel/data_structure.dart';
import 'package:math_expressions/math_expressions.dart';


class CalculatorOperations {
  static String myInput = '';
  static bool isDotUsed = false;
  static bool isSymbolUsed = false;

  static String calculator(String button, Function setState) {
    String evalResult = ''; // will hold evaluated answer

    setState(() {
      switch (button) {
        // Numbers
        case String digit when DataStructure.numbersButtons.contains(button):
          myInput += digit;
          isSymbolUsed = false;
          break;

        // Clear all
        case 'AC':
          myInput = '';
          evalResult = '';
          break;

        // Delete last char
        case 'Del':
          if (myInput.isNotEmpty) {
            myInput = myInput.substring(0, myInput.length - 1);
          }
          break;

        // Symbols (+, -, ×, ÷, =)
        case String operation when DataStructure.symbolButtons.contains(button):
          if (operation == '=') {
            try {
              // Replace × and ÷ with * and / for parsing
              String expression = myInput.replaceAll('×', '*').replaceAll('÷', '/');
              Parser p = Parser();
              Expression exp = p.parse(expression);
              ContextModel cm = ContextModel();
              double eval = exp.evaluate(EvaluationType.REAL, cm);
              evalResult = eval.toString();
            } catch (e) {
              evalResult = 'Error';
            }
          } else if (!isSymbolUsed && myInput.isNotEmpty) {
            myInput += operation;
            isSymbolUsed = true;
            isDotUsed = false;
          }
          break;

        // Decimal point
        case '.':
          if (!isDotUsed) {
            if (myInput.isEmpty || isSymbolUsed) {
              myInput += '0.';
            } else {
              myInput += '.';
            }
            isDotUsed = true;
          }
          break;
      }
    });

    return evalResult; // return to widget
  }
}
