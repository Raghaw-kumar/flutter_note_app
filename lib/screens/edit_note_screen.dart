import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _taskController;
  late List<Task> _tasks;
  bool _isEdited = false;
  final FocusNode _taskFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _taskController = TextEditingController();
    _tasks = List.from(widget.note?.tasks ?? []);

    _titleController.addListener(_markAsEdited);
    _contentController.addListener(_markAsEdited);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _taskController.dispose();
    _taskFocusNode.dispose();
    super.dispose();
  }

  void _markAsEdited() {
    if (!_isEdited) {
      setState(() => _isEdited = true);
    }
  }

  void _addTask(String content) {
    setState(() {
      _tasks.add(Task(content: content));
      _markAsEdited();
    });
  }

  void _toggleTask(int index) {
    setState(() {
      final task = _tasks[index];
      _tasks[index] = Task(
        id: task.id,
        content: task.content,
        isCompleted: !task.isCompleted,
        createdAt: task.createdAt,
      );
      _markAsEdited();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _markAsEdited();
    });
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
      _markAsEdited();
    });
  }

  Future<bool> _onWillPop() async {
    if (!_isEdited) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (content.isEmpty && title.isEmpty && _tasks.isEmpty) {
      return;
    }

    final noteProvider = context.read<NoteProvider>();

    if (widget.note != null) {
      await noteProvider.updateNote(
        widget.note!.copyWith(
          title: title,
          content: content,
          tasks: _tasks,
        ),
      );
    } else {
      await noteProvider.addNote(title, content, tasks: _tasks);
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void _handleTaskSubmitted(String value) {
    final task = value.trim();
    if (task.isNotEmpty) {
      setState(() {
        _tasks.add(Task(content: task));
        _markAsEdited();
      });
      _taskController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTabletOrLarger = width >= 600;
    final isLargeScreen = width >= 900;
    final padding = MediaQuery.of(context).padding;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    Widget content = Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTabletOrLarger ? 24 : 16,
              vertical: 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 800,
                minHeight: MediaQuery.of(context).size.height - kToolbarHeight - padding.top - padding.bottom - 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: isTabletOrLarger ? 24 : 20,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: isTabletOrLarger ? 16 : 12),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Note',
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: isTabletOrLarger ? 18 : 16,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  if (_tasks.isNotEmpty) ...[
                    SizedBox(height: isTabletOrLarger ? 24 : 16),
                    Row(
                      children: [
                        Text(
                          'Tasks',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: isTabletOrLarger ? 20 : 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${_tasks.where((t) => t.isCompleted).length}/${_tasks.length})',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: isTabletOrLarger ? 16 : 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTabletOrLarger ? 16 : 12),
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _tasks.length,
                      onReorder: _reorderTasks,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Dismissible(
                          key: ValueKey(task.id),
                          background: Container(
                            color: Theme.of(context).colorScheme.error,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteTask(index),
                          child: Card(
                            margin: EdgeInsets.symmetric(
                              vertical: isTabletOrLarger ? 4 : 3,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTabletOrLarger ? 12 : 8,
                                vertical: isTabletOrLarger ? 8 : 6,
                              ),
                              child: Row(
                                children: [
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Icon(
                                      Icons.drag_handle,
                                      size: isTabletOrLarger ? 24 : 20,
                                    ),
                                  ),
                                  SizedBox(width: isTabletOrLarger ? 12 : 8),
                                  SizedBox(
                                    width: isTabletOrLarger ? 24 : 20,
                                    height: isTabletOrLarger ? 24 : 20,
                                    child: Transform.scale(
                                      scale: textScaleFactor > 1 ? 1 : textScaleFactor,
                                      child: Checkbox(
                                        value: task.isCompleted,
                                        onChanged: (_) => _toggleTask(index),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isTabletOrLarger ? 12 : 8),
                                  Expanded(
                                    child: Text(
                                      task.content,
                                      style: TextStyle(
                                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                        color: task.isCompleted
                                            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                            : null,
                                        fontSize: isTabletOrLarger ? 16 : 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTabletOrLarger ? 16 : 8,
              vertical: isTabletOrLarger ? 12 : 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _taskController,
                        focusNode: _taskFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Add a task...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isTabletOrLarger ? 20 : 16,
                            vertical: isTabletOrLarger ? 16 : 12,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: isTabletOrLarger ? 16 : 14,
                        ),
                        onSubmitted: _handleTaskSubmitted,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        size: isTabletOrLarger ? 24 : 20,
                      ),
                      onPressed: () => _handleTaskSubmitted(_taskController.text),
                      tooltip: 'Add Task',
                      padding: EdgeInsets.all(isTabletOrLarger ? 12 : 8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (isLargeScreen) {
      content = Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: content,
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.note != null ? 'Edit Note' : 'New Note',
            style: TextStyle(
              fontSize: isTabletOrLarger ? 20 : 18,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.check,
                size: isTabletOrLarger ? 24 : 20,
              ),
              onPressed: _saveNote,
              tooltip: 'Save',
            ),
          ],
        ),
        body: content,
      ),
    );
  }
} 