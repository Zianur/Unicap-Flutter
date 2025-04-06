import 'package:flutter/material.dart';
import '../models/caption_category.dart';
import '../services/firebase_service.dart';

class CaptionCategoryController extends ChangeNotifier {
  final FirebaseService _firebaseService;

  List<CaptionCategory>? _categories;
  List<CaptionCategory>? get categories => _categories;

  List<Caption> _captions = [];
  List<Caption> get captions => _captions;

  CaptionCategoryController(this._firebaseService);

  Future<void> loadCategories() async {
    debugPrint('==============inside loadCategories========');
    try{
      _categories = null;

      // Fetch from Firebase and update the local database
      final captionCategories = await _firebaseService.fetchCategories();
      if (captionCategories.isNotEmpty) {
        _categories = captionCategories;
      }
      notifyListeners();
    }catch(e){
      debugPrint('$e');
    }
  }
}
