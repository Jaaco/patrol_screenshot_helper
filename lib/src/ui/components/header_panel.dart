import 'package:nocterm/nocterm.dart';

class HeaderPanel extends StatelessComponent {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 30, 30, 30),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '▶ ',
                style: TextStyle(
                  foreground: Paint()..color = Color.fromARGB(255, 0, 200, 100),
                ),
              ),
              TextSpan(
                text: 'Patrol Screenshot Helper - Test Runner',
                style: TextStyle(
                  foreground: Paint()..color = Color.fromARGB(255, 255, 255, 255),
                  bold: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
