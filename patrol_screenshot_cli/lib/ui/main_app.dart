import 'package:nocterm/nocterm.dart';
import 'package:riverpod/riverpod.dart';
import 'state.dart';
import '../test_file.dart';
import 'components/header_panel.dart';
import 'components/search_bar.dart';
import 'components/test_list.dart';
import 'components/detail_panel.dart';
import 'components/footer_panel.dart';

class MainApp extends StatefulComponent {
  @override
  State<StatefulComponent> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late ProviderContainer _container;

  @override
  void initState() {
    _container = ProviderContainer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: _container,
      child: Column(
        children: [
          SizedBox(height: 1, child: HeaderPanel()),
          SizedBox(height: 1, child: SearchBar()),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TestListWidget(),
                ),
                SizedBox(width: 2, child: Container(color: Color.fromARGB(255, 40, 40, 40))),
                Expanded(
                  flex: 2,
                  child: DetailPanel(),
                ),
              ],
            ),
          ),
          SizedBox(height: 1, child: FooterPanel()),
        ],
      ),
    );
  }
}
