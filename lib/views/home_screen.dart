import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/diary_controller.dart';
import 'package:unicap_cg/views/caption_category_screen.dart';
import 'package:unicap_cg/views/fav_caption_screen.dart';
import '../controllers/caption_category_controller.dart';
import 'diary_list_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Get userId first, then fetch notes
    Future.delayed(Duration.zero, () async {
      final authController = Provider.of<AuthController>(context, listen: false);
      await authController.getUserId();

      userId = authController.userId ?? 'guest';
      print('=========home screen=========userid======================$userId');

      Provider.of<DiaryController>(context, listen: false).fetchAndSaveNotes(userId);
      Provider.of<CaptionCategoryController>(context, listen: false).loadCategories();
    });
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: TabBarView(
        controller: _tabController,
        children: [
          DiaryListScreen(),
          CaptionCategoryView(),
          FavCaptionScreen(),
          LoginScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(icon: Icon(Icons.book), text: 'Diary '),
            Tab(icon: Icon(Icons.category ), text: 'Captions'),
            Tab(icon: Icon(Icons.favorite), text: 'Favorite'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
      ),
    );
  }
}
