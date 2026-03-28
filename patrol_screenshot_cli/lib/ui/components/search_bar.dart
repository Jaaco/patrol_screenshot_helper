import 'package:nocterm/nocterm.dart';

class SearchBar extends StatelessComponent {
  final String query;
  final Function(String) onQueryChanged;

  const SearchBar({
    required this.query,
    required this.onQueryChanged,
  });

  @override
  Component build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 40, 40, 40),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Row(
          children: [
            RichText(
              text: TextSpan(
                text: 'Search: ',
                style: TextStyle(
                  color: Color.fromARGB(255, 200, 200, 200),
                ),
              ),
            ),
            SizedBox(width: 2),
            RichText(
              text: TextSpan(
                text: query.isEmpty ? 'Type to filter tests...' : query,
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
}
