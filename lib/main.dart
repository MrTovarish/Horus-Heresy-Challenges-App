import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'models/entry_model.dart';
import 'screens/entry_form_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/list_screen.dart';
import 'models/turn_model.dart';
import 'models/event_model.dart';
import 'models/duel_model.dart';

const int currentDataVersion = 2;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  Hive.registerAdapter(EntryAdapter());
  Hive.registerAdapter(TurnAdapter());
  Hive.registerAdapter(DuelAdapter());
  Hive.registerAdapter(EventAdapter());
  Hive.registerAdapter(MatchResultAdapter());
  await Hive.openBox<Event>('events');
  await Hive.openBox<String>('your_characters');
  await Hive.openBox<String>('enemy_characters');

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0F1F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9FFFE7),
          secondary: Colors.amber,
        ),
        textTheme: ThemeData.dark().textTheme.copyWith(
          headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ).apply(fontFamily: 'RobotoMono'),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.black26,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white24),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF9FFFE7), width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 6,
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121B30),
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
        EntryFormScreen(
          onEntrySaved: () {
            setState(() => _selectedIndex = 0);
          },
        ),
        DashboardScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFF9FFFE7),
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Entries'),
                BottomNavigationBarItem(icon: Icon(Icons.add), label: 'New Entry'),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Dashboard'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


