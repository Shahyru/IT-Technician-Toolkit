import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/mac_service.dart';
import 'core/storage/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline local storage
  await LocalStorageService().init();

  // Preload OUI vendor database asynchronously
  MacService.loadOuiDatabase();

  runApp(const ItToolkitApp());
}
