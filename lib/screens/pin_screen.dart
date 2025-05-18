import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({Key? key}) : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _pinController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handlePinSubmission() async {
    if (_pinController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter a PIN');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final noteProvider = context.read<NoteProvider>();

      if (!authProvider.isPinSet) {
        await authProvider.setPin(_pinController.text);
        await noteProvider.loadNotes();
      } else {
        final isValid = await authProvider.verifyPin(_pinController.text);
        if (isValid) {
          await noteProvider.loadNotes();
        } else {
          setState(() => _errorMessage = 'Invalid PIN');
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
      _pinController.clear();
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

    if (confirmed == true) {
      final authProvider = context.read<AuthProvider>();
      final noteProvider = context.read<NoteProvider>();
      
      await noteProvider.deleteAllNotes();
      await authProvider.resetPin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPinSet = context.watch<AuthProvider>().isPinSet;

    return Scaffold(
      appBar: AppBar(
        title: Text(isPinSet ? 'Enter PIN' : 'Set PIN'),
        actions: [
          if (isPinSet)
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: _handleReset,
              tooltip: 'Reset App',
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
                isPinSet
                    ? 'Enter your 4-digit PIN to unlock'
                    : 'Create a 4-digit PIN to secure your notes',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
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
                    : Text(isPinSet ? 'Unlock' : 'Set PIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 