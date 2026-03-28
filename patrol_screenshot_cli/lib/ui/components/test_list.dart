import 'package:nocterm/nocterm.dart';
import '../../test_file.dart';

class TestListWidget extends StatelessComponent {
  final List<TestFile> tests;
  final int selectedIndex;
  final Function(int) onSelectionChanged;

  const TestListWidget({
    required this.tests,
    required this.selectedIndex,
    required this.onSelectionChanged,
  });

  @override
  Component build(BuildContext context) {

    if (tests.isEmpty) {
      return Container(
        color: Color.fromARGB(255, 20, 20, 20),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: RichText(
            text: TextSpan(
              text: 'No tests found',
              style: TextStyle(
                color: Color.fromARGB(255, 150, 150, 150),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: Color.fromARGB(255, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(1),
              child: RichText(
                text: TextSpan(
                  text: 'Found Tests (${tests.length})',
                  style: TextStyle(
                    color: Color.fromARGB(255, 100, 200, 100),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ...tests.asMap().entries.map((entry) {
              final index = entry.key;
              final test = entry.value;
              final isSelected = index == selectedIndex;

              return Container(
                color: isSelected
                    ? Color.fromARGB(255, 60, 100, 60)
                    : Color.fromARGB(255, 30, 30, 30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: isSelected ? '> ' : '  ',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 200, 100),
                          ),
                        ),
                        TextSpan(
                          text: test.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? Color.fromARGB(255, 255, 255, 255)
                                : Color.fromARGB(255, 200, 200, 200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
