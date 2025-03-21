import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/diary_controller.dart';

class DiaryScreen extends StatelessWidget {

  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
   String? userId = Provider.of<AuthController>(context, listen: false).user?.uid;

    return ChangeNotifierProvider(
      create: (_) => DiaryController()..fetchAndSaveNotes(userId ?? ''),
      child: Scaffold(
        appBar: AppBar(title: Text('Diary')),
        body: Consumer<DiaryController>(
          builder: (context, diaryController, child) {
            if (diaryController.notes.isEmpty) {
              return Center(child: Text('No notes found.'));
            } else {
              return ListView.builder(
                itemCount: diaryController.notes.length,
                itemBuilder: (context, index) {
                  final note = diaryController.notes[index];
                  return ListTile(
                    title: Text(note['note']),
                    subtitle: Text(note['isSynced'] == 1 ? 'Synced' : 'Not Synced'),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            String note = 'Sample note content';
            await Provider.of<DiaryController>(context, listen: false).saveNote(userId ?? '', note);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}