import 'dart:io';

import 'package:nocterm/nocterm.dart';

import '../test_discovery.dart';
import '../models/test_file.dart';

class MainApp extends StatefulComponent {
  const MainApp({super.key});

  @override
  State<StatefulComponent> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<TestFile> _files = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final files = await TestDiscoveryEngine.scan('./integration-test/');
    setState(() {
      _files = files;
      _selectedIndex = 0;
    });
  }

  bool _onKey(KeyboardEvent event) {
    if (event.logicalKey == LogicalKey.arrowUp) {
      setState(() {
        if (_selectedIndex > 0) _selectedIndex--;
      });
      return true;
    } else if (event.logicalKey == LogicalKey.arrowDown) {
      setState(() {
        if (_selectedIndex < _files.length - 1) _selectedIndex++;
      });
      return true;
    } else if (event.logicalKey == LogicalKey.enter) {
      exit(0);
    }
    return false;
  }

  @override
  Component build(BuildContext context) {
    return Focusable(
      focused: true,
      onKeyEvent: _onKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _files.isEmpty
            ? [Text('No test files found in ./integration-test/')]
            : _files.asMap().entries.map((entry) {
                final i = entry.key;
                final file = entry.value;
                final selected = i == _selectedIndex;
                return Text(
                  '${selected ? '> ' : '  '}${file.displayName}',
                  style: TextStyle(
                    color: selected
                        ? Color.fromRGB(0, 200, 100)
                        : Color.fromRGB(200, 200, 200),
                  ),
                );
              }).toList(),
      ),
    );
  }
}
