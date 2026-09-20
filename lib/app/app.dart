import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/storage/local_storage_service.dart';
import 'router.dart';
import 'theme.dart';

class ItToolkitApp extends StatefulWidget {
  const ItToolkitApp({super.key});

  @override
  State<ItToolkitApp> createState() => _ItToolkitAppState();
}

class _ItToolkitAppState extends State<ItToolkitApp> {
  late ThemeMode _themeMode;
  late String _startPage;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final storage = LocalStorageService();
    final modeStr = storage.getTheme();
    _startPage = storage.getStartPage();

    if (modeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (modeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  void _onThemeChanged(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: MainShellScreen(
        onThemeChanged: _onThemeChanged,
        initialRoute: _startPage,
      ),
    );
  }
}
