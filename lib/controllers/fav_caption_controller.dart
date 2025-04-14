import 'package:flutter/material.dart';
import 'package:unicap_cg/data/local/databse_helper.dart';
import 'package:unicap_cg/models/caption_category.dart';
import 'package:unicap_cg/models/fav_caption.dart';
import 'package:unicap_cg/services/fav_caption_service.dart';

class FavoriteCaptionController with ChangeNotifier {
  final FavoriteCaptionService _service = FavoriteCaptionService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<FavoriteCaption>? _favorites;
  bool _isLoading = false;

  List<FavoriteCaption>? get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadAndSyncFavorites(String userId) async {
    print('--------------inside loadFavorites---------');
    _favorites = null;
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try to sync with Firebase first
      _favorites = await _service.getFavCaptions(userId);
      print('=====favorites=========${favorites?.length}==============');
    } catch (e) {
      print('Error syncing favorites: $e');
      // Fallback to local cache if sync fails
      _favorites = await _dbHelper.getFavoriteCaptions(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFavorite(String userId, Caption caption) async {
    print('============Inside addFavorit=========');
    try {
      print('============Inside try=========');
      await _dbHelper.insertFavoriteCaption(FavoriteCaption(
        userId: userId,
        captionId: caption.key,
        caption: caption.caption,
        isSynced: false,
      ));

      await _service.addFavoriteCaption(FavoriteCaption(
        userId: userId,
        captionId: caption.key,
        caption: caption.caption,
        isSynced: false,
      ));

      await getAllFavCaptionsFromLocal(userId);

    } catch (e) {
      print('==============Error Inserting favorite favorite: ================$e');
      rethrow;
    }
  }

  Future<void> removeFavorite(String userId, String timestampKey) async {
    try {
      await _service.removeFavoriteCaption(userId, timestampKey);
      _favorites?.removeWhere((fav) => fav.captionId == timestampKey);
      notifyListeners();
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    }
  }

  bool? isCaptionFavorite(String caption) {
    return _favorites?.any((fav) => fav.caption == caption);
  }

  Future<void> getAllFavCaptionsFromLocal(String userId, {bool isUpdate = true}) async {
    _favorites = await _dbHelper.getFavoriteCaptions(userId);
    if(isUpdate){
      notifyListeners();
    }
  }
}