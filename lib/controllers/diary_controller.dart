import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unicap_cg/data/local/databse_helper.dart';
import 'package:unicap_cg/models/diary_entry.dart';
import 'package:unicap_cg/services/firebase_service.dart';

class DiaryController with ChangeNotifier {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // final Connectivity _connectivity = Connectivity();
  FirebaseService firebaseService = FirebaseService();

  // List of notes
  List<DiaryEntry> _notes = [];
  List<DiaryEntry> get notes => _notes;

  // Fetch notes from Firebase and save/update them locally
  Future<void> fetchAndSaveNotes(String userId) async {
    try {
      Map<dynamic, dynamic>? notesMap = await firebaseService.fetchAndSaveNotes(userId);
      for (var noteId in notesMap?.keys ?? {}) {
        String noteName = notesMap?[noteId]['name'] ?? 'noteName';
        String noteContent = notesMap?[noteId]['note'];
        print('--------note----------${noteId}');

        // Check if the note already exists in the local database
        bool noteExists = await _dbHelper.noteExists(userId, noteId);

        if (noteExists) {
          // Update the existing note
          await _dbHelper.updateNote(userId, noteId, noteName, noteContent, true);
        } else {
          // Insert the note into the local database if it doesn't exist
          await _dbHelper.insertNote(userId, noteId, noteName, noteContent, true);
        }
      }
      // Update the local notes list
      List<Map<String, dynamic>> mapList = await _dbHelper.getNotes(userId);
      _notes = mapList.map((element)=> DiaryEntry.fromMap(element)).toList();
      print('=========NOTES===========${_notes.length}');
      print('=========NOTES===========$_notes');
      notifyListeners();
    } catch (e) {
      print('=========Error fetching notes=======: $e');
    }
  }

  // Save a note locally and sync with Firebase
  Future<void> saveNote(String userId, String noteName, String note) async {
    await firebaseService.saveNote(userId, noteName, note);
    // Update the local notes list
    List<Map<String, dynamic>> mapList = await _dbHelper.getNotes(userId);
    _notes = mapList.map((element)=> DiaryEntry.fromMap(element)).toList();
    notifyListeners();
  }

  // Sync unsynced notes with Firebase
  Future<void> syncUnsyncedNotes(String userId) async {
    await firebaseService.syncUnsyncedNotes(userId);
    // Update the local notes list
    List<Map<String, dynamic>> mapList = await _dbHelper.getNotes(userId);
    _notes = mapList.map((element)=> DiaryEntry.fromMap(element)).toList();
    notifyListeners();
  }

  List<DiaryEntry> filterNotes(String query) {
    return _notes.where((note) {
      final titleMatches = note.noteId.toLowerCase().contains(query.toLowerCase());
      final contentMatches = note.noteId.toLowerCase().contains(query.toLowerCase());
      return titleMatches || contentMatches; // Match if either title or content contains the query
    }).toList();
  }
}