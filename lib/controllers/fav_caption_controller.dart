import 'package:flutter/material.dart';
import 'package:unicap_cg/data/local/databse_helper.dart';
import 'package:unicap_cg/models/fav_caption.dart';
import 'package:unicap_cg/services/fav_caption_service.dart';

class FavoriteCaptionController with ChangeNotifier {
  final FavoriteCaptionService _service = FavoriteCaptionService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<FavoriteCaption>? _favorites;
  bool _isLoading = false;

  List<FavoriteCaption>? get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites(String userId) async {
    print('--------------inside loadFavorites---------');
    _favorites = null;
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try to sync with Firebase first
      _favorites = await _service.syncFavoriteCaptions(userId);
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

  Future<void> addFavorite(String userId, String caption) async {
    try {
      final timestampKey = DateTime.now().millisecondsSinceEpoch.toString();
      await _service.addFavoriteCaption(FavoriteCaption(
        userId: userId,
        captionId: timestampKey,
        caption: caption,
        isSynced: true,
      ));
      await loadFavorites(userId);
    } catch (e) {
      print('Error adding favorite: $e');
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
}