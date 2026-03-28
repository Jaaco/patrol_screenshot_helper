import 'package:nocterm/nocterm.dart';
import 'package:riverpod/riverpod.dart';
import '../state.dart';

class DetailPanel extends StatelessComponent {
  @override
  Widget build(BuildContext context) {
    final selectedTest = context.watch(selectedTestProvider);

    if (selectedTest == null) {
      return Container(
        color: Color.fromARGB(255, 20, 20, 20),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: RichText(
            text: TextSpan(
              text: 'Select a test to view details',
              style: TextStyle(
                foreground: Paint()..color = Color.fromARGB(255, 150, 150, 150),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: Color.fromARGB(255, 20, 20, 20),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Details',
                  style: TextStyle(
                    foreground: Paint()..color = Color.fromARGB(255, 100, 200, 100),
                    bold: true,
                  ),
                ),
              ),
              SizedBox(height: 1),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Path: ',
                      style: TextStyle(
                        foreground: Paint()..color = Color.fromARGB(255, 100, 150, 255),
                        bold: true,
                      ),
                    ),
                    TextSpan(
                      text: selectedTest.path,
                      style: TextStyle(
                        foreground: Paint()..color = Color.fromARGB(255, 200, 200, 200),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Description: ',
                      style: TextStyle(
                        foreground: Paint()..color = Color.fromARGB(255, 100, 150, 255),
                        bold: true,
                      ),
                    ),
                    TextSpan(
                      text: selectedTest.description.isEmpty
                          ? '(none)'
                          : selectedTest.description,
                      style: TextStyle(
                        foreground: Paint()..color = Color.fromARGB(255, 200, 200, 200),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Modified: ',
                      style: TextStyle(
                        foreground: Paint()..color = Color.fromARGB(255, 100, 150, 255),
                        bold: true,
                      ),
                    ),
                    TextSpan(
                      text: selectedTest.lastModified.toString().split('.')[0],
                      style: TextStyle(
                        foreground: Paint()..color = Color.fromARGB(255, 200, 200, 200),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Test Cases: ${selectedTest.testCases.length}',
                      style: TextStyle(
                        foreground: Paint()..color = Color.fromARGB(255, 100, 150, 255),
                        bold: true,
                      ),
                    ),
                  ],
                ),
              ),
              ...selectedTest.testCases.map((tc) {
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '  • ',
                        style: TextStyle(
                          foreground: Paint()..color = Color.fromARGB(255, 200, 150, 100),
                        ),
                      ),
                      TextSpan(
                        text: tc.name,
                        style: TextStyle(
                          foreground: Paint()..color = Color.fromARGB(255, 180, 180, 180),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
