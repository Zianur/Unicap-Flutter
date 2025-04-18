import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unicap_cg/data/local/databse_helper.dart';
import '../models/diary_entry.dart';
import '../models/caption_category.dart';
import '../models/caption.dart';

class FirebaseService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Connectivity _connectivity = Connectivity();

  /// Caption
  Future<List<CaptionCategory>> fetchCategories() async {
    final DatabaseReference databaseRef = _databaseRef.child("Omnia").child("AllCaptions");
    //for caching data
    databaseRef.keepSynced(true);

    List<CaptionCategory> categories = [];

    try {
      // Fetch data from the 'AllCaptions' node
      DatabaseEvent event = await databaseRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        // Convert the snapshot value to a Map
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        // Iterate through each category (e.g., Aesthetic, Alone, Angry)
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            // Create a CaptionCategory object and add it to the list
            categories.add(CaptionCategory.fromMap(value));
          }
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }

    return categories;
  }


  /// Diary
  // Fetch notes from Firebase and save/update them locally
  Future<Map<dynamic, dynamic>?> fetchAndSaveNotes(String userId) async {
    try {
      DatabaseEvent event = await _databaseRef.child('User/${int.parse(userId)}/Note').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        final Map<dynamic, dynamic> notesMap = snapshot.value as Map<dynamic, dynamic>;
        return notesMap;
      }

      return null;
    } catch (e) {
      print('Error fetching notes: $e');
      return null;
    }
  }

  // Save a note locally and sync with Firebase
  Future<void> saveNote(String userId, String noteId, String noteName, String note) async {



    // Save the note locally
    /// todo - need to check the need of this line here
    // await _dbHelper.insertNote(userId, noteId, noteName, note, false);

    // Check internet connection
    var connectivityResult = await _connectivity.checkConnectivity();
    bool isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      // Save the note to Firebase
      await _databaseRef.child('User/$userId/Note/$noteId').set({'name': noteName, 'note': note});
      await _dbHelper.updateSyncStatus(noteId, true); // Mark as synced
    }
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
  }


  Future<void> removeNote(String userId, String noteId) async {
    try {
      await _databaseRef
          .child('User/$userId')
          .child('Note')
          .child(noteId)
          .remove();
    } catch (e) {
      print('=====Remove============Error removing favorite caption:================= $e');
      throw Exception('Failed to remove favorite caption');
    }
  }
}
