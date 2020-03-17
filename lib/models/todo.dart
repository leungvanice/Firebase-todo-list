class Todo {
  String id;
  String title;
  bool completed;

  Todo({this.id, this.title, this.completed});

  factory Todo.fromJson(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      completed: map['completed'],
    );
  }

  toJson() {
    return {
      'title': title,
      'completed': completed,
    };
  }
}
