import 'package:nocterm/nocterm.dart';

class DetailPanel extends StatelessComponent {
  final selectedTest;

  const DetailPanel({this.selectedTest});

  @override
  Component build(BuildContext context) {

    if (selectedTest == null) {
      return Container(
        color: Color.fromARGB(255, 20, 20, 20),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: RichText(
            text: TextSpan(
              text: 'Select a test to view details',
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
                    color: Color.fromARGB(255, 100, 200, 100),
                    fontWeight: FontWeight.bold,
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
                        color: Color.fromARGB(255, 100, 150, 255),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: selectedTest.path,
                      style: TextStyle(
                        color: Color.fromARGB(255, 200, 200, 200),
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
                        color: Color.fromARGB(255, 100, 150, 255),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: selectedTest.description.isEmpty
                          ? '(none)'
                          : selectedTest.description,
                      style: TextStyle(
                        color: Color.fromARGB(255, 200, 200, 200),
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
                        color: Color.fromARGB(255, 100, 150, 255),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: selectedTest.lastModified.toString().split('.')[0],
                      style: TextStyle(
                        color: Color.fromARGB(255, 200, 200, 200),
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
                        color: Color.fromARGB(255, 100, 150, 255),
                        fontWeight: FontWeight.bold,
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
                          color: Color.fromARGB(255, 200, 150, 100),
                        ),
                      ),
                      TextSpan(
                        text: tc.name,
                        style: TextStyle(
                          color: Color.fromARGB(255, 180, 180, 180),
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
