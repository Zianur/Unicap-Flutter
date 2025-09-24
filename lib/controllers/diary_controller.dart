import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:unicap_cg/data/local/databse_helper.dart';
import 'package:unicap_cg/di_container.dart';
import 'package:unicap_cg/helper/network_info.dart';
import 'package:unicap_cg/models/diary_entry.dart';
import 'package:unicap_cg/services/firebase_service.dart';

class DiaryController with ChangeNotifier {

  final DatabaseHelper dbHelper;
  final FirebaseService firebaseService;

  DiaryController({required this.dbHelper, required this.firebaseService});

  // List of notes
  List<DiaryEntry>? _notes;
  List<DiaryEntry>? get notes => _notes;
  bool _isLoading = false;
  bool get isLoading => _isLoading;


  // Sync unsynced notes with Firebase
  Future<void> syncUnsyncedNotes(String userId) async {
    if(await _canUploadToFirebase(userId)){
      await firebaseService.syncUnsyncedNotes(userId);
    }

    await fetchAndSaveNotes(userId);
  }

  Future<bool> _canUploadToFirebase(String userId) async => await isUserOnline() && userId != 'guest';



  /// Refactor this method by following the favorite caption controller
  // Fetch notes from Firebase and save/update them locally
  Future<void> fetchAndSaveNotes(String userId) async {
    try {

      Map<dynamic, dynamic>? notesMap;
      if(await _canUploadToFirebase(userId)){
        notesMap = await firebaseService.fetchAndSaveNotes(userId);
      }
      debugPrint('================Fetched notes map: ${jsonEncode(notesMap)}');


      for (var noteId in notesMap?.keys ?? {}) {
        var noteData = notesMap?[noteId];

        // Only process entries where value is a Map (i.e., valid note)
        if (noteData is Map) {
          String noteName = noteData['name'] ?? 'noteName';
          String noteContent = noteData['note'] ?? '';

          debugPrint('--------note----------$noteId');
          debugPrint('--------note name----------$noteName');
          debugPrint('--------note content----------$noteContent');

          bool noteExists = await dbHelper.noteExists(userId, noteId);
          if (noteExists) {
            await dbHelper.updateNote(userId, noteId, noteName, noteContent, true);
          } else {
            await dbHelper.insertNote(userId, noteId, noteName, noteContent, true);
          }
        } else {
          debugPrint('⚠️ Skipped invalid note: ID=$noteId | value=$noteData');
        }
      }

      // Update the local notes list
      await getAllNotesFromLocal(userId);
      notifyListeners();

      debugPrint('=========userId===========$userId');
      debugPrint('=========NOTES===========${_notes?.length}');
      debugPrint('=========NOTES===========$_notes');
    } catch (e) {
      debugPrint('=========Error fetching notes=======: $e');
    }
  }



  // Save a note locally and sync with Firebase
  Future<void> saveNote(String userId, String noteName, String? noteId, String note) async {
    debugPrint('=============inside saveNote userId==============$userId');
    debugPrint('=============inside note==============$note');
    _isLoading = true;
    notifyListeners();

    bool isOnline = await isUserOnline();

    // bool noteExists = await dbHelper.noteExists(userId, noteId);

    if (noteId?.isNotEmpty ?? false) {
      debugPrint('=============inside noteId != null==============');
      // Update the existing note
      await dbHelper.updateNote(userId, noteId!, noteName, note, isOnline ? true : false);
    } else {
      debugPrint('=============inside noteId == null==============');

      noteId = DateTime.now().millisecondsSinceEpoch.toString();
      debugPrint('=============noteId ==============$noteId');
      await dbHelper.insertNote(userId, noteId, noteName, note, false);
    }
    if (isOnline && userId != 'guest'){
      debugPrint('=============inside isonline==============');
      await firebaseService.saveNote(userId, noteId, noteName, note);
    }

    await getAllNotesFromLocal(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> isUserOnline() async {
    bool isOnline = await sl<NetworkInfo>().isConnected;
    return isOnline;
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
    List<Map<String, dynamic>> mapList = await dbHelper.getNotes(userId);
    _notes = mapList.map((element)=> DiaryEntry.fromMap(element)).toList();
    print('=============notes length==================${_notes?.length}');
  }



  Future<void> removeNote(String userId, String noteId) async {
    try {
      print('===========================inside removeNote==================${_notes?.length}');
      await dbHelper.deleteNote(userId, noteId);

      if(await isUserOnline()){
        await firebaseService.removeNote(userId, noteId);
      }

      await fetchAndSaveNotes(userId);
      notifyListeners();
    } catch (e) {
      print('==================Error Removing notes: $e===================');
      rethrow;
    }
  }
}