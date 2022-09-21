import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

ThemeData themesData({
  Color? seedColor,
}) {
  final theme = ThemeData();
  final colorScheme = ColorScheme.fromSeed(seedColor: seedColor ?? Colors.blue);

  return theme.copyWith(
    colorScheme: colorScheme,
    indicatorColor: colorScheme.primary,
    useMaterial3: true,
  );
}

final themeDataProvider = StateProvider.family<ThemeData, Color?>(
    (ref, seedColor) => themesData(seedColor: seedColor));

class ThemeNotifier extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  SharedPreferences? prefs;

  ThemeNotifier() {
    _init();
  }

  _init() async {
    prefs = await SharedPreferences.getInstance();

    int theme = prefs?.getInt("theme") ?? themeMode.index;
    themeMode = ThemeMode.values[theme];
    notifyListeners();
  }

  setTheme(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
    prefs?.setInt("theme", mode.index);
  }
}

final themeNotifierProvider =
    ChangeNotifierProvider<ThemeNotifier>((_) => ThemeNotifier());

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeNotifierProvider);

    final themeData = ref.watch(themeDataProvider(Colors.green));

    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: themeNotifier.themeMode,
      // Define your themes here
      theme: themeData,
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Dynamic Theme")),
      body: Column(
        children: [
          _singleTile("Dark Theme", ThemeMode.dark, notifier),
          _singleTile("Light Theme", ThemeMode.light, notifier),
          _singleTile("System Theme", ThemeMode.system, notifier),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
      ),
    );
  }

  Widget _singleTile(String title, ThemeMode mode, ThemeNotifier notifier) {
    return RadioListTile<ThemeMode>(
        value: mode,
        title: Text(title),
        groupValue: notifier.themeMode,
        onChanged: (val) {
          if (val != null) notifier.setTheme(val);
        });
  }
}
