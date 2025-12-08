import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:unicap_cg/data/local/databse_helper.dart';
import 'package:unicap_cg/di_container.dart';
import 'package:unicap_cg/helper/network_info.dart';
import 'package:unicap_cg/models/caption_category.dart';
import 'package:unicap_cg/models/fav_caption_model.dart';
import 'package:unicap_cg/services/fav_caption_service.dart';

class FavoriteCaptionController with ChangeNotifier {
  
  final FavoriteCaptionService favoriteCaptionService;
  final DatabaseHelper dbHelper;
  
  
  FavoriteCaptionController({required this.favoriteCaptionService, required this.dbHelper});

  List<FavoriteCaption>? _favorites;
  List<FavoriteCaption>? get favorites => _favorites;
  bool _isLoading = false;
  String _captionKey = '';


  bool get isLoading => _isLoading;
  String get captionKey => _captionKey;

  Future<void> syncUnsyncedFavCaptions(String userId) async {
    debugPrint('=============inside syncUnsyncedFavCaptions====================');
    if(await _canUploadToFirebase(userId)){
      await favoriteCaptionService.syncFavoriteCaptions(userId);
    }
    await loadAndSaveFavCaptions(userId);
  }

  Future<bool> _canUploadToFirebase(String userId) async => await isUserOnline() && userId != 'guest';

  Future<void> loadAndSaveFavCaptions(String userId) async {

    try {
      List<FavoriteCaption>? allFavCaptions;

      if(await _canUploadToFirebase(userId)){
        allFavCaptions = await favoriteCaptionService.getFavCaptions(userId);
      }


      if(allFavCaptions?.isNotEmpty ?? false){
        for(FavoriteCaption caption in allFavCaptions!){
          dbHelper.insertFavoriteCaption(caption);
        }
      }

      await getAllFavCaptionsFromLocal(userId);
      debugPrint('=====favorites=========${favorites?.length}==============');

    } catch (e) {
      debugPrint('=========Error getting favorites captions===============: $e');
      // Fallback to local cache if sync fails
      _favorites = await dbHelper.getFavoriteCaptions(userId);
    } finally {
      notifyListeners();
    }
  }

  Future<void> addFavorite(String userId, Caption caption) async {
    debugPrint('============Inside addFavorite=========');
    try {
      debugPrint('============Inside try=========');
      _captionKey = caption.key;
      _isLoading = true;
      notifyListeners();

      await dbHelper.insertFavoriteCaption(FavoriteCaption(
        userId: userId,
        captionId: caption.key,
        caption: caption.caption,
        isSynced: false,
      ));

    } catch (e) {
      debugPrint('==============Error Inserting favorite favorite to local: ================$e');
    }

    if(await _canUploadToFirebase(userId)){
      await favoriteCaptionService.addFavoriteCaption(FavoriteCaption(
        userId: userId,
        captionId: caption.key,
        caption: caption.caption,
        isSynced: false,
      ));
    }

    _isLoading = false;
    await getAllFavCaptionsFromLocal(userId);
  }

  Future<bool> isUserOnline() async {
    final connectivityResult = await sl<NetworkInfo>().isConnected;
    final bool isUserOnline = connectivityResult != ConnectivityResult.none;
    return isUserOnline;
  }

  Future<void> removeFavorite(String userId, String captionId) async {
    try {
      debugPrint('============inside remove try==============$userId and $captionId}');

      _captionKey = captionId;
      _isLoading = true;
      notifyListeners();

      await dbHelper.deleteFavoriteCaption(userId, captionId);
    } catch (e) {
      debugPrint('=============controller============Error removing favorite from local: $e');
    }

    if(await _canUploadToFirebase(userId)){
      await favoriteCaptionService.removeFavoriteCaption(userId, captionId);
    }

    await loadAndSaveFavCaptions(userId);

    _isLoading = false;
    notifyListeners();
  }

  bool isCaptionFavorite(String caption) {
    return _favorites?.any((fav) => fav.caption == caption) ?? false;
  }

  Future<void> getAllFavCaptionsFromLocal(String userId, {bool isUpdate = true}) async {
    _favorites = await dbHelper.getFavoriteCaptions(userId);
    if(isUpdate){
      notifyListeners();
    }
  }


  void filterFavCaption({required String queryText, required String userId}) async {
    if(queryText.isEmpty){
      await getAllFavCaptionsFromLocal(userId);
    }
    else{
      _favorites = _favorites?.where((caption) {
        return caption.caption.toLowerCase().contains(queryText.toLowerCase());
      }).toList();
    }

    notifyListeners();
  }
}