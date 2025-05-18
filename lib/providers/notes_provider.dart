import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/local_storage_service.dart';

class NotesProvider with ChangeNotifier {
  final LocalStorageService localStorageService;
  List<Note> _notes = [];

  NotesProvider(this.localStorageService);

  List<Note> get notes => _notes;

  Future<void> loadNotes() async {
    _notes = await localStorageService.loadNotes();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await localStorageService.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> updateNote(Note updatedNote) async {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index >= 0) {
      _notes[index] = updatedNote;
      await localStorageService.saveNotes(_notes);
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    await localStorageService.saveNotes(_notes);
    notifyListeners();
  }
}