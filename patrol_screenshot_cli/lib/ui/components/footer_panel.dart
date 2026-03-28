import 'package:nocterm/nocterm.dart';
import 'package:riverpod/riverpod.dart';
import '../state.dart';

class FooterPanel extends StatelessComponent {
  @override
  Widget build(BuildContext context) {
    final status = context.watch(executionStatusProvider);
    final tests = context.watch(filteredTestsProvider);

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
                      foreground: Paint()..color = Color.fromARGB(255, 0, 200, 100),
                    ),
                  ),
                  TextSpan(
                    text: '[Cancel] ',
                    style: TextStyle(
                      foreground: Paint()..color = Color.fromARGB(255, 200, 0, 0),
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: statusText,
                style: TextStyle(foreground: Paint()..color = statusColor),
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'Found: ${tests.length} | ↑↓: Nav | Enter: Run | q: Quit',
                style: TextStyle(
                  foreground: Paint()..color = Color.fromARGB(255, 150, 150, 150),
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
