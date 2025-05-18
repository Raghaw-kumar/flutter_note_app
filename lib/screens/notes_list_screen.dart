import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import 'note_detail_screen.dart';
import '../widgets/note_item.dart';

class NotesListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: Consumer<NotesProvider>(
        builder: (ctx, notesProvider, _) => ListView.builder(
          itemCount: notesProvider.notes.length,
          itemBuilder: (ctx, index) {
            final note = notesProvider.notes[index];
            return NoteItem(note: note);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NoteDetailScreen(),
            ),
          );
        },
      ),
    );
  }
}