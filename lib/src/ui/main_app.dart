import 'package:nocterm/nocterm.dart';
import 'state.dart';
import 'components/header_panel.dart';
import 'components/search_bar.dart';
import 'components/test_list.dart';
import 'components/detail_panel.dart';
import 'components/footer_panel.dart';

class MainApp extends StatefulComponent {
  const MainApp({super.key});

  @override
  State<StatefulComponent> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  AppState _appState = const AppState();

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    final tests = await loadTests();
    setState(() {
      _appState = _appState.copyWith(allTests: tests);
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _appState = _appState.copyWith(searchQuery: query, selectedIndex: 0);
    });
  }

  void _onSelectTest(int index) {
    setState(() {
      _appState = _appState.copyWith(selectedIndex: index);
    });
  }

  @override
  Component build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 1, child: HeaderPanel()),
        SizedBox(height: 1, child: SearchBar(onChanged: _onSearchChanged)),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TestListWidget(
                  tests: _appState.filteredTests,
                  selectedIndex: _appState.selectedIndex,
                  onSelectTest: _onSelectTest,
                ),
              ),
              SizedBox(
                width: 1,
                child: Container(
                  color: Color.fromRGB(40, 40, 40),
                ),
              ),
              Expanded(
                flex: 2,
                child: DetailPanel(selectedTest: _appState.selectedTest),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 1,
          child: FooterPanel(
            testCount: _appState.filteredTests.length,
            status: _appState.executionStatus,
          ),
        ),
      ],
    );
  }
}
