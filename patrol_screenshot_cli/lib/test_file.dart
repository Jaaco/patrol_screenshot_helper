/// Model for a discovered test file
class TestFile {
  final String path;
  final String name;
  final String description;
  final DateTime lastModified;
  final List<TestCase> testCases;

  TestFile({
    required this.path,
    required this.name,
    required this.description,
    required this.lastModified,
    this.testCases = const [],
  });

  /// Display name for the test (last component of path)
  String get displayName => name.isEmpty ? path.split('/').last : name;

  @override
  String toString() => 'TestFile(name: $name, path: $path, cases: ${testCases.length})';
}

/// Model for individual test case
class TestCase {
  final String name;
  final int lineNumber;
  final String? description;

  TestCase({
    required this.name,
    required this.lineNumber,
    this.description,
  });

  @override
  String toString() => 'TestCase(name: $name, line: $lineNumber)';
}
