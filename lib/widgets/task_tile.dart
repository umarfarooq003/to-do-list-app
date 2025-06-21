import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: Checkbox(value: task.isDone, onChanged: (_) => onChanged()),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.dueDate != null)
              Text("Due: ${DateFormat('MM/dd/yyyy').format(task.dueDate!)}"),
            Row(
              children: [
                Chip(
                  label: Text(task.category),
                  backgroundColor: Color(int.parse(task.categoryColor)),
                ),
                SizedBox(width: 10),
                Text("Priority: ${task.priority}"),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: onDelete,
        ),
        tileColor: task.isDone ? Colors.grey[200] : null,
      ),
    );
  }
}
