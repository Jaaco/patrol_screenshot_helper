import 'package:nocterm/nocterm.dart';
import '../../models/test_file.dart';

class DetailPanel extends StatelessComponent {
  final TestFile? selectedTest;

  const DetailPanel({super.key, required this.selectedTest});

  @override
  Component build(BuildContext context) {
    if (selectedTest == null) {
      return Container(
        color: Color.fromRGB(20, 20, 20),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Text(
            'Select a test to view details',
            style: TextStyle(color: Color.fromRGB(150, 150, 150)),
          ),
        ),
      );
    }

    final test = selectedTest!;
    return Container(
      color: Color.fromRGB(20, 20, 20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Details',
                style: TextStyle(
                  color: Color.fromRGB(100, 200, 100),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 1),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Path: ',
                    style: TextStyle(
                      color: Color.fromRGB(100, 150, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: test.path,
                    style: TextStyle(color: Color.fromRGB(200, 200, 200)),
                  ),
                ]),
              ),
              const SizedBox(height: 1),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Description: ',
                    style: TextStyle(
                      color: Color.fromRGB(100, 150, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: test.description.isEmpty ? '(none)' : test.description,
                    style: TextStyle(color: Color.fromRGB(200, 200, 200)),
                  ),
                ]),
              ),
              const SizedBox(height: 1),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Test Cases: ${test.testCases.length}',
                    style: TextStyle(
                      color: Color.fromRGB(100, 150, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
              ),
              ...test.testCases.map((tc) => RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '  • ',
                        style: TextStyle(color: Color.fromRGB(200, 150, 100)),
                      ),
                      TextSpan(
                        text: tc.name,
                        style: TextStyle(color: Color.fromRGB(180, 180, 180)),
                      ),
                    ]),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
