import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/caption_category.dart';
import '../services/firebase_service.dart';

class CaptionCategoryController extends ChangeNotifier {
  final FirebaseService firebaseService;

  CaptionCategoryController({required this.firebaseService});

  List<CaptionCategory>? _categories;
  List<CaptionCategory>? get categories => _categories;

  List<Caption>? _captions;
  List<Caption>? get captions => _captions;

  Future<void> loadCategories() async {
    debugPrint('==============inside loadCategories========');
    try{
      _categories = null;

      // Fetch from Firebase and update the local database
      final captionCategories = await firebaseService.fetchCategories();
      if (captionCategories.isNotEmpty) {
        _categories = captionCategories;
      }
      notifyListeners();
    }catch(e){
      debugPrint('$e');
    }
  }

  Future<void> getCaptions(CaptionCategory category) async {
    _captions = category.captions ?? [];
    notifyListeners();
  }

  void filterCategories({required String queryText}) async {
    if(queryText.isEmpty){
      /// todo - need to work on the caching
      await loadCategories();
    }
    else{
      _categories = _categories?.where((category) {
        return category.name?.toLowerCase().contains(queryText.toLowerCase()) ?? false;
      }).toList();
    }

    notifyListeners();
  }

  void filterCaptions({required String queryText, required CaptionCategory category}) async {
    if(queryText.isEmpty){
      getCaptions(category);
    }
    else{
      _captions = _captions?.where((caption) {
        return caption.caption.toLowerCase().contains(queryText.toLowerCase());
      }).toList();
    }

    notifyListeners();
  }
}
