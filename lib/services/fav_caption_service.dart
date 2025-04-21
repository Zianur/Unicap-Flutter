import 'package:firebase_database/firebase_database.dart';
import 'package:unicap_cg/data/local/databse_helper.dart';
import 'package:unicap_cg/models/fav_caption_model.dart';

class FavoriteCaptionService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<FavoriteCaption>?> getFavCaptions(String userId) async {
    try{
      // 3. Get updated list from Firebase
      final snapshot = await _databaseRef.child('User').child(userId).child('FavCaptions').once();
      final List<FavoriteCaption> allCaptions = [];

      if (snapshot.snapshot.value != null) {
        final Map<dynamic, dynamic> values =
        snapshot.snapshot.value as Map<dynamic, dynamic>;

        // 4. Update local cache with Firebase data
        for (final entry in values.entries) {
          final captionId = entry.key as String;
          final data = entry.value as Map<dynamic, dynamic>;

          final favCaption = FavoriteCaption(
            userId: userId,
            captionId: captionId,
            caption: data['caption'] as String,
            isSynced: true,
          );

          await _dbHelper.insertFavoriteCaption(favCaption);
          allCaptions.add(favCaption);
        }
      }

      // 5. Return merged list (prioritizing Firebase data)
      return allCaptions;
    }catch(e){
      print('=========could not get fav captions============= $e');
      return null;
    }
  }

  Future<void> addFavoriteCaption(FavoriteCaption caption) async {
    try {
      print('============Inside service try=========');
      //Try to save to Firebase
      ///working fine
      await _databaseRef
          .child('User/${caption.userId}/FavCaptions/${caption.captionId}')
          .set({
        'caption': caption.caption,
      });
    } catch (e) {
      print('============Error adding favorite caption: =================$e');
      throw Exception('Failed to add favorite caption');
    }
  }

  Future<void> removeFavoriteCaption(String userId, String captionId) async {
    try {
      await _databaseRef
          .child('User/$userId')
          .child('FavCaptions')
          .child(captionId)
          .remove();
    } catch (e) {
      print('=====Remove============Error removing favorite caption:================= $e');
      throw Exception('Failed to remove favorite caption');
    }
  }

  Future<void> syncFavoriteCaptions(String userId) async {

    // 1. Get all local favorite captions
    final localCaptions = await _dbHelper.getFavoriteCaptions(userId);

    // 2. Sync unsynced captions with Firebase
    final unsynced = localCaptions.where((c) => !c.isSynced).toList();
    for (final caption in unsynced) {
      try {
        /// adding to firebase
        await addFavoriteCaption(caption);
        await _dbHelper.markFavoriteAsSynced(userId, caption.captionId);
      } catch (e) {
        print('==================Failed to sync caption ${caption.captionId}: $e');
        continue;
      }
    }
  }
}