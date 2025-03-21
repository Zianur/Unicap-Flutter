import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:unicap_cg/data/local/databse_helper.dart';

class DiaryController with ChangeNotifier {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Connectivity _connectivity = Connectivity();

  // List of notes
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> get notes => _notes;

  // Fetch notes from Firebase and save/update them locally
  Future<void> fetchAndSaveNotes(String userId) async {
    try {
      DatabaseEvent event = await _databaseRef.child('User/$userId/Note').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> notesMap = snapshot.value as Map<dynamic, dynamic>;

        for (var noteId in notesMap.keys) {
          String noteContent = notesMap[noteId]['note'];
          print('--------note----------${noteContent}');

          // Check if the note already exists in the local database
          bool noteExists = await _dbHelper.noteExists(userId, noteId);

          if (noteExists) {
            // Update the existing note
            await _dbHelper.updateNote(userId, noteId, noteContent, true);
          } else {
            // Insert the note into the local database if it doesn't exist
            await _dbHelper.insertNote(userId, noteId, noteContent, true);
          }
        }

        // Update the local notes list
        _notes = await _dbHelper.getNotes(userId);
        print('=========NOTES===========${_notes.length}');
        print('=========NOTES===========$_notes');
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching notes: $e');
    }
  }

  // Save a note locally and sync with Firebase
  Future<void> saveNote(String userId, String note) async {
    String noteId = DateTime.now().millisecondsSinceEpoch.toString();

    // Save the note locally
    await _dbHelper.insertNote(userId, noteId, note, false);

    // Check internet connection
    var connectivityResult = await _connectivity.checkConnectivity();
    bool isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      // Save the note to Firebase
      await _databaseRef.child('User/$userId/Note/$noteId').set({'note': note});
      await _dbHelper.updateSyncStatus(noteId, true); // Mark as synced
    }

    // Update the local notes list
    _notes = await _dbHelper.getNotes(userId);

    notifyListeners();
  }

  // Sync unsynced notes with Firebase
  Future<void> syncUnsyncedNotes(String userId) async {
    List<Map<String, dynamic>> unsyncedNotes = await _dbHelper.getUnsyncedNotes();

    for (var note in unsyncedNotes) {
      String noteId = note['noteId'];
      String noteContent = note['note'];

      await _databaseRef.child('User/$userId/Note/$noteId').set({'note': noteContent});
      await _dbHelper.updateSyncStatus(noteId, true); // Mark as synced
    }

    // Update the local notes list
    _notes = await _dbHelper.getNotes(userId);
    notifyListeners();
  }
}