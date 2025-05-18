import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'notes_list_screen.dart';

class PinAuthScreen extends StatelessWidget {
  final _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              decoration: InputDecoration(labelText: 'Enter 4-digit PIN'),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final pin = _pinController.text;
                if (pin.length == 4) {
                  await context.read<AuthProvider>().authenticate(pin);
                  if (context.read<AuthProvider>().isAuthenticated) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => NotesListScreen(),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid PIN')),
                    );
                  }
                }
              },
              child: Text('Unlock'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthProvider>().reset();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('App reset, please set a new PIN.')),
                );
              },
              child: Text('Forgot PIN?'),
            ),
          ],
        ),
      ),
    );
  }
}