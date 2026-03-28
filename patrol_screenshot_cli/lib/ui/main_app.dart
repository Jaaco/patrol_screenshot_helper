import 'package:nocterm/nocterm.dart';
import '../test_file.dart';
import 'components/header_panel.dart';
import 'components/search_bar.dart';
import 'components/test_list.dart';
import 'components/detail_panel.dart';
import 'components/footer_panel.dart';
import 'state.dart';

class MainApp extends StatefulComponent {
  @override
  State<StatefulComponent> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String _searchQuery = '';
  int _selectedIndex = 0;
  TestFile? _selectedTest;
  List<TestFile> _tests = [];
  ExecutionStatus _status = ExecutionStatus.idle;

  @override
  void initState() {
    // Initialize with empty state
    super.initState();
  }

  @override
  Component build(BuildContext context) {
    final filteredTests = _tests.isEmpty ? <TestFile>[] : _tests;

    return Column(
      children: [
        SizedBox(height: 1, child: HeaderPanel()),
        SizedBox(height: 1, child: SearchBar(
          query: _searchQuery,
          onQueryChanged: (value) {
            setState(() => _searchQuery = value);
          },
        )),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: TestListWidget(
                  tests: filteredTests,
                  selectedIndex: _selectedIndex,
                  onSelectionChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _selectedTest = index < filteredTests.length ? filteredTests[index] : null;
                    });
                  },
                ),
              ),
              SizedBox(width: 1, child: Container(color: Color.fromARGB(255, 40, 40, 40))),
              Expanded(
                child: DetailPanel(selectedTest: _selectedTest),
              ),
            ],
          ),
        ),
        SizedBox(height: 1, child: FooterPanel(
          status: _status,
          tests: filteredTests,
        )),
      ],
    );
  }
}
