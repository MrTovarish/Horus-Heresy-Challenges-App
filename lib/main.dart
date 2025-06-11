import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'models/entry_model.dart';
import 'screens/entry_form_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/list_screen.dart';

const int currentDataVersion = 2;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  Hive.registerAdapter(EntryAdapter());

  final settingsBox = await Hive.openBox('settings');
  final entriesBox = await Hive.openBox<Entry>('entries');

  final savedVersion = settingsBox.get('dataVersion', defaultValue: 0);

  if (savedVersion != currentDataVersion) {
    await entriesBox.clear(); // Could replace this with migration logic later
    await settingsBox.put('dataVersion', currentDataVersion);
    debugPrint('Hive data reset due to model update.');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Tracker',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.teal,
          secondary: Colors.amber,
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => <Widget>[
    EntryListScreen(),
    EntryFormScreen(onEntrySaved: () {
      setState(() {
        _selectedIndex = 0;
      });
    }),
    DashboardScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Entries'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'New Entry'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Dashboard'),
        ],
      ),
    );
  }
}
