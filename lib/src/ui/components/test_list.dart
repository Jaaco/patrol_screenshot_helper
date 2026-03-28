import 'package:nocterm/nocterm.dart';
import 'package:riverpod/riverpod.dart';
import '../state.dart';
import '../../models/test_file.dart';

class TestListWidget extends StatefulComponent {
  @override
  State<StatefulComponent> createState() => _TestListWidgetState();
}

class _TestListWidgetState extends State<TestListWidget> {
  @override
  Widget build(BuildContext context) {
    final tests = context.watch(filteredTestsProvider);
    final selectedIndex = context.watch(selectedTestIndexProvider);

    if (tests.isEmpty) {
      return Container(
        color: Color.fromARGB(255, 20, 20, 20),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: RichText(
            text: TextSpan(
              text: 'No tests found',
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(1),
              child: RichText(
                text: TextSpan(
                  text: 'Found Tests (${tests.length})',
                  style: TextStyle(
                    foreground: Paint()..color = Color.fromARGB(255, 100, 200, 100),
                    bold: true,
                  ),
                ),
              ),
            ),
            ...tests.asMap().entries.map((entry) {
              final index = entry.key;
              final test = entry.value;
              final isSelected = index == selectedIndex;

              return GestureDetector(
                onTap: () {
                  context.read(selectedTestIndexProvider.notifier).state = index;
                },
                child: Container(
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
                              foreground: Paint()
                                  ..color = Color.fromARGB(255, 0, 200, 100),
                            ),
                          ),
                          TextSpan(
                            text: test.displayName,
                            style: TextStyle(
                              foreground: Paint()
                                  ..color = isSelected
                                      ? Color.fromARGB(255, 255, 255, 255)
                                      : Color.fromARGB(255, 200, 200, 200),
                            ),
                          ),
                        ],
                      ),
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
