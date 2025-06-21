class Task {
  String title;
  bool isDone;
  DateTime? dueDate;
  String priority;
  String category;
  String categoryColor;

  Task({
    required this.title,
    this.isDone = false,
    this.dueDate,
    this.priority = 'Medium',
    this.category = 'General',
    this.categoryColor = '4278190080',
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'category': category,
      'categoryColor': categoryColor,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      isDone: map['isDone'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      priority: map['priority'] ?? 'Medium',
      category: map['category'] ?? 'General',
      categoryColor: map['categoryColor'] ?? '4278190080',
    );
  }
}
