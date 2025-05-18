import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note? note;

  NoteDetailScreen({this.note});

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (note != null) {
      _titleController.text = note!.title;
      _contentController.text = note!.content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(note == null ? 'New Note' : 'Edit Note'),
        actions: [
          if (note != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                context.read<NotesProvider>().deleteNote(note!.id);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final content = _contentController.text.trim();

                if (title.isEmpty || content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Title and Content cannot be empty')),
                  );
                  return;
                }

                final newNote = Note(
                  id: note?.id ?? Uuid().v4(),
                  title: title,
                  content: content,
                );

                if (note == null) {
                  context.read<NotesProvider>().addNote(newNote);
                } else {
                  context.read<NotesProvider>().updateNote(newNote);
                }

                Navigator.of(context).pop();
              },
              child: Text(note == null ? 'Create Note' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}