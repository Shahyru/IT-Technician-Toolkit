import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_technician_toolkit/app/app.dart';
import 'package:it_technician_toolkit/core/storage/local_storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService().init();
  });

  testWidgets('Renders ItToolkitApp, Dashboard header, and Quick Tools', (WidgetTester tester) async {
    // Set a wide desktop test resolution
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ItToolkitApp());
    await tester.pumpAndSettle();

    // Verify Title and Subtitle exist
    expect(find.text('IT Technician Toolkit'), findsWidgets);
    expect(find.text('Quick Tools'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);

    // Verify quick tools are present on dashboard
    expect(find.text('IP Calculator'), findsWidgets);
    expect(find.text('Subnet Calculator'), findsWidgets);
    expect(find.text('Ping Reachability'), findsWidgets);
    expect(find.text('Port Reference'), findsWidgets);
    expect(find.text('Password Generator'), findsWidgets);
    expect(find.text('QR Code Generator'), findsWidgets);
  });

  testWidgets('Opens IP Calculator and verifies calculations and form fields', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ItToolkitApp());
    await tester.pumpAndSettle();

    // Tap on IP Calculator quick tool
    await tester.tap(find.text('IP Calculator').first);
    await tester.pumpAndSettle();

    // Verify screen loaded
    expect(find.text('IPv4 Subnet Calculator'), findsOneWidget);
    expect(find.text('Network & Host Boundaries'), findsOneWidget);
    expect(find.text('Binary Structure'), findsOneWidget);
    expect(find.text('192.168.1.0'), findsOneWidget);
    expect(find.text('192.168.1.255'), findsOneWidget);
  });

  testWidgets('Opens Password Generator and regenerates password', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ItToolkitApp());
    await tester.pumpAndSettle();

    // Tap on Password Generator quick tool
    await tester.tap(find.text('Password Generator').first);
    await tester.pumpAndSettle();

    expect(find.text('Cryptographic Password Generator'), findsOneWidget);
    expect(find.text('Generated Password'), findsOneWidget);
    expect(find.text('Regenerate'), findsOneWidget);

    // Tap Regenerate button
    await tester.tap(find.text('Regenerate'));
    await tester.pumpAndSettle();

    expect(find.text('Copy Password'), findsOneWidget);
  });
}
