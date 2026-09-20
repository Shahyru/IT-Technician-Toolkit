import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_technician_toolkit/core/models/port_item.dart';
import 'package:it_technician_toolkit/core/models/checklist_item.dart';
import 'package:it_technician_toolkit/core/storage/local_storage_service.dart';
import 'package:it_technician_toolkit/features/network/data/port_repository.dart';
import 'package:it_technician_toolkit/features/troubleshooting/data/troubleshooting_repository.dart';
import 'package:it_technician_toolkit/features/network/presentation/port_reference_screen.dart';
import 'package:it_technician_toolkit/features/network/presentation/subnet_calculator_screen.dart';
import 'package:it_technician_toolkit/features/troubleshooting/presentation/troubleshooting_list_screen.dart';
import 'package:it_technician_toolkit/features/settings/presentation/settings_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService().init();

    PortRepository.setMockPorts([
      const PortItem(
        port: 443,
        protocol: 'TCP',
        service: 'HTTPS',
        description: 'Secure HTTP web traffic',
        category: 'Web',
      ),
      const PortItem(
        port: 22,
        protocol: 'TCP',
        service: 'SSH',
        description: 'Secure Shell remote login',
        category: 'Remote Access',
      ),
    ]);

    TroubleshootingRepository.setMockChecklists([
      const ChecklistItem(
        id: 'test-cl-1',
        title: 'PC Won\'t Turn On',
        category: 'Hardware',
        description: 'Check power delivery and components.',
        steps: [
          ChecklistStep(
            id: 's1',
            title: 'Check wall outlet',
            description: 'Verify AC power from outlet.',
          ),
          ChecklistStep(
            id: 's2',
            title: 'Check PSU switch',
            description: 'Ensure switch is on.',
          ),
        ],
      ),
    ]);
  });

  testWidgets('PortReferenceScreen displays ports and filters by query', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(home: PortReferenceScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Network Port Reference'), findsOneWidget);
    expect(find.text('443'), findsOneWidget);
    expect(find.text('HTTPS'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);
    expect(find.text('SSH'), findsOneWidget);

    // Search for 443
    await tester.enterText(find.byType(TextField), '443');
    await tester.pumpAndSettle();

    expect(find.text('HTTPS'), findsOneWidget);
    expect(find.text('SSH'), findsNothing);
  });

  testWidgets('SubnetCalculatorScreen calculates and shows subnets table', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(home: SubnetCalculatorScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Subnet Planner & VLSM'), findsOneWidget);
    expect(find.text('Base Network Parameters'), findsOneWidget);
    expect(find.text('Subnet / CIDR'), findsOneWidget);
    expect(find.text('192.168.1.0/26'), findsWidgets);
  });

  testWidgets('TroubleshootingListScreen renders workflow checklists and allows opening', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(home: TroubleshootingListScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Troubleshooting Checklists'), findsOneWidget);
    expect(find.text('PC Won\'t Turn On'), findsOneWidget);
    expect(find.text('0/2 steps'), findsOneWidget);

    // Tap on the checklist to open detail
    await tester.tap(find.text('PC Won\'t Turn On'));
    await tester.pumpAndSettle();

    expect(find.text('Step 1: Check wall outlet'), findsOneWidget);
    expect(find.text('Diagnostic Progress: 0%'), findsOneWidget);

    // Check step 1
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(find.text('Diagnostic Progress: 50%'), findsOneWidget);
  });

  testWidgets('SettingsScreen renders themes and preferences', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    ThemeMode? selectedTheme;
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          onThemeChanged: (mode) => selectedTheme = mode,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings & Preferences'), findsOneWidget);
    expect(find.text('Theme Mode'), findsOneWidget);
    expect(find.text('Compact Tool Cards'), findsOneWidget);
    expect(find.text('Show Recently Used Tools'), findsOneWidget);

    // Switch to dark mode
    await tester.tap(find.text('Dark Mode'));
    await tester.pumpAndSettle();

    expect(selectedTheme, ThemeMode.dark);
  });
}
