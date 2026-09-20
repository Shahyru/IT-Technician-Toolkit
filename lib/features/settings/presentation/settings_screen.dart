import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/widgets/app_card.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalStorageService _storage = LocalStorageService();

  late String _themeSetting;
  late String _startPage;
  late bool _compactCards;
  late bool _showRecentTools;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _themeSetting = _storage.getTheme();
      _startPage = _storage.getStartPage();
      _compactCards = _storage.getCompactCards();
      _showRecentTools = _storage.getShowRecentTools();
    });
  }

  void _onThemeSelected(String mode) {
    setState(() => _themeSetting = mode);
    _storage.saveTheme(mode);

    ThemeMode tm;
    if (mode == 'light') {
      tm = ThemeMode.light;
    } else if (mode == 'dark') {
      tm = ThemeMode.dark;
    } else {
      tm = ThemeMode.system;
    }
    widget.onThemeChanged(tm);
  }

  Future<void> _resetApplication() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Application?'),
        content: const Text(
          'This will permanently reset all favorites, history, checklist progress, notes, and preferences to initial defaults.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset Everything', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.resetAllData();
      _loadSettings();
      _onThemeSelected('system');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application reset to factory state.')),
        );
      }
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: 'v${AppConstants.appVersion} (Build ${AppConstants.appBuild})',
      applicationIcon: const Icon(Icons.terminal, size: 40),
      applicationLegalese: 'MIT License • 100% Offline & Open Source',
      children: const [
        SizedBox(height: 14),
        Text(AppConstants.appDescription),
        SizedBox(height: 12),
        Text(
          'Designed for IT technicians, system engineers, network administrators, and help-desk specialists.\n\nAll tools run on-device with zero remote API dependencies and complete privacy.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Theme Selection
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _themeChip('system', 'System Default', Icons.brightness_auto),
                    const SizedBox(width: 8),
                    _themeChip('dark', 'Dark Mode', Icons.dark_mode_outlined),
                    const SizedBox(width: 8),
                    _themeChip('light', 'Light Mode', Icons.light_mode_outlined),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Interface Settings
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dashboard & Display', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  title: const Text('Compact Tool Cards'),
                  subtitle: const Text('Display single-line compact cards on dashboard and favorites'),
                  value: _compactCards,
                  onChanged: (val) {
                    setState(() => _compactCards = val);
                    _storage.saveCompactCards(val);
                  },
                ),
                SwitchListTile.adaptive(
                  title: const Text('Show Recently Used Tools'),
                  subtitle: const Text('Display recent launch history on the main dashboard'),
                  value: _showRecentTools,
                  onChanged: (val) {
                    setState(() => _showRecentTools = val);
                    _storage.saveShowRecentTools(val);
                  },
                ),
                const Divider(height: 1),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _startPage,
                  decoration: const InputDecoration(labelText: 'Default Start Page'),
                  items: const [
                    DropdownMenuItem(value: AppRoutes.dashboard, child: Text('Dashboard (Home)')),
                    DropdownMenuItem(value: AppRoutes.search, child: Text('Global Search')),
                    DropdownMenuItem(value: AppRoutes.ipCalculator, child: Text('IP Calculator')),
                    DropdownMenuItem(value: AppRoutes.ports, child: Text('Port Reference')),
                    DropdownMenuItem(value: AppRoutes.troubleshooting, child: Text('Troubleshooting Checklists')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _startPage = val);
                      _storage.saveStartPage(val);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Data Management
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Data & Storage Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.star_border),
                  title: const Text('Clear Favorites'),
                  subtitle: const Text('Removes all starred tools, commands, and checklists'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await _storage.clearFavorites();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Favorites cleared')),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Clear Tool History'),
                  subtitle: const Text('Deletes all local launch history logs'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await _storage.clearHistory();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('History cleared')),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.redAccent),
                  title: const Text('Reset Application Data', style: TextStyle(color: Colors.redAccent)),
                  subtitle: const Text('Erase all saved preferences and checklist notes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _resetApplication,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About & Legal
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About IT Technician Toolkit'),
              subtitle: const Text('Version ${AppConstants.appVersion} • Offline Reference Edition'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showAboutDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeChip(String mode, String label, IconData icon) {
    final selected = _themeSetting == mode;
    return Expanded(
      child: ChoiceChip(
        avatar: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: selected,
        onSelected: (_) => _onThemeSelected(mode),
      ),
    );
  }
}
