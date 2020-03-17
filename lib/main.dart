import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'models/todo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final db = Firestore.instance;
  final todoCollection = Firestore.instance.collection('todos');
  TextEditingController todoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: todoCollection.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                return new ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return new ListTile(
                        title: new Text(document['title']),
                        trailing: Checkbox(
                          value: document['completed'],
                          onChanged: (val) async {
                            Todo updatedTodo =
                                Todo(title: document['title'], completed: val);
                            await updateData(document.documentID, updatedTodo);
                          },
                        ));
                  }).toList(),
                );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: showAlert,
        tooltip: 'Create todo',
        child: Icon(Icons.add),
      ),
    );
  }

  Future showAlert() async {
    return showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Create Todo"),
        content: TextField(
          controller: todoController,
          decoration: InputDecoration(
            hintText: 'new todo',
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
              todoController.clear();
            },
          ),
          FlatButton(
            child: Text("Save"),
            onPressed: () async {
              Todo newTodo = Todo(title: todoController.text, completed: false);
              todoController.clear();
              Navigator.pop(context);
              await createTodo(newTodo);
            },
          ),
        ],
      ),
    );
  }

  createTodo(Todo newTodo) async {
    await todoCollection.add(newTodo.toJson());
  }

  updateData(String documentId, Todo todo) async {
    await todoCollection.document(documentId).updateData(todo.toJson());
  }
}
