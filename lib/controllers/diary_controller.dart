import 'dart:convert';

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
  bool _isLoading = false;
  bool get isLoading => _isLoading;


  /// Refactor this method by following the favorite caption controller
  // Fetch notes from Firebase and save/update them locally
  Future<void> fetchAndSaveNotes(String userId) async {
    try {
      // _notes = null;
      // notifyListeners();

      Map<dynamic, dynamic>? notesMap = await _service.fetchAndSaveNotes(userId);
      print('================Fetched notes map: ${jsonEncode(notesMap)}');


      for (var noteId in notesMap?.keys ?? {}) {
        var noteData = notesMap?[noteId];

        // Only process entries where value is a Map (i.e., valid note)
        if (noteData is Map) {
          String noteName = noteData['name'] ?? 'noteName';
          String noteContent = noteData['note'] ?? '';

          debugPrint('--------note----------$noteId');
          debugPrint('--------note name----------$noteName');
          debugPrint('--------note content----------$noteContent');

          bool noteExists = await _dbHelper.noteExists(userId, noteId);
          if (noteExists) {
            await _dbHelper.updateNote(userId, noteId, noteName, noteContent, true);
          } else {
            await _dbHelper.insertNote(userId, noteId, noteName, noteContent, true);
          }
        } else {
          print('⚠️ Skipped invalid note: ID=$noteId | value=$noteData');
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
  Future<void> saveNote(String userId, String noteName, String? noteId, String note) async {
    print('=============inside noteName==============$noteName');
    print('=============inside note==============$note');
    _isLoading = true;
    notifyListeners();

    var connectivityResult = await _connectivity.checkConnectivity();
    bool isOnline = connectivityResult != ConnectivityResult.none;

    // bool noteExists = await _dbHelper.noteExists(userId, noteId);

    if (noteId?.isNotEmpty ?? false) {
      print('=============inside noteId != null==============');
      // Update the existing note
      await _dbHelper.updateNote(userId, noteId!, noteName, note, isOnline ? true : false);
    } else {
      print('=============inside noteId == null==============');
      noteId = DateTime.now().millisecondsSinceEpoch.toString();
      // Insert the note into the local database if it doesn't exist
      await _dbHelper.insertNote(userId, noteId, noteName, note, isOnline ? true : false);
    }
    if (isOnline){
      print('=============inside isonline==============');
      await _service.saveNote(userId, noteId, noteName, note);
    }

    await getAllNotesFromLocal(userId);

    _isLoading = false;
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
        final titleMatches = note.noteName?.toLowerCase().contains(queryText.toLowerCase()) ?? false;
        final contentMatches = note.note.toLowerCase().contains(queryText.toLowerCase());
        return titleMatches || contentMatches;
      }).toList();
    }

    notifyListeners();
  }


  Future<void> getAllNotesFromLocal(String userId) async {
    print('=============inside getAllNotesFromLocal==================');
    List<Map<String, dynamic>> mapList = await _dbHelper.getNotes(userId);
    _notes = mapList.map((element)=> DiaryEntry.fromMap(element)).toList();
    print('=============notes length==================${_notes?.length}');
  }

  Future<void> removeNote(String userId, String noteId) async {
    try {
      print('===========================inside removeNote==================${_notes?.length}');
      await _service.removeNote(userId, noteId);
      await _dbHelper.deleteNote(userId, noteId);
      await fetchAndSaveNotes(userId);
      notifyListeners();
    } catch (e) {
      print('==================Error Removing notes: $e===================');
      rethrow;
    }
  }
}