import 'package:firebase_database/firebase_database.dart';
import 'package:unicap_cg/data/local/databse_helper.dart';

class DiaryService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Save a note locally and sync with Firebase
  Future<void> saveNote(String userId, String noteId, String note) async {
    final dbHelper = DatabaseHelper();

    // Save the note locally
    await dbHelper.insertNote(userId, noteId, note, false);

    // Check internet connection (you can use a package like `connectivity`)
    bool isOnline = await checkInternetConnection();

    if (isOnline) {
      // Save the note to Firebase
      await _databaseRef.child('User/$userId/Note/$noteId').set({'note': note});
      await dbHelper.updateSyncStatus(noteId, true); // Mark as synced
    }
  }

  // Fetch all notes from Firebase and save them locally
  Future<void> fetchAndSaveNotes(String userId) async {
    final dbHelper = DatabaseHelper();

    try {
      DatabaseEvent event = await _databaseRef.child('User/$userId/Note').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> notes = snapshot.value as Map<dynamic, dynamic>;

        notes.forEach((noteId, noteData) async {
          String note = noteData['note'];
          await dbHelper.insertNote(userId, noteId, note, true); // Save to SQLite
        });
      }
    } catch (e) {
      print('Error fetching notes: $e');
    }
  }

  // Sync unsynced notes with Firebase
  Future<void> syncUnsyncedNotes(String userId) async {
    final dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> unsyncedNotes = await dbHelper.getUnsyncedNotes();

    for (var note in unsyncedNotes) {
      String noteId = note['noteId'];
      String noteContent = note['note'];

      await _databaseRef.child('User/$userId/Note/$noteId').set({'note': noteContent});
      await dbHelper.updateSyncStatus(noteId, true); // Mark as synced
    }
  }

  // Dummy method to check internet connection (use a package like `connectivity`)
  Future<bool> checkInternetConnection() async {
    // Implement your logic to check internet connectivity
    return true; // Assume online for this example
  }
}