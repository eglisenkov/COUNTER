import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class Subject {
  String name;
  int score;

  Subject(this.name, this.score);

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(json['name'], json['score']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Score Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScoreCounter(),
    );
  }
}

class ScoreCounter extends StatefulWidget {
  @override
  _ScoreCounterState createState() => _ScoreCounterState();
}

class _ScoreCounterState extends State<ScoreCounter> {
  List<Subject> subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        title: const Text(
          'University Score Counter',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 25, 80, 27)),
        ),
        actions: <Widget>[
          IconButton(
            icon: Image.asset(
              'images/1.png',
              width: 68,
              height: 68,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return _buildSubjectCounter(subjects[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        splashColor: Color.fromARGB(255, 25, 80, 27),
        backgroundColor: Colors.green[100],
        onPressed: _addSubject,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSubjectCounter(Subject subject) {
    return ListTile(
      title: Text(subject.name),
      subtitle: Text('Score: ${subject.score}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              setState(() {
                if (subject.score > 0) {
                  subject.score--;
                  _saveSubjects();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                subject.score++;
                _saveSubjects();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                subjects.remove(subject);
                _saveSubjects();
              });
            },
          ),
        ],
      ),
    );
  }

  void _addSubject() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('Add Subject'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Subject Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  String subjectName = controller.text;
                  if (subjectName.isNotEmpty) {
                    subjects.add(Subject(subjectName, 0));
                    _saveSubjects();
                  }
                  Navigator.of(context).pop();
                });
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _loadSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      List<String> subjectsJson = prefs.getStringList('subjects') ?? [];
      subjects =
          subjectsJson.map((e) => Subject.fromJson(jsonDecode(e))).toList();
    });
  }

  void _saveSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> subjectsJson =
        subjects.map((e) => jsonEncode(e.toJson())).toList();
    prefs.setStringList('subjects', subjectsJson);
  }
}
