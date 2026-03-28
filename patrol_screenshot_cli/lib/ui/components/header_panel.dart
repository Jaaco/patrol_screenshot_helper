import 'package:nocterm/nocterm.dart';
import 'package:nocterm/src/components/rich_text.dart';

class HeaderPanel extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Container(
      color: Color.fromRGB(30, 30, 30),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '▶ ',
                style: TextStyle(
                  color: Color.fromRGB(0, 200, 100),
                ),
              ),
              TextSpan(
                text: 'Patrol Screenshot Helper - Test Runner',
                style: TextStyle(
                  color: Color.fromRGB(255, 255, 255),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
