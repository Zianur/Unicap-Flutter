import 'package:flutter/material.dart';
import 'package:unicap_cg/data/local/databse_helper.dart';
import 'package:unicap_cg/models/caption_category.dart';
import 'package:unicap_cg/models/fav_caption.dart';
import 'package:unicap_cg/services/fav_caption_service.dart';

class FavoriteCaptionController with ChangeNotifier {
  final FavoriteCaptionService _service = FavoriteCaptionService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<FavoriteCaption> _favorites = [];

  List<FavoriteCaption>? get favorites => _favorites;

  Future<void> syncUnsyncedFavCaptions(String userId) async {
    await _service.syncFavoriteCaptions(userId);
    await loadAndSaveFavCaptions(userId);
  }

  Future<void> loadAndSaveFavCaptions(String userId) async {
    // _favorites = null;
    // notifyListeners();

    try {
      List<FavoriteCaption>? allFavCaptions = await _service.getFavCaptions(userId);


      if(allFavCaptions?.isNotEmpty ?? false){
        for(FavoriteCaption caption in allFavCaptions!){
          _dbHelper.insertFavoriteCaption(caption);
        }
      }

      _favorites = await _dbHelper.getFavoriteCaptions(userId);

      print('=====favorites=========${favorites?.length}==============');

    } catch (e) {
      print('=========Error getting favorites captions===============: $e');
      // Fallback to local cache if sync fails
      _favorites = await _dbHelper.getFavoriteCaptions(userId);
    } finally {
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

  Future<void> removeFavorite(String userId, String captionId) async {
    try {
      await _service.removeFavoriteCaption(userId, captionId);
      await _dbHelper.deleteFavoriteCaption(userId, captionId);
      await loadAndSaveFavCaptions(userId);
      notifyListeners();
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    }
  }

  bool isCaptionFavorite(String caption) {
    return _favorites?.any((fav) => fav.caption == caption) ?? false;
  }

  Future<void> getAllFavCaptionsFromLocal(String userId, {bool isUpdate = true}) async {
    _favorites = await _dbHelper.getFavoriteCaptions(userId);
    print('==========inside getAllFavCaptionsFromLocal _favorites length==========${_favorites?.length}');
    if(isUpdate){
      notifyListeners();
    }
  }


  void filterFavCaption({required String queryText, required String userId}) async {
    if(queryText.isEmpty){
      await getAllFavCaptionsFromLocal(userId);
    }
    else{
      _favorites = _favorites.where((caption) {
        return caption.caption.toLowerCase().contains(queryText.toLowerCase());
      }).toList();
    }

    notifyListeners();
  }
}