import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:unicap_cg/controllers/fav_caption_controller.dart';
import 'package:unicap_cg/di_container.dart';
import '../controllers/auth_controller.dart';
import '../controllers/diary_controller.dart';
import '../controllers/caption_category_controller.dart';


List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (context) => sl<AuthController>()),
  ChangeNotifierProvider(create: (context) => sl<DiaryController>()),
  ChangeNotifierProvider(create: (context) => sl<CaptionCategoryController>()),
  ChangeNotifierProvider(create: (context) => sl<FavoriteCaptionController>()),
];
