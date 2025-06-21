import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskPreferences {
  static final _collection = FirebaseFirestore.instance.collection('tasks');

  static Future<void> saveTasks(List<Task> tasks) async {
    print("🔄 Saving ${tasks.length} tasks to Firestore...");
    final snapshot = await _collection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    for (final task in tasks) {
      await _collection.add(task.toMap());
    }
    print("✅ Tasks saved.");
  }

  static Future<List<Task>> loadTasks() async {
    print("📥 Loading tasks...");
    final snapshot = await _collection.get();
    final taskList = snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
    print("📋 Loaded ${taskList.length} tasks.");
    return taskList;
  }
}
