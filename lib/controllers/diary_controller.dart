import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:unicap_cg/data/local/databse_helper.dart';
import 'package:unicap_cg/models/diary_entry.dart';
import 'package:unicap_cg/services/firebase_service.dart';

class DiaryController with ChangeNotifier {
  // final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Connectivity _connectivity = Connectivity();
  final FirebaseService _service =  FirebaseService();

  // List of notes
  List<DiaryEntry>? _notes;
  List<DiaryEntry>? get notes => _notes;


  /// Refactor this method by following the favorite caption controller
  // Fetch notes from Firebase and save/update them locally
  Future<void> fetchAndSaveNotes(String userId) async {
    try {
      // _notes = null;
      // notifyListeners();

      Map<dynamic, dynamic>? notesMap = await _service.fetchAndSaveNotes(userId);

      for (var noteId in notesMap?.keys ?? {}) {
        String noteName = notesMap?[noteId]['name'] ?? 'noteName';
        String noteContent = notesMap?[noteId]['note'];
        debugPrint('--------note----------${noteId}');

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
      debugPrint('=========NOTES===========${_notes?.length}');
      debugPrint('=========NOTES===========$_notes');

      notifyListeners();
    } catch (e) {
      debugPrint('=========Error fetching notes=======: $e');
    }
  }

  // Save a note locally and sync with Firebase
  Future<void> saveNote(String userId, String noteName, String note) async {
    var connectivityResult = await _connectivity.checkConnectivity();
    bool isOnline = connectivityResult != ConnectivityResult.none;

    final String noteId = DateTime.now().millisecondsSinceEpoch.toString();
    bool noteExists = await _dbHelper.noteExists(userId, noteId);

    if (noteExists) {
      // Update the existing note
      await _dbHelper.updateNote(userId, noteId, noteName, note, isOnline ? true : false);
    } else {
      // Insert the note into the local database if it doesn't exist
      await _dbHelper.insertNote(userId, noteId, noteName, note, isOnline ? true : false);
    }
    if(isOnline){
      await _service.saveNote(userId, noteId, noteName, note);
    }

    getAllNotesFromLocal(userId);
    notifyListeners();
  }

  // Sync unsynced notes with Firebase
  Future<void> syncUnsyncedNotes(String userId) async {
    await _service.syncUnsyncedNotes(userId);
    await fetchAndSaveNotes(userId);
  }

 void filterNotes({required String queryText, required String userId}) async {
    if(queryText.isEmpty){
     await getAllNotesFromLocal(userId);
    }
    else{
      _notes = _notes?.where((note) {
        final titleMatches = note.noteName.toLowerCase().contains(queryText.toLowerCase());
        final contentMatches = note.note.toLowerCase().contains(queryText.toLowerCase());
        return titleMatches || contentMatches;
      }).toList();
    }

    notifyListeners();
  }


  Future<void> getAllNotesFromLocal(String userId) async {
    List<Map<String, dynamic>> mapList = await _dbHelper.getNotes(userId);
    _notes = mapList.map((element)=> DiaryEntry.fromMap(element)).toList();
  }

  Future<void> removeNote(String userId, String noteId) async {
    try {
      await _service.removeNote(userId, noteId);
      await _dbHelper.deleteNote(userId, noteId);
      await fetchAndSaveNotes(userId);
      notifyListeners();
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    }
  }
}