class Todo {
  final int? id;
  final String title;
  final String description;
  final bool completed;
  final String date;

  Todo({
    this.id,
    required this.title,
    required this.description,
    this.completed = false,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed ? 1 : 0,
      'date': date,
    };
  }

  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      completed: map['completed'] == 1,
      date: map['date'],
    );
  }

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    String? date,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      date: date ?? this.date,
    );
  }
} 