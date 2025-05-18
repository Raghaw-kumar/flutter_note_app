import 'package:flutter/material.dart';
import 'package:flutter_note_app/screens/notes_list_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notes_provider.dart';
import 'screens/pin_auth_screen.dart';
import 'services/local_storage_service.dart';
import 'services/secure_storage_service.dart';
import 'themes/light_theme.dart';
import 'themes/dark_theme.dart';
import 'providers/theme_provider.dart';  // Make sure this import is present

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Add the theme provider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Flutter Notes App',
      theme: themeProvider.themeData, // Use the theme from ThemeProvider
      home: isAuthenticated ? NotesListScreen() : PinAuthScreen(),
    );
  }
}