import 'package:nocterm/nocterm.dart';

class SearchBar extends StatefulComponent {
  final void Function(String) onChanged;

  const SearchBar({super.key, required this.onChanged});

  @override
  State<StatefulComponent> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return Container(
      color: Color.fromRGB(40, 40, 40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
        child: Row(
          children: [
            Text(
              'Search: ',
              style: TextStyle(color: Color.fromRGB(200, 200, 200)),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: component.onChanged,
                decoration: const InputDecoration(
                  hintText: 'Type to filter tests...',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
