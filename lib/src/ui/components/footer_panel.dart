import 'package:nocterm/nocterm.dart';
import '../state.dart';

class FooterPanel extends StatelessComponent {
  final ExecutionStatus status;
  final List tests;

  const FooterPanel({
    required this.status,
    required this.tests,
  });

  @override
  Component build(BuildContext context) {

    final statusText = _statusText(status);
    final statusColor = _statusColor(status);

    return Container(
      color: Color.fromARGB(255, 30, 30, 30),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '[▶ Run] ',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 200, 100),
                    ),
                  ),
                  TextSpan(
                    text: '[Cancel] ',
                    style: TextStyle(
                      color: Color.fromARGB(255, 200, 0, 0),
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: statusText,
                style: TextStyle(color: statusColor),
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'Found: ${tests.length} | ↑↓: Nav | Enter: Run | q: Quit',
                style: TextStyle(
                  color: Color.fromARGB(255, 150, 150, 150),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusText(ExecutionStatus status) {
    switch (status) {
      case ExecutionStatus.idle:
        return 'Idle';
      case ExecutionStatus.running:
        return 'Running...';
      case ExecutionStatus.passed:
        return '✓ Passed';
      case ExecutionStatus.failed:
        return '✗ Failed';
      case ExecutionStatus.error:
        return '⚠ Error';
    }
  }

  Color _statusColor(ExecutionStatus status) {
    switch (status) {
      case ExecutionStatus.idle:
        return Color.fromARGB(255, 150, 150, 150);
      case ExecutionStatus.running:
        return Color.fromARGB(255, 255, 200, 0);
      case ExecutionStatus.passed:
        return Color.fromARGB(255, 0, 200, 100);
      case ExecutionStatus.failed:
        return Color.fromARGB(255, 200, 0, 0);
      case ExecutionStatus.error:
        return Color.fromARGB(255, 255, 100, 0);
    }
  }
}
