// ignore_for_file: constant_identifier_names, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: duplicate_ignore
enum TaskStatus {
  // ignore: constant_identifier_names
  Pending,
  Ignored,
}

class Task {
  String title;
  DateTime? deadline;
  TaskStatus status;
  String? remainingTime; // New property for remaining time

  Task({
    required this.title,
    this.deadline,
    this.status = TaskStatus.Pending,
    this.remainingTime,
  });
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Task> _todoItems = [];
  final TextEditingController _textController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Todo List'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Settings'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('System Default'),
                            onTap: () {
                              _toggleTheme(ThemeMode.system);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text('Light Mode'),
                            onTap: () {
                              _toggleTheme(ThemeMode.light);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text('Dark Mode'),
                            onTap: () {
                              _toggleTheme(ThemeMode.dark);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: _buildTodoList(),
      ),
    );
  }

  Widget _buildTodoList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Enter a task',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  _showDatePicker(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () {
                  _showTimePicker(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final newTitle = _textController.text;
                  if (newTitle.isNotEmpty) {
                    _addTodoItem(newTitle, _selectedDate, _selectedTime);
                    _textController.clear();
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _todoItems.length,
            itemBuilder: (BuildContext context, int index) {
              final task = _todoItems[index];
              return ListTile(
                leading: Checkbox(
                  value: task.status == TaskStatus.Ignored,
                  onChanged: (value) {
                    setState(() {
                      task.status = task.status = value ?? false
                          ? TaskStatus.Ignored
                          : TaskStatus.Pending;
                    });
                  },
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.status == TaskStatus.Ignored
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.deadline != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Deadline: ${DateFormat('MMM d, y').format(task.deadline!)} ${DateFormat.jm().format(task.deadline!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    if (task.remainingTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Remaining: ${task.remainingTime}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: CircleAvatar(
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _removeTodoItem(index);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _selectedTime = selectedTime;
      });
    }
  }

  void _addTodoItem(String title, DateTime? date, TimeOfDay? time) {
    final newTask = Task(
      title: title,
      deadline: _combineDateAndTime(date, time),
      status: TaskStatus.Pending,
    );

    // Calculate remaining time
    final now = DateTime.now();
    if (newTask.deadline != null && newTask.deadline!.isAfter(now)) {
      final difference = newTask.deadline!.difference(now);
      newTask.remainingTime = difference.inDays > 0
          ? '${difference.inDays}d ${difference.inHours % 24}h ${difference.inMinutes % 60}m'
          : '${difference.inHours}h ${difference.inMinutes % 60}m';
    }

    setState(() {
      _todoItems.add(newTask);
    });
  }

  DateTime? _combineDateAndTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) {
      return null;
    }
    final combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return combinedDateTime;
  }

  void _removeTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TodoListScreen(),
    );
  }
}
