import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/theme_provider.dart';
import 'services/secure_storage_service.dart';
import 'services/local_storage_service.dart';
import 'screens/pin_setup_screen.dart';
import 'screens/pin_auth_screen.dart';
import 'screens/notes_list_screen.dart';

void main() {
  final secureStorageService = SecureStorageService();
  final localStorageService = LocalStorageService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(secureStorageService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotesProvider(localStorageService),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notes App',
      theme: context.watch<ThemeProvider>().themeData,
      home: FutureBuilder<bool>(
        future: context.read<AuthProvider>().hasPin(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('An error occurred')),
            );
          } else {
            bool hasPin = snapshot.data ?? false; // Ensure null-safety by providing a default
            return hasPin ? PinAuthScreen() : PinSetupScreen();
          }
        },
      ),
    );
  }
}