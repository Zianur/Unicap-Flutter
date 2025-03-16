import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../controllers/auth_controller.dart';
import '../controllers/diary_controller.dart';
import '../controllers/caption_controller.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/local_db_service.dart';

List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (context) => AuthController(AuthService())),
  ChangeNotifierProvider(create: (context) => DiaryController(FirebaseService(), LocalDBService())),
  ChangeNotifierProvider(create: (context) => CaptionController(FirebaseService(), LocalDBService())),
];
