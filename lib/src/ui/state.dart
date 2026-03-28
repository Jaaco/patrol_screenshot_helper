import '../models/test_file.dart';
import '../test_discovery.dart';

enum ExecutionStatus { idle, running, passed, failed, error }

class AppState {
  final List<TestFile> allTests;
  final String searchQuery;
  final int selectedIndex;
  final ExecutionStatus executionStatus;

  const AppState({
    this.allTests = const [],
    this.searchQuery = '',
    this.selectedIndex = 0,
    this.executionStatus = ExecutionStatus.idle,
  });

  List<TestFile> get filteredTests {
    if (searchQuery.isEmpty) return allTests;
    final lower = searchQuery.toLowerCase();
    return allTests
        .where((t) =>
            t.name.toLowerCase().contains(lower) ||
            t.path.toLowerCase().contains(lower) ||
            t.description.toLowerCase().contains(lower))
        .toList();
  }

  TestFile? get selectedTest {
    final tests = filteredTests;
    if (tests.isEmpty || selectedIndex < 0 || selectedIndex >= tests.length) {
      return null;
    }
    return tests[selectedIndex];
  }

  AppState copyWith({
    List<TestFile>? allTests,
    String? searchQuery,
    int? selectedIndex,
    ExecutionStatus? executionStatus,
  }) {
    return AppState(
      allTests: allTests ?? this.allTests,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      executionStatus: executionStatus ?? this.executionStatus,
    );
  }
}

Future<List<TestFile>> loadTests() =>
    TestDiscoveryEngine.scan('./integration-test/');
