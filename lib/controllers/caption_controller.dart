import 'package:flutter/material.dart';
import '../models/caption_category.dart';
import '../models/caption.dart';
import '../services/firebase_service.dart';
import '../services/local_db_service.dart';

class CaptionController extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final LocalDBService _localDBService;

  List<CaptionCategory> _categories = [];
  List<CaptionCategory> get categories => _categories;

  List<Caption> _captions = [];
  List<Caption> get captions => _captions;

  CaptionController(this._firebaseService, this._localDBService);

  Future<void> loadCategories() async {
    print('-------inside load categories----------------------');
    // Load from local database first
    // _categories = await _localDBService.getCategories();
    // notifyListeners();

    // Fetch from Firebase and update the local database
    final onlineCategories = await _firebaseService.fetchCategories();
    print('----------------checkData------------$onlineCategories}');
    if (onlineCategories.isNotEmpty) {
      _categories = onlineCategories;
      // await _localDBService.insertCategories(_categories);
      notifyListeners();
    }
  }

  // Future<void> loadCaptions(String categoryId) async {
  //   // Clear previous captions
  //   _captions = [];
  //   notifyListeners();
  //
  //   // Fetch from Firebase
  //   final onlineCaptions = await _firebaseService.fetchCaptions(categoryId);
  //   _captions = onlineCaptions;
  //   notifyListeners();
  // }
}
