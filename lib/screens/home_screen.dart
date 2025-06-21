// home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/task.dart';
import '../utils/preferences.dart';
import '../widgets/task_tile.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  HomeScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  final titleController = TextEditingController();
  String priority = 'Medium';
  String category = 'General';
  Color categoryColor = Colors.blue;
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    loadTasks();
  }

  Future<void> loadTasks() async {
    tasks = await TaskPreferences.loadTasks();
    setState(() {});
  }

  void saveTasks() => TaskPreferences.saveTasks(tasks);

  void scheduleNotification(Task task) async {
    if (task.dueDate == null) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.title.hashCode,
      '📝 Task Reminder',
      task.title,
      tz.TZDateTime.from(task.dueDate!, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Reminders',
          channelDescription: 'Reminds you about your tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  void addTask() {
    if (titleController.text.trim().isEmpty) return;
    final newTask = Task(
      title: titleController.text,
      priority: priority,
      category: category,
      categoryColor: categoryColor.value.toString(),
      dueDate: dueDate,
    );

    setState(() {
      tasks.add(newTask);
      titleController.clear();
      priority = 'Medium';
      category = 'General';
      categoryColor = Colors.blue;
      dueDate = null;
    });

    saveTasks();
    scheduleNotification(newTask);
  }

  void toggleDone(int index) {
    setState(() => tasks[index].isDone = !tasks[index].isDone);
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() => tasks.removeAt(index));
    saveTasks();
  }

  Future<void> pickDueDateTime(BuildContext context) async {
    final DateTime now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void pickCategoryColor() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Pick Category Color"),
        content: BlockPicker(
          pickerColor: categoryColor,
          onColorChanged: (color) => setState(() => categoryColor = color),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Done"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Task title',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: addTask,
                    ),
                  ),
                  onSubmitted: (_) => addTask(),
                ),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: priority,
                      onChanged: (val) => setState(() => priority = val!),
                      items: ['Low', 'Medium', 'High']
                          .map((e) => DropdownMenuItem(child: Text(e), value: e))
                          .toList(),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: category,
                      onChanged: (val) => setState(() => category = val!),
                      items: ['General', 'Work', 'Personal']
                          .map((e) => DropdownMenuItem(child: Text(e), value: e))
                          .toList(),
                    ),
                    const SizedBox(width: 10),
                    TextButton.icon(
                      onPressed: () => pickDueDateTime(context),
                      icon: Icon(Icons.calendar_today),
                      label: Text(
                        dueDate != null
                            ? DateFormat('MM/dd/yyyy hh:mm a').format(dueDate!)
                            : 'Pick Date & Time',
                      ),
                    ),
                    IconButton(onPressed: pickCategoryColor, icon: Icon(Icons.color_lens)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = tasks.removeAt(oldIndex);
                  tasks.insert(newIndex, item);
                  saveTasks();
                });
              },
              children: [
                for (int index = 0; index < tasks.length; index++)
                  TaskTile(
                    key: ValueKey(tasks[index].title),
                    task: tasks[index],
                    onChanged: () => toggleDone(index),
                    onDelete: () => deleteTask(index),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
