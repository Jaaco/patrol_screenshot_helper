import 'package:nocterm/nocterm.dart';
import '../../models/test_file.dart';

class TestListWidget extends StatelessComponent {
  final List<TestFile> tests;
  final int selectedIndex;
  final void Function(int) onSelectTest;

  const TestListWidget({
    super.key,
    required this.tests,
    required this.selectedIndex,
    required this.onSelectTest,
  });

  @override
  Component build(BuildContext context) {
    if (tests.isEmpty) {
      return Container(
        color: Color.fromRGB(20, 20, 20),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Text(
            'No tests found',
            style: TextStyle(color: Color.fromRGB(150, 150, 150)),
          ),
        ),
      );
    }

    return Container(
      color: Color.fromRGB(20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
              child: Text(
                'Tests (${tests.length})',
                style: TextStyle(
                  color: Color.fromRGB(100, 200, 100),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...tests.asMap().entries.map((entry) {
              final index = entry.key;
              final test = entry.value;
              final isSelected = index == selectedIndex;

              return GestureDetector(
                onTap: () => onSelectTest(index),
                child: Container(
                  color: isSelected
                      ? Color.fromRGB(60, 100, 60)
                      : Color.fromRGB(30, 30, 30),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: isSelected ? '> ' : '  ',
                            style: TextStyle(
                                color: Color.fromRGB(0, 200, 100)),
                          ),
                          TextSpan(
                            text: test.displayName,
                            style: TextStyle(
                              color: isSelected
                                  ? Color.fromRGB(255, 255, 255)
                                  : Color.fromRGB(200, 200, 200),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
