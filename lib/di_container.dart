import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/caption_category_controller.dart';
import 'package:unicap_cg/controllers/diary_controller.dart';
import 'package:unicap_cg/controllers/fav_caption_controller.dart';
import 'package:unicap_cg/controllers/translator_controller.dart';
import 'package:unicap_cg/services/auth_service.dart';
import 'package:unicap_cg/services/fav_caption_service.dart';
import 'package:unicap_cg/services/firebase_service.dart';

import 'data/local/databse_helper.dart';
import 'helper/network_info.dart';

final sl = GetIt.instance;

void init() {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  final DatabaseHelper dbHelper = DatabaseHelper();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  /// Core
  sl.registerLazySingleton(() => databaseRef);
  sl.registerLazySingleton(() => dbHelper);
  sl.registerLazySingleton(() => firebaseAuth);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => NetworkInfo(sl()));


  /// Services
  sl.registerLazySingleton(() => FirebaseService(databaseReference: sl(), dbHelper: sl()));
  sl.registerLazySingleton(() => FavoriteCaptionService(databaseRef: sl(), dbHelper: sl()));
  sl.registerLazySingleton(() => AuthService(firebaseAuth: sl()));



  /// Controller
  sl.registerLazySingleton(() => DiaryController(dbHelper: sl(), firebaseService: sl()));
  sl.registerLazySingleton(() => FavoriteCaptionController(favoriteCaptionService: sl(), dbHelper: sl()));
  sl.registerLazySingleton(() => AuthController(authService: sl()));
  sl.registerLazySingleton(() => CaptionCategoryController(firebaseService: sl()));
  sl.registerLazySingleton(() => TranslatorController());
}
