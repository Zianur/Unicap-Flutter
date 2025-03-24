import 'package:flutter/material.dart';
import '../models/caption_category.dart';
import '../services/firebase_service.dart';
import '../services/local_db_service.dart';

class CaptionCategoryController extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final LocalDBService _localDBService;

  List<CaptionCategory> _categories = [];
  List<CaptionCategory> get categories => _categories;

  List<Caption> _captions = [];
  List<Caption> get captions => _captions;

  CaptionCategoryController(this._firebaseService, this._localDBService);

  Future<void> loadCategories() async {

    // Fetch from Firebase and update the local database
    final captionCategories = await _firebaseService.fetchCategories();
    print('----------------checkData------------$captionCategories}');
    if (captionCategories.isNotEmpty) {
      _categories = captionCategories;
      notifyListeners();
    }
  }
}
