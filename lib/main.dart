import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_providers.dart';
import 'views/home_screen.dart';
import 'di_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: 'Omnia Captions and Notes',
    options: const FirebaseOptions(
        apiKey: "AIzaSyB4oeyIyZ3YNnNR-VDCIMZSZ4L8bcQixdU",
        authDomain: "all-in-all-professional.firebaseapp.com",
        databaseURL: "https://all-in-all-professional-default-rtdb.firebaseio.com",
        projectId: "all-in-all-professional",
        storageBucket: "all-in-all-professional.appspot.com",
        messagingSenderId: "897423988557",
        appId: "1:897423988557:web:e48a95289a5498f1fcc904",
        measurementId: "G-XQPVDWQCD4"
    ),
  );

  /// Dependency Injection
  di.init();


  if (!kIsWeb) {
    // Enable disk persistence
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000); // 10MB cache size
  }

  runApp(
    MultiProvider(
      providers: appProviders,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    ),
  );
}
