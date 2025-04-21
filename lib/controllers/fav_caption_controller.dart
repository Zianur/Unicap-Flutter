import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:unicap_cg/data/local/databse_helper.dart';
import 'package:unicap_cg/models/caption_category.dart';
import 'package:unicap_cg/models/fav_caption_model.dart';
import 'package:unicap_cg/services/fav_caption_service.dart';

class FavoriteCaptionController with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  final FavoriteCaptionService _service = FavoriteCaptionService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<FavoriteCaption> _favorites = [];
  List<FavoriteCaption>? get favorites => _favorites;

  Future<void> syncUnsyncedFavCaptions(String userId) async {
    if(await isUserOnline() && userId != 'guest'){
      await _service.syncFavoriteCaptions(userId);
    }
    await loadAndSaveFavCaptions(userId);
  }

  Future<void> loadAndSaveFavCaptions(String userId) async {
    // _favorites = null;
    // notifyListeners();

    try {
      List<FavoriteCaption>? allFavCaptions;

      if(await isUserOnline() && userId != 'guest'){
        allFavCaptions = await _service.getFavCaptions(userId);
      }


      if(allFavCaptions?.isNotEmpty ?? false){
        for(FavoriteCaption caption in allFavCaptions!){
          _dbHelper.insertFavoriteCaption(caption);
        }
      }

      await getAllFavCaptionsFromLocal(userId);
      notifyListeners();
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
    print('============Inside addFavorite=========');
    try {
      print('============Inside try=========');
      await _dbHelper.insertFavoriteCaption(FavoriteCaption(
        userId: userId,
        captionId: caption.key,
        caption: caption.caption,
        isSynced: false,
      ));

    } catch (e) {
      print('==============Error Inserting favorite favorite to local: ================$e');
    }

    if(await isUserOnline() && userId != 'guest'){
      await _service.addFavoriteCaption(FavoriteCaption(
        userId: userId,
        captionId: caption.key,
        caption: caption.caption,
        isSynced: false,
      ));
    }


    await getAllFavCaptionsFromLocal(userId);
  }

  Future<bool> isUserOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final bool isUserOnline = connectivityResult != ConnectivityResult.none;
    return isUserOnline;
  }

  Future<void> removeFavorite(String userId, String captionId) async {
    try {
      print('============inside remove try==============$userId and $captionId}');
      await _dbHelper.deleteFavoriteCaption(userId, captionId);
    } catch (e) {
      print('=============controller============Error removing favorite from local: $e');
    }

    if(await isUserOnline() && userId != 'guest'){
      await _service.removeFavoriteCaption(userId, captionId);
    }

    await loadAndSaveFavCaptions(userId);
    notifyListeners();
  }

  bool isCaptionFavorite(String caption) {
    return _favorites.any((fav) => fav.caption == caption);
  }

  Future<void> getAllFavCaptionsFromLocal(String userId, {bool isUpdate = true}) async {
    _favorites = await _dbHelper.getFavoriteCaptions(userId);
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