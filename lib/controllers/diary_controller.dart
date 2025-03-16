import 'dart:async';
import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/firebase_service.dart';
import '../services/local_db_service.dart';

class DiaryController extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final LocalDBService _localDBService;
  List<DiaryEntry> _entries = [];
  List<DiaryEntry> get entries => _entries;

  DiaryController(this._firebaseService, this._localDBService);

  Future<void> loadEntries(String userId) async {
    _entries = await _localDBService.getDiaryEntries();
    notifyListeners();

    if (userId.isNotEmpty) {
      final onlineEntries = await _firebaseService.fetchDiaryEntries(userId);
      if (onlineEntries.isNotEmpty) {
        _entries = onlineEntries;
        await _localDBService.insertDiaryEntries(_entries);
        notifyListeners();
      }
    }
  }

  Future<void> addEntry(String userId, DiaryEntry entry) async {
    _entries.add(entry);
    await _localDBService.insertDiaryEntry(entry);
    notifyListeners();

    if (userId.isNotEmpty) {
      Timer.periodic(Duration(seconds: 10), (timer) async {
        await _firebaseService.uploadDiaryEntry(userId, entry);
        timer.cancel();
      });
    }
  }
}
