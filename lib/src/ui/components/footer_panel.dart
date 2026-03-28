import 'package:nocterm/nocterm.dart';
import '../state.dart';

class FooterPanel extends StatelessComponent {
  final int testCount;
  final ExecutionStatus status;

  const FooterPanel({
    super.key,
    required this.testCount,
    required this.status,
  });

  @override
  Component build(BuildContext context) {
    return Container(
      color: Color.fromRGB(30, 30, 30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
        child: Row(
          children: [
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: '[▶ Run] ',
                  style: TextStyle(color: Color.fromRGB(0, 200, 100)),
                ),
                TextSpan(
                  text: _statusText,
                  style: TextStyle(color: _statusColor),
                ),
              ]),
            ),
            Expanded(child: SizedBox()),
            Text(
              'Found: $testCount | ↑↓: Nav | Enter: Run | q: Quit',
              style: TextStyle(color: Color.fromRGB(150, 150, 150)),
            ),
          ],
        ),
      ),
    );
  }

  String get _statusText {
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

  Color get _statusColor {
    switch (status) {
      case ExecutionStatus.idle:
        return Color.fromRGB(150, 150, 150);
      case ExecutionStatus.running:
        return Color.fromRGB(255, 200, 0);
      case ExecutionStatus.passed:
        return Color.fromRGB(0, 200, 100);
      case ExecutionStatus.failed:
        return Color.fromRGB(200, 0, 0);
      case ExecutionStatus.error:
        return Color.fromRGB(255, 100, 0);
    }
  }
}
