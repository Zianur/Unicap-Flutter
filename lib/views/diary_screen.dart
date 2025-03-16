import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_entry.dart';
import 'package:uuid/uuid.dart';

class DiaryScreen extends StatefulWidget {
  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final diaryController = Provider.of<DiaryController>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Diary")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: "Write your diary..."),
              maxLines: 5,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final entry = DiaryEntry(
                id: Uuid().v4(),
                title: _titleController.text,
                content: _contentController.text,
                date: DateTime.now(),
              );
              diaryController.addEntry("", entry); // "" since we aren't checking login yet
              _titleController.clear();
              _contentController.clear();
            },
            child: Text("Save"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: diaryController.entries.length,
              itemBuilder: (context, index) {
                final entry = diaryController.entries[index];
                return ListTile(
                  title: Text(entry.title),
                  subtitle: Text(entry.content),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
