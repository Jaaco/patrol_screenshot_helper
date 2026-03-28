import 'package:nocterm/nocterm.dart';
import 'package:riverpod/riverpod.dart';
import '../state.dart';

class SearchBar extends StatefulComponent {
  @override
  State<StatefulComponent> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  foreground: Paint()..color = Color.fromARGB(255, 200, 200, 200),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  // Update search query in state
                  context.read(searchQueryProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  hintText: 'Type to filter tests...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
