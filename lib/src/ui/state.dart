import 'package:riverpod/riverpod.dart';
import '../models/test_file.dart';
import '../test_discovery.dart';

enum ExecutionStatus {
  idle,
  running,
  passed,
  failed,
  error,
}

/// Discover all test files in integration-test directory
final testListProvider = FutureProvider<List<TestFile>>((ref) async {
  return TestDiscoveryEngine.scan('./integration-test/');
});

/// Current search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Selected test index
final selectedTestIndexProvider = StateProvider<int>((ref) => 0);

/// Filtered tests based on search query
final filteredTestsProvider = Provider<List<TestFile>>((ref) {
  final allTestsAsync = ref.watch(testListProvider);
  final query = ref.watch(searchQueryProvider);

  return allTestsAsync.maybeWhen(
    data: (tests) {
      if (query.isEmpty) return tests;
      final lower = query.toLowerCase();
      return tests
          .where((test) =>
              test.name.toLowerCase().contains(lower) ||
              test.path.toLowerCase().contains(lower) ||
              test.description.toLowerCase().contains(lower))
          .toList();
    },
    orElse: () => [],
  );
});

/// Get currently selected test
final selectedTestProvider = Provider<TestFile?>((ref) {
  final tests = ref.watch(filteredTestsProvider);
  final index = ref.watch(selectedTestIndexProvider);

  if (tests.isEmpty || index < 0 || index >= tests.length) {
    return null;
  }
  return tests[index];
});

/// Current execution status
final executionStatusProvider = StateProvider<ExecutionStatus>(
  (ref) => ExecutionStatus.idle,
);

/// Last execution result
final lastExecutionResultProvider = StateProvider<String?>((ref) => null);
