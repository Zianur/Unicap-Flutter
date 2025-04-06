import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:unicap_cg/controllers/fav_caption_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/diary_controller.dart';
import '../controllers/caption_category_controller.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (context) => AuthController(AuthService())),
  ChangeNotifierProvider(create: (context) => DiaryController()),
  ChangeNotifierProvider(create: (context) => CaptionCategoryController(FirebaseService())),
  ChangeNotifierProvider(create: (context) => FavoriteCaptionController()),
];
