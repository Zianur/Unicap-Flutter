import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import '../models/diary_entry.dart';
import '../models/caption_category.dart';
import '../models/caption.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> uploadDiaryEntry(String userId, DiaryEntry entry) async {
    await _db.child('users/$userId/diary/${entry.id}').set(entry.toMap());
  }

  Future<List<DiaryEntry>> fetchDiaryEntries(String userId) async {
    final snapshot = await _db.child('users/$userId/diary').get();
    if (!snapshot.exists) return [];
    return (snapshot.value as Map).values.map((e) =>
        DiaryEntry.fromMap(Map<String, dynamic>.from(e))).toList();
  }


  Future<List<CaptionCategory>> fetchCategories() async {
    final DatabaseReference databaseRef = _db.child("Omnia").child("AllCaptions");
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

  //
  // Future<List<Caption>> fetchCaptions(String categoryId) async {
  //   final snapshot = await _db.child('captions/$categoryId').get();
  //   if (!snapshot.exists) return [];
  //   return (snapshot.value as Map).values.map((e) => Caption.fromMap(Map<String, dynamic>.from(e))).toList();
  // }
}
