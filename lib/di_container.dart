import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';

import 'data/local/databse_helper.dart';
import 'helper/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  final DatabaseHelper dbHelper = DatabaseHelper();

  /// Core
  sl.registerLazySingleton(() => databaseRef);
  sl.registerLazySingleton(() => dbHelper);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => NetworkInfo(sl()));






}
