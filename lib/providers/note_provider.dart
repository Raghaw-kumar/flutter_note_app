import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/database_service.dart';

class NoteProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotes() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _databaseService.getNotes();
      _error = null;
    } catch (e) {
      _error = 'Error loading notes: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(String title, String content, {List<Task>? tasks}) async {
    if (_isLoading) return;

    final note = Note(
      title: title,
      content: content,
      tasks: tasks,
    );

    try {
      // Update local state immediately
      _notes.insert(0, note);
      notifyListeners();

      // Save to database
      await _databaseService.insertNote(note);
    } catch (e) {
      // Revert local state on error
      _notes.removeWhere((n) => n.id == note.id);
      _error = 'Error adding note: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  Future<void> updateNote(Note note) async {
    if (_isLoading) return;

    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index == -1) return;

    try {
      // Update local state immediately
      _notes[index] = note;
      notifyListeners();

      // Save to database
      await _databaseService.updateNote(note);
    } catch (e) {
      // Revert on error
      _error = 'Error updating note: $e';
      debugPrint(_error);
      await loadNotes(); // Reload to get correct state
      notifyListeners();
    }
  }

  Future<void> addTask(String noteId, String content) async {
    final noteIndex = _notes.indexWhere((note) => note.id == noteId);
    if (noteIndex == -1) return;

    try {
      final note = _notes[noteIndex];
      final newTask = Task(content: content);
      
      // Update local state immediately
      final updatedNote = note.copyWith(
        tasks: [...note.tasks, newTask],
      );
      _notes[noteIndex] = updatedNote;
      notifyListeners();

      // Save to database
      await _databaseService.updateNote(updatedNote);
    } catch (e) {
      _error = 'Error adding task: $e';
      debugPrint(_error);
      await loadNotes(); // Reload to get correct state
      notifyListeners();
    }
  }

  Future<void> toggleTask(String noteId, String taskId) async {
    final noteIndex = _notes.indexWhere((note) => note.id == noteId);
    if (noteIndex == -1) return;

    try {
      final note = _notes[noteIndex];
      final updatedTasks = note.tasks.map((task) {
        if (task.id == taskId) {
          return Task(
            id: task.id,
            content: task.content,
            isCompleted: !task.isCompleted,
            createdAt: task.createdAt,
          );
        }
        return task;
      }).toList();

      // Update local state immediately
      final updatedNote = note.copyWith(tasks: updatedTasks);
      _notes[noteIndex] = updatedNote;
      notifyListeners();

      // Save to database
      await _databaseService.updateNote(updatedNote);
    } catch (e) {
      _error = 'Error toggling task: $e';
      debugPrint(_error);
      await loadNotes(); // Reload to get correct state
      notifyListeners();
    }
  }

  Future<void> deleteTask(String noteId, String taskId) async {
    final noteIndex = _notes.indexWhere((note) => note.id == noteId);
    if (noteIndex == -1) return;

    try {
      final note = _notes[noteIndex];
      final updatedTasks = note.tasks.where((task) => task.id != taskId).toList();
      
      // Update local state immediately
      final updatedNote = note.copyWith(tasks: updatedTasks);
      _notes[noteIndex] = updatedNote;
      notifyListeners();

      // Save to database
      await _databaseService.updateNote(updatedNote);
    } catch (e) {
      _error = 'Error deleting task: $e';
      debugPrint(_error);
      await loadNotes(); // Reload to get correct state
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index == -1) return;

    final deletedNote = _notes[index];
    try {
      // Update local state immediately
      _notes.removeAt(index);
      notifyListeners();

      // Delete from database
      await _databaseService.deleteNote(id);
    } catch (e) {
      // Revert on error
      _notes.insert(index, deletedNote);
      _error = 'Error deleting note: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  Future<void> deleteAllNotes() async {
    if (_isLoading) return;

    final oldNotes = List<Note>.from(_notes);
    try {
      // Update local state immediately
      _notes = [];
      notifyListeners();

      // Delete from database
      await _databaseService.deleteAllNotes();
    } catch (e) {
      // Revert on error
      _notes = oldNotes;
      _error = 'Error deleting all notes: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }
} 