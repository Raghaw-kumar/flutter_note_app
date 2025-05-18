import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PinSetupScreen extends StatelessWidget {
  final _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              decoration: InputDecoration(labelText: 'Enter 4-digit PIN'),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final pin = _pinController.text;
                if (pin.length == 4) {
                  context.read<AuthProvider>().setPin(pin);
                }
              },
              child: Text('Set PIN'),
            ),
          ],
        ),
      ),
    );
  }
}