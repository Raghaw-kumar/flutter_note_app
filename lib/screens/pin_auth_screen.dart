import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';

class PinAuthScreen extends StatefulWidget {
  const PinAuthScreen({Key? key}) : super(key: key);

  @override
  State<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen> {
  final _pinController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;
  String? _confirmPin;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handlePinSubmission() async {
    final pin = _pinController.text;
    
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Please enter a PIN');
      return;
    }

    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      setState(() => _errorMessage = 'PIN must be 4 digits');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final noteProvider = context.read<NoteProvider>();

      if (!authProvider.isPinSet) {
        if (_confirmPin == null) {
          // First PIN entry - store for confirmation
          setState(() {
            _confirmPin = pin;
            _pinController.clear();
            _errorMessage = 'Please confirm your PIN';
          });
        } else if (_confirmPin == pin) {
          // PIN confirmed - set it
          await authProvider.setPin(pin);
          await noteProvider.loadNotes();
        } else {
          // PINs don't match
          setState(() {
            _confirmPin = null;
            _pinController.clear();
            _errorMessage = 'PINs do not match. Please try again';
          });
        }
      } else {
        // Verify existing PIN
        final isValid = await authProvider.verifyPin(pin);
        if (isValid) {
          await noteProvider.loadNotes();
        } else {
          if (!mounted) return;
          setState(() => _errorMessage = 'Invalid PIN');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (_errorMessage.isEmpty) {
          _pinController.clear();
        }
      });
    }
  }

  Future<void> _handleReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App?'),
        content: const Text(
          'This will delete all notes and reset the PIN. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final noteProvider = context.read<NoteProvider>();
      await noteProvider.deleteAllNotes();
      
      final authProvider = context.read<AuthProvider>();
      await authProvider.resetPin();
      
      if (!mounted) return;
      setState(() {
        _confirmPin = null;
        _pinController.clear();
        _errorMessage = '';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App reset successfully. Please set a new PIN.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPinSet = context.watch<AuthProvider>().isPinSet;
    final message = _confirmPin != null
        ? 'Confirm your PIN'
        : isPinSet
            ? 'Enter your PIN to unlock'
            : 'Create a 4-digit PIN';

    return Scaffold(
      appBar: AppBar(
        title: Text(isPinSet ? 'Enter PIN' : 'Set PIN'),
        actions: [
          if (isPinSet)
            TextButton(
              onPressed: _handleReset,
              child: const Text('Reset'),
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '****',
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
                onSubmitted: (_) => _handlePinSubmission(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _handlePinSubmission,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_confirmPin != null ? 'Confirm PIN' : isPinSet ? 'Unlock' : 'Set PIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}