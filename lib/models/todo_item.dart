class TodoItem {
  int? id;
  String title;
  String description;
  String category;
  String priority;
  String? dueDate;
  bool isCompleted;
  String createdAt;

  TodoItem({
    this.id,
    required this.title,
    this.description = '',
    this.category = 'Umum',
    this.priority = 'Sedang',
    this.dueDate,
    this.isCompleted = false,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  // Konversi dari Map (Database SQLite) ke Object TodoItem
  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Umum',
      priority: map['priority'] as String? ?? 'Sedang',
      dueDate: map['due_date'] as String?,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  // Konversi dari Object TodoItem ke Map untuk disimpan di Database SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'due_date': dueDate,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Factory fromJson untuk kesesuaian modul
  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem.fromMap(json);

  // toJson untuk kesesuaian modul
  Map<String, dynamic> toJson() => toMap();

  TodoItem copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? dueDate,
    bool? isCompleted,
    String? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

