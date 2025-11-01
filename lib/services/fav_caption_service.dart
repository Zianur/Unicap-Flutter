import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:unicap_cg/data/local/databse_helper.dart';
import 'package:unicap_cg/models/fav_caption_model.dart';

class FavoriteCaptionService {
  final DatabaseReference databaseRef;
  final DatabaseHelper dbHelper;
  
  FavoriteCaptionService({required this.databaseRef, required this.dbHelper});

  Future<List<FavoriteCaption>?> getFavCaptions(String userId) async {
    try{
      // 3. Get updated list from Firebase
      final snapshot = await databaseRef.child('User').child(userId).child('FavCaptions').once();
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

          await dbHelper.insertFavoriteCaption(favCaption);
          allCaptions.add(favCaption);
        }
      }

      // 5. Return merged list (prioritizing Firebase data)
      return allCaptions;
    }catch(e){
      debugPrint('=========could not get fav captions============= $e');
      return null;
    }
  }

  Future<void> addFavoriteCaption(FavoriteCaption caption) async {
    try {
      debugPrint('============Inside service try=========');
      //Try to save to Firebase
      ///working fine
      await databaseRef
          .child('User/${caption.userId}/FavCaptions/${caption.captionId}')
          .set({
        'caption': caption.caption,
      });
    } catch (e) {
      debugPrint('============Error adding favorite caption: =================$e');
      throw Exception('Failed to add favorite caption');
    }
  }

  Future<void> removeFavoriteCaption(String userId, String captionId) async {
    try {
      await databaseRef
          .child('User/$userId')
          .child('FavCaptions')
          .child(captionId)
          .remove();
    } catch (e) {
      debugPrint('=====Remove============Error removing favorite caption:================= $e');
      throw Exception('Failed to remove favorite caption');
    }
  }

  Future<void> syncFavoriteCaptions(String userId) async {
    debugPrint('=============Service ----------- inside syncUnsyncedFavCaptions====================');

    // 1. Get all local favorite captions
    final localCaptions = await dbHelper.getFavoriteCaptions(userId);

    // 2. Sync unsynced captions with Firebase
    final unsynced = localCaptions.where((c) => !c.isSynced).toList();
    for (final caption in unsynced) {
      try {
        /// adding to firebase
        await addFavoriteCaption(caption);
        await dbHelper.markFavoriteAsSynced(userId, caption.captionId);
      } catch (e) {
        debugPrint('==================Failed to sync caption ${caption.captionId}: $e');
        continue;
      }
    }
  }
}