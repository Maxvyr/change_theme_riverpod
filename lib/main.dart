import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

ThemeData themeDataLight({
  Color? seedColor,
}) {
  final theme = ThemeData.light();
  final colorScheme = ColorScheme.fromSeed(seedColor: seedColor ?? Colors.blue);

  return theme.copyWith(
    colorScheme: colorScheme,
    indicatorColor: colorScheme.primary,
    useMaterial3: true,
  );
}

ThemeData themeDataDark({
  Color? seedColor,
}) {
  final theme = ThemeData.dark();
  final colorScheme = ColorScheme.fromSeed(seedColor: seedColor ?? Colors.blue);

  return theme.copyWith(
    colorScheme: colorScheme,
    indicatorColor: colorScheme.primary,
    useMaterial3: true,
  );
}

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier() {
    _init();
  }
  ThemeMode themeMode = ThemeMode.system;
  FlutterSecureStorage? flutterSecureStorage;
  final key = "theme";

  Future<void> _init() async {
    flutterSecureStorage = const FlutterSecureStorage();
    final theme = await getTheme(key);
    themeMode = ThemeMode.values[theme];
    notifyListeners();
  }

  Future<int> getTheme(String key) async {
    return int.parse(await flutterSecureStorage?.read(key: key) ?? themeMode.index.toString());
  }

  Future<void> setTheme(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    await flutterSecureStorage?.write(key: key, value: mode.index.toString());
  }
}

final themeNotifierProvider =
    ChangeNotifierProvider<ThemeNotifier>((_) => ThemeNotifier());

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: themeNotifier.themeMode,
      // Define your themes here
      theme: themeDataLight(seedColor: Colors.black),
      darkTheme: themeDataDark(seedColor: Colors.deepOrangeAccent),
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
