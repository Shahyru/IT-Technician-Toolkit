import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_routes.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/network/presentation/network_index_screen.dart';
import '../features/network/presentation/ip_calculator_screen.dart';
import '../features/network/presentation/subnet_calculator_screen.dart';
import '../features/network/presentation/ping_screen.dart';
import '../features/network/presentation/port_reference_screen.dart';
import '../features/network/presentation/mac_tools_screen.dart';
import '../features/calculators/presentation/calculators_index_screen.dart';
import '../features/calculators/presentation/unit_converter_screen.dart';
import '../features/calculators/presentation/storage_calculator_screen.dart';
import '../features/calculators/presentation/ram_calculator_screen.dart';
import '../features/calculators/presentation/network_speed_screen.dart';
import '../features/generators/presentation/generators_index_screen.dart';
import '../features/generators/presentation/password_generator_screen.dart';
import '../features/generators/presentation/qr_generator_screen.dart';
import '../features/references/presentation/references_index_screen.dart';
import '../features/references/presentation/command_reference_screen.dart';
import '../features/troubleshooting/presentation/troubleshooting_list_screen.dart';
import '../features/favorites/presentation/favorites_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

class MainShellScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;
  final String initialRoute;

  const MainShellScreen({
    super.key,
    required this.onThemeChanged,
    this.initialRoute = AppRoutes.dashboard,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late String _currentRoute;
  bool _isSidebarCollapsed = false;
  int _mobileNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute;
  }

  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
      // Sync mobile bottom index
      if (route == AppRoutes.dashboard) {
        _mobileNavIndex = 0;
      } else if (route == AppRoutes.network || route == AppRoutes.calculators || route == AppRoutes.generators) {
        _mobileNavIndex = 1;
      } else if (route.startsWith('/references')) {
        _mobileNavIndex = 2;
      } else if (route == AppRoutes.settings || route == AppRoutes.favorites || route == AppRoutes.history) {
        _mobileNavIndex = 3;
      }
    });
  }

  Widget _buildBody() {
    switch (_currentRoute) {
      case AppRoutes.dashboard:
        return DashboardScreen(onNavigate: _navigateTo);
      case AppRoutes.search:
        return SearchScreen(onNavigate: _navigateTo);

      // Network
      case AppRoutes.network:
        return NetworkIndexScreen(onNavigate: _navigateTo);
      case AppRoutes.ipCalculator:
        return const IpCalculatorScreen();
      case AppRoutes.subnetCalculator:
        return const SubnetCalculatorScreen();
      case AppRoutes.ping:
        return const PingScreen();
      case AppRoutes.ports:
        return const PortReferenceScreen();
      case AppRoutes.macTools:
        return const MacToolsScreen();

      // Calculators
      case AppRoutes.calculators:
        return CalculatorsIndexScreen(onNavigate: _navigateTo);
      case AppRoutes.unitConverter:
        return const UnitConverterScreen();
      case AppRoutes.storageCalculator:
        return const StorageCalculatorScreen();
      case AppRoutes.ramCalculator:
        return const RamCalculatorScreen();
      case AppRoutes.networkSpeed:
        return const NetworkSpeedScreen();

      // Generators
      case AppRoutes.generators:
        return GeneratorsIndexScreen(onNavigate: _navigateTo);
      case AppRoutes.passwordGenerator:
        return const PasswordGeneratorScreen();
      case AppRoutes.qrGenerator:
        return const QrGeneratorScreen();

      // References
      case AppRoutes.references:
        return ReferencesIndexScreen(onNavigate: _navigateTo);
      case AppRoutes.windowsCommands:
        return const CommandReferenceScreen(initialPlatform: 'windows');
      case AppRoutes.linuxCommands:
        return const CommandReferenceScreen(initialPlatform: 'linux');
      case AppRoutes.powershellCommands:
        return const CommandReferenceScreen(initialPlatform: 'powershell');

      // Troubleshooting
      case AppRoutes.troubleshooting:
        return const TroubleshootingListScreen();

      // Personalization
      case AppRoutes.favorites:
        return FavoritesScreen(onNavigate: _navigateTo);
      case AppRoutes.history:
        return HistoryScreen(onNavigate: _navigateTo);
      case AppRoutes.settings:
        return SettingsScreen(onThemeChanged: widget.onThemeChanged);

      default:
        return DashboardScreen(onNavigate: _navigateTo);
    }
  }

  int _getDesktopSelectedIndex() {
    if (_currentRoute == AppRoutes.dashboard) return 0;
    if (_currentRoute.startsWith('/network')) return 1;
    if (_currentRoute.startsWith('/calculators')) return 2;
    if (_currentRoute.startsWith('/generators')) return 3;
    if (_currentRoute.startsWith('/references')) return 4;
    if (_currentRoute.startsWith('/troubleshooting')) return 5;
    if (_currentRoute == AppRoutes.favorites) return 6;
    if (_currentRoute == AppRoutes.history) return 7;
    if (_currentRoute == AppRoutes.settings) return 8;
    return 0;
  }

  void _onDesktopNavSelected(int index) {
    switch (index) {
      case 0:
        _navigateTo(AppRoutes.dashboard);
        break;
      case 1:
        _navigateTo(AppRoutes.network);
        break;
      case 2:
        _navigateTo(AppRoutes.calculators);
        break;
      case 3:
        _navigateTo(AppRoutes.generators);
        break;
      case 4:
        _navigateTo(AppRoutes.references);
        break;
      case 5:
        _navigateTo(AppRoutes.troubleshooting);
        break;
      case 6:
        _navigateTo(AppRoutes.favorites);
        break;
      case 7:
        _navigateTo(AppRoutes.history);
        break;
      case 8:
        _navigateTo(AppRoutes.settings);
        break;
    }
  }

  void _onMobileNavTapped(int index) {
    setState(() => _mobileNavIndex = index);
    switch (index) {
      case 0:
        _navigateTo(AppRoutes.dashboard);
        break;
      case 1:
        _navigateTo(AppRoutes.network);
        break;
      case 2:
        _navigateTo(AppRoutes.references);
        break;
      case 3:
        _navigateTo(AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 720;

    // Desktop Keyboard shortcut handler (Ctrl + K for search)
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          _navigateTo(AppRoutes.search);
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_currentRoute != AppRoutes.dashboard) {
            _navigateTo(AppRoutes.dashboard);
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              // Desktop Sidebar / NavigationRail
              if (isDesktop)
                NavigationRail(
                  extended: !_isSidebarCollapsed,
                  minExtendedWidth: 200,
                  selectedIndex: _getDesktopSelectedIndex(),
                  onDestinationSelected: _onDesktopNavSelected,
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(_isSidebarCollapsed ? Icons.menu : Icons.menu_open),
                          tooltip: _isSidebarCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
                          onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                        ),
                        if (!_isSidebarCollapsed) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'IT Toolkit',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ],
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
                    NavigationRailDestination(icon: Icon(Icons.hub_outlined), selectedIcon: Icon(Icons.hub), label: Text('Network')),
                    NavigationRailDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: Text('Calculators')),
                    NavigationRailDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: Text('Generators')),
                    NavigationRailDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: Text('References')),
                    NavigationRailDestination(icon: Icon(Icons.build_circle_outlined), selectedIcon: Icon(Icons.build_circle), label: Text('Troubleshoot')),
                    NavigationRailDestination(icon: Icon(Icons.star_border), selectedIcon: Icon(Icons.star), label: Text('Favorites')),
                    NavigationRailDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.history_toggle_off), label: Text('History')),
                    NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
                  ],
                ),

              if (isDesktop) const VerticalDivider(width: 1),

              // Main Active Viewport
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),

          // Mobile Bottom Navigation Bar (< 720px)
          bottomNavigationBar: isDesktop
              ? null
              : NavigationBar(
                  selectedIndex: _mobileNavIndex,
                  onDestinationSelected: _onMobileNavTapped,
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                    NavigationDestination(icon: Icon(Icons.construction_outlined), selectedIcon: Icon(Icons.construction), label: 'Tools'),
                    NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Reference'),
                    NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: 'More'),
                  ],
                ),
        ),
      ),
    );
  }
}
