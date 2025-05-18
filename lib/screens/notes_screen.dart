import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note.dart';
import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';
import '../services/theme_service.dart';
import 'edit_note_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({Key? key}) : super(key: key);

  int _getColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;  // Phone
    if (width < 900) return 2;  // Tablet portrait
    if (width < 1200) return 3; // Tablet landscape
    return 4;                   // Desktop
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final padding = MediaQuery.of(context).padding;
    final width = MediaQuery.of(context).size.width;
    final isTabletOrLarger = width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes & Tasks'),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeService>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeService>().toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (noteProvider.notes.isEmpty) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: isTabletOrLarger ? 96 : 64,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notes or tasks yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: isTabletOrLarger ? 24 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to create one',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: isTabletOrLarger ? 16 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final columnCount = _getColumnCount(context);
              final horizontalPadding = isTabletOrLarger ? 16.0 : 8.0;
              final cardWidth = (constraints.maxWidth - (horizontalPadding * 2) - (16.0 * (columnCount - 1))) / columnCount;
              final minCardHeight = isTabletOrLarger ? 150.0 : 100.0;

              return MasonryGridView.count(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  8 + padding.bottom,
                ),
                crossAxisCount: columnCount,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: noteProvider.notes.length,
                itemBuilder: (context, index) {
                  final note = noteProvider.notes[index];
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: minCardHeight,
                      maxWidth: cardWidth,
                    ),
                    child: _NoteCard(note: note),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: isLandscape ? 16 : padding.bottom,
          right: isLandscape ? padding.right : 0,
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditNoteScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;

  const _NoteCard({
    Key? key,
    required this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completedTasks = note.tasks.where((task) => task.isCompleted).length;
    final totalTasks = note.tasks.length;
    final isTabletOrLarger = MediaQuery.of(context).size.width >= 600;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditNoteScreen(note: note),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(isTabletOrLarger ? 16 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title.isNotEmpty) ...[
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: isTabletOrLarger ? 18 : 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isTabletOrLarger ? 8 : 6),
              ],
              if (note.content.isNotEmpty) ...[
                Text(
                  note.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: isTabletOrLarger ? 16 : 14,
                  ),
                  maxLines: isTabletOrLarger ? 4 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isTabletOrLarger ? 8 : 6),
              ],
              if (note.tasks.isNotEmpty) ...[
                const Divider(height: 16),
                if (totalTasks > 0)
                  Padding(
                    padding: EdgeInsets.only(bottom: isTabletOrLarger ? 8 : 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: isTabletOrLarger ? 18 : 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$completedTasks of $totalTasks tasks completed',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: isTabletOrLarger ? 14 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: note.tasks.length > (isTabletOrLarger ? 4 : 3) 
                      ? (isTabletOrLarger ? 4 : 3) 
                      : note.tasks.length,
                  itemBuilder: (context, index) {
                    final task = note.tasks[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isTabletOrLarger ? 3 : 2,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: isTabletOrLarger ? 24 : 20,
                            height: isTabletOrLarger ? 24 : 20,
                            child: Transform.scale(
                              scale: textScaleFactor > 1 ? 1 : textScaleFactor,
                              child: Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) {
                                  context.read<NoteProvider>().toggleTask(note.id, task.id);
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          SizedBox(width: isTabletOrLarger ? 10 : 8),
                          Expanded(
                            child: Text(
                              task.content,
                              style: TextStyle(
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                color: task.isCompleted
                                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                    : null,
                                fontSize: isTabletOrLarger ? 15 : 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (note.tasks.length > (isTabletOrLarger ? 4 : 3))
                  Padding(
                    padding: EdgeInsets.only(top: isTabletOrLarger ? 6 : 4),
                    child: Text(
                      '+ ${note.tasks.length - (isTabletOrLarger ? 4 : 3)} more tasks',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: isTabletOrLarger ? 13 : 11,
                      ),
                    ),
                  ),
              ],
              SizedBox(height: isTabletOrLarger ? 10 : 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(note.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: isTabletOrLarger ? 13 : 11,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.add_task, 
                          size: isTabletOrLarger ? 22 : 20,
                        ),
                        onPressed: () => _showAddTaskDialog(context),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: isTabletOrLarger ? 40 : 36,
                          minHeight: isTabletOrLarger ? 40 : 36,
                        ),
                        tooltip: 'Add Task',
                      ),
                      SizedBox(width: isTabletOrLarger ? 20 : 16),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                          size: isTabletOrLarger ? 22 : 20,
                        ),
                        onPressed: () => _confirmDelete(context),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: isTabletOrLarger ? 40 : 36,
                          minHeight: isTabletOrLarger ? 40 : 36,
                        ),
                        tooltip: 'Delete Note',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final textController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter task',
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              context.read<NoteProvider>().addTask(note.id, value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = textController.text.trim();
              if (value.isNotEmpty) {
                context.read<NoteProvider>().addTask(note.id, value);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // ignore: use_build_context_synchronously
      context.read<NoteProvider>().deleteNote(note.id);
    }
  }
} 